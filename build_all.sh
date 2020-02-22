
echo "Download SHPs of the coasts..."
docker-compose exec tools /scripts/download_shapefiles.sh

# create a geojson with the area of your map and put in /mnt/pbf. It will be used to clip the osm data, the contours and the hill-shade image
# the script will download a pbf of spain and afterwards clip it to the geojson area. For other countries adjust it.
docker-compose exec tools /scripts/create_pbf.sh

# get your DEM files from the spanish IGN and put them in mnt/dem/es
# for DEMs from other sources you will need to adjust a bit the next script 
docker-compose exec tools /scripts/create_shades_contours.sh

# Import to the DB. This will take a while... well, like the other steps
docker-compose exec tools /scripts/import_pbf.sh
docker-compose exec postgres /scripts/import_contours.sh

# compile the styles, only needed if you change them
docker-compose exec tools /scripts/compile_styles.sh

# here we go
./start_web_server.sh

# point your browser to http://localhost
