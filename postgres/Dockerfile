FROM postgis/postgis:12-3.0

# Needed only to get shp2pgsql. It's a client tool, not installed by default in the server.
RUN apt-get update && apt-get install -y postgis \
    && rm -rf /var/lib/apt/lists/*
    

