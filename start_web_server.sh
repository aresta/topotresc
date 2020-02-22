echo "Restarting apache"
# docker-compose exec tileserver service apache2 stop
# # docker-compose exec tileserver a2enconf mod_tile
docker-compose exec tileserver service apache2 start
docker-compose exec tileserver service apache2 reload # sometimes is needed

echo "Starting renderd"
docker-compose exec tileserver renderd -f -c /usr/local/etc/renderd.conf