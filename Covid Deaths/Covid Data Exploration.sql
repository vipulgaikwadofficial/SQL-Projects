SELECT * FROM [Covid Deaths Project]..covid_deaths

-- SELECT DATA TO BE USED

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Covid Deaths Project]..covid_deaths
WHERE continent is not null

-- TOTAL CASES AND TOTAL DEATHS

SELECT location , date, total_cases, total_deaths, (total_deaths/total_cases)*100 As death_percentage
FROM [Covid Deaths Project]..covid_deaths
WHERE continent is not null

-- TOTAL CASES VS POPULATION

SELECT location, date, total_cases, population, (total_cases/population)*100 AS case_percentage
FROM [Covid Deaths Project]..covid_deaths
WHERE continent is not null

-- COUNTRIES WITH HIGHEST INFECTION RATE

SELECT location, population, MAX(total_cases) as max_infection_count, MAX((total_cases/population))*100 as percentage_population_infected
FROM [Covid Deaths Project]..covid_deaths
WHERE continent is not null
GROUP BY location, population
ORDER BY percentage_population_infected

-- COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT location, population, MAX(CAST(total_deaths as int)) as max_death_count
FROM [Covid Deaths Project]..covid_deaths
WHERE continent is not null
GROUP BY location, population
ORDER BY max_death_count

-- BREAKING DOWN BY CONTINENT

SELECT continent, MAX(CAST(total_deaths as int)) AS max_death_count
FROM [Covid Deaths Project]..covid_deaths
WHERE  continent is not null
GROUP BY continent

-- GLOBAL NUMBERS BY DATE

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths
FROM [Covid Deaths Project]..covid_deaths
GROUP BY date
ORDER BY date, total_cases

-- TOTAL POPULATION VS VACCINCATION

SELECT dea.continet, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM 