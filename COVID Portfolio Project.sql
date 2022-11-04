Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--Looking at Total Cases vs. Total Deaths
-- Shows likelihood of dying if you get covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
where location like '%canada%'
order by 1,2


--Looking at Total Cases vs. Population
--Shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
--where location like '%canada%'
order by 1,2

--Looking at countries with highest infection rate comapred to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
--where location like '%canada%'
Group by location, population
order by PercentPopulationInfected desc


-- LET'S BREAK THINGS DOWN BY CONTINENT



--Showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%canada%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%canada%'
Where continent is not null
--Group by date
order by 1,2



-- USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations, total_vaccinations)
as
(
-- Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as total_vaccinations
--, (total_vaccinations/population)*100
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (total_vaccinations/population)*100
From PopvsVac



--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_vaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as total_vaccinations
--, (total_vaccinations/population)*100
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (total_vaccinations/population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as total_vaccinations
--, (total_vaccinations/population)*100
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3



Select *
From PercentPopulationVaccinated