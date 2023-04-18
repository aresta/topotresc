#!/bin/bash

echo "Creating contours"
[ -d /mnt/contours ] || mkdir -p /mnt/contours
cd /mnt/contours
export OGR_GEOJSON_MAX_OBJ_SIZE=500MB

gdal_contour -i 10 -f GeoJSON -a height -lco COORDINATE_PRECISION=3 ../shades/dem_merged.tif contours.geojson
ogr2ogr -lco GEOMETRY_NAME=way -lco COLUMN_TYPES=height=int -f PGDump --config PG_USE_COPY YES >(gzip > contours.sql.gz) contours.geojson -simplify 2 -progress
# rm contours.geojson

# Picos contours
gdal_contour -i 10 -f GeoJSON -a height -lco COORDINATE_PRECISION=3 ../shades/dem_picos.tif contours_picos.geojson
# insertar sense borrar
ogr2ogr -lco DROP_TABLE=OFF -lco CREATE_TABLE=OFF -lco GEOMETRY_NAME=way -lco COLUMN_TYPES=height=int -f PGDump --config PG_USE_COPY YES >(gzip > contours_picos.sql.gz) contours_picos.geojson -simplify 2 -progress
# rm contours_picos.geojson


