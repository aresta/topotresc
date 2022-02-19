FROM ubuntu:21.10
MAINTAINER arestabrucs
# Based on instructions from: https://wiki.openstreetmap.org/wiki/Mod_tile#Install_mod_tile_From_Source
# and ideas from https://github.com/jimmyrocks/osm-tiles-mapnik

ENV DEBIAN_FRONTEND=nonintercative
RUN apt-get update -qq && apt-get install  -y --no-install-recommends \
    curl \
    git \
    wget \
    gpg-agent \
    nodejs \
    mapnik-utils \
    npm \
    osm2pgsql \
    osmium-tool \
    software-properties-common \
    build-essential \
    gdal-bin \
  && npm install -g npm \
  && npm install -g carto