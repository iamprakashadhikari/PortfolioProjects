select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--select *
--From CovidVaccinations
--order by 3,4

--Select Data That we are going to be Using 

Select location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where location like '%states'
Order By 1,2 --Ordering by location and date

--Total Cases vs Total Deaths
--Shows Rough estimate of ding in your country if you contract COVID
Select Location, date, total_cases, total_deaths, (Cast(total_deaths as float) / (Cast(total_cases as float)))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states'
Order By 1,2 

--Total cases Vs Population
Select Location, date, population,total_cases, (Cast(total_cases as float) / (Cast(population as float)))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states'
Order By 1,2

--Highest infection Rate
Select Location, population, MAX(total_cases) AS HigestINfectionCount, MAX((Cast(total_cases as float)) / (Cast(population as float)))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states'
Group by location, population
Order By PercentPopulationInfected DESC

--Countries with Highest Death count per Population

Select Location, MAX(cast(total_deaths as int)) AS totaldeathcount
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%states'
Group by location
Order By totaldeathcount DESC

--Breaking down by Continent with highest death count

Select continent, MAX(cast(total_deaths as int)) AS totaldeathcount
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%states'
Group by continent
Order By totaldeathcount DESC

--Global Numbers

Select date, SUM(new_cases), SUM(cast(new_deaths as float)), SUM(cast(new_deaths as float))/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states'
Where continent is not null
--Group by date
Order By 1,2 --Ordering by location and date

--looking at Total Poulation vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) As NumberOfPeopleVaccinated
, (
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE 
With PopvsVac (continent, location, date, population, new_vaccinations, NumberOfPeopleVaccinated)
AS
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) As NumberOfPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(NumberOfPeopleVaccinated/population)*100
From PopvsVac

--Temp Table

Drop Table if exists #Numberofpeoplevaccinated
Create Table #Numberofpeoplevaccinated
(
continent nvarchar(255),
locatoin nvarchar(255),
date datetime,
population numeric, 
new_vaccination numeric, 
numberofpeoplevaccinated numeric
)
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) As NumberOfPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
Select *,(NumberOfPeopleVaccinated/population)*100
From #Numberofpeoplevaccinated

-- Creating views to store data for later visulizations 

Create view Numberofpeoplevaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) As NumberOfPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3