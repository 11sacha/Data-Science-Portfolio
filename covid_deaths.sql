 -- select data that I'll use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM My_personal_Projects.covid_deaths
WHERE continent is not null
ORDER BY date;

 -- Looking at Total Cases vs Total Deaths
 -- Shows chances of death contracting covid in Argentina
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM covid_deaths
where location like 'Arg%' AND continent is not null;

 -- Looking at total cases vs population
 -- Show what percentage of population got covid
SELECT location, date, population, total_cases, (population/total_cases)*100 as CasesPercentage
FROM covid_deaths
where location like 'Arg%' AND continent is not null;

 -- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM covid_deaths
 -- WHERE location like 'Arg%'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC;

 -- Showing countries with highest death count per population
SELECT location, population, MAX(total_deaths) as TotalDeathCount
FROM covid_deaths
 -- WHERE location like 'Arg%'
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount DESC;


 -- Breaking it down by continent
 -- Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as SIGNED)) as TotalDeathCount
FROM covid_deaths
 -- WHERE location like 'Arg%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

 -- Global numbers by continent
SELECT continent,
SUM(new_cases) as Total_new_cases, 
SUM(cast(new_deaths as SIGNED)) as Total_new_deaths,
SUM(cast(new_deaths as SIGNED))/SUM(new_cases)*100 as DeathPercentage
FROM covid_deaths
 -- where location like 'Arg%' 
WHERE continent is not null
GROUP BY continent;

 -- Total numbers in Argentina
SELECT
SUM(new_cases) as Total_new_cases, 
SUM(cast(new_deaths as SIGNED)) as Total_new_deaths,
SUM(cast(new_deaths as SIGNED))/SUM(new_cases)*100 as DeathPercentage
FROM covid_deaths
WHERE continent is not null AND location like 'Arg%';

 -- Looking at total population vs vaccinations
SELECT dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM covid_deaths as dea
JOIN covid_vaccinations as vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null;

 -- Creating View for later visualization

CREATE VIEW PopulationVaccinated as
SELECT dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM covid_deaths as dea
JOIN covid_vaccinations as vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null;