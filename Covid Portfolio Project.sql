Select * 
From PortfolioProject2..CovidDeaths
Where continent is not null
Order By 3,4

Select * 
From PortfolioProject2..CovidVaccinations
Order By 3,4

-- Select Data that we are going to be using 
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject2..CovidDeaths
Order By 1,2 

-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract Covid in your country 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject2..CovidDeaths
Where location like '%states%'
Order By 1,2 

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got Covid

Select continent, location, date, Population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
From PortfolioProject2..CovidDeaths
-- Where location like '%states%'
Order By 1,2 

-- Looking at Countries with Highest Infection Rate compared to Population

Select continent, location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProject2..CovidDeaths
-- Where location like '%states%'
Group by continent,location, Population
Order By PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population 

Select Location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
From PortfolioProject2..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by Location
Order By TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT 

Select continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
From PortfolioProject2..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by continent
Order By TotalDeathCount DESC


-- Showing continents with the highest death count per population

Select continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
From PortfolioProject2..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by continent
Order By TotalDeathCount DESC


-- GLOBAL NUMBERS 

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject2..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
Order By 1,2 

-- Looking at Total Population Vs Vaccinations 


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location Order By dea.location, dea.Date)
as RollingPeopleVaccinated
, --(RollingPeopleVaccinated/population)*100 
From PortfolioProject2..CovidDeaths dea
JOIN  PortfolioProject2..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- USE CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 
From PortfolioProject2..CovidDeaths dea
JOIN  PortfolioProject2..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE 
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 
From PortfolioProject2..CovidDeaths dea
JOIN  PortfolioProject2..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for late visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 
From PortfolioProject2..CovidDeaths dea
JOIN  PortfolioProject2..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select * 
FROM PercentPopulationVaccinated
