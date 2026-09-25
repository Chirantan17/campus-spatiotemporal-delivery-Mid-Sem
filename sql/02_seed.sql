TRUNCATE TABLE location_trace, order_item, "order", menu_item, customer, delivery_location, restaurant, driver, campus_zone RESTART IDENTITY CASCADE;

-- 1. CAMPUS ZONES
INSERT INTO campus_zone (zone_name, boundary) VALUES
('Academic Zone', ST_GeomFromText('POLYGON((78.540 17.520, 78.545 17.520, 78.545 17.525, 78.540 17.525, 78.540 17.520))', 4326)),
('Hostel Zone A', ST_GeomFromText('POLYGON((78.545 17.520, 78.550 17.520, 78.550 17.525, 78.545 17.525, 78.545 17.520))', 4326)),
('Hostel Zone B', ST_GeomFromText('POLYGON((78.545 17.525, 78.550 17.525, 78.550 17.530, 78.545 17.530, 78.545 17.525))', 4326)),
('Sports Complex Zone', ST_GeomFromText('POLYGON((78.535 17.520, 78.540 17.520, 78.540 17.525, 78.535 17.525, 78.535 17.520))', 4326)),
('Faculty Residential Zone', ST_GeomFromText('POLYGON((78.540 17.525, 78.545 17.525, 78.545 17.530, 78.540 17.530, 78.540 17.525))', 4326));

-- 2. DRIVERS
INSERT INTO driver (name, phone, status) VALUES
('Driver A (Ramesh)', '9876543210', 'BUSY'),
('Driver B (Suresh)', '9876543211', 'AVAILABLE'),
('Driver C (Anita)',  '9876543212', 'AVAILABLE'),
('Driver D (Vikram)', '9876543213', 'BUSY'),
('Driver E (Pooja)',  '9876543214', 'AVAILABLE'),
('Driver F (Karan)',  '9876543215', 'OFFLINE');

-- 3. RESTAURANTS
INSERT INTO restaurant (name, phone, location) VALUES
('Canteen 1 (Main Hub)',      '040-11112222', ST_SetSRID(ST_MakePoint(78.5415, 17.5215), 4326)),
('Library Snack Bar',         '040-11112223', ST_SetSRID(ST_MakePoint(78.5435, 17.5235), 4326)),
('Hostel 3 Mess & Cafe',      '040-11112224', ST_SetSRID(ST_MakePoint(78.5475, 17.5225), 4326)),
('Sports Complex Juice Bar',  '040-11112225', ST_SetSRID(ST_MakePoint(78.5375, 17.5220), 4326)),
('Faculty Club Dining',       '040-11112226', ST_SetSRID(ST_MakePoint(78.5425, 17.5275), 4326));

-- 4. DELIVERY DROP-OFF LOCATIONS
INSERT INTO delivery_location (zone_id, name, point) VALUES
(1, 'Academic Block 1 - Main Entrance', ST_SetSRID(ST_MakePoint(78.5410, 17.5210), 4326)),
(1, 'Central Library Lobby',             ST_SetSRID(ST_MakePoint(78.5430, 17.5230), 4326)),
(2, 'Hostel 1 Mess Gate',               ST_SetSRID(ST_MakePoint(78.5460, 17.5210), 4326)),
(2, 'Hostel 3 Common Room',             ST_SetSRID(ST_MakePoint(78.5480, 17.5230), 4326)),
(3, 'Hostel 5 Girls Wing Gate',         ST_SetSRID(ST_MakePoint(78.5470, 17.5270), 4326)),
(3, 'PG Married Hostel Gate',           ST_SetSRID(ST_MakePoint(78.5490, 17.5280), 4326)),
(4, 'Indoor Badminton Court',           ST_SetSRID(ST_MakePoint(78.5380, 17.5210), 4326)),
(4, 'Main Football Ground Pavilion',    ST_SetSRID(ST_MakePoint(78.5360, 17.5240), 4326)),
(5, 'Faculty Quarters Block B',         ST_SetSRID(ST_MakePoint(78.5410, 17.5280), 4326)),
(1, 'Directorate Admin Building',       ST_SetSRID(ST_MakePoint(78.5440, 17.5260), 4326));

-- 5. CUSTOMERS
INSERT INTO customer (name, phone, email) VALUES
('Rahul Sharma',   '9123456701', 'rahul.s@campus.edu'),
('Priya Patel',    '9123456702', 'priya.p@campus.edu'),
('Amit Verma',     '9123456703', 'amit.v@campus.edu'),
('Sneha Reddy',    '9123456704', 'sneha.r@campus.edu'),
('Rohan Gupta',    '9123456705', 'rohan.g@campus.edu'),
('Ananya Roy',     '9123456706', 'ananya.r@campus.edu'),
('Karthik Nair',   '9123456707', 'karthik.n@campus.edu'),
('Divya Joshi',    '9123456708', 'divya.j@campus.edu'),
('Prof. K. Rao',   '9123456709', 'k.rao@campus.edu'),
('Dr. M. Swamy',   '9123456710', 'm.swamy@campus.edu');

