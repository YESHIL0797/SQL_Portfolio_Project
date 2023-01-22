use portfolioProject;

select *
from coviddeaths
order by 3,4;


select location,date,total_cases,new_cases,total_deaths,population
from Coviddeaths c
order by 1,2;

-- Looking at total cases vs total deaths in india
-- show the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100   as DeathPercentage
from Coviddeaths 
where location like '%india%'
order by 1,2;


-- Looking at total cases vs population
-- shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100   as PercentPopulationInfected
from Coviddeaths 
where location like '%india%'
order by 1;

--  looking at the countries with the highest infection rates compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, 
	   MAX((total_cases/population))*100   as PercentPopulationInfected
from Coviddeaths 
-- where location like '%india%'
group by location, population
order by PercentPopulationInfected desc;

-- showing countries with the hightest death count per population

select location, max(cast(total_deaths as signed)) as TotalDeathCount
from Coviddeaths 
where continent is not null
group by location
order by TotaldeathCount desc;

-- Let's break things down by continent
select continent, max(cast(total_deaths as signed)) as TotalDeathCount
from Coviddeaths 
where continent is not null
group by continent
order by TotaldeathCount desc;


-- showing continent with the highest death count per population

select continent, max(cast(total_deaths as signed)) as TotalDeathCount
from Coviddeaths 
where continent is not null
group by continent
order by TotaldeathCount desc;


-- global numbers

select  sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
	 (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from Coviddeaths 
-- where location like '%india%'
where continent is not null
-- group by date
order by 1,2;



-- looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	   sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Coviddeaths dea
join covidvaccinations vac
	on dea.location =vac.location
    and dea.date =vac.date
where dea.continent is not null
order by 2,3;


-- use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	   sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Coviddeaths dea
join covidvaccinations vac
	on dea.location =vac.location
    and dea.date =vac.date
where dea.continent is not null
order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as PercentageRollingVaccination
from PopvsVac;




-- Temp table

DROP TABLE percentpopulationvaccinated;

CREATE TEMPORARY TABLE IF NOT exists percentpopulationvaccinated (
continent CHAR(255) CHARACTER SET UTF8MB4,
location CHAR(255) CHARACTER SET UTF8MB4,
date datetime,
population numeric,
new_vaccination numeric,
rollingpeoplevaccinated numeric);


INSERT INTO percentpopulationvaccinated 
SELECT dea.continent, dea.location, DATE_FORMAT(STR_TO_DATE(dea.date, '%d-%m-%Y'), '%Y-%m-%d'), dea.population, NULLIF(vac.new_vaccinations, "") as new_vaccinations, 
sum(NULLIF(vac.new_vaccinations, "")) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
FROM Coviddeaths dea 
JOIN covidvaccinations vac  ON dea.location = vac.location AND dea.date = vac.date  
WHERE dea.continent IS NOT NULL;

SELECT *, (RollingPeopleVaccinated/population)*100 as PercentageRollingVaccination FROM percentpopulationvaccinated;



-- Creating a View to store data for later visualization

Create View percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	   sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Coviddeaths dea
join covidvaccinations vac
	on dea.location =vac.location
    and dea.date =vac.date
where dea.continent is not null;

select *
from percentpopulationvaccinated

