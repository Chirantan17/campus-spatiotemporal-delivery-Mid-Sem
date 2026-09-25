-- Enable PostGIS spatial extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- Drop tables in clean cascade sequence
DROP TABLE IF EXISTS location_trace CASCADE;
DROP TABLE IF EXISTS order_item CASCADE;
DROP TABLE IF EXISTS "order" CASCADE;
DROP TABLE IF EXISTS menu_item CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS delivery_location CASCADE;
DROP TABLE IF EXISTS restaurant CASCADE;
DROP TABLE IF EXISTS driver CASCADE;
DROP TABLE IF EXISTS campus_zone CASCADE;

-- 1. Campus Zones (Geofences)
CREATE TABLE campus_zone (
    zone_id SERIAL PRIMARY KEY,
    zone_name VARCHAR(100) NOT NULL,
    boundary GEOMETRY(Polygon, 4326) NOT NULL
);

-- 2. Drivers
CREATE TABLE driver (
    driver_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    status VARCHAR(20) DEFAULT 'AVAILABLE' CHECK (status IN ('AVAILABLE', 'BUSY', 'OFFLINE'))
);

-- 3. Restaurants / Canteens
CREATE TABLE restaurant (
    restaurant_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    location GEOMETRY(Point, 4326) NOT NULL
);

-- 4. Delivery Drop-Off Locations
CREATE TABLE delivery_location (
    location_id SERIAL PRIMARY KEY,
    zone_id INT REFERENCES campus_zone(zone_id) ON DELETE SET NULL,
    name VARCHAR(100) NOT NULL,
    point GEOMETRY(Point, 4326) NOT NULL
);

-- 5. Customers
CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100)
);

-- 6. Menu Items
CREATE TABLE menu_item (
    item_id SERIAL PRIMARY KEY,
    restaurant_id INT REFERENCES restaurant(restaurant_id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    prep_time_minutes INT DEFAULT 10
);

-- 7. Orders
CREATE TABLE "order" (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customer(customer_id) ON DELETE CASCADE,
    restaurant_id INT REFERENCES restaurant(restaurant_id) ON DELETE CASCADE,
    driver_id INT REFERENCES driver(driver_id) ON DELETE SET NULL,
    destination_id INT REFERENCES delivery_location(location_id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('PENDING', 'PREPARING', 'IN_TRANSIT', 'DELIVERED', 'CANCELLED')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    fulfilled_at TIMESTAMPTZ
);

-- 8. Order Line Items
CREATE TABLE order_item (
    order_id INT REFERENCES "order"(order_id) ON DELETE CASCADE,
    item_id INT REFERENCES menu_item(item_id) ON DELETE CASCADE,
    quantity INT NOT NULL DEFAULT 1,
    price_at_order NUMERIC(10, 2) NOT NULL,
    PRIMARY KEY (order_id, item_id)
);

-- 9. GPS Telemetry Trace
CREATE TABLE location_trace (
    trace_id SERIAL PRIMARY KEY,
    driver_id INT REFERENCES driver(driver_id) ON DELETE CASCADE,
    location GEOMETRY(Point, 4326) NOT NULL,
    recorded_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Spatial Indexes
CREATE INDEX idx_campus_zone_boundary ON campus_zone USING GIST (boundary);
CREATE INDEX idx_restaurant_location ON restaurant USING GIST (location);
CREATE INDEX idx_delivery_location_point ON delivery_location USING GIST (point);
CREATE INDEX idx_location_trace_location ON location_trace USING GIST (location);