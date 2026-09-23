-- ============================================================================
-- CS G516: Seed Script (Deterministic Entities + Synthetic Telemetry Generator)
-- ============================================================================

TRUNCATE campus_zone, restaurant, menu_item, customer, delivery_location, driver, "order", order_item, location_trace RESTART IDENTITY CASCADE;

-- 1. Campus Zones
INSERT INTO campus_zone (zone_name, boundary) VALUES
('Hostel Block',       ST_GeomFromText('POLYGON((78.348 17.455, 78.352 17.455, 78.352 17.458, 78.348 17.458, 78.348 17.455))', 4326)),
('Academic Zone',      ST_GeomFromText('POLYGON((78.352 17.455, 78.356 17.455, 78.356 17.458, 78.352 17.458, 78.352 17.455))', 4326)),
('Sports & Food Hub',  ST_GeomFromText('POLYGON((78.348 17.451, 78.352 17.451, 78.352 17.454, 78.348 17.454, 78.348 17.451))', 4326));

-- 2. Restaurants
INSERT INTO restaurant (zone_id, name, location) VALUES
(3, 'Canteen 1 (Main Hub)', ST_SetSRID(ST_MakePoint(78.350, 17.452), 4326)),
(2, 'Library Snack Bar',     ST_SetSRID(ST_MakePoint(78.354, 17.456), 4326)),
(1, 'Hostel 1 Night Mess',   ST_SetSRID(ST_MakePoint(78.349, 17.457), 4326));

-- 3. Menu Items
INSERT INTO menu_item (restaurant_id, name, price, prep_time_minutes) VALUES
(1, 'Paneer Roll', 120.00, 10),
(1, 'Cold Coffee', 70.00, 5),
(2, 'Samosa Chat', 50.00, 8),
(3, 'Chicken Biryani', 180.00, 15);

-- 4. Customers
INSERT INTO customer (name, phone) VALUES
('Rahul Sharma',  '+919876543210'),
('Priya Patel',   '+919876543211'),
('Ananya Gupta',  '+919876543212');

-- 5. Delivery Drop-Off Locations
INSERT INTO delivery_location (zone_id, name, point) VALUES
(1, 'Hostel 1 Mess Gate',  ST_SetSRID(ST_MakePoint(78.349, 17.456), 4326)),
(1, 'Hostel 4 Common Room', ST_SetSRID(ST_MakePoint(78.351, 17.457), 4326)),
(2, 'Lecture Hall 2 Entrance', ST_SetSRID(ST_MakePoint(78.355, 17.456), 4326));

-- 6. Drivers
INSERT INTO driver (name, status) VALUES
('Driver A (Ramesh)', 'EN_ROUTE'),
('Driver B (Suresh)', 'AVAILABLE'),
('Driver C (Anita)',  'AVAILABLE');

-- 7. Orders
INSERT INTO "order" (customer_id, restaurant_id, driver_id, destination_id, status, created_at, fulfilled_at) VALUES
(1, 1, 1, 1, 'PREPARING', CURRENT_TIMESTAMP - INTERVAL '15 minutes', NULL),
(2, 2, 2, 3, 'DELIVERED', CURRENT_TIMESTAMP - INTERVAL '45 minutes', CURRENT_TIMESTAMP - INTERVAL '20 minutes');

-- 8. Order Items
INSERT INTO order_item (order_id, item_id, quantity, price_at_order) VALUES
(1, 1, 2, 120.00),
(1, 2, 1, 70.00),
(2, 3, 2, 50.00);

-- 9. Base Telemetry Pings
INSERT INTO location_trace (driver_id, location, recorded_at) VALUES
(1, ST_SetSRID(ST_MakePoint(78.3501, 17.4521), 4326), CURRENT_TIMESTAMP - INTERVAL '2 minutes'),
(2, ST_SetSRID(ST_MakePoint(78.3540, 17.4560), 4326), CURRENT_TIMESTAMP - INTERVAL '5 minutes'),
(3, ST_SetSRID(ST_MakePoint(78.3490, 17.4520), 4326), CURRENT_TIMESTAMP - INTERVAL '1 minute');

-- 10. Synthetic Telemetry Generator (1,000 Pings)
INSERT INTO location_trace (driver_id, location, recorded_at)
SELECT 
    (floor(random() * 3) + 1)::int AS driver_id,
    ST_SetSRID(
        ST_MakePoint(
            78.348 + (random() * 0.008),
            17.451 + (random() * 0.007)
        ), 
        4326
    ) AS location,
    CURRENT_TIMESTAMP - (random() * INTERVAL '2 hours') AS recorded_at
FROM generate_series(1, 1000);