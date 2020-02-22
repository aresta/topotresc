#!/bin/bash

# Donload the PBF of the country and clip to the area defined by the json

cd /mnt/pbf
wget -N http://download.openstreetmap.fr/extracts/europe/spain-latest.osm.pbf

# Clip big PBF to the desired area defined by the geojson (it should contain a feature, not a collection of features)
osmium extract -p /mnt/conf/picos.geojson spain-latest.osm.pbf -o picos.pbf