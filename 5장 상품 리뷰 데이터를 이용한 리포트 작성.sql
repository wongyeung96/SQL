use mydata;

select *
from dataset2;

### 2. Division별 평점 분포 계산

## 1) Division별 평균 평점 계산
# a) division name별 평균 평점
select `Division Name`,avg(rating) as `division별 평균 평점`
from dataset2
group by 1
order by 2 desc;

# b) department별 평균 평점
select `Department Name`, avg(rating) as `department별 평균 평점`
from dataset2
group by 1
order by 2 desc;

# c) trend의 평점 3점 이하 리뷰
select *
from dataset2
where `Department Name` = 'Trend' and `rating` <= 3;

# case when
select case when age between 0 and 9 then "0009"
when age between 10 and 19 then "1019" 
when age between 20 and 29 then "2029"
when age between 30 and 39 then "3039"
when age between 40 and 49 then "4049"
when age between 50 and 59 then "5059"
when age between 60 and 69 then "6069"
when age between 70 and 79 then "7079"
when age between 80 and 89 then "8089"
when age between 90 and 99 then "9099" end as `ageband`,
age
from dataset2
where `Department Name` = 'Trend' and `rating` <= 3;

# FLOOR
select floor(age/10)*10 as ageband,
age
from dataset2
where `Department Name` = 'Trend' and `rating` <= 3;

# a) Trend의 평점 3점 이하 리뷰 연령 분포
select floor(age/10)*10 as ageband, count(age) as cnt
from dataset2
where `Department Name` = 'Trend' and `rating` <= 3
group by 1
order by 2 desc;

# b) department별 연령별 리뷰 수
select floor(age/10)*10 as ageband, count(*) as cnt
from dataset2
where `Department Name` = 'Trend' 
group by 1
order by 2 desc;

# c) 50대 점 3이하 Trend 리뷰
select *
from dataset2
where `Department Name` = 'Trend' 
and rating <= 3 
and age between 50 and 59
limit 10;

### 3. 평점이 낮은 상품의 주요 Complain

## 1) Department Name, Clothing Name별 평균 평점 계산
select *
from dataset2;

select `department name`, `clothing id`,
avg(rating) as avg_rate
from dataset2
group by 1,2;

## 2) department 별 순위 생성
select *,
row_number() over(
partition by `department name` 
order by avg_rate ) as rnk
from 
(select `department name`,
`clothing id`,
avg(rating) as avg_rate
from dataset2
group by 1,2) A;

## 3) 1~10위 데이터 조회
select *
from 
(select *,
row_number() over(
partition by `department name` 
order by avg_rate ) as rnk
from 
(select `department name`,
`clothing id`,
avg(rating) as avg_rate
from dataset2
group by 1,2) A) A
where rnk between 1 and 10;

# a) department별 평균 평점이 낮은 10개 상품
create table stat as 
select *
from 
(select *,
row_number() over(
partition by `department name` 
order by avg_rate ) as rnk
from 
(select `department name`,
`clothing id`,
avg(rating) as avg_rate
from dataset2
group by 1,2) A) A
where rnk between 1 and 10;

select *
from stat
where `department name` = "bottoms";

select *
from dataset2
where `clothing id` in 
(select `clothing id`
from stat
where `department name` = "bottoms")
order by `clothing id`;

# b) TF-IDF
-- 리뷰 데이터는 수많은 단어로 구성되어 있다. 문단에는 the, product와 같이 자주 사용되지만 가치가 없는 단어들도 있고, Size, Textured와 같이 평가 내용을 파악하는 데 도움이 되는 가치 있는 단어들도 있다.
-- 이를 판단하기 위해 NLP(Natural Language Processing)에서 TF-IDF라는 Score를 이용해 단어별로 가치 수준을 매긴다,
-- TF-IDF는 R, Python을 통해 계산할 수 있다.

### 4. 연령별 Worst Department
select *
from 
(select *,
row_number() over(partition by ageband order by avg_rate) as ranks
from 
(select floor(age/10)*10 as ageband,
`department name`, 
avg(rating) as avg_rate
from dataset2
group by 1,2) A) A
where ranks = 1
order by ageband;

### 5. Size Complain
select `review text`,
case when `review text` like "%size%" then 1 else 0 end as `size_review`
from dataset2;

select count(*) as `total_count`,
sum(case when `review text` like "%size%" then 1 else 0 end) as `n_size`
from dataset2;

select floor(`age`/10)*10 as `ageband`,
`department name`,
sum(case when `review text` like "%size%" then 1 else 0 end)/count(*) as `n_size`,
sum(case when `review text` like "%large%" then 1 else 0 end)/count(*) as `large_size`,
sum(case when `review text` like "%loose%" then 1 else 0 end)/count(*) as `loose_size`,
sum(case when `review text` like "%small%" then 1 else 0 end)/count(*) as `small_size`,
sum(case when `review text` like "%tight%" then 1 else 0 end)/count(*) as `tight_size`,
sum(1) as `n_total`
from dataset2
group by 1,2
order by 1,2;

### 6. Clothing id별 size review
select `clothing id`,
sum(case when `review text` like "%size%" then 1 else 0 end) as `n_size_total`,
sum(case when `review text` like "%size%" then 1 else 0 end)/count(*) as `n_size`,
sum(case when `review text` like "%large%" then 1 else 0 end)/count(*) as `large_size`,
sum(case when `review text` like "%loose%" then 1 else 0 end)/count(*) as `loose_size`,
sum(case when `review text` like "%small%" then 1 else 0 end)/count(*) as `small_size`,
sum(case when `review text` like "%tight%" then 1 else 0 end)/count(*) as `tight_size`
from dataset2
group by 1;