SELECT MAX(actors.current_year) FROM actors;
-- 1976

WITH latest_records AS (
    SELECT *
    FROM actors_history_scd
    WHERE end_year = 1976
), history AS (
    SELECT *
    FROM actors_history_scd
    WHERE end_year < 1976
), this_year AS (
    SELECT *
    FROM actors
    WHERE current_year = 1977
), unchanged_records AS (
    SELECT
        lr.actor_id,
        lr.actor_name,
        lr.quality_class,
        lr.is_active,
        lr.start_year,
        lr.end_year + 1 AS end_year
    FROM latest_records lr
    LEFT JOIN this_year ty ON lr.actor_id = ty.actor_id
    WHERE lr.quality_class = ty.quality_class AND lr.is_active = ty.is_active
), changed_records AS (
    SELECT
        lr.actor_id,
        lr.actor_name,
        ty.quality_class,
        ty.is_active,
        1977 as start_year,
        1977 as end_year
    FROM latest_records lr
    LEFT JOIN this_year ty ON lr.actor_id = ty.actor_id
    WHERE lr.quality_class <> ty.quality_class OR lr.is_active <> ty.is_active
), ended_records AS (
    SELECT
        lr.actor_id,
        lr.actor_name,
        lr.quality_class,
        lr.is_active,
        lr.start_year,
        lr.end_year
    FROM latest_records lr
             LEFT JOIN this_year ty ON lr.actor_id = ty.actor_id
    WHERE lr.quality_class <> ty.quality_class OR lr.is_active <> ty.is_active
), new_records AS (
    SELECT
        ty.actor_id,
        ty.actor_name,
        ty.quality_class,
        ty.is_active,
        1977 as start_year,
        1977 as end_year
    FROM this_year ty
    LEFT JOIN latest_records lr ON ty.actor_id = lr.actor_id
    WHERE lr.actor_name IS NULL
)
SELECT * FROM history

UNION ALL

SELECT * FROM ended_records

UNION ALL

SELECT * FROM unchanged_records

UNION ALL

SELECT * FROM changed_records

UNION ALL

SELECT * FROM new_records