-- 6. MENU ITEMS
INSERT INTO menu_item (restaurant_id, name, price, prep_time_minutes) VALUES
(1, 'Paneer Kathi Roll',  120.00, 10),
(1, 'Cold Coffee',         70.00,  5),
(1, 'Veg Cheese Burger',   90.00,  8),
(1, 'Samosa Chat',         60.00,  5),
(1, 'Masala Dosa',         80.00, 12),
(2, 'Espresso Coffee',     60.00,  3),
(2, 'Club Sandwich',      110.00,  7),
(2, 'Chocolate Muffin',    65.00,  2),
(2, 'Iced Lemon Tea',      50.00,  3),
(3, 'Chicken Biryani',    180.00, 15),
(3, 'Butter Chicken Naan', 190.00, 15),
(3, 'Veg Thali',          130.00, 10),
(3, 'Paneer Butter Masala',160.00, 12),
(3, 'Gulab Jamun (2pcs)',  45.00,  2),
(4, 'Fresh Orange Juice',  60.00,  5),
(4, 'Protein Smoothie',   110.00,  5),
(4, 'Fruit Bowl',          80.00,  5),
(4, 'Energy Bar',          40.00,  1),
(5, 'Special South Thali', 150.00, 10),
(5, 'Filter Coffee',       35.00,  3),
(5, 'Mini Tiffin',        100.00,  8),
(5, 'Set Dosa',            75.00,  8),
(5, 'Badam Milk',          50.00,  3);

-- 7. ORDERS
INSERT INTO "order" (customer_id, restaurant_id, driver_id, destination_id, status, created_at, fulfilled_at) VALUES
(1, 1, 1, 3, 'PREPARING',  CURRENT_TIMESTAMP - INTERVAL '20 minutes', NULL),
(2, 2, 2, 2, 'DELIVERED',  CURRENT_TIMESTAMP - INTERVAL '110 minutes', CURRENT_TIMESTAMP - INTERVAL '85 minutes'),
(3, 3, 4, 4, 'IN_TRANSIT', CURRENT_TIMESTAMP - INTERVAL '35 minutes', NULL),
(4, 1, 3, 1, 'DELIVERED',  CURRENT_TIMESTAMP - INTERVAL '180 minutes', CURRENT_TIMESTAMP - INTERVAL '150 minutes'),
(5, 4, 5, 8, 'DELIVERED',  CURRENT_TIMESTAMP - INTERVAL '60 minutes', CURRENT_TIMESTAMP - INTERVAL '40 minutes'),
(6, 3, 1, 5, 'PREPARING',  CURRENT_TIMESTAMP - INTERVAL '15 minutes', NULL),
(7, 2, 2, 6, 'DELIVERED',  CURRENT_TIMESTAMP - INTERVAL '240 minutes', CURRENT_TIMESTAMP - INTERVAL '210 minutes'),
(8, 4, 3, 7, 'DELIVERED',  CURRENT_TIMESTAMP - INTERVAL '90 minutes', CURRENT_TIMESTAMP - INTERVAL '70 minutes'),
(9, 5, 5, 9, 'IN_TRANSIT', CURRENT_TIMESTAMP - INTERVAL '25 minutes', NULL),
(10, 5, 4, 10, 'PENDING',  CURRENT_TIMESTAMP - INTERVAL '5 minutes', NULL);

-- 8. ORDER ITEMS
INSERT INTO order_item (order_id, item_id, quantity, price_at_order) VALUES
(1, 1, 2, 120.00), (1, 2, 1, 70.00),
(2, 6, 1, 60.00),  (2, 7, 1, 110.00), (2, 8, 2, 65.00),
(3, 10, 2, 180.00), (3, 14, 1, 45.00),
(4, 3, 2, 90.00),  (4, 2, 2, 70.00),  (4, 4, 1, 60.00),
(5, 15, 2, 60.00), (5, 17, 1, 80.00),
(6, 11, 1, 190.00), (6, 14, 2, 45.00),
(7, 7, 2, 110.00), (7, 9, 2, 50.00),
(8, 16, 2, 110.00), (8, 18, 3, 40.00),
(9, 19, 1, 150.00), (9, 20, 2, 35.00),
(10, 21, 2, 100.00), (10, 23, 2, 50.00);

-- 9. LOCATION TRACE (1,200 GPS pings)
INSERT INTO location_trace (driver_id, location, recorded_at)
SELECT 
    d.driver_id,
    ST_SetSRID(
        ST_MakePoint(
            78.540 + (random() * 0.010), 
            17.520 + (random() * 0.010)
        ), 
        4326
    ),
    CURRENT_TIMESTAMP - (i || ' seconds')::INTERVAL
FROM generate_series(1, 200) AS i
CROSS JOIN (SELECT driver_id FROM driver WHERE status != 'OFFLINE') d;