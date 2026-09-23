-- ============================================================================
-- CS G516: Advanced Database Systems - Studio Schema
-- Target Database: PostgreSQL 15+ with PostGIS 3.3+ Extension
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS postgis;

-- Clean teardown of existing schema
DROP TABLE IF EXISTS location_trace CASCADE;
DROP TABLE IF EXISTS order_item CASCADE;
DROP TABLE IF EXISTS "order" CASCADE;
DROP TABLE IF EXISTS menu_item CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS delivery_location CASCADE;
DROP TABLE IF EXISTS restaurant CASCADE;
DROP TABLE IF EXISTS driver CASCADE;
DROP TABLE IF EXISTS campus_zone CASCADE;

-- 1. Campus Zones (Polygonal Geofences)
CREATE TABLE campus_zone (
    zone_id SERIAL PRIMARY KEY,
    zone_name VARCHAR(100) NOT NULL UNIQUE,
    boundary GEOMETRY(POLYGON, 4326) NOT NULL
);

-- 2. Restaurants / Campus Canteens (Order Origins)
CREATE TABLE restaurant (
    restaurant_id SERIAL PRIMARY KEY,
    zone_id INT NOT NULL REFERENCES campus_zone(zone_id) ON DELETE RESTRICT,
    name VARCHAR(100) NOT NULL,
    location GEOMETRY(POINT, 4326) NOT NULL
);

-- 3. Menu Items Catalog
CREATE TABLE menu_item (
    item_id SERIAL PRIMARY KEY,
    restaurant_id INT NOT NULL REFERENCES restaurant(restaurant_id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    prep_time_minutes INT NOT NULL DEFAULT 15 CHECK (prep_time_minutes > 0)
);

-- 4. Customers
CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE
);

-- 5. Delivery Drop-Off Locations
CREATE TABLE delivery_location (
    location_id SERIAL PRIMARY KEY,
    zone_id INT NOT NULL REFERENCES campus_zone(zone_id) ON DELETE RESTRICT,
    name VARCHAR(100) NOT NULL,
    point GEOMETRY(POINT, 4326) NOT NULL
);

-- 6. Drivers
CREATE TABLE driver (
    driver_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('AVAILABLE', 'PICKING_UP', 'EN_ROUTE', 'OFFLINE')) DEFAULT 'AVAILABLE'
);

-- 7. Orders Transactional Table
CREATE TABLE "order" (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customer(customer_id) ON DELETE RESTRICT,
    restaurant_id INT NOT NULL REFERENCES restaurant(restaurant_id) ON DELETE RESTRICT,
    driver_id INT REFERENCES driver(driver_id) ON DELETE SET NULL,
    destination_id INT NOT NULL REFERENCES delivery_location(location_id) ON DELETE RESTRICT,
    status VARCHAR(20) NOT NULL CHECK (status IN ('PENDING', 'PREPARING', 'PICKED_UP', 'EN_ROUTE', 'DELIVERED', 'CANCELLED')) DEFAULT 'PENDING',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    fulfilled_at TIMESTAMP WITH TIME ZONE
);

-- 8. Order Line Items Junction
CREATE TABLE order_item (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES "order"(order_id) ON DELETE CASCADE,
    item_id INT NOT NULL REFERENCES menu_item(item_id) ON DELETE RESTRICT,
    quantity INT NOT NULL CHECK (quantity > 0),
    price_at_order NUMERIC(10, 2) NOT NULL CHECK (price_at_order >= 0)
);

-- 9. Append-Only Location Trace (GPS Telemetry Stream)
CREATE TABLE location_trace (
    trace_id BIGSERIAL PRIMARY KEY,
    driver_id INT NOT NULL REFERENCES driver(driver_id) ON DELETE CASCADE,
    location GEOMETRY(POINT, 4326) NOT NULL,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Spatial GiST Indexes
CREATE INDEX idx_campus_zone_boundary ON campus_zone USING GIST (boundary);
CREATE INDEX idx_restaurant_location ON restaurant USING GIST (location);
CREATE INDEX idx_delivery_location_point ON delivery_location USING GIST (point);
CREATE INDEX idx_location_trace_location ON location_trace USING GIST (location);
CREATE INDEX idx_location_trace_driver_time ON location_trace (driver_id, recorded_at DESC);