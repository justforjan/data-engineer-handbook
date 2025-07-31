INSERT INTO actors_history_scd
WITH with_previous AS (
    SELECT
        *,
        LAG(is_active, 1) OVER (PARTITION BY actor_id ORDER BY current_year) AS previous_is_active,
        LAG(quality_class, 1) OVER (PARTITION BY actor_id ORDER BY current_year) AS previous_quality_class
    FROM actors
    ), changes AS (
    SELECT
        *,
        CASE
            WHEN is_active <> previous_is_active THEN 1
            WHEN quality_class <> previous_quality_class THEN 1
            ELSE 0
        END AS change_indicator
    FROM with_previous
    ), streaks AS (
    SELECT
        *,
        SUM(change_indicator) OVER (PARTITION BY actor_id ORDER BY current_year) AS streak_identifier
    FROM changes
    )

    SELECT
        actor_id,
        MIN(actor_name) as actor_name,
        quality_class,
        is_active,
        MIN(current_year) AS start_year,
        MAX(current_year) AS end_year
    FROM streaks
    GROUP BY actor_id, streak_identifier, quality_class, is_active
    ORDER BY actor_id, streak_identifier;
