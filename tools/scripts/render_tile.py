#!/usr/bin/python
#encoding: utf-8
import mapnik
import time
from io import BytesIO

print( "Mapnik version:", mapnik.mapnik_version())

merc = mapnik.Projection('+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0.0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs +over')
longlat = mapnik.Projection('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')
mapfile = "/mnt/openstreetmap-carto/mapnik.xml"

# bounds = (-4.915, 43.162, -4.805, 43.211) # Picos
bounds = (1.94, 41.62, 2.03, 41.67)  # St Llorenç

start_time = time.time()

bbox = mapnik.Box2d(*bounds)
transform = mapnik.ProjTransform( longlat, merc)
merc_bbox = transform.forward( bbox)

image_size = 4000
map = mapnik.Map(image_size, image_size)
mapnik.load_map( map, mapfile, False)

map.zoom_to_box(merc_bbox)
im = mapnik.Image( image_size, image_size)
mapnik.render( map, im)

im.save('/mnt/test.png','png256:z=9')
print("--- %s seconds ---" % (time.time() - start_time))

