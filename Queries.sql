Select * 
from CovidProject..CovidVaccinations

Select * 
from CovidProject..CovidDeaths$
--1.
Select location,date, total_cases, total_deaths, population
from CovidProject..CovidDeaths$
where continent is not null
order by 1, 2

--2.
--Total Cases to Total Deaths
--Shows how fatal the Covid cases where in Nigeria
Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercent
from CovidProject..CovidDeaths$
where location = 'Nigeria'
Order by 1, 2

--3.
--Total Cases to Total Population
--Percentage of population that contracted Covid in Nigeria
Select location, date, total_cases, population,(total_cases/population) * 100 as Cases_per_population
from CovidProject..CovidDeaths$
where location = 'Nigeria'
Order by 1, 2

--4.
--What countries that have the hightest infection rate compared to population
Select location,population,date, max(total_cases) as Highest_infection_per_country,  
max(total_cases/population) * 100 as HighestCasesPercentage
from CovidProject..CovidDeaths$
group by location, population,date
order by HighestCasesPercentage desc

--5.
--Countries with the highest no of death
--The datatype of column total death was stored as a nvarchar which was giving some errors. its been casted to an int datatype.
Select location,population, max(cast (total_deaths as int))as Total_deaths
from CovidProject..CovidDeaths$
where continent is not null
group by location, population
order by 3 desc

--6.
--Continents with the highest no of death
Select location, max(cast (total_deaths as int))as Total_deaths
from CovidProject..CovidDeaths$
where continent is null and location not in ('world', 'international', 'European Union')
group by location
order by 2 desc


--7.
--Total no of people that died worldwide
select sum(new_cases)as total_cases, sum (cast(new_deaths as int)) as total_deaths, 
sum (cast(new_deaths as int))/sum(new_cases) * 100 as percentage_of_death_worldwide
from CovidProject..CovidDeaths$ 
where continent is not null
order by 1,2

--8.
--joining both tables for further use

Select * 
from CovidProject..CovidVaccinations as  Vaccs
join CovidProject..CovidDeaths$ as Death
on Vaccs.location = Death.location
and Vaccs.date = Death.date

--9.
--Number of people in the world that have been vaccinated
--Total number of population to Total number of vaccinations

Select dea.continent, dea.location, dea.population, dea.date,  max(vac.total_vaccinations) as people_vaccinated
from CovidProject..CovidDeaths$ as dea
join CovidProject..CovidVaccinations as vac
on dea.location = vac.location
where dea.continent is not null

--10.
--Number of people in the world that have been vaccinated per country and date
--Total number of population to Total number of vaccinations in a day using a window function and a cte

with Shortcut  (continent, location, population, date, new_vaccination, rolling_num)
as 
(
Select dea.continent, dea.location, dea.population, dea.date,  vac.new_vaccinations new_vacc, 
sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) rolling_num
from CovidProject..CovidDeaths$ as dea
join CovidProject..CovidVaccinations as vac
on dea.location = vac.location
where dea.continent is not null)

select * , (rolling_num/population) * 100 as percentage_people_vaccinated
from shortcut