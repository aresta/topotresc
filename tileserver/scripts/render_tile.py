#!/usr/bin/python
#encoding: utf-8
import mapnik
import sys, os
import time
import PIL.Image
from StringIO import StringIO
from io import BytesIO
from zipfile import ZipFile

print( "Version", mapnik.mapnik_version())

merc = mapnik.Projection('+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0.0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs +over')
longlat = mapnik.Projection('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')
mapfile = "/mnt/openstreetmap-carto/mapnik.xml"

# bounds = (1.94, 41.63, 2.03, 41.67)
# bounds = (1.70, 41.38, 2.18, 41.73)     # Bcn:  montserrat, sant llorenç, valles...
bounds = (1.90, 41.55, 2.10, 41.70)
# bounds = (1.93, 41.61, 1.97, 41.64)
# bounds = (1.698, 41.727, 1.703, 41.73)

start_time = time.time()

bbox = mapnik.Box2d(*bounds)
transform = mapnik.ProjTransform( longlat, merc)
merc_bbox = transform.forward( bbox)

tiles_folder = "/scripts/tilezips/"
tile_size = 256
zip_tile_size = 8
block_size = 24
image_size = tile_size * block_size
max_zoom = 17

map = mapnik.Map(image_size, image_size)
mapnik.load_map( map, mapfile, True)

t1 =time.time()
map.zoom_to_box(merc_bbox)
im = mapnik.Image( image_size, image_size)
mapnik.render( map, im)

t2 =time.time()
# im.save( "/var/www/html/test_original.png", 'png256:z=9')
img = PIL.Image.open( StringIO( im.tostring('png24:z=0'))) # high color depth before slicing

# Slice image in tiles
tile_x = 0 # x*block_size
tile_y = 0 # y*block_size

t3 = time.time() ######
image_file = BytesIO()
for zx in range(block_size/zip_tile_size):
    base_x = zx * zip_tile_size
    for zy in range(block_size/zip_tile_size):
        base_y = zy * zip_tile_size
        zip_name = tiles_folder + "%s_%s.zip" % ( tile_x + base_x ,tile_y + base_y )
        with ZipFile( zip_name, 'w') as zip: 
            for tx in range( zip_tile_size ):
                i = base_x + tx
                for ty in range( zip_tile_size ):
                    # tt1 = time.time() ######
                    j = base_y + ty
                    
                    image_file.seek(0)
                    image_file.truncate(0)
                    img.crop(( i*tile_size, j*tile_size, (i+1)*tile_size, (j+1)*tile_size )).\
                        convert('RGB').convert('P', palette=PIL.Image.ADAPTIVE).\
                        save( image_file, format="PNG", optimize=True)
                    
                    # tt3 = time.time() ######
                    zip.writestr("%s_%s.png" % ( tile_x + i, tile_y + j ), image_file.getvalue())
                    # tt4 = time.time() ######
                    # print(" ::::::  %0.3f %0.3f" % (tt3-tt1, tt4-tt3))
t4 = time.time() ######
print("%0.3f %0.3f %0.3f" % (t2-t1, t3-t2, t4-t3))


print("--- %s seconds ---" % (time.time() - start_time))
print('Done!')
