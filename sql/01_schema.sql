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
DROP VIEW IF EXISTS integrity_audit CASCADE;
DROP VIEW IF EXISTS order_total CASCADE;

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
    phone VARCHAR(20) UNIQUE,
    status VARCHAR(20) DEFAULT 'AVAILABLE' CHECK (status IN ('AVAILABLE', 'BUSY', 'OFFLINE'))
);

-- 3. Restaurants & Messes
CREATE TABLE restaurant (
    restaurant_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    facility_type VARCHAR(20) DEFAULT 'Canteen' CHECK (facility_type IN ('Canteen', 'Mess')),
    target_demographic VARCHAR(50) DEFAULT 'All',
    student_rating NUMERIC(3, 2) CHECK (student_rating >= 1.00 AND student_rating <= 5.00),
    phone VARCHAR(20) UNIQUE,
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
    phone VARCHAR(20) UNIQUE,
    email VARCHAR(100)
);

-- 6. Menu Items
CREATE TABLE menu_item (
    item_id SERIAL PRIMARY KEY,
    restaurant_id INT REFERENCES restaurant(restaurant_id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) DEFAULT 'General',
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    serve_start_time TIME NOT NULL DEFAULT '06:00:00',
    serve_end_time TIME NOT NULL DEFAULT '22:00:00',
    prep_time_minutes INT DEFAULT 10,
    UNIQUE (item_id, restaurant_id) 
);

-- 7. Orders
CREATE TABLE "order" (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customer(customer_id) ON DELETE RESTRICT,
    restaurant_id INT REFERENCES restaurant(restaurant_id) ON DELETE RESTRICT,
    driver_id INT REFERENCES driver(driver_id) ON DELETE SET NULL,
    destination_id INT REFERENCES delivery_location(location_id) ON DELETE RESTRICT,
    status VARCHAR(20) NOT NULL CHECK (status IN ('PENDING', 'PREPARING', 'IN_TRANSIT', 'DELIVERED', 'CANCELLED')),
    delivery_fee NUMERIC(10, 2) DEFAULT 0.00 CHECK (delivery_fee >= 0),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    fulfilled_at TIMESTAMPTZ,
    UNIQUE (order_id, restaurant_id)
);

-- 8. Order Line Items
CREATE TABLE order_item (
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    restaurant_id INT NOT NULL, 
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0 AND quantity <= 50),
    price_at_order NUMERIC(10, 2) NOT NULL CHECK (price_at_order >= 0),
    PRIMARY KEY (order_id, item_id),
    FOREIGN KEY (order_id, restaurant_id) REFERENCES "order" (order_id, restaurant_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id, restaurant_id) REFERENCES menu_item (item_id, restaurant_id) ON DELETE RESTRICT
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

-- ============================================================================
-- BUSINESS VIEWS & AUDITS
-- ============================================================================

-- A. Order Total View (Eliminates storing redundant totals)
CREATE VIEW order_total AS
SELECT o.order_id,
       COALESCE(SUM(oi.quantity * oi.price_at_order), 0) + o.delivery_fee AS total_amount
FROM "order" o
LEFT JOIN order_item oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.delivery_fee;

-- B. System Integrity Audit View (Diagnostic Tool for IC Walkthrough)
CREATE VIEW integrity_audit AS
-- 1. Orders missing line items
SELECT 'Order Missing Items' AS violation, order_id::text AS detail
FROM "order" o
WHERE NOT EXISTS (SELECT 1 FROM order_item oi WHERE oi.order_id = o.order_id)
UNION ALL
-- 2. Spatial inconsistency
SELECT 'Spatial Inconsistency (Drop-off outside zone)' AS violation, dl.name AS detail
FROM delivery_location dl
JOIN campus_zone z ON dl.zone_id = z.zone_id
WHERE NOT ST_Covers(z.boundary, dl.point)
UNION ALL
-- 3. Driver state mismatch (Active order but driver is not busy/available correctly)
SELECT 'Driver State Mismatch' AS violation, d.name AS detail
FROM "order" o
JOIN driver d ON o.driver_id = d.driver_id
WHERE o.status IN ('PENDING', 'PREPARING', 'IN_TRANSIT') AND d.status = 'OFFLINE';

-- ============================================================================
-- PREVENTATIVE IUD TRIGGERS
-- ============================================================================

-- 1. Order Guard: Prevents editing closed orders
CREATE OR REPLACE FUNCTION order_lifecycle_guard() RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IN ('DELIVERED', 'CANCELLED') THEN
        RAISE EXCEPTION 'Update Anomaly: Cannot modify an already closed order.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER order_guard
BEFORE UPDATE ON "order"
FOR EACH ROW EXECUTE FUNCTION order_lifecycle_guard();

-- 2. Trace Append-Only: Prevents historical GPS tampering
CREATE OR REPLACE FUNCTION prevent_trace_update_delete() RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Update/Delete Anomaly: Location traces are immutable telemetry and cannot be edited.';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trace_append_only
BEFORE UPDATE OR DELETE ON location_trace
FOR EACH ROW EXECUTE FUNCTION prevent_trace_update_delete();