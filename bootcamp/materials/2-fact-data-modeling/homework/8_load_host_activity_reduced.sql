
INSERT INTO host_activity_reduced
WITH daily_aggregate AS (
    SELECT
        host,
        UNNEST(ARRAY[
            COUNT(1),
            COUNT(DISTINCT user_id)
            ]) as metric_numer,
        UNNEST(ARRAY[
            'num_site_hits',
            'num_unique_users'
            ]) as metric_name,
        MIN(DATE(event_time)) as event_time
    FROM events
    WHERE DATE(event_time) = DATE('2023-01-03')
    AND host IS NOT NULL
    GROUP BY host
),
    yesterday_array AS (
        SELECT
            *
        FROM host_activity_reduced
        WHERE month_start = DATE('2023-01-01')
    )
SELECT
    COALESCE(da.host, ya.host),
    COALESCE(ya.month_start, DATE(DATE_TRUNC('month', event_time))),
    da.metric_name,
    CASE
        WHEN ya.metric_array IS NOT NULL
            -- yesterdays array exists so we want to add today metric or 0
            THEN ya.metric_array || COALESCE(da.metric_numer, 0)
            -- yesterdays metric does not exist. We need to fill the array with 0 up until yesterdays day and then add todays value
            ELSE ARRAY_FILL(0, ARRAY[COALESCE(DATE(event_time) - ya.month_start, 0)])
                     || COALESCE(da.metric_numer, 0)
            END as metric_array
FROM daily_aggregate da
FULL OUTER JOIN yesterday_array ya ON
    da.host = ya.host AND da.metric_name = ya.metric_name
ON CONFLICT (host, month_start, metric_name)
DO UPDATE SET metric_array = EXCLUDED.metric_array;


SELECT * FROM host_activity_reduced



