-- ============================================================================
-- 3. PURE TEMPORAL QUERIES (Time-Series & Window Aggregations)
-- ============================================================================

-- Q5.1: Retrieve orders placed within the last 2 hours
SELECT o.order_id, c.name AS customer_name, o.status, o.created_at
FROM "order" o
JOIN customer c ON o.customer_id = c.customer_id
WHERE o.created_at >= CURRENT_TIMESTAMP - INTERVAL '2 hours';

-- Q5.2: Fulfillment Duration - Compute average delivery time (in minutes) per canteen
SELECT r.name AS restaurant_name,
       COUNT(o.order_id) AS completed_orders,
       ROUND(AVG(EXTRACT(EPOCH FROM (o.fulfilled_at - o.created_at)) / 60.0)::numeric, 2) AS avg_fulfillment_minutes
FROM "order" o
JOIN restaurant r ON o.restaurant_id = r.restaurant_id
WHERE o.status = 'DELIVERED' AND o.fulfilled_at IS NOT NULL
GROUP BY r.restaurant_id, r.name;

-- Q5.3: Driver Telemetry Frequency - Count GPS telemetry pings per driver in the last hour
SELECT driver_id, COUNT(*) AS total_pings, MAX(recorded_at) AS latest_ping_time
FROM location_trace
WHERE recorded_at >= CURRENT_TIMESTAMP - INTERVAL '1 hour'
GROUP BY driver_id
ORDER BY driver_id;