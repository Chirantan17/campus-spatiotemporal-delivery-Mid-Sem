-- ============================================================================
-- 2. PURE SPATIAL QUERIES (PostGIS Geometry & Geofencing)
-- ============================================================================

-- Q4.1: Point-in-Polygon Geofence Check - Find all canteens inside 'Academic Zone'
SELECT r.restaurant_id, r.name AS canteen_name, z.zone_name
FROM restaurant r
JOIN campus_zone z ON ST_Contains(z.boundary, r.location)
WHERE z.zone_name = 'Academic Zone';

-- Q4.2: Distance Calculation - Straight-line distance (in meters) between Canteen 1 and Mess Gate
SELECT r.name AS canteen_name, dl.name AS dropoff_point,
       ST_Distance(r.location::geography, dl.point::geography) AS distance_meters
FROM restaurant r, delivery_location dl
WHERE r.name = 'Canteen 1 (Main Hub)' AND dl.name = 'Hostel 1 Mess Gate';

-- Q4.3: Categorize all delivery drop-off points by campus zone geofence
SELECT z.zone_name, dl.name AS dropoff_location_name
FROM campus_zone z
JOIN delivery_location dl ON ST_Contains(z.boundary, dl.point)
ORDER BY z.zone_name;