Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as FatalityRate
From [dbo].[CovidDeaths$]
Where location like 'Phili%' and continent is not null
Order by 1,2

--INFECTION RATE PERCENTAGE ON POPULATION

Select location, date, population, total_cases, (total_cases/population)*100 as InfectionRate
From [dbo].[CovidDeaths$]
--Where location like 'Phili%'
Where continent is not null
Order by 1,2


--HIGHEST TOTAL CASES AND INFECTION RATE PER LOCATION

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as InfectionRate
From [dbo].[CovidDeaths$]
--Where location like 'Phili%'
Where continent is not null
Group by location, population
Order by 4 desc


--HIGHEST DEATHTOLL PER LOCATION

Select location, Max(total_deaths) as TotalDeathCount
From [dbo].[CovidDeaths$]
--Where location like 'Phili%'
Where continent is not null
Group by location
Order by 2 desc


--HIGHEST DEATHTOLL PER CONTINENT

Select continent, Max(total_deaths) as TotalDeathCount
From [dbo].[CovidDeaths$]
--Where location like 'Phili%'
Where continent is not null
Group by continent
Order by 2 desc


--INCREASE OF VACCINATED PEOPLE

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as
	cummulative_new_vaccinations
From [dbo].[CovidDeaths$] as dea
Join [dbo].[CovidVaccination$] as vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--USING CTE ON INCREASE OF VACCINATED PEOPLE

With PopVac(Continent, Location, Date, Population, New_Vaccination, Commulative_New_Vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as
	cummulative_new_vaccinations
From [dbo].[CovidDeaths$] as dea
Join [dbo].[CovidVaccination$] as vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (Commulative_New_Vaccinations/Population)*100 as VacPercentage
From PopVac


--USING TEMP TABLE

Drop table if exists #VaccinatedPopulationPercentage
Create Table #VaccinatedPopulationPercentage
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime,
Population numeric,
New_Vaccinations numeric,
Cummulative_New_Vaccinations numeric
)
Insert into #VaccinatedPopulationPercentage
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as
	cummulative_new_vaccinations
From [dbo].[CovidDeaths$] as dea
Join [dbo].[CovidVaccination$] as vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (cummulative_new_vaccinations/Population)*100 as VacPercentage
From #VaccinatedPopulationPercentage


--CREATING VIEW TO STORE DATA FOR VISUALIZATIONS LATER

Create View DeathTollperContinent as
Select continent, Max(total_deaths) as TotalDeathCount
From [dbo].[CovidDeaths$]
Where continent is not null
Group by continent


Create View DeathTollperLocation as
Select location, Max(total_deaths) as TotalDeathCount
From [dbo].[CovidDeaths$]
--Where location like 'Phili%'
Where continent is not null
Group by location

Create View CovidStatsPhilippines as
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as FatalityRate
From [dbo].[CovidDeaths$]
Where location like 'Phili%' and continent is not null

Create View IncreaseInNumberofVaccinations as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as
	cummulative_new_vaccinations
From [dbo].[CovidDeaths$] as dea
Join [dbo].[CovidVaccination$] as vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null



