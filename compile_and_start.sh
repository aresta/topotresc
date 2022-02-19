echo "Compiling styles"
docker-compose start tools
docker-compose exec tools /scripts/compile_styles.sh
rm -fR tiles/default/*

echo "Restarting apache"
# docker-compose exec tileserver service apache2 stop
# # docker-compose exec tileserver a2enconf mod_tile
docker-compose exec tileserver service apache2 start
docker-compose exec tileserver service apache2 reload # sometimes is needed to restart twice

echo "Starting renderd"
docker-compose exec tileserver renderd -f -c /usr/local/etc/renderd.conf