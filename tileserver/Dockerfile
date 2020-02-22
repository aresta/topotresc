FROM debian:10.2-slim
MAINTAINER arestabrucs
# Based on instructions from: https://wiki.openstreetmap.org/wiki/Mod_tile#Install_mod_tile_From_Source
# and ideas from https://github.com/jimmyrocks/osm-tiles-mapnik

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      apache2 \
      apache2-dev \
      autoconf \
      automake \
      build-essential \
      git-core \
      libmapnik3.0 \
      libmapnik-dev \
      mapnik-utils \
      python-mapnik \
      fonts-noto-cjk fonts-noto-hinted fonts-noto-unhinted fonts-hanazono ttf-unifont \
    && rm -rf /var/lib/apt/lists/*

# Install mod tile
RUN mkdir -p /src && \
    mkdir -p /var/run/renderd && \
    mkdir -p /var/lib/mod_tile && \
    git clone git://github.com/SomeoneElseOSM/mod_tile.git /src/mod_tile && \
    cd /src/mod_tile && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    make install-mod_tile && \
    ldconfig

