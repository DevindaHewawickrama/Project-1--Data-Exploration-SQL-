SELECT *
FROM PortofolioProject1..CovidDeaths
ORDER BY 1,2


--SELECT *
--FROM PortofolioProject1..CovidVaccinations
--ORDER BY 1,2

--Selecting the data that are going to be used

SELECT location, date, total_cases, total_deaths, population 
FROM..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract Covid in Sri Lanka
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM..CovidDeathsAsia
WHERE location like '%Sri Lanka%'
ORDER BY 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM..CovidDeathsAsia
WHERE location like '%Sri Lanka%'
ORDER BY 1,2

--Looking at countries with highest Infection rate compared to population in Asia
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 AS PercentPopulationInfected
FROM..CovidDeathsAsia
GROUP BY location, population
ORDER BY 4 DESC

--Looking at countries with Highest Death Count per Population in Asia
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM..CovidDeathsAsia
GROUP BY location
ORDER BY TotalDeathCount DESC

--For Continents
--With highest death counts
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Global Numbers
-- total deaths , total cases and the death percentage for each day 
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM..CovidDeaths
--WHERE location like '%Sri Lanka%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Total number of deaths ,cases and the death percentage from the begining to now
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Total population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortofolioProject1..CovidDeaths dea
Join PortofolioProject1..CovidVaccinations vac
ON  dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations ,  RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortofolioProject1..CovidDeaths dea
Join PortofolioProject1..CovidVaccinations vac
ON  dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortofolioProject1..CovidDeaths dea
Join PortofolioProject1..CovidVaccinations vac
ON  dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating view to store data for visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortofolioProject1..CovidDeaths dea
Join PortofolioProject1..CovidVaccinations vac
ON  dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--order by2,3