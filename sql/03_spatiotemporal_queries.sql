-- Query 1: Find delivery locations inside 'Hostel Block' (ST_Contains)
SELECT d.name AS location_name, z.zone_name
FROM delivery_location d
JOIN campus_zone z ON ST_Contains(z.boundary, d.point)
WHERE z.zone_name = 'Hostel Block';

-- Query 2: Find active drivers within 500 meters of Hostel 1 Mess (ST_DWithin)
SELECT dr.name AS driver_name, 
       ST_Distance(lt.location::geography, dl.point::geography) AS distance_meters
FROM location_trace lt
JOIN driver dr ON lt.driver_id = dr.driver_id
CROSS JOIN delivery_location dl
WHERE dl.name = 'Hostel 1 Mess'
  AND ST_DWithin(lt.location::geography, dl.point::geography, 500);

-- Query 3: Find Nearest Driver to Library Gate using KNN Operator (<->)
SELECT dr.name AS nearest_driver,
       lt.location <-> dl.point AS spatial_distance
FROM location_trace lt
JOIN driver dr ON lt.driver_id = dr.driver_id
CROSS JOIN delivery_location dl
WHERE dl.name = 'Library Gate'
ORDER BY lt.location <-> dl.point
LIMIT 1;
