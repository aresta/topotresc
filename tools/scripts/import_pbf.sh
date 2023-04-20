#!/bin/bash

export PGUSER=render
export PGPASSWORD=render

# NO esborra la taula contours
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
  /mnt/pbf/$AREA.pbf


# Import coast lines. Filtered to Spain area only.
gunzip /mnt/base_data/simplified_water_polygons.sql.gz -c | psql -h postgres -U render -d renderdb
gunzip /mnt/base_data/water_polygons.sql.gz -c | psql -h postgres -U render -d renderdb
