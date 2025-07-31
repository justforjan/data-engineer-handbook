SELECT * FROM actor_films;

SELECT MIN(year) FROM actor_films;
-- 1970

SELECT MAX(year) FROM actor_films;
-- 2021

SELECT actor, COUNT(1) FROM actor_films GROUP BY actor, year;
-- more than 1 movie per year per actor

INSERT INTO actors
WITH last_year AS (
    SELECT * FROM actors
    WHERE current_year = 1976
),
    this_year AS (
        SELECT * FROM actor_films WHERE year = 1977
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

SELECT *
FROM actors
WHERE current_year = 1975