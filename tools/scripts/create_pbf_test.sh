#!/bin/bash

# Donload the PBF of the country and clip to the area defined by the json
echo "TEST - Download PBFs, clip and build area"

[ -d /mnt/pbf ] || mkdir -p /mnt/pbf
cd /mnt/pbf

wget -N http://download.openstreetmap.fr/extracts/europe/spain-latest.osm.pbf

# crop pbf to map area (tot.geojson)
osmium extract --overwrite -p ../conf/test.geojson spain-latest.osm.pbf -o test.pbf
echo "test.pbf created"

