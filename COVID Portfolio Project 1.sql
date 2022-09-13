Select *
From PortfolioProject..CovidDeaths
where continent is not null 
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--select Data that Im going to be using 


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total cases VS Total Deaths 
--(how many cases are there in this countryand then how many deaths do they have per how many deaths they have for their entire cases)

--the percentage of ppl who are dying who actually get infected or who report being infected 
--shows likelihood of dying if you contract covid in usa 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--Looking at Total cases VS Population
--Shows what percentage of population got Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location like '%south korea%'
order by 1,2

--what countries have the highest infection rates compared to the population
--Looking at countries with highest infection rate compared to population 

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%south korea%'
Group by location, population
order by PercentPopulationInfected desc

--showing countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%south korea%'
where continent is not null
Group by location
order by TotalDeathCount desc


--Let's break things down by continent


--showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%south korea%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--global numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2



--Join Looking at total population VS Vaccinations -- sum(convert(int,vac.new_vaccinations)) instade of SUM(Cast(vac.new_vaccinations as int))

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
From  PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

;With PopvsVac(Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/Population)*100
From  PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac




--tepm table 


DROP Table if exists #PercentPopulationVaccinated --adding this if you have plan on making any alterations, when you run it multiple times you don't have to go back and delete the view or temp table or drop.
--just bulit in, It's at the top easy to maintain and looks good 
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/Population)*100
From  PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated







