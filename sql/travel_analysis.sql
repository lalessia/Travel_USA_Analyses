


--GEOPOLITICAN ANALYSIS

/*WARNING*/

/*
This query aims highlight the COUNTRY order by TOTAL WARNING receved by USA 

Query columns detail:
- country
- tot_warn
- warn_rank
*/
select w.country, count(*) AS tot_warn, ROW_NUMBER() OVER(ORDER BY count(*) DESC) AS warn_rank
from travel_danger.warnings as w
group by w.country
order by 3;

/*total warning for sub region*/
select c.region, c.subregion, count(c.subregion) as tot_warn_for_subregion
from travel_danger.warnings as w
left join travel_danger.continents c
on c.country = w.country
where region is not null
group by c.region, c.subregion 
order by 3 desc;

/*total warning for continents */
select c.region, count(c.region) as tot_warn_for_region
from travel_danger.warnings as w
left join travel_danger.continents c
on c.country = w.country
where region is not null
group by c.region 
order by 2 desc;

/*
list of countries that have received at least one warning
*/
select distinct(country) from(
select w.country, count(*) as tot_warn
from travel_danger.warnings as w
group by w.country);


/*AMERICAN DEATH ABROAD*/

/*
Country by American Killed
*/
select ad.country, count(*) as tot_killed, ROW_NUMBER() OVER(ORDER BY count(*) DESC) AS warn_killed
from travel_danger.american_deaths_abroad as ad
where ad.causeofdeath 
	in ('homicide', 'Terrorist Action', 'Hostage-related', 'Homicide', 'Execution')
group by ad.country
order by 2 desc;

/*
total American Killed per subregion
*/
select c.subregion, count(*) as tot_kill_for_subregion --ad.country, count(*) as tot_killed, ROW_NUMBER() OVER(ORDER BY count(*) DESC) AS warn_killed
from travel_danger.american_deaths_abroad as ad
inner join travel_danger.continents as c
on c.country = ad.country
where ad.causeofdeath 
	in ('homicide', 'Terrorist Action', 'Hostage-related', 'Homicide', 'Execution')
group by c.subregion
order by 2 desc;

/*
total American Killed per continents
*/
select c.region, count(*) as tot_kill_for_region --ad.country, count(*) as tot_killed, ROW_NUMBER() OVER(ORDER BY count(*) DESC) AS warn_killed
from travel_danger.american_deaths_abroad as ad
inner join travel_danger.continents as c
on c.country = ad.country
where ad.causeofdeath 
	in ('homicide', 'Terrorist Action', 'Hostage-related', 'Homicide', 'Execution')
group by c.region
order by 2 desc;

/*PASSENGERS*/

/*
Numbers passengers by country
*/
select destcountry as country_code, c.country, sum(ou.passengers) as total_passengers
from travel_danger.origin_us ou inner join travel_danger.continents as c
on ou.destcountry = c.code
group by destcountry, c.country
order by 3 desc;

/*
Numbers passengers by subregion
*/
select c.subregion, sum(ou.passengers) as total_passengers
from travel_danger.origin_us ou inner join travel_danger.continents as c
on ou.destcountry = c.code
group by c.subregion
order by 2 desc;

/*
passengers month by month, country by country
*/
select o.destcountry as code, c.country, o.year, o.month, sum(o.passengers) as tot_pass
from travel_danger.origin_us as o
inner join travel_danger.continents as c
on o.destcountry = c.code
group by o.destcountry, o.year, o.month, c.code, c.country
order by 1, 3, 4

/*
Percentage travelling killed respect travelling total death
*/
select tot_kill.*, tot_death.total_death, tot_pass.total_passengers,
round(tot_kill.total_killed::decimal / tot_pass.total_passengers * 100000, 2) as perc_killed_on_traveller,
round(tot_kill.total_killed::decimal / tot_death.total_death, 2) * 100 as perc_killed_on_death
from (
	select ad.country, count(*) as total_killed
	from travel_danger.american_deaths_abroad as ad
	where type_death = 'Killed'
	group by country
	order by 2 desc
) as tot_kill 
inner join (
	select ad.country, count(*) as total_death
	from travel_danger.american_deaths_abroad as ad
	group by ad.country
) as tot_death
on tot_death.country = tot_kill.country
inner join (
	select c.country, sum(ou.passengers) as total_passengers
	from travel_danger.origin_us ou inner join travel_danger.continents as c
	on ou.destcountry = c.code
	group by c.country
) as tot_pass 
on tot_pass.country = tot_death.country
where tot_pass.total_passengers > 0
and tot_pass.total_passengers > tot_death.total_death
and tot_pass.total_passengers > 100000
order by 6 desc;

