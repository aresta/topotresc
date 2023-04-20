#!/bin/bash

# Shapefile Download
  # Although most of the data used to create the map is directly from the
  # OpenStreetMap data file that you downloaded above, some shapefiles for
  # things like low-zoom country boundaries are still needed. To download and
  # index these:

[ -d /mnt/base_data ] || mkdir -p /mnt/base_data
cd /mnt/base_data
wget https://osmdata.openstreetmap.de/download/simplified-water-polygons-split-3857.zip
wget https://osmdata.openstreetmap.de/download/water-polygons-split-3857.zip
unzip '*.zip'
rm -f *.zip

# Not needed for our zoom levels
# wget https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/cultural/ne_110m_admin_0_boundary_lines_land.zip
# [ -d ne_110m_admin_0_boundary_lines_land ] || mkdir -p ne_110m_admin_0_boundary_lines_land
# mv ne_110m_admin_0_boundary_lines_land.* ne_110m_admin_0_boundary_lines_land

# extract the coast lines to sql to be imported, filtered to the Spain area: x >= -4 and x <= 1 and y >= 13 and y <= 17
ogr2ogr \
    -f PGDump \
    -progress \
    -where 'x >= -4 and x <= 1 and y >= 13 and y <= 17' \
    -lco GEOMETRY_NAME=way \
    -lco SPATIAL_INDEX=NONE \
    -lco EXTRACT_SCHEMA_FROM_LAYER_NAME=YES \
    -nln simplified_water_polygons \
    --config PG_USE_COPY YES \
    >(gzip > simplified_water_polygons.sql.gz) \
    simplified-water-polygons-split-3857/simplified_water_polygons.shp

ogr2ogr \
    -f PGDump \
    -progress \
    -where 'x >= -4 and x <= 1 and y >= 13 and y <= 17' \
    -lco GEOMETRY_NAME=way \
    -lco SPATIAL_INDEX=NONE \
    -lco EXTRACT_SCHEMA_FROM_LAYER_NAME=YES \
    -nln water_polygons \
    --config PG_USE_COPY YES \
    >(gzip > water_polygons.sql.gz) \
    water-polygons-split-3857/water_polygons.shp