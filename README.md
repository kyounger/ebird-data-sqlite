A repo that will hold my ebird data download utilities

Shell file helps bring your zip download into a sqlite db.

Query here can be run against that db to give you all observations within a max distance of a specified gps coordinate.

```
WITH params AS (
    SELECT 
        36.052833 AS center_lat,
        -94.115258 AS center_lon,
        6371 AS earth_radius_km,  -- Earth's radius in kilometers
        0.201168 AS max_distance_km -- 1/8 mile in kilometers
)
SELECT *
FROM observations, params
WHERE (
    earth_radius_km * ACOS(
        COS(RADIANS(center_lat)) * COS(RADIANS(Latitude)) * COS(RADIANS(center_lon - Longitude)) +
        SIN(RADIANS(center_lat)) * SIN(RADIANS(Latitude))
    )
) <= max_distance_km;
```
