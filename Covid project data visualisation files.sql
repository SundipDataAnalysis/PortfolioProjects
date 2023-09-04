-- Queries to use for data visualisations in Tableau

--1) 

-- showing the total cases globally and the total deaths recorded and death percentage globally
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/
	Nullif(Sum(new_cases),0)*100 AS death_percentage
from PortfolioProject.dbo.CovidDeaths
--where location like '%kingdom%'
where continent is not null
--group by date
order by 1,2

---- showing the total cases globally and the total deaths recorded and death percentage globally
--Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/
--	Nullif(Sum(new_cases),0)*100 AS death_percentage
--from PortfolioProject.dbo.CovidDeaths
----where location like '%kingdom%'
--where location = 'World'
----group by date
--order by 1,2


--2) 

-- taken out as they are not included in the above queries and we want consistency across analysis
-- European union is part of Europe for example


select location, SUM(new_deaths) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location like '%kingdom%'
where continent is null
and location not in ('World', 'European Union', 'International')
and location not in ('High income', 'Upper middle income', 'Lower middle income', 'low income')
group by location
order by TotalDeathCount desc


--3)


select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS 
	PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
--where location like '%kingdom%'
group by Location, population
order by PercentPopulationInfected desc


--4)

select Location, population,date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS 
	PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
--where location like '%kingdom%'
group by Location, population, date 
order by PercentPopulationInfected desc