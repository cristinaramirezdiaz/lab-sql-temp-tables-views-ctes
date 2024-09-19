USE sakila;

-- crear una view

CREATE VIEW rental_summary AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM
    customer c
LEFT JOIN
    rental r ON c.customer_id = r.customer_id
GROUP BY
    c.customer_id, c.first_name, c.last_name, c.email;

-- crear una tabla temporal

CREATE TEMPORARY TABLE payment_summary AS
SELECT
    c.customer_id,
    SUM(p.amount) AS total_paid
FROM
    customer c
LEFT JOIN
    payment p ON c.customer_id = p.customer_id
GROUP BY
    c.customer_id;

-- crear una CTE

WITH customer_summary AS (
    SELECT
        r.customer_name,
        r.email,
        r.rental_count,
        COALESCE(p.total_paid, 0) AS total_paid
    FROM
        rental_summary r
    LEFT JOIN
        payment_summary p ON r.customer_id = p.customer_id
)
SELECT
    customer_name,
    email,
    rental_count,
    total_paid,
    CASE
        WHEN rental_count > 0 THEN total_paid / rental_count
        ELSE 0
    END AS average_payment_per_rental
FROM
    customer_summary;
