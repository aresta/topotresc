#!/bin/bash

cd /mnt/contours
export PGPASSWORD=render

# append contour lines

# tot
shp2pgsql -d -I -g way -s 3857:900913 contours_test_simpl.shp contour | psql -h postgres -U render -d renderdb

# split long contours to improve render performance
echo 'Dividint contours llargs...' 
psql -h postgres -U render -d renderdb -c 'with to_subdivide as (    
    delete from contour 
    where ST_NPoints(way) > 800 
    returning id, height, way   
)   
insert into contour (id, height, way)   
    select  
        id, height, st_multi( ST_Subdivide(way, 800)) as way    
    from to_subdivide;'