/*
	Relazione tra emissione dei warning e passeggeri aggregate per country nei mesi appena prima del warning 
	e subito dopo i warning
*/
select *, 
	pass_next_month - pass_past_month as delta_pass,
	CASE
		WHEN pass_next_month <> 0 THEN 
	 	ROUND((pass_next_month + pass_past_month)::decimal/pass_next_month, 2)*((pass_next_month - pass_past_month)/abs(pass_next_month - pass_past_month))
		WHEN pass_next_month = 0 THEN 0
		ELSE 0
	END AS perc_delta_pass
	from(
		with trafic_pass as (
			select o.destcountry, c.country, o.year, o.month, sum(o.passengers) as tot_pass
			from travel_danger.origin_us as o
			inner join travel_danger.continents as c
			on o.destcountry = c.code
			group by o.destcountry, o.year, o.month, c.code, c.country
		)
		select w.pubdate::date as warn_date
		, w.country
		, EXTRACT(MONTH FROM pubdate::date) as month
		, EXTRACT(YEAR FROM pubdate::date) as year
		, warn_rank.num_warn
		, warn_rank.warn_rank
		, (select tot_pass
		   from trafic_pass
		   where year = EXTRACT(YEAR FROM pubdate::date - INTERVAL '1 MONTH')
		   and country = w.country
		   and month = EXTRACT(MONTH FROM pubdate::date - INTERVAL '1 MONTH')
		  ) as pass_past_month, 
		(select tot_pass
		 from trafic_pass
		 where year = EXTRACT(YEAR FROM pubdate::date + INTERVAL '1 MONTH')
		 and country = w.country
		 and month = EXTRACT(MONTH FROM pubdate::date + INTERVAL '1 MONTH')
		) as pass_next_month
		from travel_danger.warnings as w
		inner join (
			select w.country, count(*) AS num_warn, ROW_NUMBER() OVER(ORDER BY count(*) DESC) AS warn_rank
			from travel_danger.warnings as w
			group by w.country
		)as warn_rank
		on w.country = warn_rank.country
	)
	order by  10 desc;


/* 
Distribuzione dei morti, uccisioni, warning, passeggeri nei diversi mesi dell'anno
*/

select tot_d.*, tot_k.total_killed, tot_p.total_passengers, tot_w.total_warning
from(
	--total death month by month
	select EXTRACT(MONTH FROM date::date) as month, count(*) as total_death
	from travel_danger.american_deaths_abroad
	group by EXTRACT(MONTH FROM date::date)
) as tot_d
inner join (
	--total killed month by month
	select EXTRACT(MONTH FROM date::date) as month, count(*) as total_killed
	from travel_danger.american_deaths_abroad d
	where d.type_death = 'Killed'
	group by EXTRACT(MONTH FROM date::date)
) as tot_k
on tot_d. month = tot_k.month
inner join (
	--total passengers month by month
	select month, sum(o.passengers) as total_passengers
	from travel_danger.origin_us o
	group by month
) as tot_p
on tot_d. month = tot_p.month
inner join (
	--total warnings month by month
	select EXTRACT(MONTH FROM pubdate::date) as month, count(*) as total_warning
	from travel_danger.warnings
	group by EXTRACT(MONTH FROM pubdate::date)
) as tot_w
on tot_d. month = tot_w.month
order by 1;

/* 
Distribuzione dei morti, uccisioni, warning, passeggeri nei diversi anni 
*/

