#!/usr/bin/python
#encoding: utf-8
import mapnik
import os
import time
from math import pi,cos,sin,log,exp, atan
from io import BytesIO
import PIL.Image
import multiprocessing
import json
import shapely.geometry as geom
import shapely.ops as ops
import matplotlib.pyplot as plt

print( "Version", mapnik.mapnik_version())

merc = mapnik.Projection('+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0.0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs +over')
longlat = mapnik.Projection('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')
mapfile = "/mnt/openstreetmap-carto/mapnik.xml"
DEG_TO_RAD = pi/180
RAD_TO_DEG = 180/pi

TILES_DIR = "/tiles/"

def minmax(a,b,c):
    a = max(a,b)
    return min(a,c)

class GoogleProjection:
    def __init__(self,levels=18, image_size=1):
        self.Bc = []
        self.Cc = []
        self.zc = []
        self.Ac = []
        c = image_size
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


def worker( queue, block_size ):  # render_tile
    name = multiprocessing.current_process().name
    print("Starting", name)
    folder_mask_x = ~(int('11111',2))    # '...11111110000' mask to convert tile coord to folder names
    folder_mask_y = ~(int('1111111',2))  # y folders contain zips that already contain 8x8 tiles each
    image_size = TILE_SIZE * block_size
    map = mapnik.Map(image_size, image_size)
    mapnik.load_map( map, mapfile, False)
    prj = mapnik.Projection(map.srs)
    gprj = GoogleProjection( MAX_ZOOM+1, image_size=image_size)
    while True:
        t1 = time.time() ######
        task = queue.get()
        if task == "Done": break
        ( x, y, z, folder ) = task

        # tile_x = round( x / TILE_SIZE)
        # tile_y = round( y / TILE_SIZE)
        tile_x = x // TILE_SIZE
        tile_y = y // TILE_SIZE
        # first_tile_path = "%s%s/%s/%s_%s.png" % ( folder, tile_x & folder_mask_x, tile_y & folder_mask_y, tile_x, tile_y)  
        img_folder = "%s%s/%s/" % (folder, tile_x & folder_mask_x , tile_y & folder_mask_y)
        img_name = img_folder + "%s_%s.png" % ( tile_x, tile_y )
        # check if tiles already exist
        if os.path.exists( img_name): 
            print("Tile already exist", img_name)
            continue
        # Convert to LatLong (EPSG:4326)
        l0 = gprj.fromPixelToLL(( x, y + image_size), z)
        l1 = gprj.fromPixelToLL(( x + image_size, y), z)
        # Convert to map projection (e.g. mercator co-ords EPSG:900913)
        c0 = prj.forward(mapnik.Coord(l0[0],l0[1]))
        c1 = prj.forward(mapnik.Coord(l1[0],l1[1]))
        bbox = mapnik.Box2d(c0.x,c0.y, c1.x,c1.y)
        map.zoom_to_box(bbox)
        if(map.buffer_size < 128):
            map.buffer_size = 128
        im = mapnik.Image( image_size, image_size)
        # t2 = time.time()
        mapnik.render(map, im)
        # t3 = time.time()
        if not os.path.isdir( img_folder):
            os.makedirs(img_folder)
        im.save(img_name, 'png:z=1')
        t7 = time.time() ######
        # print(name, folder, tile_x, tile_y, "%0.3f %0.3f %0.3f %0.3f %0.3f" % (t7-t1, t2-t1, t3-t2, t7-t4))
        print(name, folder, tile_x, tile_y, "%0.2fs" % (t7-t1))
    print(name,"done!")

def render_tiles( map_polygon, zoom, image_size, folder, areas_done):
    tiles = []
    (minx, miny, maxx, maxy) = [ (int(p) & ~(int('FF',16))) for p in map_polygon.bounds] # bounds return floats. Convert to and correct to the 256 closer tile   
    if areas_done: plt.plot( *areas_done.exterior.xy)
    for y in range( miny, maxy+1, image_size):
        for x in range( minx, maxx+1, image_size):
            tile = geom.box( x, y, x+image_size, y+image_size)
            if not map_polygon.contains( tile) or ( areas_done and areas_done.contains( tile)):
            # if not map_polygon.intersects( box( *tile)):
                # print("Skiping;", tile)
                continue
            # print("Adding;", tile)
            task = ( x, y, zoom, folder)
            queue.put( task)
            tiles.append( tile)
    plt.clf()
    plt.plot( *map_polygon.exterior.xy)
    for tile in tiles: plt.plot( *tile.exterior.xy, c='green')
    if areas_done: plt.plot( *areas_done.exterior.xy, c="red")
    plt.savefig( TILES_DIR + "tiles_%s_%s.png" % (zoom, image_size))
    return ops.unary_union( tiles)
    
def start_workers( block_size):    
    workers.clear()
    for _ in range(NUM_WORKERS):
        p = multiprocessing.Process(target=worker, args=( queue, block_size)) 
        workers.append(p)
        p.start()

def read_map( geojson_file):
    with open( geojson_file, "r") as file:
        data = json.load( file)
    return data["features"][0]["geometry"]["coordinates"][0] # map in lat lon coordinates

def render_map( geojson_map, zooms):
    start_time = time.time()
    map_ll = read_map( geojson_map)
    areas_done = {}
    for block_size in [16]:
        start_workers( block_size )
        image_size = TILE_SIZE * block_size
        gprj = GoogleProjection( MAX_ZOOM+1, image_size=image_size)
        zoom_correction = int(log(block_size,2))
        for zoom in range(zooms[0], zooms[1]+1):
            zoom_corrected = zoom - zoom_correction
            folder = TILES_DIR + ("%s/" % zoom)
            if not os.path.isdir(folder): os.mkdir(folder)
            map_polygon = geom.Polygon([ gprj.fromLLtoPixel( point_ll, zoom_corrected) for point_ll in map_ll ]) # transform the polygon to pixel coordinates
            area_done = render_tiles( map_polygon, zoom_corrected, image_size, folder, areas_done.get( zoom))
            if zoom in areas_done:
                areas_done[zoom] = area_done.union( areas_done.get( zoom))
            else:
                areas_done[zoom] = area_done
            plt.clf()
            plt.plot( *map_polygon.exterior.xy)
            if zoom in areas_done and areas_done[zoom]: plt.plot( *(areas_done[zoom].exterior.xy), c='red')
            plt.savefig( TILES_DIR + "area_done_%s_%s.png" % ( zoom, image_size))
        for _ in workers: queue.put("Done")
        while not queue.empty():
            print(" *-------------------------------------------------------------------> %0.2fs.  \t#  Queue size: %s" % (time.time() - start_time, queue.qsize()))
            time.sleep(10)
        
    total_time = time.time() - start_time
    print( "Total_time", total_time)


TILE_SIZE = 256
MAX_ZOOM = 17
NUM_WORKERS = 8
queue = multiprocessing.Queue()
workers = []

if __name__ == '__main__':
    t1 = time.time()

    geojson_map = "/mnt/conf/test.geojson"
    map_ll = read_map( geojson_map)

    render_map( geojson_map, zooms=(15,16))

    print(" ********** TOTAL TIME #   %0.2f seconds ----*" % ( time.time() - t1))

    # docker-compose exec tools /scripts/render_tilezip2.py