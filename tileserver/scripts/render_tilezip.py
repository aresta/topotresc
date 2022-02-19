#!/usr/bin/python
#encoding: utf-8
import mapnik
import sys, os
import time
from math import pi,cos,sin,log,exp,atan
import PIL.Image
from StringIO import StringIO
from io import BytesIO
import multiprocessing
from zipfile import ZipFile
import json
import csv

print( "Version", mapnik.mapnik_version())

merc = mapnik.Projection('+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0.0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs +over')
longlat = mapnik.Projection('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')
mapfile = "/mnt/openstreetmap-carto/mapnik.xml"
DEG_TO_RAD = pi/180
RAD_TO_DEG = 180/pi

TILE_DIR = "/scripts/tiles/"

def minmax (a,b,c):
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


def worker( queue, TILE_SIZE, block_size, slice_to_zip=True, ZIP_TILE_SIZE=8 ):  # render_tile
    name = multiprocessing.current_process().name
    print("Starting", name)
    folder_mask_x = ~(int('11111',2))    # '...11111110000' mask to convert tile coord to folder names
    folder_mask_y = ~(int('1111111',2))  # y folders contain zips that already contain 8x8 tiles each
    image_size = TILE_SIZE * block_size
    map = mapnik.Map(image_size, image_size)
    mapnik.load_map( map, mapfile, True)
    prj = mapnik.Projection(map.srs)
    gprj = GoogleProjection( MAX_ZOOM+1, image_size=image_size)
    image_file = BytesIO() # we will reuse the buffer
    while True:
        t1 = time.time() ######
        task = queue.get()
        if task == "Done": break
        ( x, y, z, folder ) = task

        # check if tiles already exist
        tile_x = x*block_size
        tile_y = y*block_size
        first_tile_path = "%s%s/%s/%s_%s.%s" % ( folder, tile_x & folder_mask_x, tile_y & folder_mask_y, 
            tile_x, tile_y, ('zip' if slice_to_zip else 'png'))        
        if os.path.exists( first_tile_path): 
            print("Tiles already exists", first_tile_path)
            continue

        # check that any of the ziptiles is in the list of visited tilezips
        skip = True
        for zx in range(block_size/ZIP_TILE_SIZE):
                base_x = zx * ZIP_TILE_SIZE
                for zy in range(block_size/ZIP_TILE_SIZE):
                    base_y = zy * ZIP_TILE_SIZE
                    zip_folder = "%s%s/%s/" % (folder, (tile_x + base_x) & folder_mask_x , (tile_y + base_y) & folder_mask_y)
                    zip_name = "%s%s_%s.zip" % ( zip_folder, tile_x + base_x ,tile_y + base_y )
                    if zip_name in zips_visited: 
                        skip = False
                        break
        if skip:
            print("Skipping. Tilezip not in zips_visited list", first_tile_path)
            continue

        p0 = (x * image_size, (y + 1) * image_size)
        p1 = ((x + 1) * image_size, y * image_size)

        # Convert to LatLong (EPSG:4326)
        l0 = gprj.fromPixelToLL(p0, z)
        l1 = gprj.fromPixelToLL(p1, z)
        # Convert to map projection (e.g. mercator co-ords EPSG:900913)
        c0 = prj.forward(mapnik.Coord(l0[0],l0[1]))
        c1 = prj.forward(mapnik.Coord(l1[0],l1[1]))

        bbox = mapnik.Box2d(c0.x,c0.y, c1.x,c1.y)
        map.zoom_to_box(bbox)
        if(map.buffer_size < 128):
            map.buffer_size = 128
        im = mapnik.Image( image_size, image_size)
        mapnik.render(map, im)
        
        if slice_to_zip:
            # Slice image in tiles        
            img = PIL.Image.open( StringIO( im.tostring('png:z=0'))) # high color depth before slicing
            for zx in range(block_size/ZIP_TILE_SIZE):
                base_x = zx * ZIP_TILE_SIZE
                for zy in range(block_size/ZIP_TILE_SIZE):
                    base_y = zy * ZIP_TILE_SIZE
                    zip_folder = "%s%s/%s/" % (folder, (tile_x + base_x) & folder_mask_x , (tile_y + base_y) & folder_mask_y)
                    zip_name = "%s%s_%s.zip" % ( zip_folder, tile_x + base_x ,tile_y + base_y )
                    if zip_name not in zips_visited: 
                        print("Tile not in zips_visited list", first_tile_path)
                        continue
                    # if os.path.exists( zip_name): continue
                    if not os.path.isdir( zip_folder):
                        os.makedirs(zip_folder)
                    with ZipFile( zip_name, 'w') as zip: 
                        for tx in range( ZIP_TILE_SIZE ):
                            i = base_x + tx
                            for ty in range( ZIP_TILE_SIZE ):
                                j = base_y + ty
                                image_file.seek(0)  # reset the buffer
                                image_file.truncate(0)
                                img.crop(( i*TILE_SIZE, j*TILE_SIZE, (i+1)*TILE_SIZE, (j+1)*TILE_SIZE )).\
                                    convert('RGB').convert('P', palette=PIL.Image.ADAPTIVE).\
                                    save( image_file, format="PNG", optimize=True)
                                zip.writestr("%s_%s.png" % ( tile_x + i, tile_y + j ), image_file.getvalue())
        else:
            # just save image without slicing or zip
            img_folder = "%s%s/%s/" % (folder, tile_x & folder_mask_x , tile_y & folder_mask_y)
            if not os.path.isdir( img_folder):
                os.makedirs(img_folder)
            img_name = "%s%s_%s.png" % ( img_folder, tile_x, tile_y )
            im.save(img_name, 'png')

        t7 = time.time() ######
        # print(name, folder, tile_x, tile_y, "%0.3f %0.3f %0.3f %0.3f" % (t4-t1, t5-t4, t6-t5, t7-t6))
        print(name, folder, tile_x, tile_y, "%0.2fs" % (t7-t1))
    print(name,"done!")

