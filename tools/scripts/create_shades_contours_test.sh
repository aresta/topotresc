#!/bin/bash

# hill-shades
[ -d /mnt/shades ] || mkdir -p /mnt/shades
[ -d /mnt/contours ] || mkdir -p /mnt/contours
cd /mnt/shades

ogr2ogr -f GeoJSON test_3043.geojson -s_srs EPSG:4326 -t_srs EPSG:3043 ../conf/test.geojson

### Test area - should be in spain pbf area ###
gdalbuildvrt -a_srs EPSG:25830 dem_test.vrt ../dem/es/*_HU30_*.asc
gdalwarp -ts 9000 0 -multi -wo NUM_THREADS=ALL_CPUS -of GTiff -overwrite -co COMPRESS=DEFLATE -co PREDICTOR=2 -co TILED=YES -t_srs EPSG:3857 -co BIGTIFF=YES -r bilinear  -cutline test_3043.geojson -crop_to_cutline dem_test.vrt dem_test.tif
gdaldem hillshade -z 1.2 -multidirectional dem_test.tif shades_test.tif

# test contours
gdal_contour -i 5 -off 0  -a height dem_test.tif ../contours/contours_test.shp
ogr2ogr ../contours/contours_test_simpl.shp ../contours/contours_test.shp -simplify 2

# merge all shades
gdalbuildvrt shades_merged.vrt shades_test.tif

gdaldem color-relief -of PNG dem_test.tif ../conf/color_relief.txt color_relief_test.tif
gdalbuildvrt color_relief.vrt color_relief_test.tif
