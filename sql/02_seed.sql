-- Seed Campus Zone (Main Campus Area Polygon)
INSERT INTO campus_zone (zone_name, boundary) VALUES
('Hostel Block', ST_GeomFromText('POLYGON((78.348 17.455, 78.352 17.455, 78.352 17.458, 78.348 17.458, 78.348 17.455))', 4326)),
('Academic Zone', ST_GeomFromText('POLYGON((78.352 17.455, 78.356 17.455, 78.356 17.458, 78.352 17.458, 78.352 17.455))', 4326));

-- Seed Delivery Locations
INSERT INTO delivery_location (name, zone_id, point) VALUES
('Hostel 1 Mess', 1, ST_SetSRID(ST_MakePoint(78.349, 17.456), 4326)),
('Library Gate', 2, ST_SetSRID(ST_MakePoint(78.353, 17.457), 4326));

-- Seed Drivers & Locations
INSERT INTO driver (name, status) VALUES ('Driver A', 'BUSY'), ('Driver B', 'AVAILABLE');

INSERT INTO location_trace (driver_id, location) VALUES
(1, ST_SetSRID(ST_MakePoint(78.350, 17.456), 4326)),
(2, ST_SetSRID(ST_MakePoint(78.354, 17.457), 4326));