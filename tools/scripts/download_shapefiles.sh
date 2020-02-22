#!/bin/bash

# Shapefile Download
  # Although most of the data used to create the map is directly from the
  # OpenStreetMap data file that you downloaded above, some shapefiles for
  # things like low-zoom country boundaries are still needed. To download and
  # index these:
python /mnt/openstreetmap-carto/scripts/get-shapefiles.py -d /mnt/base_data
cd /mnt/base_data
rm -f *.zip
