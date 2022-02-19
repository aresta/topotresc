# Notes de treball temporals, tests...

### Crear poligons (geojson) i guardar com xxx.geojson
> http://geojson.io/ 

---

## PBFs
mnt/pbf
### Descarregar regions
## -N to overwrite
# wget -N http://download.geofabrik.de/europe/spain-latest.osm.pbf
wget -N http://download.openstreetmap.fr/extracts/europe/spain-latest.osm.pbf
wget -N http://download.openstreetmap.fr/extracts/europe/france-latest.osm.pbf
# wget -N http://download.openstreetmap.fr/extracts/europe/france/midi_pyrenees-latest.osm.pbf
# wget -N http://download.openstreetmap.fr/extracts/europe/france/aquitaine-latest.osm.pbf
wget -N http://download.geofabrik.de/europe/andorra-latest.osm.pbf
# wget -N http://download.geofabrik.de/europe/france/languedoc_roussillon-latest.osm.pbf
# wget -N http://download.geofabrik.de/europe/france/midi_pyrenees-latest.osm.pbf
# wget -N http://download.geofabrik.de/europe/france/aquitaine-latest.osm.pbf
# wget -N http://download.geofabrik.de/europe/france-latest.osm.pbf
# wget -N http://download.openstreetmap.fr/extracts/europe/france-latest.osm.pbf

---


### Cat tot
ogr2ogr cat_3043.geojson -s_srs EPSG:4326 -t_srs EPSG:3043 cat.geojson
ogr2ogr cat_3035.geojson -s_srs EPSG:4326 -t_srs EPSG:3035 cat.geojson

osmium extract -p cat.geojson ../pbf/spain-latest.osm.pbf -o piri_es.pbf
osmium extract -p cat.geojson ../pbf/france-latest.osm.pbf -o piri_fr.pbf
osmium renumber ../pbf/andorra-latest.osm.pbf -o piri_and.pbf
osmium renumber --start-id=1000000 piri_es.pbf -o piri_es_b.pbf
osmium renumber --start-id=50000000 piri_fr.pbf -o piri_fr_b.pbf
osmium merge piri_and.pbf piri_es_b.pbf piri_fr_b.pbf --overwrite -o cat.pbf
rm piri_and.pbf piri_fr.pbf piri_es.pbf piri_fr_b.pbf piri_es_b.pbf

