USE dw;

-- 清空表
TRUNCATE TABLE dim_customer;
TRUNCATE TABLE dim_product;
TRUNCATE TABLE dim_order;
TRUNCATE TABLE fact_sales_order;

-- 装载客户维度表
INSERT INTO customer_dim (customer_sk,customer_number,customer_name,customer_street_address,customer_zip_code,customer_city,customer_state,`version`,effective_date,expiry_date)
SELECT
	row_number() over (ORDER BY t1.customer_number) + t2.sk_max,
	t1.customer_number, 
	t1.customer_name, 
	t1.customer_street_address,
	t1.customer_zip_code, 
	t1.customer_city, 
	t1.customer_state, 
	1,
	'2016-03-01', 
	'2050-01-01'
FROM rds.customer t1
CROSS JOIN 
	(SELECT COALESCE(MAX(customer_sk),0) sk_max 
	FROM dim_customer) t2;
	
-- 装载产品维度表
INSERT INTO dim_product (product_sk,product_code,product_name,product_category,`version`,effective_date,expiry_date)
SELECT row_number() over (ORDER BY t1.product_code) + t2.sk_max,
	product_code, 
	product_name, 
	product_category, 
	1,
	'2016-03-01', 
	'2050-01-01'
FROM rds.product t1
CROSS JOIN
	(SELECT COALESCE(MAX(product_sk),0) sk_max 
	FROM product_dim) t2;
	
-- 装载订单维度表
INSERT INTO dim_order(order_sk,order_number,`version`,effective_date,expiry_date)
SELECT row_number() over (ORDER BY t1.order_number) + t2.sk_max,
	order_number, 
	1, 
	order_date, 
	'2050-01-01'
FROM rds.sales_order t1
CROSS JOIN
	(SELECT COALESCE(MAX(order_sk),0) sk_max 
	FROM dim_order) t2;
	
-- 装载销售订单事实表
INSERT INTO fact_sales_order()
SELECT order_sk, 
	customer_sk, 
	product_sk, 
	date_sk, 
	order_amount
FROM rds.sales_order a
JOIN dim_order b ON a.order_number = b.order_number
JOIN dim_customer c ON a.customer_number = c.customer_number
JOIN dim_product d ON a.product_code = d.product_code
JOIN dim_date e ON (a.order_date) = e.date