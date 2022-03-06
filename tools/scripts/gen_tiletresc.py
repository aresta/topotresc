#!/usr/bin/python
#encoding: utf-8
from math import pi,cos,sin,log,exp,atan
from subprocess import call
import sys, os
from Queue import Queue
import threading
import mapnik
import PIL.Image
from StringIO import StringIO

TILE_DIR = "/var/www/html/tresc_tiles/"
MAP_XML_FILE = "/mnt/openstreetmap-carto/mapnik.xml"

OSM_TILE_SIZE = 256 # in px

DEG_TO_RAD = pi/180
RAD_TO_DEG = 180/pi

# Default number of rendering threads to spawn, should be roughly equal to number of CPU cores available
NUM_THREADS = 6

def minmax (a,b,c):
    a = max(a,b)
    a = min(a,c)
    return a

class GoogleProjection:
    def __init__(self,levels=18, tile_size=1):
        self.Bc = []
        self.Cc = []
        self.zc = []
        self.Ac = []
        c = tile_size
        for d in range(0,levels):
            e = c/2
            self.Bc.append(c/360.0)
            self.Cc.append(c/(2 * pi))
            self.zc.append((e,e))
            self.Ac.append(c)
            c *= 2
                
    def fromLLtoPixel(self,ll,zoom):
         d = self.zc[zoom]
         e = round(d[0] + ll[0] * self.Bc[zoom])
         f = minmax(sin(DEG_TO_RAD * ll[1]),-0.9999,0.9999)
         g = round(d[1] + 0.5*log((1+f)/(1-f))*-self.Cc[zoom])
         return (e,g)
     
    def fromPixelToLL(self,px,zoom):
         e = self.zc[zoom]
         f = (px[0] - e[0])/self.Bc[zoom]
         g = (px[1] - e[1])/-self.Cc[zoom]
         h = RAD_TO_DEG * ( 2 * atan(exp(g)) - 0.5 * pi)
         return (f,h)



class RenderThread:
    def __init__(self, q, lock, maxZoom, block_size):
        self.block_size = block_size # in OSM tiles
        self.tile_size = OSM_TILE_SIZE * self.block_size # in px
        self.zoom_correction = int(log(self.block_size,2)) # TODO: correct this in funcs
        self.q = q
        self.map = mapnik.Map(self.tile_size, self.tile_size)
        # Load style XML
        mapnik.load_map(self.map, MAP_XML_FILE, True)
        # Obtain <Map> projection
        self.prj = mapnik.Projection(self.map.srs)
        # Projects between tile pixel co-ordinates and LatLong (EPSG:4326)
        self.tileproj = GoogleProjection( maxZoom+1, tile_size=self.tile_size)
        self.lock = lock
        self.__terminate = False        
        
    def terminate(self): 
        self.q.put(None)     # queue could be empty and renderer blocked waiting 
        self.__terminate = True

    def render_tile(self, x, y, z):
        # Calculate pixel positions of bottom-left & top-right
        p0 = (x * self.tile_size, (y + 1) * self.tile_size)
        p1 = ((x + 1) * self.tile_size, y * self.tile_size)

        # Convert to LatLong (EPSG:4326)
        l0 = self.tileproj.fromPixelToLL(p0, z)
        l1 = self.tileproj.fromPixelToLL(p1, z)

        # Convert to map projection (e.g. mercator co-ords EPSG:900913)
        c0 = self.prj.forward(mapnik.Coord(l0[0],l0[1]))
        c1 = self.prj.forward(mapnik.Coord(l1[0],l1[1]))

        bbox = mapnik.Box2d(c0.x,c0.y, c1.x,c1.y)
        
        self.map.zoom_to_box(bbox)
        if(self.map.buffer_size < 128):
            self.map.buffer_size = 128

        print "%s rendering block: %i %i %i" % (threading.currentThread().getName(), (z + self.zoom_correction), x, y)

        im = mapnik.Image( self.tile_size, self.tile_size)
        mapnik.render(self.map, im)
        # img = PIL.Image.frombytes('RGBA', (self.tile_size, self.tile_size), im.tostring())
        img = PIL.Image.open( StringIO( im.tostring('png256'))) # convert to 8 bits PIL image
        for i in range( self.block_size):
            if self.__terminate: break
            xx = (x * self.block_size) + i
            tile_folder = "%s%i/%i/" % ( TILE_DIR, (z + self.zoom_correction), xx)

            if not os.path.isdir( tile_folder):
                self.lock.acquire()
                if not os.path.isdir(tile_folder): os.makedirs( tile_folder) # to avoid collisions
                self.lock.release()
                
            for j in range( self.block_size):
                if self.__terminate: break
                yy = (y * self.block_size) + j
                tile_uri = "%s%i.png" % ( tile_folder, yy)
                tile = img.crop(( i*OSM_TILE_SIZE, j*OSM_TILE_SIZE, (i+1)*OSM_TILE_SIZE, (j+1)*OSM_TILE_SIZE ))
                tile.save( tile_uri, optimize=True)


    def loop(self):           
        while not self.__terminate:
            #Fetch a tile from the queue and render it
            r = self.q.get()
            if (r == None):
                print "None signal => finishing"
                self.q.task_done()
                break
            ( x, y, z) = r
            self.render_tile( x, y, z)
            self.q.task_done()
        print "Thread %s exiting" % threading.currentThread().getName()



