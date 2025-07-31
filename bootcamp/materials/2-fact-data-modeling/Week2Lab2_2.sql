WITH users AS (
    SELECT * FROM users_cumulated
    WHERE date = DATE('2023-01-31')
), series AS (
    SELECT * FROM generate_series(DATE('2023-01-01'), DATE('2023-01-31'), INTERVAL '1 day') AS series_date
), place_holder_ints AS (
    SELECT
        CASE WHEN
                 dates_active @> ARRAY [DATE(series_date)]
                 THEN CAST(POW(2, 32 - (date - DATE(series_date))) AS BIGINT)
             ELSE 0 END as placeholer_int_value,

        *
    FROM users
             CROSS JOIN series
)
SELECT
    user_id,
    CAST(CAST(SUM(placeholer_int_value) AS BIGINT) AS BIT(32)),
    BIT_COUNT(CAST(CAST(SUM(placeholer_int_value) AS BIGINT) AS BIT(32))) > 0  dim_is_monthly_active,
    BIT_COUNT(CAST('1111111000000000000000000000000' AS BIT(32)) &
        CAST(CAST(SUM(placeholer_int_value) AS BIGINT) AS BIT(32))) > 0 as dim_is_weekly_active,
    BIT_COUNT(CAST('1000000000000000000000000000000' AS BIT(32)) &
              CAST(CAST(SUM(placeholer_int_value) AS BIGINT) AS BIT(32))) > 0 as dim_is_daily_active

FROM place_holder_ints
GROUP BY user_id




