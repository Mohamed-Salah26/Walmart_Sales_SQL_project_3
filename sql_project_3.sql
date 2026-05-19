select *
from walmart;

select count(*)
from walmart;

-- -----------------------------------
-- Solving business problems 
-- -----------------------------------


-- Q1: Find different payment methods, number of transactions, 
-- and quantity sold by payment method
select payment_method, count(*) number_of_transaction, SUM(quantity) number_of_quantity_sold
from walmart
group by payment_method
order by 2 DESC;


-- Project Question #2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating
With ranked As (
select branch, category, 
round(avg(rating),2) as average_rating,
RANK() over (partition by category order by avg(rating) DESC) AS ranking
from walmart
group by branch, category
order by 3 DESC
)
select branch, category, average_rating
from ranked
where ranking = 1;


-- Q3: Identify the busiest day of the week for each branch based on the number of transactions
with busy AS (
select branch,DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) Day_name , count(*) number_of_transaction,
rank() over(partition by branch order by count(*) DESC) rnk
from walmart
group by branch, DAYNAME(STR_TO_DATE(date, '%d/%m/%y'))
)
select branch, Day_name, number_of_transaction
from busy
where rnk = 1
order by 3 DESC;


-- Q4: Calculate the total quantity of items sold per payment method
select payment_method, count(*) quantity_sale
from walmart
group by payment_method
order by 2 DESC;


-- Q5: Determine the average, minimum, and maximum rating of categories for each city
select city, category,
round(avg(rating),2) Average_Rating, min(rating) Min_Rating, max(rating) Max_Rating
from walmart
group by city, category
order by 1 ;


-- Q6: Calculate the total profit for each category
select category, round(SUM(Profit * profit_margin),2) Total_profit
from walmart
group by category
order by 2 DESC;


-- Q7: Determine the most common payment method for each branch (Use subquery)
select branch, payment_method, paying from (
select branch, payment_method, count(*) paying,
rank () over (partition by Branch order by count(*) DESC) as rnk
from walmart
group by Branch, payment_method ) AS ranked
where rnk = 1;


-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
select *,
CASE
	WHEN hour(time) < 12 THEN 'Morning'
    WHEN hour(time) between 12 and 17 then 'After noon'
	ELSE 'Evening'
END AS Shifts
from walmart;


-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)
-- Revenue Decrease Rtion = (current year revenue - past year revenue) / past year revenue


WITH revenue_2023 AS (
select branch, SUM(Profit) revenue
from walmart
where YEAR(str_to_date(date, '%d/%m/%y')) = 2023
group by branch
),
revenue_2022 AS
(
select branch,SUM(Profit) AS revenue
from walmart
where YEAR(str_to_date(date, '%d/%m/%y')) = 2022
group by branch
)

select 
r3.branch,
r3.revenue as 2023_revenue,
r2.revenue as 2022_revenue,
round( ((r3.revenue - r2.revenue)/ r2.revenue) * 100, 2) AS revenue_decrease_ratio

from revenue_2023 as r3
join revenue_2022 as r2
	on r3.branch = r2.branch
where r3.revenue < r2.revenue
order by 4 ASC
limit 5











