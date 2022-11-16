Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3, 4


--Select *
--From PortfolioProject..CovidDeaths
--order by 3, 4


-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1, 2  


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%suriname%' and continent is not null
order by 1, 2  


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%' and continent is not null
order by 1, 2  


-- Looking at Countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%suriname%' and continent is not null
Group by population, location
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%suriname%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT



-- Showing the continent with the highest death count

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%suriname%'
Where continent is null
Group by location
order by TotalDeathCount desc




-- GLOBAL NUMBERS

Select SUM(new_cases) as TotalCases, sum(cast(new_deaths as float)) as TotalDeaths, sum(cast(new_deaths as float))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%suriname%' 
where continent is not null
--Group by date
order by 1, 2  



-- Looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location ,dea.date) as RollingPeopleVaccinated
--, Roll
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location ,dea.date) as RollingPeopleVaccinated
--, Roll
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac



--TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location ,dea.date) as RollingPeopleVaccinated
--, Roll
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3


Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating View to store data for later visualizations



Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location ,dea.date) as RollingPeopleVaccinated
--, Roll
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3