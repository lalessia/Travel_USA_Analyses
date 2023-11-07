CREATE TABLE travel_danger.SDwarnings_10_09to06_16
(
title character varying,
country character varying,
pubdate character varying,
link character varying,
description character varying
);

COPY travel_danger.SDwarnings_10_09to06_16 FROM '/Users/malefica/alessia/informatica/corsi/start_to_impact/01_SQL/progetto finale/travel/final_project/dataset/SDwarnings_10_09to06_16.csv' WITH (FORMAT csv);
CREATE TABLE travel_danger.BTSCountryCodes
(
Code character varying,
Description character varying
);

COPY travel_danger.BTSCountryCodes FROM '/Users/malefica/alessia/informatica/corsi/start_to_impact/01_SQL/progetto finale/travel/final_project/dataset/BTSCountryCodes.csv' WITH (FORMAT csv);
CREATE TABLE travel_danger.SDamerican_deaths_abroad_10_09_to_06_16
(
country character varying,
date character varying,
location character varying,
causeofdeath character varying
);

COPY travel_danger.SDamerican_deaths_abroad_10_09_to_06_16 FROM '/Users/malefica/alessia/informatica/corsi/start_to_impact/01_SQL/progetto finale/travel/final_project/dataset/SDamerican_deaths_abroad_10_09_to_06_16.csv' WITH (FORMAT csv);
CREATE TABLE travel_danger.continents2
(
name character varying,
alpha2 character varying,
alpha3 character varying,
countrycode integer,
iso31662 character varying,
region character varying,
subregion character varying,
intermediateregion character varying,
regioncode real,
subregioncode real,
intermediateregioncode real
);

COPY travel_danger.continents2 FROM '/Users/malefica/alessia/informatica/corsi/start_to_impact/01_SQL/progetto finale/travel/final_project/dataset/continents2.csv' WITH (FORMAT csv);
CREATE TABLE travel_danger.BTSOriginUS_10_09_to_06_16
(
id integer,
X integer,
PASSENGERS integer,
ORIGINCOUNTRY character varying,
DESTCOUNTRY character varying,
YEAR integer,
MONTH integer
);

COPY travel_danger.BTSOriginUS_10_09_to_06_16 FROM '/Users/malefica/alessia/informatica/corsi/start_to_impact/01_SQL/progetto finale/travel/final_project/dataset/BTSOriginUS_10_09_to_06_16.csv' WITH (FORMAT csv);
