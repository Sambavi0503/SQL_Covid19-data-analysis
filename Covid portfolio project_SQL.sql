select location,date,total_cases,new_cases,total_deaths,population
from Portfolio_Project_SQL.dbo.deaths order by 1,2

--Looking at total cases vs Total Deaths


select location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from Portfolio_Project_SQL.dbo.deaths

-- Filtering just %states% in location

select location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from Portfolio_Project_SQL.dbo.deaths
where location like'%states%' order by 1,2

--looking at total cases vs population
--shows what percentage of people got covid

select location,date,total_cases,new_cases, population,(total_cases/ population)*100 as deathpercentage
from Portfolio_Project_SQL.dbo.deaths
where location like'%states%' order by 1,2

select population from Portfolio_Project_SQL.dbo.deaths

---Looking at the country with the highest infection rate compared to population


select location,population, MAX(total_cases) as Highestinfectedcount, MAX((total_cases/ population))*100 as percentpopulationinfection
from Portfolio_Project_SQL.dbo.deaths
group by location, population 
order by percentpopulationinfection desc

---showing country with highest death count per population

select location,population,MAX(total_deaths) as totaldeathcount
from Portfolio_Project_SQL.dbo.deaths
group by location,population
order by totaldeathcount desc

--lets break down by using continent
select continent,MAX(total_deaths) as totaldeathcount
from Portfolio_Project_SQL.dbo.deaths
where continent is not null
group by continent
order by totaldeathcount desc

--with location

select location,MAX(total_deaths) as totaldeathcount
from Portfolio_Project_SQL.dbo.deaths
where continent is  null
group by location
order by totaldeathcount desc

--global number

select date ,sum(new_cases)as total_cases,SUM(cast(new_deaths as int))as total_deaths,
SUM(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from Portfolio_Project_SQL.dbo.deaths
where continent is not null
group by date

--now we are going to take a look into another table
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from Portfolio_Project_SQL.dbo.deaths dea
join Portfolio_Project_SQL.dbo.vaccination vac
on dea.location=vac.location
and  dea.date=vac.date
Where dea.continent is not null
order by 1,2,3


select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from Portfolio_Project_SQL.dbo.deaths dea
join Portfolio_Project_SQL.dbo.vaccination vac
on dea.location=vac.location
and  dea.date=vac.date
Where dea.continent is not null
order by 1,2,3


---with CTE

with popvsvac(continent,Location,date,population,new_vaccinations,Rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from Portfolio_Project_SQL.dbo.deaths dea
join Portfolio_Project_SQL.dbo.vaccination vac
on dea.location=vac.location
and  dea.date=vac.date
Where dea.continent is not null
)

select *,(Rollingpeoplevaccinated/population)*100
from popvsvac

--- percentage of people getting vacinated 

SELECT dea.location, SUM(dea.population) as Population, SUM(cast(vac.new_vaccinations as int)) as vaccinated, 
MAX(cast(vac.people_fully_vaccinated as int))/MAX(dea.population)*100 as Vaccine_percent
From Portfolio_Project_SQL.dbo.deaths as dea
Join Portfolio_Project_SQL.dbo.vaccination as vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is not null AND dea.continent like '%asia%'
Group by dea.location
Order by Vaccine_percent DESC;

DROP Table if exists #PercentPopulationVacinated
create table #percentpopulationvacinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentpopulationvacinated

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from Portfolio_Project_SQL.dbo.deaths dea
join Portfolio_Project_SQL.dbo.vaccination vac
on dea.location=vac.location
and  dea.date=vac.date
--Where dea.continent is not null


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVacinated