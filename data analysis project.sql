-- top 10 highest revenue generating products 
select product_id, sum(sale_price) as sales 
from sys.df_orders 
group by product_id
order by sales desc 
limit 10;

-- top 5 highest selling products im each region
with cte as (
select region, product_id, sum(sale_price) as sales 
from sys.df_orders 
group by region, product_id)
select * from (
select * 
, row_number() over(partition by region order by sales desc) as row_num
from cte) A
where row_num <= 5;

-- month to month growth comparison for 2022 and 2023 sales (eg. Jan 2022 vs. Jan 2023)
with cte as (
select year(order_date) as order_year, month(order_date) as order_month, 
sum(sale_price) as sales
from sys.df_orders
group by year(order_date), month(order_date)
)
select order_month
, sum(case when order_year = 2022 then sales else 0 end) as sales_2022
, sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month;

-- highest sales months for each categoty
with cte as (
select category, format(order_date,'yyyyMM') as order_year_month
, sum(sale_price) as sales 
from sys.df_orders
group by category, format(order_date,'yyyyMM')
)
select * from (
select *,
row_number() over(partition by category order by sales desc) as row_num
from cte
) A
where row_num=1;

-- Subcategory with highest profit in 2023 compared to 2022 
with cte as (
select sub_category,year(order_date) as order_year,
sum(sale_price) as sales
from sys.df_orders
group by sub_category,year(order_date)
	)
, cte2 as (
select sub_category
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by sub_category
)
select *
,(sales_2023-sales_2022)
from  cte2
order by (sales_2023-sales_2022) desc
limit 1