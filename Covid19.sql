/*
Covid 19
Data Set: https://ourworldindata.org/covid-deaths
*/

Select *
From portfolio..vaccine
order by date, location 


Select *
From portfolio..deaths
order by date, location


Select location, date, total_vaccinations, people_vaccinated, people_fully_vaccinated
From portfolio..vaccine
order by date, location


Select location, date, total_cases, new_cases, total_deaths, population
From portfolio..deaths
order by date, location


-- Global

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as PercentageOfDeath
From portfolio..deaths
where continent is not null 
order by iso_code, continent

-- Countries with the highest infection rate relative to the population

Select location, population, MAX(total_cases),  Max((total_cases/population))*100 as percentage_infected
From portfolio..deaths
Group by location, population
order by percentage_infected desc


-- Countries with the highest mortality rate 

Select Location, MAX(cast(Total_deaths as int)) as total
From portfolio..deaths
Where continent is not null 
Group by location
order by total desc


-- Continents with the highest mortality rate

Select continent, MAX(cast(Total_deaths as int)) as total
From portfolio..deaths
Where continent is not null 
Group by continent
order by total desc


-- Shows the chances of a fatal outcome if you get infected with covid in your country

Select Location, date, total_cases, total_deaths, total_deaths/total_cases*100 as percantage
From portfolio..deaths
Where continent is not null and total_deaths is not null
order by date, location


-- The percentage of the population that has received at least one Covid vaccine

Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as Vac
From portfolio..deaths d
Join portfolio..vaccine v on d.location = v.location and d.date = v.date
where d.continent is not null 
order by 2,3


-- Percentage of the population infected with Covid 19

Select Location, date, Population, total_cases,  (total_cases/population)*100 as percentage_infected
From portfolio..deaths
order by iso_code, continent


-- CTE 

With PopulationVsVaccination (Continent, Location, Date, Population, New_Vaccinations, Vac)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as Vaccinated
From portfolio..deaths d Join portfolio..vaccine v On d.location = v.location and d.date = v.date
where d.continent is not null 
)
Select *, (Vaccinated/Population)*100
From PopulationVsVaccination


-- Create View 

Create View PercentageOfPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as Vaccinated
From portfolio..deaths d Join portfolio..vaccine v On d.location = v.location and d.date = v.date
where d.continent is not null 


-- Temp table 

DROP Table if exists #PercentageOfPopulationVaccinated
Create Table #PercentageOfPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Vaccinated numeric
)

Insert into #PercentageOfPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as Vaccinated

From portfolio..deaths d
Join portfolio..vaccine v
	On d.location = v.location
	and d.date = v.date

Select *, (Vaccinated/Population)*100
From #PercentageOfPopulationVaccinated