def render_tiles(bbox, minZoom=1,maxZoom=17, block_size=1, num_threads=NUM_THREADS):
    print "render_tiles(",bbox, minZoom,maxZoom, ")"

    # Launch rendering threads
    queue = Queue(32)
    lock = threading.Lock()
    renderers = []
    for i in range(num_threads):
        renderer = RenderThread( queue, lock, maxZoom, block_size)
        render_thread = threading.Thread(target=renderer.loop)
        render_thread.start()
        print "Started render thread %s" % render_thread.getName()
        renderers.append( renderer)

    tile_size = OSM_TILE_SIZE * block_size
    gprj = GoogleProjection( maxZoom+1, tile_size=tile_size) 

    ll0 = (bbox[0],bbox[3])
    ll1 = (bbox[2],bbox[1])

    zoom_correction = int(log(block_size,2))
    for z in range( minZoom - zoom_correction, maxZoom - zoom_correction + 1):
        px0 = gprj.fromLLtoPixel(ll0,z)
        px1 = gprj.fromLLtoPixel(ll1,z)

        two_pot_z = 2**z # small optimizations
        two_pot_z_minus_1 = two_pot_z
 
        # check if we have directories in place
        zoom = "%s" % (z + zoom_correction)
        if not os.path.isdir(TILE_DIR + zoom):
            os.mkdir(TILE_DIR + zoom)
        for x in range(int(px0[0]/tile_size),int(px1[0]/tile_size)+1):
            # Validate x co-ordinate
            if (x < 0) or (x >= two_pot_z):
                continue
            for y in range(int(px0[1]/tile_size),int(px1[1]/tile_size)+1):
                # Validate x co-ordinate
                if (y < 0) or (y >= two_pot_z):
                    continue
                # Submit tile to be rendered into the queue
                t = ( x, y, z)
                try:
                    queue.put(t)
                except KeyboardInterrupt:
                    print "Ctrl-c detected, exiting..."
                    for renderer in renderers:
                        renderer.terminate()
                    raise SystemExit("Done")
    
    print "All tiles sent to queue"
    for renderer in renderers: 
        queue.put(None)
    queue.join() # wait for the colleagues to finish
    print "Queue Done!"
    

if __name__ == "__main__":
    home = os.environ['HOME']
    
    # St Llorenc
    # bbox = (1.70, 41.38, 2.18, 41.73)
    bbox = (0.1, 40.05, 3.38, 43.08) # Catalunya
    # render_tiles(bbox, 7, 9, block_size=1)
    # render_tiles(bbox, 10, 10, block_size=2)
    # render_tiles(bbox, 13, 13, block_size=8)
    render_tiles(bbox, 14, 17, block_size=16)



