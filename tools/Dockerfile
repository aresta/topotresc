FROM ubuntu:20.04
MAINTAINER arestabrucs
# Based on instructions from: https://wiki.openstreetmap.org/wiki/Mod_tile#Install_mod_tile_From_Source
# and ideas from https://github.com/jimmyrocks/osm-tiles-mapnik

ENV DEBIAN_FRONTEND=nonintercative
RUN apt update -qq && apt install -y --no-install-recommends \
    curl \
    git \
    wget \
    zip unzip \
    gpg-agent \
    python3-mapnik \
    mapnik-utils \
    python3-mapnik \
    python3-psycopg2 \
    python3-yaml \
    python-is-python3 \
    python3-queuelib \
    python3-pip \
    npm \
    postgresql-client \
    osm2pgsql \
    osmium-tool \
    software-properties-common \
    build-essential \
    gdal-bin \
    fonts-noto-hinted fonts-noto-unhinted fonts-noto-cjk \
    ttf-unifont fonts-hanazono \
  && npm install -g carto \
  && pip install pillow shapely matplotlib flask \
  && rm -rf /var/lib/apt/lists/*