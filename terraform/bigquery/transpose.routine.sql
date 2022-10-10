-- This SQL file goes unused because of the terraform configuration, but this is
-- left for documentation purposes.
CREATE OR REPLACE FUNCTION mvtm.transpose(datum STRING) 
RETURNS ARRAY<STRUCT<role STRING, name STRING>> 
LANGUAGE js AS """
return Object.entries(JSON.parse(datum)).map(([key, value]) => ({role: key, name: value}))
""";