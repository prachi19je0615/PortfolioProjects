select *
From Portfolioproject ..CovidDeaths
where continent is not null 
--when continent is null means that this location is actually an entire continent
order by 3,4

--select *
--From Portfolioproject ..CovidVaccinations
--order by 3,4

--select data that we are going to be using

select Location, date, total_cases,new_cases, total_deaths, population
From Portfolioproject ..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract COVID in your country
select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From Portfolioproject ..CovidDeaths
where location like '%india%'
order by 1,2


--looking at total cases vs population
--shows what percentage of population got COVID
select Location, date,population, total_cases,(total_cases/population)*100 as PercentagepopulationInfected
From Portfolioproject ..CovidDeaths
--where location like '%india%'
order by 1,2

--looking at countries with highest infection rate compared to population
select Location, population, MAX(total_cases)as HighestInfectionCount ,max((total_cases/population))*100 as PercentagepopulationInfected
From Portfolioproject ..CovidDeaths
--where location like '%india%'
group by Location, population
order by PercentagepopulationInfected desc



--showing countries with highest death count per population
select Location, max(cast(total_deaths as int))as TotalDeathCount
From Portfolioproject ..CovidDeaths
--where location like '%india%'
where continent is not null 
group by Location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT 


 -- showing the continents with highest death count per population

 select continent, max(cast(total_deaths as int))as TotalDeathCount
From Portfolioproject ..CovidDeaths
--where location like '%india%'
where continent is not null 
group by continent
order by TotalDeathCount desc

-- global numbers 
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int) )/sum(New_cases) as DeathPercentage
From Portfolioproject ..CovidDeaths
--where location like '%india%'
where continent is not null
group by date
order by 1,2

--get us total cases
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int) )/sum(New_cases) as DeathPercentage
From Portfolioproject ..CovidDeaths
--where location like '%india%'
where continent is not null
--group by date
order by 1,2

-- looking at total population vs vaccinations
--joining 2 tables
-- divide RollingPeopleVaccinated by population to know how many people in that country are vaccinated this cannot be done it is showing error so we have to use temp table
select dea.continent , dea.location, dea.date,dea.population,vac.new_vaccinations,sum(convert(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3


--Use cte

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent , dea.location, dea.date,dea.population,vac.new_vaccinations,sum(convert(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select* , (RollingPeopleVaccinated/population)*100
from PopvsVac




-- temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent , dea.location, dea.date,dea.population,vac.new_vaccinations,sum(convert(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select* , (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated




-- creating view to store for later visualizations
create view PercentPopulationVaccinated as 
select dea.continent , dea.location, dea.date,dea.population,vac.new_vaccinations,sum(convert(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated 


