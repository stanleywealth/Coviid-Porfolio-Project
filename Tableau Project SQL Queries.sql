/*

CREATING A VIEWS FOR VISUALIZATION 

*/



-- Countries with highest total cases of Covi-19 in the world by Percentage

Select location, population, Max(total_cases) As HighestInfectionCount, Max((total_cases/population))*100 As PercentagePopulationInfected
From CovidProject..CovidDeaths
--Where location like 'Canada'
Where continent is not NULL
Group by location, population
Order by PercentagePopulationInfected desc


-- Added date to thesame query above

Select location, population, date, Max(total_cases) As HighestInfectionCount, Convert(Decimal(13,2), Max((total_cases/population))*100) As [% PercentagePopulationInfected]
From CovidProject..CovidDeaths
--Where location like 'United States'
Where continent is not NULL
Group by location, population, date
Order by [% PercentagePopulationInfected] desc



-- Countries by the highest Covid-19 death

Select location, Max(cast(total_deaths as int)) As HighestDeathCount
From CovidProject..CovidDeaths
--Where location like 'Canada'
Where continent is not NULL
Group by location
Order by HighestDeathCount desc



-- What's the total cases by continent (This query shows the total cases of covid-19 per continent using the current data from Feb. 23 2020 - Jul. 24 2021)

Select location, Max(cast(total_cases as int)) As HighestCasesCount
From CovidProject..CovidDeaths
--Where location like 'Nigeria'
Where continent is NULL
Group by location
Order by HighestCasesCount desc



-- What's the TOTAL DEATHS by continent (This query shows the total daeth of each continent using the current data from Feb. 23 2020 - Jul. 24 2021)

Select location, Max(cast(total_deaths as int)) As HighestDeathCount
From CovidProject..CovidDeaths
--Where location like 'Nigeria'
Where continent is NULL
and location not in ('World', 'International', 'European Union')  -- This line of query was added to remove non-continent (like World, International, and European Union)
Group by location
Order by HighestDeathCount desc



-- Global Total Figures (This query shows the New Cases, Total Cases, Death Percentage of the World using the current data from Feb. 23 2020 - Jul. 24 2021)

Select SUM(new_cases) As [Total Cases], SUM(cast(new_deaths as int)) As [Total Deaths], CONVERT(Decimal(10,2), SUM(cast(new_deaths as int))/SUM(new_cases)*100) As [Death Percent]
From CovidProject..CovidDeaths
--Where location like 'Nigeria'
Where continent is not NULL
--Group by date
Order by 1, 2



-- This query shows the percentage of people vaccinated vs population  

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