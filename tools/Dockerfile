FROM ubuntu:18.04
MAINTAINER arestabrucs
# Based on instructions from: https://wiki.openstreetmap.org/wiki/Mod_tile#Install_mod_tile_From_Source
# and ideas from https://github.com/jimmyrocks/osm-tiles-mapnik

RUN apt-get update -qq && apt-get install  -y --no-install-recommends \
    curl \
    git \
    wget \
    nodejs \
    mapnik-utils \
    npm \
    osm2pgsql \
    osmium-tool \
    software-properties-common \
  && add-apt-repository ppa:ubuntugis/ubuntugis-unstable && apt-get update -qq \
  && apt-get install -y --no-install-recommends \
    gdal-bin \
  && npm install -g npm \
  && npm install -g carto