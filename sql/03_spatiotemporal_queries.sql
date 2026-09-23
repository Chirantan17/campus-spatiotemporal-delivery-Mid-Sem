-- ============================================================================
-- CS G516: Baseline SQL Workload Suite (Q1 - Q8)
-- ============================================================================

-- Q1: Fetch full menu catalog for a restaurant (Operational)
SELECT mi.item_id, mi.name AS item_name, mi.price, mi.prep_time_minutes, r.name AS restaurant_name
FROM menu_item mi
JOIN restaurant r ON mi.restaurant_id = r.restaurant_id
WHERE r.name = 'Canteen 1 (Main Hub)';

-- Q2: Find all food stalls located within the 'Academic Zone' geofence (Spatial)
SELECT r.restaurant_id, r.name AS restaurant_name, z.zone_name
FROM restaurant r
JOIN campus_zone z ON ST_Contains(z.boundary, r.location)
WHERE z.zone_name = 'Academic Zone';

-- Q3: Retrieve order history within a peak temporal window (Temporal)
SELECT o.order_id, c.name AS customer_name, r.name AS restaurant_name, o.status, o.created_at
FROM "order" o
JOIN customer c ON o.customer_id = c.customer_id
JOIN restaurant r ON o.restaurant_id = r.restaurant_id
WHERE o.created_at >= CURRENT_TIMESTAMP - INTERVAL '1 hour';

-- Q4: Automated Pickup Geofence Check - Detect drivers within 30m of canteen (Spatio-Temporal)
SELECT DISTINCT o.order_id, d.name AS driver_name, r.name AS restaurant_name,
       ST_Distance(lt.location::geography, r.location::geography) AS distance_meters
FROM "order" o
JOIN driver d ON o.driver_id = d.driver_id
JOIN restaurant r ON o.restaurant_id = r.restaurant_id
JOIN location_trace lt ON lt.driver_id = d.driver_id
WHERE o.status = 'PREPARING'
  AND ST_DWithin(lt.location::geography, r.location::geography, 30);

-- Q5: Nearest Available Driver Dispatch via GiST Index KNN Operator (<->) (Spatio-Temporal KNN)
SELECT d.driver_id, d.name AS driver_name,
       lt.location <-> r.location AS spatial_bounding_distance
FROM driver d
JOIN location_trace lt ON d.driver_id = lt.driver_id
CROSS JOIN restaurant r
WHERE r.name = 'Canteen 1 (Main Hub)'
  AND d.status = 'AVAILABLE'
ORDER BY lt.location <-> r.location
LIMIT 1;

-- Q6: Two-Leg Delivery Route Distance Calculation (Spatio-Temporal)
SELECT o.order_id, d.name AS driver_name, r.name AS restaurant_name, dl.name AS destination_name,
       ST_Distance(lt.location::geography, r.location::geography) AS driver_to_pickup_meters,
       ST_Distance(r.location::geography, dl.point::geography) AS pickup_to_dropoff_meters,
       (ST_Distance(lt.location::geography, r.location::geography) + ST_Distance(r.location::geography, dl.point::geography)) AS total_route_meters
FROM "order" o
JOIN driver d ON o.driver_id = d.driver_id
JOIN restaurant r ON o.restaurant_id = r.restaurant_id
JOIN delivery_location dl ON o.destination_id = dl.location_id
JOIN location_trace lt ON lt.driver_id = d.driver_id
WHERE o.status = 'PREPARING';

-- Q7: Campus Zone Revenue Aggregation (Analytical / Spatial)
SELECT z.zone_name, COUNT(DISTINCT o.order_id) AS total_orders,
       COALESCE(SUM(oi.quantity * oi.price_at_order), 0) AS total_revenue_inr
FROM campus_zone z
LEFT JOIN delivery_location dl ON ST_Contains(z.boundary, dl.point)
LEFT JOIN "order" o ON o.destination_id = dl.location_id
LEFT JOIN order_item oi ON o.order_id = oi.order_id
GROUP BY z.zone_id, z.zone_name
ORDER BY total_revenue_inr DESC;

-- Q8: Average Order Preparation & Delivery Fulfillment Duration (Analytical / Temporal)
SELECT r.name AS restaurant_name,
       COUNT(o.order_id) AS completed_orders,
       AVG(EXTRACT(EPOCH FROM (o.fulfilled_at - o.created_at)) / 60.0) AS avg_fulfillment_minutes
FROM "order" o
JOIN restaurant r ON o.restaurant_id = r.restaurant_id
WHERE o.status = 'DELIVERED'
GROUP BY r.restaurant_id, r.name;