SELECT * FROM actor_films;

SELECT MIN(year) FROM actor_films;
-- 1970

SELECT actor, COUNT(1) FROM actor_films GROUP BY actor, year;
-- more than 1 movie per year per actor

INSERT INTO actors
WITH last_year AS (
    SELECT * FROM actors
    WHERE current_year = 1972
),
    this_year AS (
        SELECT * FROM actor_films WHERE year = 1973
    ),
    this_year_agg AS(
        SELECT
            actorid,
            actor,
            AVG(rating) as avg_rating,
            ARRAY_AGG(ROW(film, votes, rating, filmid)::film_info) as film_info,
            MIN(year) as year
        FROM this_year
        GROUP BY actorid, actor
    )
SELECT
    COALESCE(l.actor_id, tg.actorid) as actor_id,
    COALESCE(l.actor_name, tg.actor) as actor_name,
    CASE WHEN l.film_info IS NULL
        THEN tg.film_info
        WHEN tg.film_info IS NOT NULL
        THEN l.film_info || tg.film_info
        ELSE l.film_info
    END as film_info,
    CASE WHEN tg.avg_rating IS NOT NULL THEN
        CASE WHEN (tg.avg_rating) > 8.0 THEN 'star'
             WHEN (tg.avg_rating) > 7.0 THEN 'good'
             WHEN (tg.avg_rating) > 6.0 THEN 'average'
             ELSE 'bad' END::quality_class
        ELSE l.quality_class END as quality_class,
    CASE WHEN tg.avg_rating IS NOT NULL THEN TRUE ELSE FALSE END as is_active,
    COALESCE(l.current_year + 1, tg.year) as year

FROM last_year l
FULL OUTER JOIN this_year_agg tg ON l.actor_id = tg.actorid;

WITH years AS (
    SELECT * FROM generate_series(1969, 2022) as year
), a AS (
    SELECT
        actorid as actor_id,
        MIN(year) as first_year
    FROM actor_films
    GROUP BY actorid
), actors_and_years AS (
    SELECT
        a.actor_id,
        y.year
    FROM a
    JOIN years y ON a.first_year <= y.year
    ),
    actor_films_all_years AS(
        SELECT *
        FROM actors_and_years ay
        LEFT JOIN actor_films af
            ON ay.actor_id = af.actorid
            AND ay.year = af.year
    )



-- SELECT
--     actor,
--     ARRAY_AGG(ROW(film, votes, rating, filmid)::film_info) OVER (PARTITION BY actorid ORDER BY year) as film_info
-- FROM actor_films;

SELECT *
FROM actors
WHERE current_year = 1973;