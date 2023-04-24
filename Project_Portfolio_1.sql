use projectportfolio;

select * from coviddeaths
where continent is not null
limit 5000;

-- select specific data
select location, date, total_cases, new_cases, total_deaths, population from coviddeaths;
-- total cases vs total deaths
select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as CaseVSDeath 
from coviddeaths 
where continent is not null
group by location;

-- Location having "AF"
select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as CaseVSDeath from coviddeaths 
where location like '%af%' and continent is not null
group by location;

-- total cases vs population
select location, date, total_cases,  population, (total_cases/population)*100 as CasevsPopulation from coviddeaths 
group by location;

select location, date, total_cases,  population, (total_cases/population)*100 as PopulationInfected from coviddeaths 
group by location, date;

-- Countries with highesh infection rate compared to Population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases)/population)*100 as PopulationInfected 
from coviddeaths 
group by location, population
order by PopulationInfected desc;

-- Showing countries with Highest Death count
select location, max(cast(total_deaths as unsigned)) as TotalDeathCount 
from coviddeaths 
where continent is not null
group by location
order by HighestDeathCount desc;

-- Highlight things via continets
select continent, max(cast(total_deaths as unsigned)) as TotalDeathCount 
from coviddeaths 
where continent is not null
group by continent
order by TotalDeathCount desc;

-- showing continets with highest death count
select continent, max(cast(total_deaths as unsigned)) as TotalDeathCount 
from coviddeaths 
where location like '%af%' and continent is not null
group by continent
order by TotalDeathCount desc;

-- Global numbers
select  date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from coviddeaths 
where continent is not null
group by date;

-- New cases vs new deaths
select  date, sum(new_cases) as Total_cases,  sum(cast(new_deaths as unsigned)) as Total_deaths, 
sum(cast(new_deaths as unsigned))/sum(new_cases)*100 AS DeathPercentage
from coviddeaths 
where continent is not null
group by date;

--  Total cases vs Total deaths 
select sum(new_cases) as Total_cases,  sum(cast(new_deaths as unsigned)) as Total_deaths, 
sum(cast(new_deaths as unsigned))/sum(new_cases)*100 AS DeathPercentage
from coviddeaths 
where continent is not null;

-- Covid Vaccination
select * from covidvaccinations;

-- Join CovidDeaths & CovidVaccinations
select * from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
limit 1000;

-- looking Total population Vs Vaccinations
use projectportfolio;
select dea.date, dea.location, dea.population, dea.continent, vac.new_vaccinations
 from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by dea.location;

-- looking Total people vaccinated location wise
use projectportfolio;
select dea.date, dea.location, dea.population, dea.continent, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by dea.location;

-- using CTE
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.date, dea.location, dea.population, dea.continent, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
order by dea.location
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac;

-- Temp Table

drop temporary table if exists PercentPopulationVaccinated;
Create temporary table PercentPopulationVaccinated
(
continent varchar(255),
location varchar (255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
);
insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
order by dea.location;
select  *
from PercentPopulationVaccinated;

-- creating view to store data for visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
order by dea.location;

select * from percentpopulationvaccinated;




