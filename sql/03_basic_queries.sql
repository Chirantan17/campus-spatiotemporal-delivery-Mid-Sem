-- ============================================================================
-- 1. BASIC RELATIONAL / OPERATIONAL QUERIES
-- ============================================================================

-- Q3.1: Fetch full menu catalog for a specific canteen
SELECT mi.item_id, mi.name AS item_name, mi.price, mi.prep_time_minutes, r.name AS restaurant_name
FROM menu_item mi
JOIN restaurant r ON mi.restaurant_id = r.restaurant_id
WHERE r.name = 'Canteen 1 (Main Hub)';

-- Q3.2: List active pending/preparing orders with customer details
SELECT o.order_id, c.name AS customer_name, c.phone, r.name AS canteen_name, o.status, o.created_at
FROM "order" o
JOIN customer c ON o.customer_id = c.customer_id
JOIN restaurant r ON o.restaurant_id = r.restaurant_id
WHERE o.status IN ('PENDING', 'PREPARING');

-- Q3.3: Calculate total item count and line-item total per order
SELECT oi.order_id, COUNT(oi.item_id) AS total_unique_items, SUM(oi.quantity) AS total_item_qty, SUM(oi.quantity * oi.price_at_order) AS order_total_inr
FROM order_item oi
GROUP BY oi.order_id
ORDER BY oi.order_id;