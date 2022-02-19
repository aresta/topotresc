#!/bin/bash

# Donload the PBF of the country and clip to the area defined by the json
echo "Download PBFs, clip and build tot.pbf"

cd /mnt/pbf
wget -N http://download.openstreetmap.fr/extracts/europe/spain-latest.osm.pbf
wget -N http://download.openstreetmap.fr/extracts/europe/france-latest.osm.pbf
wget -N http://download.geofabrik.de/europe/andorra-latest.osm.pbf

# Clip big PBF to the desired area defined by the geojson (it should contain a feature, not a collection of features)
osmium extract -p ../conf/tot.geojson spain-latest.osm.pbf -o piri_es.pbf
osmium extract -p ../conf/tot.geojson france-latest.osm.pbf -o piri_fr.pbf
# renumber id's to avoid errors with repeated id's. As the PBF's come from diferent sources there is not guarantee that id's are unique
osmium renumber andorra-latest.osm.pbf -o piri_and.pbf
osmium renumber --start-id=1000000 piri_es.pbf -o piri_es_b.pbf
osmium renumber --start-id=50000000 piri_fr.pbf -o piri_fr_b.pbf

### picos ####
osmium extract -p ../conf/picos.geojson spain-latest.osm.pbf -o picos.pbf
osmium renumber --start-id=80000000 picos.pbf -o picos_b.pbf

osmium merge piri_and.pbf piri_es_b.pbf piri_fr_b.pbf picos_b.pbf --overwrite -o tot.pbf
rm piri_and.pbf piri_fr.pbf piri_es.pbf piri_fr_b.pbf piri_es_b.pbf picos.pbf picos_b.pbf

