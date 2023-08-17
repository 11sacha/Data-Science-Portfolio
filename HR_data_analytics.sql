-- Quick overview of dataset
SELECT * FROM My_personal_Projects.hr_data_analytics_project;

DESCRIBE hr_data_analytics_project; -- table brief description

-- ** Data Cleaning **

-- changing proper column name
ALTER TABLE hr_data_analytics_project
CHANGE COLUMN id employee_id VARCHAR(20) NULL;


SET sql_safe_updates = 0; -- turns off sql security update feature

-- Date formatting birthdate column
UPDATE hr_data_analytics_project
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr_data_analytics_project
MODIFY COLUMN birthdate DATE;

-- Date formatting hire_date column
UPDATE hr_data_analytics_project
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr_data_analytics_project
MODIFY COLUMN hire_date DATE;

-- Date formatting termdate column
UPDATE hr_data_analytics_project
SET termdate = IF(termdate IS NOT NULL AND termdate != '', date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')), '0000-00-00')
WHERE true;

SELECT termdate from hr_data_analytics_project;

SET sql_mode = 'ALLOW_INVALID_DATES';

ALTER TABLE hr_data_analytics_project
MODIFY COLUMN termdate DATE;

-- Adding new column for employee's age
ALTER TABLE hr_data_analytics_project
ADD COLUMN age INT;

UPDATE hr_data_analytics_project
SET age = timestampdiff(YEAR, birthdate, CURDATE());

-- Check for abnormalities
SELECT
	MIN(age) as youngest,
    MAX(age) as oldest
FROM hr_data_analytics_project;

SELECT count(*)
FROM hr_data_analytics_project
WHERE age > 18;

-- ** Data Analysis **

-- Gender breakdown of employees
SELECT	gender,
		count(*) as count
FROM hr_data_analytics_project
GROUP BY gender;

-- Race/ethnicity breakdown of employees
SELECT	race,
		count(*) AS count
FROM hr_data_analytics_project
GROUP BY race
ORDER BY count desc;

-- Age distribution of employees
SELECT	max(age) as oldest,
		min(age) as youngest,
		avg(age) as average_age
FROM hr_data_analytics_project;

SELECT
	CASE
	WHEN age >= 18 AND age < 25 THEN '18-24'
    WHEN age >= 25 AND age < 39 THEN '25-38'
    WHEN age >= 39 AND age < 51 THEN '39-50'
    WHEN age >= 51 AND age < 58 THEN '51-57'
    ELSE '58+'
END as age_group,
count(*) as count
FROM hr_data_analytics_project
GROUP BY age_group;

-- Age distribution by gender
SELECT
	CASE
	WHEN age >= 18 AND age < 25 THEN '18-24'
    WHEN age >= 25 AND age < 39 THEN '25-38'
    WHEN age >= 39 AND age < 51 THEN '39-50'
    WHEN age >= 51 AND age < 58 THEN '51-57'
    ELSE '58+'
END as age_group,
count(*) as count,
gender
FROM hr_data_analytics_project
GROUP BY gender, age_group
ORDER BY gender, age_group;

-- Employees work location distribution
SELECT	location,
		count(*) as count
FROM hr_data_analytics_project
GROUP BY location;

-- Average length of employment
SELECT	round(avg(datediff(termdate, hire_date))/365, 2) as avg_length_employment
FROM hr_data_analytics_project
WHERE termdate <= curdate();

-- Gender distribution across departments
SELECT	department,
		gender,
        count(*) as count
FROM hr_data_analytics_project
GROUP BY department, gender
ORDER BY department;

-- Job titles distribution
SELECT	jobtitle,
		count(*) as count
FROM hr_data_analytics_project
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- Department with highest turnover rate
SELECT	department,
		total_count,
        terminated_count,
        terminated_count/total_count as termination_rate
FROM (
	SELECT department,
		count(*) as total_count,
        SUM(CASE WHEN termdate <= curdate() THEN 1 ELSE 0 END) as terminated_count
        FROM hr_data_analytics_project
        GROUP BY department
        ) as subquery
ORDER BY termination_rate DESC;

-- Distribution of employees across location by city and state
SELECT location_state,
	count(*) as count
FROM hr_data_analytics_project
GROUP BY location_state
ORDER BY count DESC;

-- Employee count over time
SELECT	
	year_1,
    hires,
    terminations,
    hires - terminations as net_change,
    round((hires - terminations)/hires * 100,2) as net_change_percent
FROM (
	SELECT	
		year(hire_date) as year_1,
        count(*) as hires,
        SUM(CASE WHEN termdate <= curdate() THEN 1 ELSE 0 END) as terminations
	FROM hr_data_analytics_project
    GROUP BY year(hire_date)
    ) as subquery
ORDER BY year_1 ASC;
    
-- Average tenure by department
SELECT	department,
	round(avg(datediff(termdate, hire_date)/365),0) as avg_tenure
FROM hr_data_analytics_project
WHERE termdate <= curdate() AND termdate<> 0000-00-00
GROUP BY department;







