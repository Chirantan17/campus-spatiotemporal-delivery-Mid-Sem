CREATE EXTENSION IF NOT EXISTS postgis;

DROP TABLE IF EXISTS location_trace CASCADE;
DROP TABLE IF EXISTS "order" CASCADE;
DROP TABLE IF EXISTS driver CASCADE;
DROP TABLE IF EXISTS delivery_location CASCADE;
DROP TABLE IF EXISTS campus_zone CASCADE;

CREATE TABLE campus_zone (
    zone_id SERIAL PRIMARY KEY,
    zone_name VARCHAR(100) NOT NULL,
    boundary GEOMETRY(POLYGON, 4326) NOT NULL
);

CREATE TABLE delivery_location (
    location_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    zone_id INT REFERENCES campus_zone(zone_id),
    point GEOMETRY(POINT, 4326) NOT NULL
);

CREATE TABLE driver (
    driver_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    status VARCHAR(20) DEFAULT 'AVAILABLE'
);

CREATE TABLE "order" (
    order_id SERIAL PRIMARY KEY,
    driver_id INT REFERENCES driver(driver_id),
    destination_id INT REFERENCES delivery_location(location_id),
    status VARCHAR(20) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE location_trace (
    trace_id BIGSERIAL PRIMARY KEY,
    driver_id INT REFERENCES driver(driver_id),
    location GEOMETRY(POINT, 4326) NOT NULL,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Basic GiST Spatial Indexes
CREATE INDEX idx_campus_zone_boundary ON campus_zone USING GIST (boundary);
CREATE INDEX idx_delivery_location_point ON delivery_location USING GIST (point);
CREATE INDEX idx_location_trace_location ON location_trace USING GIST (location);