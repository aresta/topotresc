#!/bin/bash

# Shapefile Download
  # Although most of the data used to create the map is directly from the
  # OpenStreetMap data file that you downloaded above, some shapefiles for
  # things like low-zoom country boundaries are still needed. To download and
  # index these:

[ -d /mnt/base_data ] || mkdir -p /mnt/base_data
cd /mnt/base_data
wget https://osmdata.openstreetmap.de/download/simplified-water-polygons-split-3857.zip
wget https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/cultural/ne_110m_admin_0_boundary_lines_land.zip
wget https://osmdata.openstreetmap.de/download/water-polygons-split-3857.zip
unzip '*.zip'
rm -f *.zip
[ -d ne_110m_admin_0_boundary_lines_land ] || mkdir -p ne_110m_admin_0_boundary_lines_land
mv ne_110m_admin_0_boundary_lines_land.* ne_110m_admin_0_boundary_lines_land

