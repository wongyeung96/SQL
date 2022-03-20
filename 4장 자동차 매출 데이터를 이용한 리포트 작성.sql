use classicmodels;

### 2. 구매 지표 추출
## 1) 매출액(일자별, 월별, 연도별)
# a) 일별 매출액 조회

select A.orderdate, sum(priceeach*quantityordered) as `일별 매출액`
from orders A
left join orderdetails B
on A.ordernumber = B.ordernumber
group by 1
order by 1;

# b) 월별 매출액 조회 - substr(문자열, 시작위치, 길이)
select substr(A.orderdate,1,7) as `월`, sum(priceeach*quantityordered) as `월별 매출액`
from orders A
left join orderdetails B
on A.ordernumber = B.ordernumber
group by 1
order by 1;

# c) 연도별 매출액 조회
select substr(A.orderdate,1,4) as `년`, sum(priceEach*quantityOrdered) as `연도별 매출액`
from orders A
left join orderdetails B
on A.ordernumber = B.ordernumber
group by 1
order by 1;


## 2) 구매자 수, 구매 건수(일자별, 월별, 연도별)
# 일별
select orderdate, count(distinct customerNumber) as `구매자 수(중복 제거)`, count(ordernumber) as `구매 건수`
from orders
group by 1
order by 1;

# 월별
select substr(orderdate,1,7) as `월`, count(distinct customernumber) as `월별 구매자 수(중복 제거)`, count(ordernumber) as `월별 구매 건수`
from orders
group by 1
order by 1;

# 연도별
select substr(orderdate,1,4) as `년`, count(distinct customernumber) as `연도별 구매자 수(중복 제거)`, count(ordernumber) as `연도별 구매 건수`
from orders
group by 1
order by 1;

## 3) 인당 매출액(연도별) -- 연도별 고객의 수 한명당 얼마의 매출인지 
select substr(orderdate,1,4) as `년`, 
count(distinct customernumber) as `연도별 고객 수`,
sum(priceEach*quantityordered) as `연도별 매출액`,
sum(priceEach*quantityordered)/count(distinct customernumber) as `연도별 인당 매출액`
from orders A
left join orderdetails B
on A.ordernumber = B.ordernumber
group by 1
order by 1;

# 회원별 연도별 매출액
select substr(orderdate,1,4) as `년`, 
customernumber, 
sum(priceeach*quantityOrdered) as `인당 매출액`
from orders A
left join orderdetails B
on A.ordernumber = B.ordernumber
group by 1, 2
order by 2;

## 4) 건당 구매 금액(ATV, Average Transaction Value)(연도별) -- 연도, 총 구매 건수, 총 매출액, 건당 구매 금액
select substr(A.orderdate,1,4) as `year`,
count(distinct A.orderNumber) as `연도별 총 구매 건수`,
sum(priceEach*quantityOrdered) as `연도별 총 매출액`,
sum(priceEach*quantityOrdered)/count(*) as `연도별 건당 구매 금액`
from orders A
left join orderdetails B
on A.ordernumber = B.ordernumber
group by 1
order by 1;

### 3. 그룹별 구매 지표 구하기
use classicmodels;

## 1) 국가별, 도시별 매출액

select  country, city, sum(priceeach*quantityordered) as `국가,도시별 매출액`
from orders A
left join orderdetails B
on A.ordernumber = B.ordernumber
left join customers C
on A.customernumber = C.customernumber
group by 1,2
order by 1,2;

## 2) 북미(USA, Canada) vs 비북미 매출액 비교
select case when country in ('usa','canada') then 'North America'
else 'Others' end as `Country_GRP`
from customers;

select  case when country in ('usa','canada') then 'North America'
else 'Others' end as `Country_GRP`, sum(priceeach*quantityordered) as `북미 비북미 총 매출액`
from orders A
left join orderdetails B
on A.ordernumber = B.ordernumber
left join customers C
on A.customernumber = C.customernumber
group by 1;

## 3) 매출 Top 5 국가 및 매출
create table stat as
select  country, 
sum(priceeach*quantityordered) as `국가별 총 매출액`
from orders A
left join orderdetails B
on A.ordernumber = B.ordernumber
left join customers C
on A.customernumber = C.customernumber
group by 1
order by 2 desc;

