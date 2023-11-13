select*
from CovidDeaths$

select *
from CovidVaccinations$


/* SELECTING THE NEEDED DATA */
SELECT location, date,total_cases, new_cases,total_deaths,population
from CovidDeaths$
order by 1,2


/* LOOKING AT TOTAL CASES VS TOTAL DEATHS AND SHOWS LIKELY HOOD OF DYING IN THE SELECTED COUNTRY*/
SELECT location, date,total_cases, new_cases,total_deaths, round((total_deaths/total_cases)*100,2) as Death_Perc
from CovidDeaths$
where location like '%bosni%'
order by 1,2


/* LOOKING AT TOTAL CASES AND POPULATION PERCENTAGE POPULATION THAT GOT COVID*/
SELECT location, date,total_cases,population, round((total_cases/population)*100,2) as CasePercentage
from CovidDeaths$ 
where location like '%bosni%'
order by 1,2


/* COUNTRIES WITH HIGHEST INFECTION RATE */
SELECT location,max(total_cases) as HighestInfectionRate,population, round(max(total_cases/population)*100,2) as PercentageInfected
from CovidDeaths$ 
--where location like '%bosni%'
group by location,population
order by PercentageInfected


/*COUNTRIES WITH HIGHEST DEATH RATE*/
select location,max(total_deaths) as TotalDeathCount
from CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount Desc


/* BREAKING THINGS DOWN BY CONTINENT */
select continent,max(total_deaths) as TotalDeathCount
from CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount Desc

/*GLOBAL NUMBER */
SELECT SUM(new_cases) as TotalCases,SUM(new_deaths) as TotalDeath,(sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from CovidDeaths$
where continent is not null
--group by date
order by 1,2


--DEALING WITH SECOND FILE 
SELECT *
FROM CovidVaccinations$


--JOINING THE TWO DATA TOGETHER
SELECT *
FROM CovidDeaths$ dea
join CovidVaccinations$ vas
on dea.location = vas.location and dea.date = vas.date


--LOOKING AT TOTAL POPULATION AND VACCINATION
SELECT dea.continent, dea.date, dea.population,dea.location,vas.new_vaccinations,sum(vas.new_vaccinations)
over(partition by dea.location) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths$ dea
join CovidVaccinations$ vas
on dea.location = vas.location and dea.date = vas.date
where dea.continent is not null 
order by 4,5


--USING CTE
with popvsvas(continent,date,population,location,new_vaccinations,RollingPeopleVaccinated)
as (SELECT dea.continent, dea.date, dea.population,dea.location,vas.new_vaccinations,sum(vas.new_vaccinations)
over(partition by dea.location) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths$ dea
join CovidVaccinations$ vas
on dea.location = vas.location and dea.date = vas.date
where dea.continent is not null )
select *,(RollingPeopleVaccinated/population)*100 as PercentageVaccinated
from popvsvas


		--TEMP TABLE
	drop table if exists #populationpercentagevaccine
	CREATE TABLE #populationpercentagevaccine(
	continent nvarchar(100),
	date datetime,
	population numeric,
	location nvarchar(100),
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)
	insert into #populationpercentagevaccine
	SELECT dea.continent, dea.date, dea.population,dea.location,vas.new_vaccinations,sum(vas.new_vaccinations)
	over(partition by dea.location) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
	FROM CovidDeaths$ dea
	join CovidVaccinations$ vas
	on dea.location = vas.location and dea.date = vas.date
	where dea.continent is not null 
	select *,(RollingPeopleVaccinated/population)*100 as PercentageVaccinated
	from #populationpercentagevaccine


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION
CREATE view PercentPopulationVaccinated as
SELECT dea.continent, dea.date, dea.population,dea.location,vas.new_vaccinations,sum(vas.new_vaccinations)
	over(partition by dea.location) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
	FROM CovidDeaths$ dea
	join CovidVaccinations$ vas
	on dea.location = vas.location and dea.date = vas.date
	where dea.continent is not null 

	select *
	from PercentPopulationVaccinated
