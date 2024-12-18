SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccination
--ORDER BY 3,4

-- select data that we are going to be using

SELECT location, date, total_cases,new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2 

-- Looking at total_cases and total_deaths
-- show likelihood of dying if you contract covid in ur country
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)* 100 DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%State%'
AND continent is not null
ORDER BY 1,2 

--Looking at total_cases and population
-- show that percentage of population got covid
SELECT location, population, total_cases, (total_cases/ population) *100 Incidence_Rate
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%VietNam%'
AND continent is not null
ORDER BY 1,2 

--Looking at countries with Highest Infection Rate compared to population
SELECT location, population, MAX(total_cases) HighestInfectionRate, MAX((total_cases/ population)) *100 Incidence_Rate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Incidence_Rate DESC

-- Showing  countries with highest death count per population

SELECT location, MAX(cast(total_deaths as INT)) TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- break things down by continent
SELECT location, MAX(cast(total_deaths as INT)) TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Looking at population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) 
RollingPeopleVaccinated
-- (RollingPeopleVaccinated/ population) *100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
WHERE dea.continent is not null
ORDER BY 2,3

-- use CTE

WITH CTE_PopvsVac (Continent, Location, Date, Population, New_Vac, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) 
RollingPeopleVaccinated
-- (RollingPeopleVaccinated/ population) *100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
WHERE dea.continent is not null
-- ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated/ population) *100
FROM CTE_PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date_time DATE,
Population NUMERIC,
New_Vac NUMERIC,
RollingPeopleVaccinated NUMERIC
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) 
RollingPeopleVaccinated
-- (RollingPeopleVaccinated/ population) *100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
WHERE dea.continent is not null
-- ORDER BY 2,3