gdalbuildvrt -a_srs EPSG:3043 dem_cat.vrt ../dem/cat/*.txt
gdalwarp -ts 25000 0 -multi -wo NUM_THREADS=ALL_CPUS -of GTiff  -overwrite -co COMPRESS=DEFLATE -co PREDICTOR=2 -co TILED=YES -t_srs EPSG:3857 -r bilinear -cutline cat_3043.geojson -crop_to_cutline dem_cat.vrt dem_cat.tif
gdaldem hillshade -z 1.2 -multidirectional dem_cat.tif shades_cat.tif

gdalwarp -overwrite -co COMPRESS=DEFLATE -co PREDICTOR=2 -co TILED=YES -t_srs EPSG:3857 -r bilinear -cutline cat_3035.geojson -crop_to_cutline ../dem/tot25m/eu_dem_v11_E30N20.TIF dem_fr.tif
gdaldem hillshade -z 1.2 -multidirectional dem_fr.tif shades_fr.tif

gdalbuildvrt -a_srs EPSG:25830 dem_es.vrt ../dem/es/*_HU30_*.asc
gdalwarp -ts 23000 0 -multi -wo NUM_THREADS=ALL_CPUS -of GTiff -overwrite -co COMPRESS=DEFLATE -co PREDICTOR=2 -co TILED=YES -t_srs EPSG:3857 -r bilinear  -cutline cat_3043.geojson -crop_to_cutline dem_es.vrt dem_es.tif
gdaldem hillshade -z 1.2 -multidirectional dem_es.tif shades_es.tif

gdalbuildvrt shades_merged.vrt shades_fr.tif shades_cat.tif shades_es.tif
gdalwarp --config GDAL_CACHEMAX 500 -wm 500 -multi -wo NUM_THREADS=ALL_CPUS -overwrite -co COMPRESS=DEFLATE -co PREDICTOR=2 -co TILED=YES -r bilinear dem_fr.tif dem_cat.tif dem_es.tif dem_merged.tif
gdal_contour -i 10 -a height dem_merged.tif contours.shp


### Montserrat
ogr2ogr monts_3043.geojson -s_srs EPSG:4326 -t_srs EPSG:3043 monts.geojson
ogr2ogr monts_3035.geojson -s_srs EPSG:4326 -t_srs EPSG:3035 monts.geojson
osmium extract --overwrite -p monts.geojson ../pbf/spain-latest.osm.pbf -o monts.pbf

gdalbuildvrt -a_srs EPSG:3043 dem_monts.vrt ../dem/cat/*.txt
gdalwarp -multi -wo NUM_THREADS=ALL_CPUS -of GTiff  -overwrite -co COMPRESS=DEFLATE -co PREDICTOR=2 -co TILED=YES -t_srs EPSG:3857 -r bilinear -cutline monts_3043.geojson -crop_to_cutline dem_monts.vrt dem_monts.tif
gdaldem hillshade -z 1.2 -multidirectional dem_monts.tif shades_monts.tif

gdalbuildvrt shades_merged.vrt shades_monts.tif
gdal_contour -i 5 -a height dem_monts.tif contours.shp

### St Llorenç de Munt
ogr2ogr stllor_3043.geojson -s_srs EPSG:4326 -t_srs EPSG:3043 stllor.geojson
ogr2ogr stllor_3035.geojson -s_srs EPSG:4326 -t_srs EPSG:3035 stllor.geojson
osmium extract --overwrite -p stllor.geojson ../pbf/spain-latest.osm.pbf -o stllor.pbf

gdalbuildvrt -a_srs EPSG:3043 dem_stllor.vrt ../dem/cat/*.txt
gdalwarp -multi -wo NUM_THREADS=ALL_CPUS -of GTiff  -overwrite -co COMPRESS=DEFLATE -co PREDICTOR=2 -co TILED=YES -t_srs EPSG:3857 -r bilinear -cutline stllor_3043.geojson -crop_to_cutline dem_stllor.vrt dem_stllor.tif
gdaldem hillshade -z 1.2 -multidirectional dem_stllor.tif shades_stllor.tif

gdalbuildvrt shades_merged.vrt shades_stllor.tif
gdal_contour -i 5 -a height dem_stllor.tif contours.shp

### Ordesa
ogr2ogr ordesa_3043.geojson -s_srs EPSG:4326 -t_srs EPSG:3043 ordesa.geojson
ogr2ogr ordesa_3035.geojson -s_srs EPSG:4326 -t_srs EPSG:3035 ordesa.geojson
osmium extract --overwrite -p ordesa.geojson ../pbf/spain-latest.osm.pbf -o ordesa.pbf

gdalbuildvrt -a_srs EPSG:25830 dem_ordesa.vrt ../dem/es/*_HU30_*.asc
gdalwarp -multi -wo NUM_THREADS=ALL_CPUS -of GTiff  -overwrite -co COMPRESS=DEFLATE -co PREDICTOR=2 -co TILED=YES -t_srs EPSG:3857 -r bilinear -cutline ordesa_3043.geojson -crop_to_cutline dem_ordesa.vrt dem_ordesa.tif
gdaldem hillshade -z 1.2 -multidirectional dem_ordesa.tif shades_ordesa.tif

gdalbuildvrt shades_merged.vrt shades_ordesa.tif
gdal_contour -i 20 -off 0 -a height dem_ordesa.tif contours_00.shp
gdal_contour -i 20 -off 5 -a height dem_ordesa.tif contours_05.shp
gdal_contour -i 20 -off 10 -a height dem_ordesa.tif contours_10.shp
gdal_contour -i 20 -off 15 -a height dem_ordesa.tif contours_15.shp


### Piri Oest
ogr2ogr piri_oest_3043.geojson -s_srs EPSG:4326 -t_srs EPSG:3043 piri_oest.geojson
ogr2ogr piri_oest_3035.geojson -s_srs EPSG:4326 -t_srs EPSG:3035 piri_oest.geojson

osmium extract -p piri_oest.geojson ../pbf/spain-latest.osm.pbf -o piri_es.pbf
osmium extract -p piri_oest.geojson ../pbf/france-latest.osm.pbf -o piri_fr.pbf
osmium renumber --start-id=1000000 piri_es.pbf -o piri_es_b.pbf
osmium renumber --start-id=50000000 piri_fr.pbf -o piri_fr_b.pbf
osmium merge piri_es_b.pbf piri_fr_b.pbf --overwrite -o piri_oest.pbf
rm piri_fr.pbf piri_es.pbf piri_fr_b.pbf piri_es_b.pbf

gdalwarp -overwrite -co COMPRESS=DEFLATE -co PREDICTOR=2 -co TILED=YES -t_srs EPSG:3857 -r bilinear -cutline piri_oest_3035.geojson -crop_to_cutline ../dem/tot25m/eu_dem_v11_E30N20.TIF dem_fr.tif
gdaldem hillshade -z 1.2 -multidirectional dem_fr.tif shades_fr.tif

gdalbuildvrt -a_srs EPSG:25830 dem_es.vrt ../dem/es/*_HU30_*.asc
gdalwarp -ts 20000 0 -multi -wo NUM_THREADS=ALL_CPUS -of GTiff -overwrite -co COMPRESS=DEFLATE -co PREDICTOR=2 -co TILED=YES -t_srs EPSG:3857 -r bilinear  -cutline piri_oest_3043.geojson -crop_to_cutline dem_es.vrt dem_es.tif
gdaldem hillshade -z 1.2 -multidirectional dem_es.tif shades_es.tif

gdalbuildvrt shades_merged.vrt shades_fr.tif shades_es.tif
gdalwarp --config GDAL_CACHEMAX 500 -wm 500 -multi -wo NUM_THREADS=ALL_CPUS -overwrite -co COMPRESS=DEFLATE -co PREDICTOR=2 -co TILED=YES -r bilinear dem_fr.tif dem_es.tif dem_merged.tif
gdal_contour -i 10 -a height dem_merged.tif contours.shp


### Catalunya sud
ogr2ogr cat_sud_3043.geojson -s_srs EPSG:4326 -t_srs EPSG:3043 cat_sud.geojson
ogr2ogr cat_sud_3035.geojson -s_srs EPSG:4326 -t_srs EPSG:3035 cat_sud.geojson
osmium extract -p cat_sud.geojson ../pbf/spain-latest.osm.pbf -o cat_sud.pbf

gdalbuildvrt -a_srs EPSG:3043 dem_cat.vrt ../dem/cat/*.txt 
gdalwarp -ts 23000 0 -multi -wo NUM_THREADS=ALL_CPUS -of GTiff  -overwrite -co COMPRESS=DEFLATE -co PREDICTOR=2 -co TILED=YES -t_srs EPSG:3857 -r bilinear -cutline cat_sud_3043.geojson -crop_to_cutline dem_cat.vrt dem_cat.tif
gdaldem hillshade -z 1.2 -multidirectional dem_cat.tif shades_cat.tif

gdalbuildvrt -a_srs EPSG:25830 dem_es.vrt ../dem/cat/*_HU30_*.asc
gdalwarp -ts 23000 0 -multi -wo NUM_THREADS=ALL_CPUS -of GTiff -overwrite -co COMPRESS=DEFLATE -co PREDICTOR=2 -co TILED=YES -t_srs EPSG:3857 -r bilinear  -cutline cat_sud_3043.geojson -crop_to_cutline dem_es.vrt dem_es.tif
gdaldem hillshade -z 1.2 -multidirectional dem_es.tif shades_es.tif

gdalbuildvrt shades_merged.vrt shades_cat.tif shades_es.tif
gdalwarp --config GDAL_CACHEMAX 500 -wm 500 -multi -wo NUM_THREADS=ALL_CPUS -overwrite -co COMPRESS=DEFLATE -co PREDICTOR=2 -co TILED=YES -r bilinear dem_es.tif dem_cat.tif dem_merged.tif
gdal_contour -i 10 -a height dem_merged.tif contours.shp


### Tot
osmium extract -p tot.geojson ../pbf/spain-latest.osm.pbf -o piri1.pbf
osmium extract -p tot.geojson ../pbf/languedoc_roussillon-latest.osm.pbf -o piri2.pbf
osmium extract -p tot.geojson ../pbf/midi_pyrenees-latest.osm.pbf -o piri3.pbf
osmium extract -p tot.geojson ../pbf/andorra-latest.osm.pbf -o piri4.pbf
osmium extract -p tot.geojson ../pbf/aquitaine-latest.osm.pbf -o piri5.pbf
osmium merge piri1.pbf piri2.pbf piri3.pbf piri4.pbf piri5.pbf --overwrite -o tot_merged.pbf
rm piri1.pbf piri2.pbf piri3.pbf piri4.pbf piri5.pbf 

<!-- osmium tags-filter --overwrite -o tot.pbf tot2.pbf \
    nw/highway=motorway,primary,secondary,tertiary place=city,town,village \
    boundary=administrative,protected_area waterway=river \
    water=river,lake,pond,reservoir r/network=nwn,rwn tourism=alpine_hut -->

gdalwarp -ts 10000 0 -overwrite -co COMPRESS=DEFLATE -co PREDICTOR=2 -co TILED=YES -t_srs EPSG:3857 -r bilinear -cutline tot.geojson -crop_to_cutline ../dem/tot25m/eu_dem_v11_E30N20.TIF dem_tot.tif
gdaldem hillshade -z 1.5 -multidirectional dem_tot.tif shades_tot.tif
gdaldem color-relief -of PNG dem_tot.tif color-relief.txt color_relief.tif


---


> **postgres**
export PGPASSWORD=render_user
cd mnt/dem/
shp2pgsql -d -I -g way -s 3857:900913 contours_est.shp contour | psql -h postgres -U render_user -d render




