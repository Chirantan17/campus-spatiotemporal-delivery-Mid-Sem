TRUNCATE TABLE location_trace, order_item, "order", menu_item, customer, delivery_location, restaurant, driver, campus_zone RESTART IDENTITY CASCADE;

-- 1. CAMPUS ZONES (Geofences)
INSERT INTO campus_zone (zone_name, boundary) VALUES
('Academic Zone', ST_GeomFromText('POLYGON((78.540 17.520, 78.545 17.520, 78.545 17.525, 78.540 17.525, 78.540 17.520))', 4326)),
('Hostel Zone A', ST_GeomFromText('POLYGON((78.545 17.520, 78.550 17.520, 78.550 17.525, 78.545 17.525, 78.545 17.520))', 4326)),
('Hostel Zone B', ST_GeomFromText('POLYGON((78.545 17.525, 78.550 17.525, 78.550 17.530, 78.545 17.530, 78.545 17.525))', 4326)),
('Sports Complex Zone', ST_GeomFromText('POLYGON((78.535 17.520, 78.540 17.520, 78.540 17.525, 78.535 17.525, 78.535 17.520))', 4326)),
('Faculty Residential Zone', ST_GeomFromText('POLYGON((78.540 17.525, 78.545 17.525, 78.545 17.530, 78.540 17.530, 78.540 17.525))', 4326)),
('Staff Quarters Zone', ST_GeomFromText('POLYGON((78.530 17.525, 78.535 17.525, 78.535 17.530, 78.530 17.530, 78.530 17.525))', 4326));

-- 2. DRIVERS
INSERT INTO driver (name, phone, status) VALUES
('Driver A (Ramesh)', '9876543210', 'BUSY'),
('Driver B (Suresh)', '9876543211', 'AVAILABLE'),
('Driver C (Anita)',  '9876543212', 'AVAILABLE'),
('Driver D (Vikram)', '9876543213', 'BUSY'),
('Driver E (Pooja)',  '9876543214', 'AVAILABLE'),
('Driver F (Karan)',  '9876543215', 'OFFLINE');

-- 3. RESTAURANTS & MESSES
INSERT INTO restaurant (name, facility_type, target_demographic, student_rating, phone, location) VALUES
('Canteen 1 (Main Hub)',      'Canteen', 'All', 4.5, '040-11112222', ST_SetSRID(ST_MakePoint(78.5415, 17.5215), 4326)),
('Library Snack Bar',         'Canteen', 'All', 4.2, '040-11112223', ST_SetSRID(ST_MakePoint(78.5435, 17.5235), 4326)),
('Hostel 3 Mess & Cafe',      'Canteen', 'All', 3.9, '040-11112224', ST_SetSRID(ST_MakePoint(78.5475, 17.5225), 4326)),
('Sports Complex Juice Bar',  'Canteen', 'All', 4.6, '040-11112225', ST_SetSRID(ST_MakePoint(78.5375, 17.5220), 4326)),
('Faculty Club Dining',       'Canteen', 'Faculty', 4.8, '040-11112226', ST_SetSRID(ST_MakePoint(78.5425, 17.5275), 4326)),
('Mess 1 (1st & 2nd Year)',   'Mess', '1st/2nd Year', 2.1, '040-22223331', ST_SetSRID(ST_MakePoint(78.5465, 17.5215), 4326)), 
('Mess 2 (3rd & 4th Year)',   'Mess', '3rd/4th Year', 3.8, '040-22223332', ST_SetSRID(ST_MakePoint(78.5475, 17.5285), 4326)),
('Mess 3 (Girls Hostel)',     'Mess', 'Girls', 4.2, '040-22223333', ST_SetSRID(ST_MakePoint(78.5485, 17.5265), 4326));

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
(1, 'Directorate Admin Building',       ST_SetSRID(ST_MakePoint(78.5440, 17.5260), 4326)),
(6, 'Staff Quarters Block C',           ST_SetSRID(ST_MakePoint(78.5325, 17.5275), 4326));

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
INSERT INTO menu_item (restaurant_id, name, category, price, serve_start_time, serve_end_time, prep_time_minutes) VALUES
(1, 'Paneer Kathi Roll',  'General', 120.00, '06:00:00', '22:00:00', 10),
(1, 'Cold Coffee',         'General',  70.00, '06:00:00', '22:00:00', 5),
(1, 'Veg Cheese Burger',   'General',  90.00, '06:00:00', '22:00:00', 8),
(1, 'Samosa Chat',         'General',  60.00, '06:00:00', '22:00:00', 5),
(1, 'Masala Dosa',         'General',  80.00, '06:00:00', '11:00:00', 12),
(2, 'Espresso Coffee',     'General',  60.00, '08:00:00', '20:00:00', 3),
(2, 'Club Sandwich',      'General', 110.00, '08:00:00', '20:00:00', 7),
(2, 'Chocolate Muffin',    'General',  65.00, '08:00:00', '20:00:00', 2),
(2, 'Iced Lemon Tea',      'General',  50.00, '08:00:00', '20:00:00', 3),
(3, 'Chicken Biryani',    'General', 180.00, '12:00:00', '22:00:00', 15),
(3, 'Butter Chicken Naan', 'General', 190.00, '12:00:00', '22:00:00', 15),
(3, 'Veg Thali',          'General', 130.00, '12:00:00', '15:30:00', 10),
(3, 'Paneer Butter Masala','General', 160.00, '12:00:00', '22:00:00', 12),
(3, 'Gulab Jamun (2pcs)',  'General',  45.00, '12:00:00', '22:00:00', 2),
(4, 'Fresh Orange Juice',  'General',  60.00, '06:00:00', '21:00:00', 5),
(4, 'Protein Smoothie',   'General', 110.00, '06:00:00', '21:00:00', 5),
(4, 'Fruit Bowl',          'General',  80.00, '06:00:00', '21:00:00', 5),
(4, 'Energy Bar',          'General',  40.00, '06:00:00', '21:00:00', 1),
(5, 'Special South Thali', 'General', 150.00, '12:00:00', '15:00:00', 10),
(5, 'Filter Coffee',       'General',  35.00, '07:00:00', '18:00:00', 3),
(5, 'Mini Tiffin',        'General', 100.00, '07:00:00', '11:00:00', 8),
(5, 'Set Dosa',            'General',  75.00, '07:00:00', '11:00:00', 8),
(5, 'Badam Milk',          'General',  50.00, '07:00:00', '18:00:00', 3),
(1, 'Double Egg Roll',              'Snack',            60.00, '16:00:00', '20:00:00', 8),
(1, 'Chicken Tikka Roll',           'Snack',            90.00, '16:00:00', '20:00:00', 10),
(4, 'Seasonal Watermelon Bowl',     'Healthy_Seasonal', 70.00, '06:00:00', '21:00:00', 5),
(4, 'High-Protein Grilled Chicken', 'Healthy_Protein', 140.00, '12:00:00', '21:00:00', 15);

