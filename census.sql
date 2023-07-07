select * from [project for sql  Analysis].dbo.Data1

select * from [project for sql  Analysis].dbo.Data2

----number of row into the projects 

select count(*) from [project for sql  Analysis]..Data1

select count(*) from [project for sql  Analysis]..Data2


------analysis for bihar and jharkhand

select * from [project for sql  Analysis]..Data1 where state in ('Jharkhand' , 'Bihar')	

-----population of India

select sum(population) as population from [project for sql  Analysis]..Data2


------avg gorwth

select state , AVG(growth)*100 as avg_gorwth  from [project for sql  Analysis]..Data1 group by state

------avg sex Ratio

select state ,ROUND( AVG(sex_ratio),0) as sex_ratio  from [project for sql  Analysis]..Data1 group by state order by sex_ratio desc

---avg  literacy rate

select state ,ROUND( AVG(Literacy),0) as avg_literacy_ratio  from [project for sql  Analysis]..Data1 group by state having ROUND( AVG(Literacy),0)>90 order by avg_literacy_ratio desc

---top 3 state with highest growth ratio

select top 3 state , AVG(growth)*100 as avg_gorwth  from [project for sql  Analysis]..Data1 group by state order by avg_gorwth desc

---bottom  3 state with lowest sex ratio

select top  3  state ,ROUND( AVG(sex_ratio),0) as sex_ratio  from [project for sql  Analysis]..Data1 group by state order by sex_ratio asc
 

 ------top 3 and bottom 3 state in literacy 

 drop table if exists #topstates
	 Create table #topstates
	 (state nvarchar (255),
	 topstates	float
	 )
	 insert into #topstates

	select   state ,ROUND( AVG(Literacy),0) as literacy_ratio  from [project for sql  Analysis]..Data1 group by state order by literacy_ratio desc

	select top 3 * from #topstates order by #topstates.topstates desc

	
 drop table if exists #bottomstates
	 Create table #bottomstates
	 (state nvarchar (255),
	 bottomstates	float
	 )
	 insert into #bottomstates 

	select   state ,ROUND( AVG(Literacy),0) as literacy_ratio  from [project for sql  Analysis]..Data1 group by state order by literacy_ratio desc

	select top 3 * from #bottomstates order by #bottomstates.bottomstates asc

	----union operator 

	select * from (
		select top 3 * from #topstates order by #topstates.topstates desc) a 
		union
		select * from (
		select top 3 * from #bottomstates order by #bottomstates.bottomstates asc)b


	-------states starting with letter a 

	select distinct state from [project for sql  Analysis]..Data1 where lower(state)like 'a%'


	select * from [project for sql  Analysis].dbo.Data1

select * from [project for sql  Analysis].dbo.Data2
 

 ----joining both the 
 select d.state , sum(d.males) total_males ,sum(d.females) total_females from
(select c.district , c.state , round(c.population/(c.sex_ratio+1),0) males , round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.district , a.state , a.sex_ratio/1000 sex_ratio , b.population from [project for sql  Analysis]..Data1 a inner join [project for sql  Analysis]..Data2 b  on  a.district = b.district)c)d
group by d.state


------total literacy rate 
select c.state ,sum(literate_people)Total_literate_people , sum(illiterate_people)Total_illiterate_people from
(select d.district , d.state , round(d.literacy_ratio*d.population,0) literate_people , round((1-d.literacy_ratio)*d.population,0) illiterate_people from
(select a.district , a.state , a.Literacy/100 literacy_ratio , b.population from [project for sql  Analysis]..Data1 a inner join [project for sql  Analysis]..Data2 b  on  a.district = b.district)d)c
group by c.state

----popuplation in previous census

select e.state ,sum(e.previous_census_population) Previuos_census_population, sum(e.current_census_population)current_census_population from
(select d.district ,d.state ,round(d.population/(1+d.growth),0) previous_census_population , d.population current_census_population from
(select a.district , a.state , a.Growth Growth , b.population from [project for sql  Analysis]..Data1 a inner join [project for sql  Analysis]..Data2 b  on  a.district = b.district)d)e
group by e.State

 ----population versus area

select (t.Total_area/t.Previuos_census_population)as previous_population_vs_area , (t.Total_area/t.current_census_population)Current_census_population_vs_area from
(select q.* ,p.Total_area from(
select '1' as keyyy , n.*from
( select e.state ,sum(e.previous_census_population) Previuos_census_population, sum(e.current_census_population)current_census_population from
(select d.district ,d.state ,round(d.population/(1+d.growth),0) previous_census_population , d.population current_census_population from
(select a.district , a.state , a.Growth Growth , b.population from [project for sql  Analysis]..Data1 a inner join [project for sql  Analysis]..Data2 b  on  a.district = b.district)d)e
group by e.State) n)q inner join(

select '1' as keyy,m.*from
(select SUM(area_km2) Total_area from [project for sql  Analysis]..Data2)m)p on q.keyyy =p.keyy)t

------Window function 
------top 3 district with hghest literacy rate from each state

select a.* from
(select district , state , Literacy , RANK()over (partition by state order by literacy desc)Rankk from [project for sql  Analysis]..Data1)a
where a.rankk in(1,2,3)order by State