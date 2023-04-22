# echo "Download SHPs of the coasts..."
# Run this only the first time. Once the files are in mnt/base_data/ you can comment out the line below
# docker-compose exec tools /scripts/download_shapefiles.sh

# create a geojson with the area of your map and put in /mnt/pbf. It will be used to clip the osm data, the contours and the hill-shade image
# the script will download pbf's of spain, france & andorra and clip & merge it to the geojson area.
# docker-compose exec tools /scripts/create_pbf.sh

# get your DEM files from the spanish IGN and put them in mnt/dem/es
# for DEMs from other sources you will need to adjust a bit the next script
# Run this only when you change the area of your map. Otherwise the shades and countour lines are always the same
docker-compose exec tools /scripts/create_shades_contours.sh

# Import to the DB. This will take a while... well, like the other steps
docker-compose exec --env AREA=tot tools /scripts/import_pbf.sh
# Import contours only if you changed the area of your map. Otherwise it's needed only the 1st time, as they would be already in the DB.
docker-compose exec tools /scripts/import_contours.sh

# compile the styles, only needed if you change them
# docker-compose exec tools /scripts/compile_styles.sh

# here we go
docker-compose exec tools /scripts/start_web_server.sh

# point your browser to http://localhost

docker-compose exec tools /scripts/render_tile.py