-- 7. ORDERS
INSERT INTO "order" (customer_id, restaurant_id, driver_id, destination_id, status, delivery_fee, created_at, fulfilled_at) VALUES
(1, 1, 1, 3, 'PREPARING',  0.00, CURRENT_TIMESTAMP - INTERVAL '20 minutes', NULL),
(2, 2, 2, 2, 'DELIVERED',  0.00, CURRENT_TIMESTAMP - INTERVAL '110 minutes', CURRENT_TIMESTAMP - INTERVAL '85 minutes'),
(3, 3, 4, 4, 'IN_TRANSIT', 0.00, CURRENT_TIMESTAMP - INTERVAL '35 minutes', NULL),
(4, 1, 3, 1, 'DELIVERED',  0.00, CURRENT_TIMESTAMP - INTERVAL '180 minutes', CURRENT_TIMESTAMP - INTERVAL '150 minutes'),
(5, 4, 5, 8, 'DELIVERED',  0.00, CURRENT_TIMESTAMP - INTERVAL '60 minutes', CURRENT_TIMESTAMP - INTERVAL '40 minutes'),
(6, 3, 1, 5, 'PREPARING',  0.00, CURRENT_TIMESTAMP - INTERVAL '15 minutes', NULL),
(7, 2, 2, 6, 'DELIVERED',  0.00, CURRENT_TIMESTAMP - INTERVAL '240 minutes', CURRENT_TIMESTAMP - INTERVAL '210 minutes'),
(8, 4, 3, 7, 'DELIVERED',  0.00, CURRENT_TIMESTAMP - INTERVAL '90 minutes', CURRENT_TIMESTAMP - INTERVAL '70 minutes'),
(9, 5, 5, 9, 'IN_TRANSIT', 0.00, CURRENT_TIMESTAMP - INTERVAL '25 minutes', NULL),
(10, 1, NULL, 3, 'PENDING', 0.00, CURRENT_TIMESTAMP - INTERVAL '5 minutes', NULL), 
(4, 1, 3, 1, 'CANCELLED', 0.00, CURRENT_TIMESTAMP - INTERVAL '45 minutes', NULL),
(9, 4, 2, 11, 'PREPARING', 25.00, CURRENT_TIMESTAMP - INTERVAL '8 minutes', NULL),
(1, 1, 3, 11, 'DELIVERED', 45.50, CURRENT_TIMESTAMP - INTERVAL '300 minutes', CURRENT_TIMESTAMP - INTERVAL '260 minutes');

-- 8. ORDER ITEMS 
INSERT INTO order_item (order_id, item_id, restaurant_id, quantity, price_at_order) VALUES
(1, 1, 1, 2, 120.00), (1, 2, 1, 1, 70.00),
(2, 6, 2, 1, 60.00),  (2, 7, 2, 1, 110.00), (2, 8, 2, 2, 65.00),
(3, 10, 3, 2, 180.00), (3, 14, 3, 1, 45.00),
(4, 3, 1, 2, 90.00),  (4, 2, 1, 2, 70.00),  (4, 4, 1, 1, 60.00),
(5, 15, 4, 2, 60.00), (5, 17, 4, 1, 80.00),
(6, 11, 3, 1, 190.00), (6, 14, 3, 2, 45.00),
(7, 7, 2, 2, 110.00), (7, 9, 2, 2, 50.00),
(8, 16, 4, 2, 110.00), (8, 18, 4, 3, 40.00),
(9, 19, 5, 1, 150.00), (9, 20, 5, 2, 35.00),
(10, 1, 1, 1, 120.00), (10, 2, 1, 2, 70.00),
(11, 3, 1, 1, 90.00),
(12, 16, 4, 2, 110.00),
(13, 25, 1, 1, 135.00); 

-- 9. LOCATION TRACE
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

-- 10. The Intentional "Ghost Driver" Anomaly (To be caught by the Audit View!)
UPDATE driver SET status = 'OFFLINE' WHERE driver_id = 1;