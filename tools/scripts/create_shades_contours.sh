#!/bin/bash

# hill-shades
cd /mnt/shades
ogr2ogr -f GeoJSON picos_3043.geojson -s_srs EPSG:4326 -t_srs EPSG:3043 /mnt/conf/picos.geojson
ogr2ogr -f GeoJSON picos_3035.geojson -s_srs EPSG:4326 -t_srs EPSG:3035 /mnt/conf/picos.geojson

gdalbuildvrt -a_srs EPSG:25830 dem_es.vrt ../dem/es/*_HU30_*.asc

gdalwarp -multi -wo NUM_THREADS=ALL_CPUS -of GTiff -overwrite -co COMPRESS=DEFLATE -co PREDICTOR=2 -co TILED=YES -t_srs EPSG:3857 -r bilinear  -cutline picos_3043.geojson -crop_to_cutline dem_es.vrt dem_es.tif
gdaldem hillshade -z 1.2 -multidirectional dem_es.tif shades_es.tif

# colour relief
gdaldem color-relief -of PNG dem_es.tif /mnt/conf/color_relief.txt color_relief.tif

# contours
cd /mnt/contours
gdal_contour -i 10 -a height /mnt/shades/dem_es.tif contours.shp