select * from ecommerce;

-- Sales Analytics (4 Queries)
-- 1.	Total Revenue, Total Orders, AOV 
select round(sum(revenue),2) as total_revenue,
count(distinct order_id) as total_orders,
round(sum(revenue)/count(distinct order_id),2) as avg_order_value from ecommerce;

-- 2.	Monthly Revenue Trend  
select order_year, order_month, round(sum(revenue),2) as monthly_revenue from ecommerce
group by order_year, order_month
order by order_year, order_month;
-- 3.	Month with Highest / Lowest Sales 
-- Highest Sales
select order_year, order_month, round(sum(revenue),2) as revenue from ecommerce
group by order_year, order_month
having count(distinct order_id) > 100
order by revenue desc
limit 1;

-- Lowest Sales
select order_year, order_month, round(sum(revenue),2) as revenue from ecommerce
group by order_year, order_month
having count(distinct order_id) > 100
order by revenue asc
limit 1;

-- 4.	Month-over-Month Growth Rate  
SELECT order_year,order_month, ROUND(SUM(revenue),2) AS revenue,
LAG(round(SUM(revenue),2)) OVER (ORDER BY order_year,order_month) AS prev_month,
ROUND(
(SUM(revenue) - LAG(SUM(revenue)) OVER (ORDER BY order_year,order_month)) 
/ NULLIF(LAG(SUM(revenue)) OVER (ORDER BY order_year,order_month),0) * 100, 2
) AS growth_percentage
FROM ecommerce
GROUP BY order_year,order_month
ORDER BY order_year,order_month;

-- Product Analytics (4 Queries)
-- 5.	Top 10 Products by Revenue
select product_category_name_english, 
COUNT(distinct(order_id)) AS total_orders,
round(sum(revenue),2) as total_revenue from ecommerce
group by product_category_name_english
order by total_revenue desc
limit 10;

-- 6.	Lowest Performing Products 
select product_category_name_english, COUNT(distinct(order_id)) AS total_orders,
round(sum(revenue),2) as total_revenue from ecommerce
group by product_category_name_english
having count(distinct order_id) > 50
order by total_revenue asc
limit 10;

-- 7.	Category with Highest Revenue 
select product_category_name_english, round(sum(revenue),2) as total_revenue from ecommerce
group by product_category_name_english
order by total_revenue desc
limit 5;

-- 8.	Products with High Orders but Low Revenue  
select product_category_name_english, count(distinct order_id) as total_orders,
round(sum(revenue),2) as total_revenue,
round(sum(revenue)/count(distinct order_id),2) as avg_revenue_per_order from ecommerce
group by product_category_name_english
order by total_orders desc, avg_revenue_per_order asc
limit 10;

-- Customer Analytics (4 Queries)
-- 9.	Repeat vs New Customers (%) 
select 
case
when order_count = 1 then 'New Customer'
else 'Repeat Customer'
end as customer_type,
count(*) as total_customers, round(count(*)*100.0 / sum(count(*)) over(),2) as percentage
from(
select customer_unique_id, count(distinct order_id) as order_count from ecommerce
group by customer_unique_id) t
group by customer_type;

-- 10.	AOV for New vs Returning Customers 
SELECT customer_type, ROUND(AVG(order_value),2) AS avg_order_value
FROM (
    SELECT 
    e.customer_unique_id, e.order_id, SUM(e.revenue) AS order_value,
    CASE 
        WHEN c.order_count = 1 THEN 'New Customer'
        ELSE 'Returning Customer'
    END AS customer_type
    FROM ecommerce e
    JOIN (
        SELECT customer_unique_id, COUNT(DISTINCT order_id) AS order_count FROM ecommerce
        GROUP BY customer_unique_id) c
    ON e.customer_unique_id = c.customer_unique_id
    GROUP BY e.customer_unique_id, e.order_id, customer_type) t
GROUP BY customer_type;

-- 11.	Top Spending Customers 
select customer_unique_id, round(sum(revenue),2) as total_spent
from ecommerce
group by customer_unique_id
order by total_spent desc
limit 10;
-- 12.	Average Time Between Purchases
select customer_unique_id, round(avg(days_between),0) as avg_days_between_orders from
(select customer_unique_id, datediff(order_purchase_timestamp, lag(order_purchase_timestamp)
over (partition by customer_unique_id order by order_purchase_timestamp )) as days_between
from ecommerce) t 
where days_between > 0
group by customer_unique_id
order by avg_days_between_orders desc
limit 10;
-- Regional Analytics (2–3 Queries)
-- 13.	Revenue by Region / City 
select customer_state,customer_city,round(sum(revenue),2) as total_revenue from ecommerce
group by customer_state,customer_city
order by total_revenue desc
limit 10;
-- 14.	Highest AOV by Region 
select customer_state,count(distinct order_id) as total_orders,
round(sum(revenue),2) as total_revenue,
round(round(sum(revenue),2)/count(distinct order_id),2) as avg_order_value
from ecommerce
group by customer_state
order by avg_order_value desc
limit 10;

-- 15.	Regional Growth Over Time 
SELECT * FROM (
SELECT customer_state, order_year, ROUND(SUM(revenue),2) AS total_revenue,
LAG(ROUND(SUM(revenue),2)) OVER (PARTITION BY customer_state ORDER BY order_year) 
AS prev_year_revenue,
ROUND((SUM(revenue) - LAG(SUM(revenue)) OVER (PARTITION BY customer_state ORDER BY order_year))
/ NULLIF(LAG(SUM(revenue)) OVER (PARTITION BY customer_state ORDER BY order_year),0) * 100, 2) 
AS growth_percentage FROM ecommerce
GROUP BY customer_state, order_year) t
WHERE prev_year_revenue > 1000
ORDER BY order_year desc, growth_percentage DESC limit 10;

-- Review Analytics (Bonus Section)
-- 16.	Average review score per category 
select product_category_name_english, 
count(review_score) as total_reviews,round(avg(review_score),1) as avg_review_score 
from ecommerce
where review_score > 0
group by product_category_name_english
having count(review_score)>50
order by avg_review_score desc limit 10;

-- 17.	Review score by region 
select customer_city, count(review_score) as total_reviews,
round(avg(review_score),1) as avg_review_score from ecommerce
where review_score > 0
group by customer_city
having count(review_score)>50
order by total_reviews desc limit 10;

-- 18.	Review score over time
select order_month, count(review_score) as total_reviews,
round(avg(review_score),1) as avg_review_score from ecommerce
where review_score > 0
group by order_month
order by order_month desc limit 10;

-- 19. Low Review Score Categories
select product_category_name_english, 
count(review_score) as total_reviews,round(avg(review_score),1) as avg_review_score 
from ecommerce
where review_score > 0
group by product_category_name_english
having count(review_score)>50
order by avg_review_score asc limit 10;

-- 20️ Delivery Time vs Review Score
select
case
when delivery_days <= 3 then 'Fast Delivery'
when delivery_days <= 7 then 'Medium Delivery'
else 'Slow Delivery'
end as delivery_speed,
count(*) as total_orders,
round(avg(review_score),1) as avg_review_score
from ecommerce
where review_score > 0
group by delivery_speed
order by avg_review_score desc;