select tot_d.*, tot_k.total_killed, tot_p.total_passengers, tot_w.total_warning
from(
	--total death year by year
	select EXTRACT(year FROM date::date) as year, count(*) as total_death
	from travel_danger.american_deaths_abroad
	group by EXTRACT(year FROM date::date)
) as tot_d
inner join (
	--total killed year by year
	select EXTRACT(year FROM date::date) as year, count(*) as total_killed
	from travel_danger.american_deaths_abroad d
	where d.type_death = 'Killed'
	group by EXTRACT(year FROM date::date)
) as tot_k
on tot_d.year = tot_k.year
inner join (
	--total passengers year by year
	select year, sum(o.passengers) as total_passengers
	from travel_danger.origin_us o
	group by year
) as tot_p
on tot_d.year = tot_p.year
inner join (
	--total warnings year by year
	select EXTRACT(year FROM pubdate::date) as year, count(*) as total_warning
	from travel_danger.warnings
	group by EXTRACT(year FROM pubdate::date)
) as tot_w
on tot_d.year = tot_w.year
order by 1;

/*
elenco dei paesi che hanno ricevuto warning ma non riportano uccisioni
*/ 

select country, count(*) as num_warn
from travel_danger.warnings
where country not in (
	select country
	from travel_danger.american_deaths_abroad
	where type_death = 'Killed'
	group by country
)
group by country
order by 2 desc;

/*
elenco dei paesi che hanno commesso omicidi ma non riportano warning
*/
select country, count(*) as num_killed
from travel_danger.american_deaths_abroad
where type_death = 'Killed' 
and country not in (
	select country
	from travel_danger.warnings 
	group by country
)
group by country
order by 2 desc;

/* 
Report by continents
(continent, total_warning, total_passenger, total_death, total_killed) 
*/

select pass.*, warn.total_warning, death.total_death, kill.total_killed
from(
	-- total passengers by continents
	select c.region, sum (pass.passengers) as total_passengers
	from travel_danger.origin_us pass
	inner join travel_danger.continents as c
	on pass.destcountry = c.code
	group by c.region
) as pass 
full outer join(
	-- total warning by country
	select c.region, count(w.pubdate) as total_warning
	from travel_danger.warnings as w
	inner join travel_danger.continents as c
	on w.country = c.country
	group by c.region
) as warn
on pass.region = warn.region
full outer join(
	-- total death by continents
	select c.region, count(date) as total_death
	from travel_danger.american_deaths_abroad as d
	inner join travel_danger.continents as c
	on d.country = c.country
	group by region
	
) as death
on pass.region = death.region
full outer join(
	-- total killed by continents
	select c.region, count(date) as total_killed
	from travel_danger.american_deaths_abroad as d
	inner join travel_danger.continents as c
	on d.country = c.country
	where d.type_death = 'Killed'
	group by region
	
)as kill
on pass.region = kill.region;

select distinct(causeofdeath)
from travel_danger.american_deaths_abroad
order by 1;


/************
ZONA TEST 
************
*/

select *
from travel_danger.continents

select distinct country from(
select pass_by_month.*, warn.date as date_warning
from (
	select pass.destcountry, pass.year, pass.month, sum(pass.passengers) as num_pass, cc.country
	from travel_danger.origin_us as pass 
	inner join 
	travel_danger.country_codes as cc
	on cc.code = pass.destcountry
	group by pass.destcountry, pass.year, pass.month, cc.country
) as pass_by_month
right join (
	select 
	pubdate::date as date, 
	w.country, 
	w.code, 
	EXTRACT(MONTH FROM pubdate::date) as month,
	EXTRACT(YEAR FROM pubdate::date) as year,
	count(*) as num_warning
	from travel_danger.warnings w
	group by w.country, w.pubdate::date, w.code
) as warn
on warn.country = pass_by_month.country
and warn.month = pass_by_month.month
and warn.year = pass_by_month.year
and warn.country in (
	select distinct(country) from(
		select w.country, count(*) as tot_warn
		from travel_danger.warnings as w
		group by w.country
		order by tot_warn desc)
)
order by 5, 2, 3);



/*
numero di warning ordinati per stati da quelli che hanno ricevuto più warning 
a quelli che hanno ricevuto meno warning, 
ulteriormente ordinati  per ordine temporale per warning ricevuto
*/

select w.pubdate::date as date
, w.country
, EXTRACT(MONTH FROM pubdate::date) as month
, EXTRACT(YEAR FROM pubdate::date) as year
, warn_rank.num_warn
, warn_rank.warn_rank
from travel_danger.warnings as w
inner join (
	select w.country, count(*) AS num_warn, ROW_NUMBER() OVER(ORDER BY count(*) DESC) AS warn_rank
	from travel_danger.warnings as w
	group by w.country
)as warn_rank
on w.country = warn_rank.country
order by warn_rank.warn_rank, year, month;

