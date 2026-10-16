-- ============================================================================
-- 07_order_lifecycle.sql - End-to-End Transaction & Spatiotemporal Execution
-- ============================================================================
-- Purpose: This script walks the faculty through a complete order lifecycle 
-- using pure raw SQL. It mirrors the exact 5-step process shown in the 
-- interactive index.html visualizer.
--
-- Note for IC: We utilize `currval(pg_get_serial_sequence())` so this script 
-- is 100% dynamic. It will always target the newly created order regardless 
-- of how many orders currently exist in the seed data.
-- ============================================================================

-- ============================================================================
-- STEP 1: ORDER CREATION (ACID Transaction)
-- Customer 4 (Sneha) orders 2x Veg Thali and 1x Cold Coffee from Canteen 1.
-- Delivery location: Academic Block 1 - Main Entrance (Destination 1).
-- Concept: We wrap the header and line-item inserts in a BEGIN/COMMIT block 
-- to ensure Atomicity—either the whole order succeeds, or none of it does.
-- ============================================================================
BEGIN;

-- Insert Transaction Header (status: 'PENDING', driver: NULL)
INSERT INTO "order" (customer_id, restaurant_id, driver_id, destination_id, status, delivery_fee, created_at, fulfilled_at)
VALUES (4, 1, NULL, 1, 'PENDING', 0.00, CURRENT_TIMESTAMP, NULL);

-- Insert Line Items with Historical Price Snapshots
INSERT INTO order_item (order_id, item_id, restaurant_id, quantity, price_at_order)
VALUES 
(currval(pg_get_serial_sequence('"order"', 'order_id'))::INT, 1, 1, 2, 120.00), -- 2x Veg Thali
(currval(pg_get_serial_sequence('"order"', 'order_id'))::INT, 2, 1, 1, 70.00);  -- 1x Cold Coffee

COMMIT;

-- Verification: Display the newly inserted relational data and dynamic View total (Expected: 310.00)
SELECT * FROM "order" WHERE order_id = currval(pg_get_serial_sequence('"order"', 'order_id'))::INT;
SELECT * FROM order_item WHERE order_id = currval(pg_get_serial_sequence('"order"', 'order_id'))::INT;
SELECT * FROM order_total WHERE order_id = currval(pg_get_serial_sequence('"order"', 'order_id'))::INT;


-- ============================================================================
-- STEP 2: CANTEEN ACCEPTANCE
-- The Canteen acknowledges the order and begins cooking.
-- Concept: Standard row update modifying the state machine.
-- ============================================================================
UPDATE "order" 
SET status = 'PREPARING' 
WHERE order_id = currval(pg_get_serial_sequence('"order"', 'order_id'))::INT 
  AND status = 'PENDING';

-- Verification:
SELECT order_id, status FROM "order" WHERE order_id = currval(pg_get_serial_sequence('"order"', 'order_id'))::INT;


-- ============================================================================
-- STEP 3: SPATIAL DRIVER DISPATCH
-- The system automatically finds the closest 'AVAILABLE' driver to Canteen 1.
-- Concept: PostGIS K-Nearest Neighbor (KNN) Search.
-- Note for IC: The `<->` operator uses the GiST spatial index to calculate 
-- bounding-box distances exponentially faster than standard geometry math.
-- ============================================================================
WITH nearest_driver AS (
    SELECT d.driver_id 
    FROM driver d 
    JOIN location_trace lt ON d.driver_id = lt.driver_id
    JOIN restaurant r ON r.restaurant_id = 1 
    WHERE d.status = 'AVAILABLE'
    ORDER BY lt.location <-> r.location 
    LIMIT 1
)
UPDATE "order" 
SET driver_id = (SELECT driver_id FROM nearest_driver), status = 'IN_TRANSIT' 
WHERE order_id = currval(pg_get_serial_sequence('"order"', 'order_id'))::INT;

-- Instantly update that driver's workforce status to prevent double-booking
UPDATE driver 
SET status = 'BUSY' 
WHERE driver_id = (SELECT driver_id FROM "order" WHERE order_id = currval(pg_get_serial_sequence('"order"', 'order_id'))::INT);

-- Verification: Show driver workforce status change
SELECT driver_id, name, status FROM driver ORDER BY driver_id;


-- ============================================================================
-- STEP 4: TELEMETRY & AUTOMATED PICKUP (GEOFENCING)
-- The assigned driver physically reaches Canteen 1.
-- Concept: Geofence proximity trigger (ST_DWithin).
-- ============================================================================
-- 1. Driver's mobile app sends a real-time GPS ping matching Canteen 1's exact location
INSERT INTO location_trace (driver_id, location, recorded_at)
VALUES (
    (SELECT driver_id FROM "order" WHERE order_id = currval(pg_get_serial_sequence('"order"', 'order_id'))::INT),
    ST_SetSRID(ST_MakePoint(78.5415, 17.5215), 4326), 
    CURRENT_TIMESTAMP
);

-- 2. System verifies the driver is spatially within 30 meters of the Canteen
SELECT ST_DWithin(lt.location::geography, r.location::geography, 30.0) AS pickup_geofence_valid
FROM location_trace lt, restaurant r 
WHERE lt.driver_id = (SELECT driver_id FROM "order" WHERE order_id = currval(pg_get_serial_sequence('"order"', 'order_id'))::INT)
  AND r.restaurant_id = 1
ORDER BY lt.recorded_at DESC LIMIT 1;


-- ============================================================================
-- STEP 5: DELIVERY COMPLETION & WORKFORCE RELEASE
-- The driver successfully drops off the food at the destination.
-- Concept: State termination and workforce pool replenishment.
-- ============================================================================
-- 1. Free the driver back into the dispatch pool
UPDATE driver 
SET status = 'AVAILABLE' 
WHERE driver_id = (SELECT driver_id FROM "order" WHERE order_id = currval(pg_get_serial_sequence('"order"', 'order_id'))::INT);

-- 2. Close the order and lock in the fulfillment timestamp
UPDATE "order" 
SET status = 'DELIVERED', fulfilled_at = CURRENT_TIMESTAMP 
WHERE order_id = currval(pg_get_serial_sequence('"order"', 'order_id'))::INT;

-- Verification: Show closed order and freed driver
SELECT order_id, driver_id, status, fulfilled_at FROM "order" WHERE order_id = currval(pg_get_serial_sequence('"order"', 'order_id'))::INT;
SELECT driver_id, name, status FROM driver ORDER BY driver_id;


-- ============================================================================
-- FINAL SYSTEM AUDIT
-- Concept: Real-time consistency check.
-- Purpose: Expected Output: 0 Rows. This proves to the faculty that despite 
-- running a complex, multi-table spatiotemporal transaction, our strict schema 
-- constraints and state-machine logic prevented any logistical anomalies.
-- ============================================================================
SELECT * FROM integrity_audit;