def get_polygon_segments( geojson_file ):
    with open( geojson_file, "r") as file:
        data = json.load( file)
    features = data["features"]
    polygon = features[0]["geometry"]["coordinates"][0]
    segments = []
    for i in range( len(polygon)-1 ):
        segments.append((polygon[i], polygon[i+1]))
    return segments
    
def scan_lines_segments( segments ):
    segment_points = [ first for (first,_) in segments]
    higher_point = max( segment_points, key=lambda (x,y): y )
    lower_point = min( segment_points, key=lambda (x,y): y )
    points = set()
    for y in range( lower_point[1], higher_point[1]+1):
        intersections = set()
        for segment in segments:
            if segment[0][1] > y and segment[1][1] > y: continue
            if segment[0][1] < y and segment[1][1] < y: continue
            if segment[0][1]  == segment[1][1]: 
                intersections.add(segment[0][0])
                intersections.add(segment[1][0])
                continue
            prop = float(segment[1][0] - segment[0][0]) / float(segment[0][1] - segment[1][1])
            x = round((prop * (segment[0][1] - y))) + segment[0][0]
            intersections.add(int(x))
        intersections_sorted = sorted( intersections )
        if len(intersections_sorted) == 1:
            points.add((intersections_sorted[0],y))
        for i in range(len(intersections_sorted)-1):
            for x in range(intersections_sorted[i]-1, intersections_sorted[i+1]+2):
                points.add((x,y))
            i += 1
    return points.union(segment_points)
    

def render_tilezips( geojson_file, zooms, block_size):
    image_size = TILE_SIZE * block_size
    gprj = GoogleProjection( MAX_ZOOM+1, image_size=image_size)
    segments = get_polygon_segments( geojson_file )
    zoom_correction = int(log(block_size,2))
    total_block_tiles = 0
    for zoom in range(zooms[0]-zoom_correction, zooms[1]-zoom_correction+1):
        segments_px = [ (gprj.fromLLtoPixel( ll1, zoom), gprj.fromLLtoPixel( ll2, zoom)) for (ll1,ll2) in segments ]
        segments_xy = [ ((int(x1/image_size),int(y1/image_size)),(int(x2/image_size),int(y2/image_size))) for ((x1,y1),(x2,y2)) in segments_px ]
        two_pot_z = 2**zoom
        zoom_corrected = "%s" % (zoom + zoom_correction)
        folder = TILE_DIR + ("%s/" % zoom_corrected)
        if not os.path.isdir(folder):
            os.mkdir(folder)
        tiles_to_render = scan_lines_segments( segments_xy )
        for (x,y) in tiles_to_render:
            if (x < 0) or (x >= two_pot_z) or (y < 0) or (y >= two_pot_z):
                print("ERROR: x,y out of range",x,y)
                continue
            task = ( x, y, zoom, folder)
            queue.put( task)
        print("Rendering tiles", zoom_corrected,  [( x*block_size, y*block_size) for (x,y) in tiles_to_render])
        total_block_tiles += len(tiles_to_render)
    return total_block_tiles

 
