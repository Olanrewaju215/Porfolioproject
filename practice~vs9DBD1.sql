select *
from [portfolio project ]..CovidDeaths
order by 3,4

--select *
--from [portfolio project ]..Covidvacciantion
--order by 3,4

-- Select Data for the project 

select location, date, total_cases, new_cases, total_deaths, population
from [portfolio project ]..CovidDeaths


-- Looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [portfolio project ]..CovidDeaths
where location like '%nigeria%'

--looking at the total cases vs population
--shows what percentage of population got covid

select location, date, total_cases, population, (total_cases/population)*100 as CasesPopulation
from [portfolio project ]..CovidDeaths
--where location like '%nigeria%'

-- looking at country with highest infection rate compared to population
select location, population , max(total_cases) as Highestinfectioncount, max((total_deaths/total_cases))*100 as CasesPopulation
from [portfolio project ]..CovidDeaths
--where location like '%nigeria%'
group by location, population
order by CasesPopulation desc

--showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as Totaldeathcount
from [portfolio project ]..CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by location
order by Totaldeathcount desc

--lets break things down by continent

select continent, max(cast(total_deaths as int)) as Totaldeathcount
from [portfolio project ]..CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by continent
order by Totaldeathcount desc

-- shwoing continents with the highest death counts per population
select continent, max(cast(total_deaths as int)) as Totaldeathcount
from [portfolio project ]..CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by continent
order by Totaldeathcount desc

-- global numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [portfolio project ]..CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by date
order by 1,2

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [portfolio project ]..Coviddeaths dea
join [portfolio project ]..Covidvacciantion vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
order by 2,3

--use cte
with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [portfolio project ]..Coviddeaths dea
join [portfolio project ]..Covidvacciantion vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
--order by 2,3
)
select *
from popvsvac

-- temp table
Drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)
insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [portfolio project ]..Coviddeaths dea
join [portfolio project ]..Covidvacciantion vac
	on dea.location = vac.location
	and dea.date = vac.date
--	where dea.continent is not null 
--order by 2,3
select *, (Rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated

--creating view to store data for later visualization
create view percentpopulationvacinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [portfolio project ]..Coviddeaths dea
join [portfolio project ]..Covidvacciantion vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *
from percentpopulationvacinated