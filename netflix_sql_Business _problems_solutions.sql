create table netflix(
show_id	varchar(10),
s_type	varchar(10),
title	varchar(200),
director varchar(250),
s_cast	varchar(1000),
country	varchar(150),
date_added	varchar(70),
release_year int,
rating	varchar(20),
duration varchar(20),
listed_in	varchar(300),
descriptions varchar(1000)
);
select * from netflix;
drop table netflix;

select *from netflix where release_year<2005;

select count(*) as total_content from netflix;

select distinct s_type from netflix;


--Business problems 
-- 1.count number of tv shows vs number of movies
select s_type,count(*) 
from netflix 
group by s_type

--2.Find most common rating for movies and tv shows
select s_type,rating  from 
(select s_type,rating, count(*),
rank()over( partition by s_type order by count(*) desc) as ranking 
from netflix group by 1,2  
order by 1,3 desc)as t1 where ranking=1

select s_type,rating, count(*),rank()over(partition by s_type order by  )
from netflix group by 1,2  order by 1,3 desc

--3.list all movies released in a specific year(2000)
select show_id, title from netflix where release_year=2000 and s_type='Movie'

--4.top 5 countries with the most content on netflix
--try
select country, count(*) from netflix group by country order by count(*) desc 
-- actual soln
select trim(unnest(string_to_array(country,','))) as new_country , 
count(show_id) as total_content from netflix
group by new_country 
order by total_content desc limit 5

--5.identify the longest movie
select show_id, duration from netflix
where s_type='Movie' 
order by duration desc nulls last
--alternate and faster
select show_id, duration from netflix
where s_type='Movie' 
and 
duration=(select max(duration) from netflix)

--6. Find the content in the last 8 years
-- as per relase date 
select show_id, release_year from netflix
where release_year>( extract(year from current_date))-8

--as per date_added
select show_id,TO_date(date_added,'Month DD,YYYY') as added_date from netflix
where TO_date(date_added,'Month DD,YYYY')>current_date- INTERVAL '8 years'

--7.Find all movies and Tv shows by director 'Rajiv Chilaka'

-- doesnot return rows with multiple directors
select show_id,title,s_type, director from netflix where director='Rajiv Chilaka';

-- correct soln but  case sensitive
select show_id,title,s_type, director from netflix where director like '%Rajiv Chilaka%';

--ilike to get all variations
select show_id,title,s_type, director from netflix where director ilike '%Rajiv Chilaka%';

--8.list all tv series with more than 5 seasons 
select *, SPLIT_PART(duration, ' ',1) as seasons 
from netflix where 
s_type='TV Show' and
 SPLIT_PART(duration, ' ',1)::int>5;

--9.count the number of content items in each genre
select

select  trim(unnest(string_to_array(listed_in,','))) as genre, 
count(*)  from netflix group by 
1 order by count desc;

/* 10.find each year and average number of  content released in india on netflix
return  top 5 years with highest avg  count*/

-- using release_year
select release_year, count(show_id)as no_of_releases from netflix 
where country= 'India' 
group by release_year order by no_of_releases desc limit 5;

--using date_added

--------total content 
select count(*) from netflix where country= 'India'

select extract(year from to_date(date_added,'Month DD YYYY'))as date, 
count(show_id)as no_of_releases,
round(count(*)::numeric/(select count(*) 
           from netflix where country= 'India')::numeric *100,2) as avg_count 
from netflix 
where country= 'India' 
group by 1 order by 2 desc limit 5;

--11.List all movies that are documentries

select show_id,s_type,listed_in from netflix  
where s_type='Movie' and 
listed_in ilike '%Documentaries%'

--12. Find all contents without a director
 select * from netflix where director is null

--13.how all movies with salman khan in the last 10 years

select show_id, title,s_cast from netflix 
where s_cast ilike '%salman khan%' and
extract(year from to_date(date_added,'Month DD,YYYY'))>(extract(year from current_date)-10)

--14.Find the top 10 actors who have appreared in the highest  umbers of movies produced in india

select 
trim(unnest(string_to_array(s_cast,','))) as actor,
count(*) as total_count 
from netflix  where country ilike '%India%'
group by 1 order by 2 desc limit 10

--15.Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords in description field . 
--label these content as 'Bad ' and all other as 'Good', 
--count how many items in each category

--select * from netflix
--using CTE
with new_table as 
(
select *, case when descriptions ilike 'kill' or 
descriptions ilike '%Violence%'
then 'Bad_content'
else 'Good_content'
end category
from netflix
)
select category, count(*)
 from new_table group by category
