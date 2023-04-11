select * from project.dbo.Data1;

select * from project.dbo.Data2;

--count of rows into our dataset

select count(*) from project..Data1
select count(*) from project..Data2

--dataset fro jharkhand and bihar

select * from project..Data1
where state in ('Jharkhand','Bihar')

--population of india

select sum(population) as total_population from project..Data2

--avg growth 

select AVG(growth)*100 as avg_growth from project..data1

--avg growth of states

select state,AVG(growth)*100 as avg_growth from project..data1
group by state 

--avg sex ratio by states

select state,round(AVG(sex_ratio),0) as avg_sex_ratio from project..data1 group by state order by avg_sex_ratio desc 

--avg literacy rate >90

select state,round(AVG(literacy),0) as avg_literacy from project..data1 
group by state having round(AVG(literacy),0)>90 order by avg_literacy desc 

--top 3 states that shown highest avg growth rate

select top 3 state,AVG(growth)*100 as avg_growth from project..data1
group by state order by avg_growth desc

--bottom 3 states that shown lowest avg growth rate

select top 3 state,AVG(growth)*100 as avg_growth from project..data1
group by state order by avg_growth asc

--top and bottom 3 states in literacy state

drop table if exists #topstates;
create table #topstates
(
 state nvarchar(255),
 topstate float
)

insert into #topstates
select state,round(AVG(literacy),0) as avg_literacy from project..data1
group by state order by avg_literacy desc;



drop table if exists #bottomstates;
create table #bottomstates
(
 state nvarchar(255),
 bottomstate float
)

insert into #bottomstates
select state,round(AVG(literacy),0) as avg_literacy from project..data1
group by state order by avg_literacy asc;

--union operator
select * from (
select top 3 * from #topstates order by #topstates.topstate desc) as a
UNION
select * from(
select top 3 * from #bottomstates order by #bottomstates.bottomstate asc) as b


--states starting with letter a

select distinct state from project..data1
where lower(state) like 'a%'

--Advanced--

--calculating the male and female count
with cte as(
select a.district,a.state,a.sex_ratio/1000 as sex_ratio,b.population from project..data1 a inner join  project..data2 b on a.district=b.district
)

select state,round(Population/(sex_ratio+1),0) as total_males,round((population*sex_ratio)/(sex_ratio+1),0) as total_females from cte order by state

--total literacte people  total literate ppl/population=literacy ratio   

select a.district,a.state,(a.literacy/100)*b.Population as literate_people,(1-a.literacy/100)*b.Population as illiterate_people,b.population from project..data1 a inner join  project..data2 b on a.district=b.district
 

 --population in the previous census   current population=previous population+(growth*previous population)
 with cte as(
 select a.district,a.state,a.growth as growth,b.population from project..data1 a inner join  project..data2 b on a.district=b.district),

 cte1 as(
 select district,state,round(population/(1+growth),0) as previous_census_population,population as current_census_population from cte)

 ,cte2 as(
 select state,sum(previous_census_population) as total_population_previous_census,sum(current_census_population) as total_population_current_year from cte1 
 group by state)

 select sum(total_population_previous_census) as whole_previous_census_population,sum(total_population_current_year) as whole_current_census_population  from cte2

 ---population vs area

  with cte as(
 select a.district,a.state,a.growth as growth,b.population from project..data1 a inner join  project..data2 b on a.district=b.district),

 cte1 as(
 select district,state,round(population/(1+growth),0) as previous_census_population,population as current_census_population from cte)

 ,cte2 as(
 select state,sum(previous_census_population) as total_population_previous_census,sum(current_census_population) as total_population_current_year from cte1 
 group by state)
 ,whole_pop as(
 select sum(total_population_previous_census) as whole_previous_census_population,sum(total_population_current_year) as whole_current_census_population  from cte2 )
 ,area as(
 select sum(Area_km2) as total_area from project..Data2)

 select a.total_area/w.whole_previous_census_population as prev_census_comp,a.total_area/w.whole_current_census_population as curr_census_comp from whole_pop w inner join area a on 1=1

 ---Calculating population density of previous census and current census

 with cte as(
 select a.district,a.state,a.growth as growth,b.population from project..data1 a inner join  project..data2 b on a.district=b.district),

 cte1 as(
 select district,state,round(population/(1+growth),0) as previous_census_population,population as current_census_population from cte)

 ,cte2 as(
 select state,sum(previous_census_population) as total_population_previous_census,sum(current_census_population) as total_population_current_year from cte1 
 group by state)
,area as(
select state,sum(Area_km2) as total_area from project..Data2 group by state)

select c2.state,round(c2.total_population_previous_census/a.total_area,2) as prev_census_pop_density,round(c2.total_population_current_year/a.total_area,2) as current_census_pop_density 
from cte2 c2 inner join area a on c2.state=a.state


 ---( window function ) Top 3 districts of every state in terms of literacy
with rank as(
 select district,state,literacy,dense_rank() over(partition by state order by literacy desc) rnk from project..data1 
 )

  select * from rank where rnk<4 order by state

  ---Top 3 districts of every state in terms of literacy
with d_rnk as(
 select district,state,Sex_Ratio,dense_rank() over(partition by state order by sex_ratio desc) d_rnk from project..data1 
 )

  select * from d_rnk where d_rnk<4 order by state

  