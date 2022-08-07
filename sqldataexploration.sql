select *
from PortfolioProject..coviddeaths
order by 3,4

--select *
--from PortfolioProject..covidvacines
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..coviddeaths
order by 1,2

--total cases vs total deaths vs population
select location, date, total_cases, population, (total_cases/population)*100 as deathperrentage
from PortfolioProject..coviddeaths
where location like '%india%' 
order by 1,2

-- looking at countires witht highest infection rate compared to population

select location, max(total_cases) as highestinfection, population, (max(total_cases)/population)*100 as highestpopulationinfected
from PortfolioProject..coviddeaths
--where location like '%india%' 
group by location, population
order by highestpopulationinfected desc

--shows countries with highest death count per population

select location, max(total_cases) as highestinfection, population, (max(total_cases)/population)*100 as highestpopulationinfected
from PortfolioProject..coviddeaths
--where location like '%india%' 
group by location, population
order by highestpopulationinfected desc

-- shows countries with highest death count
select location, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..coviddeaths
--where location like '%india%' 
where continent is not null
group by location
order by totaldeathcount desc


-- lets break things down by continent

select continent, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..coviddeaths
--where location like '%india%' 
where continent is not null
group by continent
order by totaldeathcount desc

-- shows the continent with highest death count per population

select continent, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..coviddeaths
--where location like '%india%' 
where continent is not null
group by continent
order by totaldeathcount desc


--gloabl numbers

select sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..coviddeaths
--where location like '%india%' 
where continent is not null
order by 1,2

-- looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated 
from PortfolioProject..coviddeaths dea 
join PortfolioProject..covidvacines vac	
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte

with PopsvsVac (continent, location, date, population, New_vaccinations, rollingpeoplevaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplecvaccinated 
from PortfolioProject..coviddeaths dea 
join PortfolioProject..covidvacines vac	
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

)

select *, (rollingpeoplevaccinated/population)*100
from PopsvsVac

--temp table

drop table if exists #percentpopulationvaccinated
Create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplecvaccinated 
from PortfolioProject..coviddeaths dea 
join PortfolioProject..covidvacines vac	
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated

--creating view to store data for visualization

create view percentpopulationvaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplecvaccinated 
from PortfolioProject..coviddeaths dea 
join PortfolioProject..covidvacines vac	
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from percentpopulationvaccinated