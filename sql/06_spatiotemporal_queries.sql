-- ============================================================================
-- 4. SPATIO-TEMPORAL QUERIES (Combined Spatial & Temporal Constraints)
-- ============================================================================

-- Q6.1: Automated Pickup Geofence Check - Detect drivers within 30m of canteen for active orders (uses latest telemetry ping)
WITH latest_telemetry AS (
    SELECT DISTINCT ON (driver_id) driver_id, location, recorded_at
    FROM location_trace
    ORDER BY driver_id, recorded_at DESC
)
SELECT DISTINCT o.order_id, d.name AS driver_name, r.name AS canteen_name,
       ROUND(ST_Distance(lt.location::geography, r.location::geography)::numeric, 2) AS distance_meters,
       lt.recorded_at AS ping_time
FROM "order" o
JOIN driver d ON o.driver_id = d.driver_id
JOIN restaurant r ON o.restaurant_id = r.restaurant_id
JOIN latest_telemetry lt ON lt.driver_id = d.driver_id
WHERE o.status = 'PREPARING'
  AND ST_DWithin(lt.location::geography, r.location::geography, 30);

-- Q6.2: Nearest Available Driver Dispatch via GiST Index KNN Operator (<->) on LATEST telemetry ping
WITH latest_telemetry AS (
    SELECT DISTINCT ON (driver_id) driver_id, location, recorded_at
    FROM location_trace
    ORDER BY driver_id, recorded_at DESC
)
SELECT d.driver_id, d.name AS driver_name, d.status,
       lt.location <-> r.location AS spatial_bounding_distance
FROM driver d
JOIN latest_telemetry lt ON d.driver_id = lt.driver_id
CROSS JOIN restaurant r
WHERE r.name = 'Canteen 1 (Main Hub)'
  AND d.status = 'AVAILABLE'
ORDER BY lt.location <-> r.location
LIMIT 1;

-- Q6.3: Two-Leg Delivery Route Distance (Driver -> Canteen Pickup -> Drop-Off) using LATEST telemetry ping
WITH latest_telemetry AS (
    SELECT DISTINCT ON (driver_id) driver_id, location, recorded_at
    FROM location_trace
    ORDER BY driver_id, recorded_at DESC
)
SELECT o.order_id, d.name AS driver_name, r.name AS canteen_name, dl.name AS destination,
       ROUND(ST_Distance(lt.location::geography, r.location::geography)::numeric, 2) AS driver_to_canteen_m,
       ROUND(ST_Distance(r.location::geography, dl.point::geography)::numeric, 2) AS canteen_to_dropoff_m,
       ROUND((ST_Distance(lt.location::geography, r.location::geography) + ST_Distance(r.location::geography, dl.point::geography))::numeric, 2) AS total_route_m
FROM "order" o
JOIN driver d ON o.driver_id = d.driver_id
JOIN restaurant r ON o.restaurant_id = r.restaurant_id
JOIN delivery_location dl ON o.destination_id = dl.location_id
JOIN latest_telemetry lt ON lt.driver_id = d.driver_id
WHERE o.status = 'PREPARING';

-- Q6.4: Spatio-Temporal Zone Revenue Analysis - Revenue generated per zone (Excludes CANCELLED and PENDING orders)
SELECT z.zone_name, 
       COUNT(DISTINCT o.order_id) AS total_delivered_orders,
       COALESCE(SUM(oi.quantity * oi.price_at_order), 0) AS revenue_inr
FROM campus_zone z
LEFT JOIN delivery_location dl ON ST_Contains(z.boundary, dl.point)
LEFT JOIN "order" o ON o.destination_id = dl.location_id AND o.status = 'DELIVERED'
LEFT JOIN order_item oi ON o.order_id = oi.order_id
GROUP BY z.zone_id, z.zone_name
ORDER BY revenue_inr DESC;

-- ============================================================================
-- FLAGSHIP SPATIO-TEMPORAL AGGREGATION
-- ============================================================================

-- Q6.5: Continuous Trajectory Synthesis - Reconstruct full driver travel path (LINESTRING) from discrete pings
SELECT d.driver_id,
       d.name AS driver_name,
       COUNT(lt.trace_id) AS total_telemetry_pings,
       MIN(lt.recorded_at) AS trip_start_time,
       MAX(lt.recorded_at) AS trip_end_time,
       ST_MakeLine(lt.location ORDER BY lt.recorded_at) AS continuous_trajectory_geom,
       ROUND((ST_Length(ST_MakeLine(lt.location ORDER BY lt.recorded_at)::geography))::numeric, 2) AS total_distance_covered_meters
FROM driver d
JOIN location_trace lt ON d.driver_id = lt.driver_id
GROUP BY d.driver_id, d.name
HAVING COUNT(lt.trace_id) > 1
ORDER BY d.driver_id;