def render_geojson( file, block_size, zooms):
    NUM_WORKERS = 8
    workers = []
    for i in range(NUM_WORKERS):
        p = multiprocessing.Process(target=worker, args=( queue, TILE_SIZE, block_size, False))  # last param: slice_to_zip
        workers.append(p)
        p.start()

    start_time = time.time()
    total_block_tiles = render_tilezips( file, zooms, block_size)
    for _ in workers:
        queue.put("Done")
    while not queue.empty():
        print(" *-------------------------------------------------------------------> %0.2fs.  \t#  Remaining blocks: %s" % (time.time() - start_time, queue.qsize()))
        time.sleep(10)
    total_time = time.time() - start_time
    print(" *---- Zooms:%s # Block_size:%s #  Block_tiles:%s in %0.2f seconds ----*" % ( zooms, block_size, total_block_tiles , total_time))
    print("OSM tiles per second: %0.3f" % (total_block_tiles * block_size*block_size / total_time) )

def read_zips_visited():
    with open('/scripts/logs-insights-results-7.csv') as csv_file:
        csv_reader = csv.DictReader(csv_file)
        for row in csv_reader:
            zips_visited.append( "%s%s/%s/%s/%s.zip" % ( TILE_DIR, row['z'],row['x'],row['y'],row['zip']) )
    print( "zips_visited", zips_visited)

TILE_SIZE = 256
MAX_ZOOM = 17
ll_bounds = (1.96, 41.58, 2.06, 41.68)
# ll_bounds = (2.0, 41.62, 2.03, 41.65)
# ll_bounds = (1.043, 41.058, 1.411, 41.701)
# ll_bounds = (1.411, 41.132, 2.25, 43.00)
queue = multiprocessing.Queue()
zips_visited = []

if __name__ == '__main__':
    geojson_piricat = "/mnt/conf/tot.geojson"
    # geojson_piricat = "/mnt/conf/temp2.geojson"
    geojson_picos = "/mnt/conf/picos_render.geojson"
    
    read_zips_visited()

    t1 = time.time()
    render_geojson( geojson_piricat, block_size=8, zooms=(7,12))
    render_geojson( geojson_piricat, block_size=16, zooms=(13,15))
    render_geojson( geojson_piricat, block_size=32, zooms=(16,17))
    # render_geojson( geojson_piricat, block_size=8, zooms=(16,17))

    render_geojson( geojson_picos, block_size=8, zooms=(7,14))
    render_geojson( geojson_picos, block_size=16, zooms=(15,16))
    render_geojson( geojson_picos, block_size=32, zooms=(17,17))

    print(" ********** TOTAL TIME #   %0.2f seconds ----*" % ( time.time() - t1))

    # esborrar arxius de menys de xxx i folders vuits
    # find 7 -size -25k -delete
    # find 8 -size -25k -delete
    # find 9 -size -25k -delete
    # find 10 -size -25k -delete
    # find 11 -size -25k -delete
    # find 12 -size -50k -delete
    # find 13 -size -120k -delete
    # find 14 -size -120k -delete
    # find 15 -size -120k -delete
    # find 16 -size -240k -delete
    # find 17 -size -240k -delete

    # Pujar un de suelto
    # aws s3 cp . s3://upload-tiles/ --recursive --exclude "*" --include "*/31840_23984.png"

    # docker-compose exec tileserver /scripts/render_tilezip.py