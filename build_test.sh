# PBF
cd /mnt/pbf/
wget -N http://download.openstreetmap.fr/extracts/europe/spain-latest.osm.pbf
osmium extract --overwrite -p ../conf/test.geojson spain-latest.osm.pbf -o test.pbf
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
  test.pbf

# shades
cd /mnt/shades
ogr2ogr -f GeoJSON test_3043.geojson -s_srs EPSG:4326 -t_srs EPSG:3043 ../conf/test.geojson
gdalbuildvrt -a_srs EPSG:25830 dem_test.vrt ../dem/es/*_HU30_*.asc
gdalwarp -multi -wo NUM_THREADS=ALL_CPUS -of GTiff -overwrite -co COMPRESS=DEFLATE -co PREDICTOR=2 -co TILED=YES -t_srs EPSG:3857 -co BIGTIFF=YES -r bilinear  -cutline test_3043.geojson -crop_to_cutline dem_test.vrt dem_test.tif
gdaldem hillshade -z 1.2 -multidirectional dem_test.tif shades_test.tif
gdalbuildvrt shades_merged.vrt shades_test.tif

# color_relief
gdaldem color-relief -of PNG dem_test.tif ../conf/color_relief.txt color_relief_test.tif
gdalbuildvrt color_relief.vrt color_relief_test.tif

# contours
cd /mnt/contours
export OGR_GEOJSON_MAX_OBJ_SIZE=500MB
gdal_contour -i 10 -f GeoJSON -a height -lco COORDINATE_PRECISION=3 ../shades/dem_test.tif contours_test.geojson
ogr2ogr -lco GEOMETRY_NAME=way -lco COLUMN_TYPES=height=int -f PGDump --config PG_USE_COPY YES >(gzip > contours_test.sql.gz) contours_test.geojson -simplify 2 -progress
# rm contours_test.geojson
export PGPASSWORD=render
gunzip contours_test.sql.gz -c | psql -h postgres -U render -d renderdb

# compile the styles, only needed if you change them
#docker-compose exec tools /scripts/compile_styles.sh

cd /scripts
./render_tilezip.py

# here we go
docker-compose exec tools /scripts/start_web_server.sh

# point your browser to http://127.0.0.1:5000/

