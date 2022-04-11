--SELECT *
--FROM Portfolio_Project..Covid_vaccination
--ORDER BY 3,4

--SELECT *
--FROM Portfolio_Project..Covid_Deaths
--ORDER BY 3,4

--Exploratoty Data Analysis: Deaths
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project..Covid_Deaths
ORDER BY 1,2

--Total cases vs Total Deaths [Percentage]
-- shows the likelihood of dying at present
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
FROM Portfolio_Project..Covid_Deaths
WHERE location LIKE '%states%'
ORDER BY 1,2

--Total cases vs Population [Percentage]
--Percentage of people got affected by Covid-19
SELECT location, date,population, total_cases,  (total_cases/population)*100 as Cases_percentage
FROM Portfolio_Project..Covid_Deaths
--WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at countries with highest covid rates  compared to population

SELECT location,population, MAX(total_cases) as Highest_CaseCount,  MAX((total_cases/population))*100 as MaxPopulation_percentage
FROM Portfolio_Project..Covid_Deaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY MaxPopulation_percentage DESC

-- Countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM Portfolio_Project..Covid_Deaths
--WHERE location LIKE '%states%'
WHERE continent is not NULL
GROUP BY location
ORDER BY Total_Death_Count DESC

--CONTINENT

--Continents with highest death counts

SELECT continent, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM Portfolio_Project..Covid_Deaths
--WHERE location LIKE '%states%'
WHERE continent is not NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC

--Global Statistics [Grouped by date]

SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as INT)) as Total_Deaths , SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as Death_percentage_Global
FROM Portfolio_Project..Covid_Deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Joining Deaths and Vaccination Table
SELECT *
FROM Portfolio_Project..Covid_Deaths dea
JOIN Portfolio_Project..Covid_vaccination vac
ON dea.location = vac.location
AND dea.date = vac.date

-- Number of new vaccinations per population grouped by date and the location

SELECT dea.continent , dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
as Rolling_Vaccination_Count
FROM Portfolio_Project..Covid_Deaths dea
JOIN Portfolio_Project..Covid_vaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

--USING CTE
 with POPvsVAC (continent, location, date, population, new_vaccinations,Rolling_Vaccination_Count)
 as 
 (
 SELECT dea.continent , dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
as Rolling_Vaccination_Count
FROM Portfolio_Project..Covid_Deaths dea
JOIN Portfolio_Project..Covid_vaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
)
SELECT *, (Rolling_Vaccination_Count/population)*100
FROM POPvsVAC

--Temp Table

DROP TABLE if exists PercentageOfPopulationVaccinated
CREATE TABLE PercentageOfPopulationVaccinated
(
Continent nvarchar(200),
Location nvarchar(200),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_Vaccination_Count numeric
)
INSERT INTO PercentageOfPopulationVaccinated
 SELECT dea.continent , dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
as Rolling_Vaccination_Count
FROM Portfolio_Project..Covid_Deaths dea
JOIN Portfolio_Project..Covid_vaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not NULL
SELECT *, (Rolling_Vaccination_Count/population)*100
FROM PercentageOfPopulationVaccinated





