
Select * from CovidProject..CovidDeaths
Order by 3, 4


--Select * from CovidProject..CovidVaccinations
--Order by 3, 4

-- Choosing data to be used 

Select location, date, new_cases, total_cases, total_deaths, population 
From CovidProject..CovidDeaths
Order by 1, 2


-- 1. What's the total cases compared to total death (Percentage rate of dying if you contact Covid)?

Select location, date, total_cases, total_deaths, CONVERT(decimal(10,2),(total_deaths/total_cases)*100) As DeathPercentageCount
From CovidProject..CovidDeaths
Where location like 'Nigeria'
Order by 1, 2


-- 2. What's the total cases compared to the population (Showing the percentage of population that have contact Covid)

Select location, date, total_cases, population, (total_cases/population)*100 As PercentagePopulationInfected
From CovidProject..CovidDeaths
Where location like 'United States'
Order by 1, 2


-- 3. Countries with highest total cases in the world

Select location, population, Max(total_cases), Max((total_cases/population))*100 As PercentagePopulationInfected
From CovidProject..CovidDeaths
--Where location like 'United States'
Where continent is not NULL
Group by location, population
Order by PercentagePopulationInfected desc


-- 4. What Countries has the highest death rate per population

Select location, Max(cast(total_deaths as int)) As HighestDeathCount
From CovidProject..CovidDeaths
--Where location like 'Canada'
Where continent is not NULL
Group by location
Order by HighestDeathCount desc


-- 5. What's the total cases by continent

Select location, Max(cast(total_cases as int)) As HighestCasesCount
From CovidProject..CovidDeaths
--Where location like 'United States'
Where continent is NULL
Group by location
Order by HighestCasesCount desc


-- 6. What's the TOTAL DEATHS by continent

Select location, Max(cast(total_deaths as int)) As HighestDeathCount
From CovidProject..CovidDeaths
--Where location like 'United States'
Where continent is NULL
Group by location
Order by HighestDeathCount desc


-- 6. Global Figures (New Cases, Total Cases, Death Percentage)

Select SUM(new_cases) As [Total Cases], SUM(cast(new_deaths as int)) As [Total Deaths], CONVERT(Decimal(10,2), SUM(cast(new_deaths as int))/SUM(new_cases)*100) As [Death Percent]
From CovidProject..CovidDeaths
--Where location like 'United States'
Where continent is not NULL
--Group by date
Order by 1, 2


-- JOINING TABLE TO WORK WITH BOTH CovidDeaths AND CovidVaccinations

Select death.continent, death.location, death.date, Vac.new_vaccinations, Vac.total_vaccinations
From CovidProject..CovidDeaths As death
Join CovidProject..CovidVaccinations As Vac
	On death.location = Vac.location
	and death.date = Vac.date


-- 7. What's the total Population Compared to Vaccinations
--	  Using CTE

With PopVac (continent, location, date, population, new_vaccination, TotalVaccinationCount)
as (
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by death.location Order by death.location, death.date) As TotalVaccinationCount
From CovidProject..CovidDeaths As death
Join CovidProject..CovidVaccinations As Vac
	On death.location = Vac.location
	and death.date = Vac.date
Where death.continent is not NULL and death.location = 'Nigeria'
--Order by 1, 2
)
Select *, (TotalVaccinationCount/population)*100 As PercentagePopVac
From PopVac



-- Using A TEM TABLE

Drop Table if Exists #PercentVaccinatedCount
CREATE TABLE #PercentVaccinatedCount (
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
TotalVaccinationCount int
)

INSERT INTO #PercentVaccinatedCount  
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by death.location Order by death.location, death.date) As TotalVaccinationCount
From CovidProject..CovidDeaths As death
Join CovidProject..CovidVaccinations As Vac
	On death.location = Vac.location
	and death.date = Vac.date
Where death.continent is not NULL and death.location = 'Canada'
--Order by 1, 2

Select *, (TotalVaccinationCount/population)*100 As PercentagePopVac
From #PercentVaccinatedCount




							-- CREATING A VIEWS FOR VISUALIZATION


-- First View
-- Countries by the highest Covid-19 death

Select location, Max(cast(total_deaths as int)) As HighestDeathCount
From CovidProject..CovidDeaths
--Where location like 'Canada'
Where continent is not NULL
Group by location
Order by HighestDeathCount desc

-- Second View
-- What's the total cases by continent (This script shows the total cases of covid-19 per continent using the current data from Feb. 23 2020 - Jul. 24 2021)

Select location, Max(cast(total_cases as int)) As HighestCasesCount
From CovidProject..CovidDeaths
--Where location like 'United States'
Where continent is NULL
Group by location
Order by HighestCasesCount desc


-- Third View
-- What's the TOTAL DEATHS by continent (This script shows the total daeth of each continent using the current data from Feb. 23 2020 - Jul. 24 2021)

Select location, Max(cast(total_deaths as int)) As HighestDeathCount
From CovidProject..CovidDeaths
--Where location like 'United States'
Where continent is NULL
Group by location
Order by HighestDeathCount desc


-- Fourth View
-- Global Total Figures (This script shows the New Cases, Total Cases, Death Percentage of the World using the current data from Feb. 23 2020 - Jul. 24 2021)

Select SUM(new_cases) As [Total Cases], SUM(cast(new_deaths as int)) As [Total Deaths], CONVERT(Decimal(10,2), SUM(cast(new_deaths as int))/SUM(new_cases)*100) As [Death Percent]
From CovidProject..CovidDeaths
--Where location like 'United States'
Where continent is not NULL
--Group by date
Order by 1, 2


-- Fifth View

Create View 
[Percentage Vaccinated By Country] 
As
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by death.location Order by death.location, death.date) As TotalVaccinationCount
From CovidProject..CovidDeaths As death
Join CovidProject..CovidVaccinations As Vac
	On death.location = Vac.location
	and death.date = Vac.date
Where death.continent is not NULL 
--Order by 1, 2;

Select *
From [Percentage Vaccinated By Country]