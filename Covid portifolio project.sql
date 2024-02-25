Select *
FROM PortifolioProject..CovidDeaths
Order BY 3,4

--Select *
--FROM PortifolioProject..CovidVaccinations
--Order BY 3,4
-- select the data that we are using Select *
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortifolioProject..CovidDeaths
Order BY 1,2


--looking at total cases vs total deaths
-- showss the likelihood of dying if you contract COVID 
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortifolioProject..CovidDeaths
WHERE location like '%states%'
Order BY 1,2

--LOOKING AT TOTAL CASES VS POPULATION
--shows what percentage of population got covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationinfected
FROM PortifolioProject..CovidDeaths
WHERE location like '%states%'
Order BY 1,2


--looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationinfected
FROM PortifolioProject..CovidDeaths
GROUP BY location, population
Order BY PercentPopulationinfected DESC

--lets breaek things down by continent

--showing countries with highest death count per population

SELECT continent,MAX(cast(Total_deaths as int)) as TotalDeathcount
FROM PortifolioProject..CovidDeaths
where continent is not null
GROUP BY continent
Order BY TotalDeathcount DESC

-- Global Numbers

SELECT date, sum(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totalDeaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM PortifolioProject..CovidDeaths
where continent is not null
Group by date
Order BY 1,2

--USE CTES
  with popvsVac(Continent, location, Date, population, new_vaccinations, RollingPeopleVaccinated)
  as
  (
--LOOKING AT TOTAL POPULATION VS VACCINATION 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
 FROM PortifolioProject..CovidDeaths dea
JOIN  PortifolioProject..CovidVaccinations vac
 ON  dea.location = vac.location
 and dea.date = vac.date
  where dea.continent is not null
 -- Order BY 2,3
  )
  select*, (RollingPeopleVaccinated/population)*100
  from popvsVac

  --TEMPTABLES
  DROP Table if exists  #percentpopulationvaccinated
  Create Table #percentpopulationvaccinated
  (
   continent nvarchar(255),
   location nvarchar(255),
   Date datetime,
   population numeric,
   New_vaccinations numeric,
   RollingPeopleVaccinated numeric
   )

  Insert into  #percentpopulationvaccinated
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
 FROM PortifolioProject..CovidDeaths dea
JOIN  PortifolioProject..CovidVaccinations vac
 ON  dea.location = vac.location
 and dea.date = vac.date
  where dea.continent is not null
 -- Order BY 2,3

  select*, (RollingPeopleVaccinated/population)*100
  from #percentpopulationvaccinated


  --Creating a view to mstore data for later vissualization
  CREATE view percentpopulationvaccinated as
   Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
 FROM PortifolioProject..CovidDeaths dea
JOIN  PortifolioProject..CovidVaccinations vac
 ON  dea.location = vac.location
 and dea.date = vac.date
  where dea.continent is not null
 -- Order BY 2,3

 select*
 FROM percentpopulationvaccinated
