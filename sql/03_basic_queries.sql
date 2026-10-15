-- ============================================================================
-- 1. BASIC RELATIONAL / OPERATIONAL QUERIES
-- ============================================================================

-- Q3.0: FLAGSHIP DIAGNOSTIC - Execute this first for the IC Walkthrough!
-- It should output exactly 1 row (Our intentional Driver Mismatch anomaly)
SELECT * FROM integrity_audit;

-- Q3.1: Fetch full menu catalog for a specific canteen
SELECT mi.item_id, mi.name AS item_name, mi.category, mi.price, 
       mi.serve_start_time, mi.serve_end_time, r.name AS restaurant_name
FROM menu_item mi
JOIN restaurant r ON mi.restaurant_id = r.restaurant_id
WHERE r.name = 'Canteen 1 (Main Hub)';

-- Q3.2: List active pending/preparing orders with customer details
SELECT o.order_id, c.name AS customer_name, c.phone, r.name AS canteen_name, o.status, o.created_at
FROM "order" o
JOIN customer c ON o.customer_id = c.customer_id
JOIN restaurant r ON o.restaurant_id = r.restaurant_id
WHERE o.status IN ('PENDING', 'PREPARING');

-- Q3.3: Utilize the Order Total View (Proves derived totals vs redundant storage)
SELECT ot.order_id, ot.total_amount AS final_invoice_total, o.delivery_fee, o.status
FROM order_total ot
JOIN "order" o ON ot.order_id = o.order_id
ORDER BY ot.order_id;

-- Q3.4: ANOMALY PROOF — Historical Price Snapshot Audit
SELECT oi.order_id, mi.name AS item_name,
       oi.price_at_order AS historical_price_paid,
       mi.price AS current_catalog_price,
       (mi.price - oi.price_at_order) AS price_drift_difference
FROM order_item oi
JOIN menu_item mi ON oi.item_id = mi.item_id
ORDER BY oi.order_id;

-- Q3.5: List all dining facilities and their ratings
SELECT r.restaurant_id, r.name, r.facility_type, r.target_demographic, r.student_rating
FROM restaurant r
ORDER BY r.student_rating DESC;