USE PortfolioProject;

SELECT * FROM covid_deaths;

SELECT * FROM covidvac;

SELECT location, date, total_cases, new_cases, total_deaths, population FROM covid_deaths
ORDER BY 1,2;

-- Totalcases // totaldeaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS Deathpercentage FROM covid_deaths
WHERE location LIKE '%Nigeria%'
ORDER BY 1,2;

-- Totalcases // population

SELECT location, date, total_cases, population, (total_cases/population)* 100 AS Deathpercentage FROM covid_deaths
WHERE location LIKE '%Nigeria%'
ORDER BY 1,2;

-- looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX(total_cases/population) * 100 AS PercentPopulationInfected FROM covid_deaths
GROUP BY population, location 
ORDER BY PercentPopulationInfected DESC;

-- showing countries with the highest death count per population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM covid_deaths
WHERE continent is not NULL 
GROUP BY location 
ORDER BY TotalDeathCount DESC;

-- showing continents with the highest death count per population
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM covid_deaths
WHERE continent is not NULL 
GROUP BY continent 
ORDER BY TotalDeathCount DESC;


-- Global NUMbers
SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths,SUM(new_deaths)/SUM(new_cases)* 100 AS DeathPercentage
FROM covid_deaths
WHERE continent is not NULL 
GROUP BY date
ORDER BY 1,2;

/* joining the two table togther using date and location */

SELECT * FROM covid_deaths dea
JOIN covidvac vac
ON dea.location = vac.location
AND dea.date = vac.date
 ORDER BY 1,2;

-- looking at total-population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollPeopleVac
FROM covid_deaths dea
JOIN covidvac vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL

/* want to get totalnumber of vaccinated people 
 * using the new column RollPopleVac/population
 * introduce CTE so it can allow the ne column created "RollPeopleVac to be used
 */

-- CTE
WITH PopvsVac(continent, location, date, population, new_vaccinations, RollPeopleVac) 

AS

(

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollPeopleVac
FROM covid_deaths dea
JOIN covidvac vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL

)
SELECT *,(RollPeopleVac/population)*100 FROM PopvsVac


/* second method
 * using template table
 */

DROP TABLE if exists peoplevaccinated
CREATE TABLE peoplevaccinated
(Continent NVARCHAR(255),
 Location NVARCHAR(255),
 Date date,
 Population numeric,
 New_vaccinations numeric,
 RollPeopleVac numeric
)
Insert into peoplevaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollPeopleVac
FROM covid_deaths dea
JOIN covidvac vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
SELECT *,
(RollPeopleVac/population)*100 
    FROM peoplevaccinated


-- creating views to store data for later visualisation
CREATE VIEW peoplevaccinatedd AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollPeopleVac
FROM covid_deaths dea
JOIN covidvac vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL

























