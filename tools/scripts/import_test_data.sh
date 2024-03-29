#!/bin/bash

export PGUSER=render
export PGPASSWORD=render

# PBF
echo 'Importing OSM data'
osm2pgsql  -H postgres \
  -d renderdb \
  --create \
  --slim \
  -G \
  --hstore \
  --tag-transform-script /mnt/openstreetmap-carto/openstreetmap-carto.lua \
  -C 12000 \
  --number-processes 12 \
  -S /mnt/openstreetmap-carto/openstreetmap-carto.style \
  /mnt/pbf/test.pbf


# Import coast lines. Filtered to Spain area only
echo 'Importing coast lines'
gunzip /mnt/base_data/simplified_water_polygons.sql.gz -c | psql -h postgres -U render -d renderdb
gunzip /mnt/base_data/water_polygons.sql.gz -c | psql -h postgres -U render -d renderdb


# contours lines
echo 'Importing contours data'
gunzip /mnt/contours/contours_test.sql.gz -c | psql -h postgres -U render -d renderdb