/*
passenger month by month, country by country
*/
select o.destcountry, cc.country, o.year, o.month, sum(o.passengers) as tot_pass
from travel_danger.origin_us as o
inner join travel_danger.country_codes as cc
on o.destcountry = cc.code
group by o.destcountry, o.year, o.month, cc.code, cc.country
order by 1, 2, 3

/*
	destcountry 
	country
	year
	month
	tot_pass
*/
select o.destcountry, cc.country, o.year, o.month, sum(o.passengers) as tot_pass
from travel_danger.origin_us as o
inner join travel_danger.country_codes as cc
on o.destcountry = cc.code
group by o.destcountry, o.year, o.month, cc.code, cc.country
order by o.destcountry

/*
total travel death by continents
*/
select 
--cc.code,
--cc.country, 
--d.date, 
--d.causeofdeath, 
--d.location, 
c.region, 
--c.subregion
count(date) as total_death
from travel_danger.american_deaths_abroad as d
inner join 
travel_danger.country_codes as cc
on cc.country = d.country
inner join travel_danger.continents as c
on cc.code = c.code
group by region;

/*
total killed by continents
*/
select 
--cc.code,
--cc.country, 
--d.date, 
--d.causeofdeath, 
--d.location, 
c.region, 
--c.subregion
count(date) as total_death
from travel_danger.american_deaths_abroad as d
inner join 
travel_danger.country_codes as cc
on cc.country = d.country
inner join travel_danger.continents as c
on cc.code = c.code
where d.type_death = 'Killed'
group by region;

/*
the query return this columns:
code, country, num_warning, region, subregion
group by num_warning
*/
select cc.*, count(w.pubdate) as num_warning, 
c.region, c.subregion
from travel_danger.warnings as w
inner join travel_danger.country_codes as cc
on cc.country = w.country
inner join travel_danger.continents as c
on cc.code = c.code
group by cc.country, cc.code, c.region, c.subregion
order by num_warning desc;

/*
total warning by continents
*/
select warning_rank.region, sum(warning_rank.num_warning) as total_warning
from(
	select cc.*, count(w.pubdate) as num_warning, 
	c.region, c.subregion
	from travel_danger.warnings as w
	inner join travel_danger.country_codes as cc
	on cc.country = w.country
	inner join travel_danger.continents as c
	on cc.code = c.code
	group by cc.country, cc.code, c.region, c.subregion
	order by num_warning desc
) as warning_rank 
group by warning_rank.region;

/*
total travel death by continents
*/
select 
--cc.code,
--cc.country, 
--d.date, 
--d.causeofdeath, 
--d.location, 
c.region, 
--c.subregion
count(date) as total_death
from travel_danger.american_deaths_abroad as d
inner join 
travel_danger.country_codes as cc
on cc.country = d.country
inner join travel_danger.continents as c
on cc.code = c.code
group by region;

/*
total killed by continents
*/
select 
--cc.code,
--cc.country, 
--d.date, 
--d.causeofdeath, 
--d.location, 
c.region, 
--c.subregion
count(date) as total_death
from travel_danger.american_deaths_abroad as d
inner join 
travel_danger.country_codes as cc
on cc.country = d.country
inner join travel_danger.continents as c
on cc.code = c.code
where d.type_death = 'Killed'
group by region;

/*
total passengers by continents
*/
select c.region, 
--c.subregion, 
sum (pass.passengers) as total_passengers
--cc.*, pass.year, pass.month, pass.passengers, c.region, c.subregion 
from travel_danger.origin_us pass
inner join travel_danger.country_codes cc
on pass.destcountry = cc.code
inner join travel_danger.continents c
on c.code = cc.code
group by c.region
--, c.subregion

/*
details of continet's countries
*/
select cc.*, count(w.pubdate) as total_warning, 
c.region, c.subregion
from travel_danger.warnings as w
inner join travel_danger.country_codes as cc
on cc.country = w.country
inner join travel_danger.continents as c
on cc.code = c.code
where 
--c.region = 'Europe'
--c. region = 'Americas'
c. region = 'Africa'
--c. region = 'Asia'
group by cc.country, cc.code, c.region, c.subregion
order by total_warning desc


select *
from travel_danger.american_deaths_abroad


