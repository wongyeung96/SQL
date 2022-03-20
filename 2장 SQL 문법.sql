### SELECT

# 테이블들이 저장된 DB 경로 설정
use classicmodels;

# 1) 칼럼 조회
select customernumber
from customers;

# 2) 집계함수
select sum(amount), count(checknumber)
from payments;

# 3) *(모든 결과 조회)
select *
from classicmodels.products; 

select productName, productLine
from classicmodels.products;

# 4) AS
select count(productCode) as n_products
from classicmodels.products;

# 5) DISTINCT
select *
from classicmodels.orderdetails;

select distinct(ordernumber)
from classicmodels.orderdetails;

### WHERE

# 1) BETWEEN
select *
from orderdetails
where priceeach Between 30 and 50;

# 2) 대소 관계 표현
select *
from orderdetails
where priceeach >= 30;

# 3) IN
select customernumber, country
from customers
where country in ("usa",'canada');

# 4) NOT IN
select customernumber
from customers
where country not in ('use','canada');

# 5) IS NULL
select employeenumber
from employees
where reportsto is null;

select employeenumber
from employees
where reportsto is not null;

# 6) LIKE '%TEXT%'
select addressline1
from customers
where addressline1 like '%ST%';


### GROUP BY
select *
from customers;

select country, city, count(*) as n_customers
from customers
group by country, city;

select sum(case when country = 'usa' then 1 else 0 end) as n_usa,
sum(case when country = 'usa' then 1 else 0 end)/count(*) as usa_portion
from customers;

### JOIN
select *
from customers;

select *
from orders;

# 1) LEFT JOIN
select  B.ordernumber, A.country
from customers A
left join orders B
on A.customernumber = B.customerNumber;

select  B.ordernumber, A.country
from customers A
left join orders B
on A.customernumber = B.customerNumber
where A.country = 'usa';

# 2) INNER JOIN
select B.ordernumber, A.country
from customers A
inner join orders B
on A.customernumber = B.customernumber
where A.country = 'usa';

# 3) FULL JOIN

### CASE WHEN

select country,
case when country in ('usa','canada') then '북미'
else '북미아님' end as region
from customers;

select
case when country in ('usa','canada') then '북미'
else '북미아님' end as region,
count(customernumber) as n_customers
from customers
group by 1;

-- group by는 select보다 후순위이다.

### RANK, DENSE_RANK, ROW_NUMBER(기본 오름차순)
-- ROW_NUMBER : 동점인 경우에도 서로 다른 등수로 계산(ex. 1 2 3 4)
-- DENSE_RANK : 동점의 등수 바로 다음 수로 수위를 매긴다.(ex. 1 2 2 3)
-- RANK : 동점인 경우의 데이터 세트를 고려해 다음 등수르 매긴다.(ex. 1 2 2 4)

select buyprice,
rank() over(order by buyprice) as RANKs,
dense_rank() over(order by buyprice) as DENSERANK,
row_number() over(order by buyprice) as ROWNUMBER 
from products;

select productline, buyprice,
rank() over(partition by productline order by buyprice) as RANKs,
dense_rank() over(partition by productline order by buyprice) as denserank,
row_number() over(partition by productline order by buyprice) as rownumber
from products;

### SUBQUERY
select*
from customers;

select ordernumber
from orders
where customernumber in (select customernumber
from customers
where country = 'usa');