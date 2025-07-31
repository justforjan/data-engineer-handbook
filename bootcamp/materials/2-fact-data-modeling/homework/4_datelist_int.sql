WITH users AS(
    SELECT *
    FROM user_devices_cumulated WHERE date = DATE('2023-01-21')
),
    series AS (
    SELECT
        CAST(day_series AS DATE)
    FROM generate_series('2023-01-01', '2023-01-31', INTERVAL '1 day') as day_series
), placeholder AS (
    SELECT
        *,
        CASE
            WHEN device_activity_datelist @> ARRAY[day_series]
                -- we subtract from 32 as a BIGINT is 32 Bits long
                THEN CAST(POW(2, 32 - (date - day_series)) AS BIGINT)
                ELSE 0 END AS placeholder_int
    FROM users u, series
    )

SELECT
    user_id,
    browser_type,
    -- this integer represents the activity in the past 32 days, encoded in number
    SUM(placeholder_int) as datelist_int,
    -- from left to right, a 1 at position i stands for an activity on day today - i days
    CAST(CAST(SUM(placeholder_int) AS BIGINT) AS BIT(32)) as bit_array
FROM placeholder
GROUP BY user_id, browser_type;