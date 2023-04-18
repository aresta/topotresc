#!/bin/bash

cd /mnt/contours
export PGPASSWORD=render

# import contour lines

# Pirineus + Catalunya
gunzip contours.sql.gz -c | psql -h postgres -U render -d renderdb

# picos
gunzip contours_picos.sql.gz -c | psql -h postgres -U render -d renderdb

# split long contours to improve render performance
echo 'Dividint contours llargs...' 
psql -h postgres -U render -d renderdb -c 'with to_subdivide as (
        delete from contour  
    where ST_NPoints(way) > 800  
    returning id, height, way    
)    
insert into contour (id, height, way)    
    select   
        id, height, ST_Subdivide(way, 800) as way     
    from to_subdivide;'

