USE covid;

-- As of May 3rd
SELECT * FROM us_covid;
SELECT * FROM us_state_vaccinations;

-- Delete United States from state column
DELETE FROM us_state_vaccinations
WHERE state = 'United States';

-- Top States in Mortality
SELECT
	state,
	total_deaths
FROM us_covid
ORDER BY 2 DESC;
-- LIMIT 7;

-- Mortality rate - highest state
SELECT
	state,
	total_cases_per_mil,
	deaths_per_mil,
	deaths_per_mil/total_cases_per_mil AS mortality_rate
FROM us_covid
ORDER BY mortality_rate DESC;

-- Likelyhood of dying due to COVID in NJ
SELECT
	state,
	total_cases,
	total_deaths,
	(CAST(total_deaths AS DECIMAL(11,4))*100/total_cases) AS Death_Percentage
FROM us_covid
WHERE state LIKE '%Jersey%'
ORDER BY 1,2;

-- Daily vaccination change in NJ
-- LAG() fucntion to compare roles.
WITH vaccination_lag AS (
SELECT
	date_vaccination,
	state,
	daily_vaccinations,
	LAG(daily_vaccinations) OVER(
	PARTITION BY state
) AS vaccination_previous_day
FROM us_state_vaccinations
),
vaccination_count_change AS (
SELECT 
	*,
	COALESCE(daily_vaccinations - vaccination_previous_day) AS percent_change
FROM vaccination_lag
)
SELECT
*,
	CASE
		WHEN percent_change > 0 THEN 'increase'
		WHEN percent_change = 0 THEN 'no change'
	ELSE 'decrease'
	END AS daily_change
FROM vaccination_count_change
WHERE state = 'New Jersey'
AND date_vaccination LIKE '%/22%';

-- Daily vaccination count in NJ
SELECT
	state,
	date_vaccination,
	CASE
		WHEN daily_vaccinations IS NOT NULL THEN daily_vaccinations
		ELSE '0'
	END AS daily_vaccinations
FROM us_state_vaccinations
WHERE state LIKE '%Jersey%';

-- Top States in Vaccinations as of May 3rd
SELECT
	state,
	CAST(total_vaccinations AS UNSIGNED) AS total_vax
FROM us_state_vaccinations
WHERE date_vaccination = '5/2/22'
ORDER BY total_vax DESC;

-- Total Cases, Deaths, Recovery and Vaccinations by State using Join
SELECT
	cov.state,
	cov.total_cases,
	cov.total_deaths,
	vax.total_vaccinations,
	cov.total_recovery
FROM us_covid cov
JOIN us_state_vaccinations vax
ON cov.state = vax.state
WHERE date_vaccination = '5/2/22';