create table stat_rnk as
select country, `국가별 총 매출액`,
dense_rank() over(order by `국가별 총 매출액` desc) as ranks
from stat;

select *
from stat_rnk
where ranks <=5;

# 위 과정을 Subquery를 이용해서 하나의 쿼리로 처리
select *
from 
(select country,
`국가별 총 매출액`,
dense_rank() over(order by `국가별 총 매출액` desc) ranks
from 
(select country,
sum(priceeach*quantityordered) as `국가별 총 매출액`
from orders A
left join orderdetails B
on A.ordernumber = B.ordernumber
left join customers C
on A.customernumber = C.customernumber
group by 1) A) A
where ranks <= 5;

-- where절은 from에 위치한 테이블에서만 조건을 걸 수 있다. 그런데 ranks는 select에서 생성한 칼럼이라 조건절(where)에서 사용할 수 없기 때문에 subquery를 생성해서 만드는 것입니다.

### 4. 재구매율
select A.customernumber, 
A.orderdate,
B.customernumber,
B.orderdate
from orders A
left join orders B
on A.customernumber = B.customernumber and substr(A.orderdate,1,4) = substr(B.orderdate,1,4) -1;

## 1) 국가별 2004,2005 Retention Rate(%) 재구매율
select C.country, 
substr(A.orderdate,1,4) as `year`,
count(distinct A.customernumber) BU_1,
count(distinct B.customernumber) BU_2,
count(distinct B.customernumber)/count(distinct A.customernumber) as `retention_rate(%)`
from orders A
left join orders B
on A.customernumber = B.customernumber and substr(A.orderdate,1,4) = substr(B.orderdate,1,4)-1
left join customers C
on A.customernumber  = C.customernumber
group by 1,2;

### 5. Best Seller
create table product_sales as
select D.productname,
sum(quantityordered*priceeach) as SALES
from orders A
left join customers B
on A.customernumber = B.customernumber
left join orderdetails C
on A.ordernumber = C.ordernumber
left join products D
on C.productcode = D.productcode
where B.country = 'usa'
group by 1;

select *
from 
(select productname, SALES, 
row_number() over(order by SALES desc) as ranks
from product_sales) A
where ranks <=5;

### 6. Churn Rate(%)
-- Churn Rate란 활동 고객 중 얼마나 많은 고객이 비활동 고객으로 전환되었는지를 의미하느 지표!!
-- 고객 1명을 획득하는 비용을 Acquisition Cost라고 부른다.

## 1) Churn Rate(%) 구하기
select max(orderdate) as mx_order
from orders; 

select customernumber,max(orderdate) as mx_order
from orders
group by 1;

# DATEDIFF()
-- DATEDIFF(date1, date2) : date1 - date2 결과가 출력됩니다.

select customernumber, mx_order,
datediff('2005-06-01',mx_order) as diff
from 
(select customernumber,max(orderdate) as mx_order
from orders
group by 1) A;

-- diff가 90일 이상일 경우에 churn(비활동 고객)으로 분류해볼게요.
select case when diff >= 90 then "churn" 
else "non-churn" end as churn,
customer
count(distinct customernumber) as count
from 
(select customernumber, mx_order,
datediff('2005-06-01',mx_order) as diff
from 
(select customernumber,max(orderdate) as mx_order
from orders
group by 1) A) A
group by 1 ; 

## 2) churn 고객이 가장 많이 구매한 Productline
create table churn_list as
select case when diff >= 90 then "churn" 
else "non-churn" end as churn,
customernumber
from 
(select customernumber, mx_order,
datediff('2005-06-01',mx_order) as diff
from 
(select customernumber,max(orderdate) as mx_order
from orders
group by 1) A) A;

select *
from churn_list;

select D.churn,
C.productline,
count(distinct B.customernumber) as BU
from orderdetails A
left join orders B
on A.ordernumber = B.ordernumber
left join products C
on A.productcode = C.productcode
left join churn_list D
on B.customernumber = D.customernumber
group by 1,2
order by 1,3 desc;

-- churn type과 productline 사이에는 눈에 띄는 관계가 없는 것으로 보입니다.

















