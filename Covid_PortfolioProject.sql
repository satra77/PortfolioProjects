select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4 

--Select * 
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2 

--Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2 

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, Population, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2 

-- Looking at Countries with Highest Infection Rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Let's break things down by Continent

--showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) 
as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 
as DeathPercentage From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location 
Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, 
RollingPeopleVaccinated) as
(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location 
Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location 
Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

USE PortfolioProject; 
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
    --, (RollingPeopleVaccinated / population) * 100 AS PercentPopulationVaccinated
FROM 
    CovidDeaths dea
JOIN 
    CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;


DROP VIEW IF EXISTS PercentPopulationVaccinated;

Select *
From PercentPopulationVaccinated