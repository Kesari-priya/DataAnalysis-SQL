use practicedb;
-- Datawrangling  with SQL Queries
select * from dbo.earthquake;

SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'earthquake'

-- This shows that shows that the data are stored in wrong datatype; 
--Dates and time as well as some numerical values are stored with text.
-- This will throw up error during calculation and will also bring out wrong queries that will skew our analysis.alter

SELECT MIN(len(Date)), MAX(len(Date))
from dbo.earthquake;-- MIN=10, Max=24

-- Making sure that there are no other length apart from the two above

SELECT * FROM dbo.earthquake where len(Date) <> 10 and  len(Date)<> 24;

-- Using the LEFT function to clean up the Date string
SELECT LEFT(Date,10) from dbo.earthquake;
UPDATE dbo.earthquake SET Date=LEFT(Date,10);
SELECT Date FROM dbo.earthquake where len(Date)= 24; --No Rows RETURNED

SELECT DATE from dbo.earthquake where len(Date)=11;--1975-02-23T02:58:41.000Z
SELECT DATE from dbo.earthquake where date like '____-__-__';
UPDATE dbo.earthquake SET Date='28-04-1985' where Date like'1985-04-28%';

-- To Standardize Date column
ALTER TABLE dbo.earthquake
ADD  Date2 date;-- New Column Added

SELECT CONVERT(date,Date,103) from dbo.earthquake;
--Converting Date Column datatype

UPDATE dbo.earthquake SET DATE2 =CONVERT(date, Date,103);-- throws up some error of incorrect datetime values

-- To find the cause of the error
Select * from dbo.earthquake
where DATE like '____-%';-- 3 rown returned
--(since there are not much I will manually update the 3 columns with REPLACE function

SELECT Date, DATE2 from dbo.earthquake;

--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- To standardize the time column

SELECT cast (Time as time) as Updated_Time from dbo.earthquake;

ALTER TABLE dbo.earthquake
ADD  Time2 time;-- New Column Added

UPDATE dbo.earthquake SET Time2 =cast (Time as time);-- this threw up error 'Truncated incorrect time value'

-- To find the cause of the error
Select  max(len(Time)), min(len(Time)) from dbo.earthquake;-- min=8, max =24

Select  * from dbo.earthquake where  len(Time)=24;--3
Select  * from dbo.earthquake where  len(Time)=8;--23409

-- To show the abnormal time length:
select Time from dbo.earthquake where  len(Time)=24; 

-- Cleaning up the Time length with SUBSTRING FUNCTION
Select Time, SUBSTRING(Time,12,8) as 'new time' from dbo.earthquake where len(Time) = 24;-- 3 Rows found

-- To replace the 3 rows with the correct Time length
update dbo.earthquake
Set Time = replace(Time,'1975-02-23T02:58:41.000Z', SUBSTRING(Time,12,8))
where Time = '1975-02-23T02:58:41.000Z';

update dbo.earthquake 
Set Time = replace(Time,'1985-04-28T02:53:41.530Z', SUBSTRING(Time,12,8))
where Time = '1985-04-28T02:53:41.530Z';

update dbo.earthquake 
Set Time = replace(Time,'2011-03-13T02:23:34.520Z', SUBSTRING(Time,12,8))
where Time = '2011-03-13T02:23:34.520Z';

-- To check if the correction has been effected correctly
Select min(len(Time)), Max(len(Time)) from dbo.earthquake;-- Min(8), Max(8)

-- Again Update the new column Time2
Update datacleaning.earthquakes
set Time2 = cast(Time as time);

SELECT TIME, Time2 from dbo.earthquake;

--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Using CASE FUNCTION handle the blank values in the columns before converting them to the appropriate datatype
Select count(*) from dbo.earthquake where DepthError = ''-- 18951 rows returned

ALTER TABLE dbo.earthquake ALTER column DepthError double;
ALTER TABLE dbo.earthquake ALTER column Depth_Seismic_Stations int;
ALTER TABLE dbo.earthquake ALTER column MagnitudeError double;
ALTER TABLE dbo.earthquake ALTER column Magnitude_Seismic_Stations int;
ALTER TABLE dbo.earthquake ALTER column AzimuthalGap double;
ALTER TABLE dbo.earthquake ALTER column HorizontalDistance double;
ALTER TABLE dbo.earthquake ALTER column HorizontalError double;
ALTER TABLE dbo.earthquake ALTER column Root_Mean_Square double; 

UPDATE dbo.earthquake SET [DepthError]= CASE 
WHEN [DepthError]='' then 0.0 ELSE [DepthError] END;

UPDATE dbo.earthquake SET [Depth_Seismic_Stations]= CASE 
WHEN [Depth_Seismic_Stations]='' then 0.0 ELSE [Depth_Seismic_Stations] END;

UPDATE dbo.earthquake SET [MagnitudeError]= CASE 
WHEN [MagnitudeError]='' then 0.0 ELSE [MagnitudeError] END;

UPDATE dbo.earthquake SET [HorizontalError]= CASE 
WHEN [HorizontalError]='' then 0.0 ELSE [HorizontalError] END;

UPDATE dbo.earthquake SET [Magnitude_Seismic_Stations]= CASE 
WHEN [Magnitude_Seismic_Stations]='' then 0.0 ELSE [Magnitude_Seismic_Stations] END;

UPDATE dbo.earthquake SET [HorizontalDistance]= CASE 
WHEN [HorizontalDistance]='' then 0.0 ELSE [HorizontalDistance] END;

UPDATE dbo.earthquake SET [AzimuthalGap]= CASE 
WHEN [AzimuthalGap]='' then 0.0 ELSE [AzimuthalGap] END;

UPDATE dbo.earthquake SET [Root_Mean_Square]= CASE 
WHEN [Root_Mean_Square]='' then 0.0 ELSE [Root_Mean_Square] END;
--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- CHECKING FOR DUPLICATES USING CTE
With cte as (
SELECT *, row_number() over(partition by Date2, Time2, Latitude, Longitude order by ID) rownum
from dbo.earthquake)
Select count(*) from cte where rownum >1; -- 0 (No duplicate values)

-- CREATING NEW COLUMNS (YEAR, MONTH, DAY, WEEK, DAY OF WEEK) FROM THE DATE2 COLUMN
-- Year 
SELECT YEAR(Date2) from dbo.earthquake;--YEAR

Alter table dbo.earthquake 
Add Year int;
--Add Weekdays varchar(10);--alter table datacleaning.earthquakes add column Year int after Time2;
Update dbo.earthquake set Year =YEAR(Date2);

--- Month and MonthName
select MONTH(Date2), Datename(month,Date2) from dbo.earthquake;

Alter table dbo.earthquake 
Add Month int; 

Update dbo.earthquake set Month =Month(Date2);

-- Week
Select Datename(WEEK,Date2) from dbo.earthquake;

Alter table dbo.earthquake
Add column Week int;

update dbo.earthquake set Week =Datename(WEEK,Date2);

-- Day of the week
select Datename(WEEKDAY,Date2) from dbo.earthquake;

Alter  table dbo.earthquake 
Add Weekdays VARCHAR(10); 

update dbo.earthquake set Weekdays =Datename(WEEKDAY,Date2);

-- Looking for outliers (with the knowledge that the years data were collected were 1965-2016 and magnitude is >= 5.5)
select Year from dbo.earthquake 
where Year < 1965 or Year > 2016; --0

select * from dbo.earthquake
where Magnitude < 5.5; -- 0

-- Deleting UNUSED COLUMN
Alter table dbo.earthquake
Drop column Date,
Drop column Time;

Select * from dbo.earthquake;
