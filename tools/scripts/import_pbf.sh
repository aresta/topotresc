#!/bin/bash

# NO esborra la taula contours

export PGUSER=render
export PGPASSWORD=render
osm2pgsql  -H postgres \
  -d renderdb \
  --create \
  --slim \
  -G \
  --hstore \
  --tag-transform-script /mnt/openstreetmap-carto/openstreetmap-carto.lua \
  -C 12000 \
  --number-processes 5 \
  -S /mnt/openstreetmap-carto/openstreetmap-carto.style \
  /mnt/pbf/picos.pbf