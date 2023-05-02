--select * 
--from PortfolioProject..CovidVaccinations$
--order by 3,4

select * 
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

--Looking at Total cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of Population got Covid
select location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
group by location, population
order by PercentagePopulationInfected desc

-- Showing countries with highest death count per population
-- Total_death col is a varchar so its casted to int to get accurate data

select  location, max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--Lets break things down by continent

select  location, max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is  null
group by location
order by TotalDeathCount desc

-- Showing continent with the highest death count per population

select  continent, max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not  null
group by continent
order by TotalDeathCount desc

-- Global numbers

select date, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not  null
group by date
order by 1,2

select  sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not  null
order by 1,2

select * 
from PortfolioProject..CovidVaccinations$

select *
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
      on dea.location = vac.location
	  and dea.date = vac.date

--Looking at Total Population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations--, people_vaccinated/population as VaccinatedPercentage
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
      on dea.location = vac.location
	  and dea.date = vac.date
	  where dea.continent is not null and dea.population is not null
	  order by 1,2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
      on dea.location = vac.location
	  and dea.date = vac.date
	  where dea.continent is not null and dea.population is not null
	  order by 1,2,3

-- use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
      on dea.location = vac.location
	  and dea.date = vac.date
	  where dea.continent is not null and dea.population is not null
)
select *, (RollingPeopleVaccinated/Population)*100 from PopvsVac


-- Temp Table

Drop Table if exists #percentPopulationVaccinated
Create table #percentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
      on dea.location = vac.location
	  and dea.date = vac.date
  where dea.continent is not null and dea.population is not null


select *, (RollingPeopleVaccinated/Population)*100 from #percentPopulationVaccinated


-- Creating View to store data for later visualization

create view percentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
      on dea.location = vac.location
	  and dea.date = vac.date
  where dea.continent is not null and dea.population is not null
  --order by 2, 3
