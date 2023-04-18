#!/bin/bash

export PGUSER=render
export PGPASSWORD=render

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


echo 'Importing contours data'
gunzip /mnt/contours/contours_test.sql.gz -c | psql -h postgres -U render -d renderdb
