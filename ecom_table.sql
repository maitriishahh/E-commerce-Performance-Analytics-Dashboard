create database ecommerce_analysis;
use ecommerce_analysis;

SHOW VARIABLES LIKE 'secure_file_priv';

CREATE TABLE ecommerce (
order_id TEXT,
customer_id TEXT,
order_status TEXT,
order_purchase_timestamp DATETIME,
order_approved_at DATETIME,
order_delivered_carrier_date DATETIME,
order_delivered_customer_date DATETIME,
order_estimated_delivery_date DATETIME,
order_item_id INT,
product_id TEXT,
seller_id TEXT,
shipping_limit_date DATETIME,
price DOUBLE,
freight_value DOUBLE,
product_name_lenght INT,
product_description_lenght INT,
product_photos_qty INT,
product_weight_g DOUBLE,
product_length_cm DOUBLE,
product_height_cm DOUBLE,
product_width_cm DOUBLE,
product_category_name_english TEXT,
customer_unique_id TEXT,
customer_zip_code_prefix INT,
customer_city TEXT,
customer_state TEXT,
payment_value DOUBLE,
payment_type TEXT,
review_id TEXT,
review_score INT,
review_creation_date DATETIME,
review_answer_timestamp DATETIME,
revenue DOUBLE,
order_month TEXT,
order_year INT,
delivery_days INT
);

LOAD DATA INFILE 
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ecomm_cleaned.csv'
INTO TABLE ecommerce
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
order_id,
customer_id,
order_status,
@order_purchase_timestamp,
@order_approved_at,
@order_delivered_carrier_date,
@order_delivered_customer_date,
@order_estimated_delivery_date,
order_item_id,
product_id,
seller_id,
@shipping_limit_date,
price,
freight_value,
product_name_lenght,
product_description_lenght,
product_photos_qty,
product_weight_g,
product_length_cm,
product_height_cm,
product_width_cm,
product_category_name_english,
customer_unique_id,
customer_zip_code_prefix,
customer_city,
customer_state,
payment_value,
payment_type,
review_id,
review_score,
@review_creation_date,
@review_answer_timestamp,
revenue,
order_month,
order_year,
delivery_days
)
SET
order_purchase_timestamp = NULLIF(@order_purchase_timestamp,''),
order_approved_at = NULLIF(@order_approved_at,''),
order_delivered_carrier_date = NULLIF(@order_delivered_carrier_date,''),
order_delivered_customer_date = NULLIF(@order_delivered_customer_date,''),
order_estimated_delivery_date = NULLIF(@order_estimated_delivery_date,''),
shipping_limit_date = NULLIF(@shipping_limit_date,''),
review_creation_date = NULLIF(@review_creation_date,''),
review_answer_timestamp = NULLIF(@review_answer_timestamp,'');

select count(*) from ecommerce