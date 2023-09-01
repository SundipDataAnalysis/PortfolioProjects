
select * from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--select * from PortfolioProject.dbo.CovidVaccinations
--order by 3,4

-- Select data to be used

select Location, date, total_cases, new_cases, total_deaths, population -- relevant data selected creates temp table for columns selected
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2

-- calculation of total cases vs total deaths for each country
-- shows how likely deaths occur if you contract covid per country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

-- asses total cases vs population
-- percentage of population contracting Covid

select Location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
--where location like '%kingdom%'
where continent is not null
order by 1,2

-- what countries have the Highest Infection Rate compared to Population

select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS 
	PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
--where location like '%kingdom%'
where continent is not null
group by Location, population
order by PercentPopulationInfected desc

-- countries with Highest Death Count per Population

select Location, MAX(Total_deaths) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location like '%kingdom%'
where continent is not null
group by Location, population
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT 


--select location, MAX(Total_deaths) as TotalDeathCount
--from PortfolioProject.dbo.CovidDeaths
----where location like '%kingdom%'
--where continent is null
--group by location 
--order by TotalDeathCount desc  -- this code chunk shows more accurate numbers for death count

-- showing continents with highest death count per population

select continent, MAX(Total_deaths) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location like '%kingdom%'
where continent is not null
group by continent 
order by TotalDeathCount desc -- issue is some countries are excluded such as Canada


-- Global numbers

Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/
	Nullif(Sum(new_cases),0)*100 AS death_percentage
from PortfolioProject.dbo.CovidDeaths
--where location like '%kingdom%'
where continent is not null
group by date
order by 1,2 --this shows results globally for death percentages by date

-- showing the total cases globally and the total deaths recorded and death percentage globally
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/
	Nullif(Sum(new_cases),0)*100 AS death_percentage
from PortfolioProject.dbo.CovidDeaths
--where location like '%kingdom%'
where continent is not null
--group by date
order by 1,2

--joining tables together on location and date
--Total Population vs Vaccinations
 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, 
dea.date) AS RollingPeopleVaccinated -- name of new column
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
 	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- above results don't show rolling count but the total as the new column has the same values
-- it summed the new vaccinations by location - SUM(vac.new_vaccinations) OVER (Partition by dea.location)


-- USE A CTE
-- RollingPeopleVaccinated divide by population using a CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, 
dea.date) AS RollingPeopleVaccinated -- name of new column
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
 	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- TEMP TABLE

DROP table if exists #PercentPopulationVaccinated -- use drop table if exists when not using where clause below
-- adding drop table is good to make changes so when you run it multiple times, don't have to delete the view or temp table or drop temp table
Create table  #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population float, 
New_vaccinations bigint,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, 
dea.date) AS RollingPeopleVaccinated -- name of new column
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
 	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



-- Creating view to store data for visualisations

--Use PortfolioProject if the view created goes to master database in system databases
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, 
dea.date) AS RollingPeopleVaccinated -- name of new column
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
 	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

--DROP VIEW IF EXISTS PercentPopulationVaccinated -- use if it shows duplication


select * 
from PercentPopulationVaccinated
