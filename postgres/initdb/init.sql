-- Database is already created by the environment params in docker:
--      POSTGRES_USER
--      POSTGRES_PASSWORD
--      POSTGRES_DB

-- Warning: make sure that the folder postgres/data is empty!  Remove all .DS_Store .git files.

-- Geospatially enable the new database (not sure if needed)
CREATE EXTENSION postgis;
CREATE EXTENSION hstore;
ALTER TABLE geometry_columns OWNER TO render;
ALTER TABLE spatial_ref_sys OWNER TO render;