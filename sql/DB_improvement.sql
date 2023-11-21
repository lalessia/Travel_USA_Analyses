/*
Rename all tables for greater readability
*/

ALTER TABLE travel_danger.btscountrycodes
RENAME TO country_codes;

ALTER TABLE travel_danger.btsoriginus_10_09_to_06_16
RENAME TO origin_us;

ALTER TABLE travel_danger.sdamerican_deaths_abroad_10_09_to_06_16
RENAME TO american_deaths_abroad;

ALTER TABLE travel_danger.sdwarnings_10_09to06_16
RENAME TO warnings;

/*
Rename column description into country_codes with country
*/
ALTER TABLE travel_danger.country_codes
RENAME COLUMN description TO country;


/*
The column id and column x are the same, then I can drop a column x
*/
ALTER TABLE travel_danger.origin_us
DROP COLUMN x;

/*
In travel_danger.warnings table:
renamed column country to code
renamed column title to country
*/

ALTER TABLE travel_danger.warnings
RENAME COLUMN country TO code;

ALTER TABLE travel_danger.warnings
RENAME COLUMN title TO country;


/*
DATA CLEANING TABLE: travel_danger.warnings
*/

UPDATE travel_danger.warnings
SET country = REPLACE(country, ' Travel Warning', '')
WHERE country like '% Travel Warning';

UPDATE travel_danger.warnings
SET country = REPLACE(country, ', Democratic Republic of the', '')
WHERE country like '%, Democratic Republic of the';

UPDATE travel_danger.warnings
SET country = 'North Korea'
WHERE country = 'Democratic People''s Republic of Korea (North Korea)';

UPDATE travel_danger.warnings
SET country = REPLACE(country, ' Travel Alert', '')
WHERE country like '% Travel Alert';

UPDATE travel_danger.warnings
SET country = REPLACE(country, country, right(country, (length (country) - 11)))
WHERE country like '201%';

UPDATE travel_danger.warnings
SET country = REPLACE(country, country, 'Israel')
WHERE country like 'Israel%';

UPDATE travel_danger.warnings
SET country = REPLACE(country, country, 'Cote d''Ivoire')
where country like '%Ivoire%';

UPDATE travel_danger.warnings
SET country = REPLACE(country, country, 'Tunisia')
where country like 'Tunisia%';

UPDATE travel_danger.warnings
SET country = REPLACE(country, country, 'Russia')
where country like 'Russia%';

UPDATE travel_danger.warnings
SET country = REPLACE(country, country, 'South Sudan')
where country like '%South Sudan%';

UPDATE travel_danger.warnings
SET country = REPLACE(country, country, 'Haiti')
where country like 'Haiti%';

UPDATE travel_danger.warnings
SET country = REPLACE(country, country, 'Congo')
where country like '%Congo';

/*
DATA CLEANING TABLE: travel_danger.american_deaths_abroad
*/

UPDATE travel_danger.american_deaths_abroad
SET country = REPLACE(country, country, 'Albania')
where country = 'Abania';

UPDATE travel_danger.american_deaths_abroad
SET country = REPLACE(country, country, 'Dominican Republic')
where country = 'Dominica';

UPDATE travel_danger.american_deaths_abroad
SET country = REPLACE(country, country, 'Kyrgyzstan')
where country = 'Kyrgyz Republic';

UPDATE travel_danger.american_deaths_abroad
SET country = REPLACE(country, country, 'United Kingdom')
where country = 'UK';

/*
Inserted column 'type_death' to american_deaths_abroad  table, that show if death is accident or killing
*/
ALTER TABLE travel_danger.american_deaths_abroad 
ADD COLUMN type_death character varying;

UPDATE travel_danger.american_deaths_abroad  SET type_death =
	(CASE
		WHEN causeofdeath in ('homicide', 'Terrorist Action', 'Hostage-related', 'Homicide', 'Execution')
		THEN 'Killed'
		ELSE 'Accident'
	END);	
	
UPDATE travel_danger.american_deaths_abroad
SET type_death = REPLACE(type_death, type_death, 'Other Accident')
where causeofdeath in ('Other Accident', 'Other Accident-', 'Other accident');

UPDATE travel_danger.american_deaths_abroad
SET type_death = REPLACE(type_death, type_death, 'Vehicle Accident')
where causeofdeath like '%Veh%';

select distinct(causeofdeath)
from travel_danger.american_deaths_abroad
where causeofdeath not like '%Auto%'
and causeofdeath not in ('homicide', 'Terrorist Action', 'Hostage-related', 'Homicide', 'Execution')
and causeofdeath <> 'Other Accident'


UPDATE travel_danger.american_deaths_abroad
SET causeofdeath = REPLACE(causeofdeath, causeofdeath, 'Vehicle Accident - Auto')
where causeofdeath like '%Auto%'


/*
DATA CLEANING TABLE: travel_danger.continents 
*/
ALTER TABLE travel_danger.continents 
RENAME COLUMN name TO country;

ALTER TABLE travel_danger.continents 
RENAME COLUMN alpha2 TO code;
