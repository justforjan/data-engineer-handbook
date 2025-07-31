SELECT MIN(event_time) FROM events;
-- Min: 2023-01-01

INSERT INTO user_devices_cumulated
WITH yesterday AS (
    SELECT * FROM user_devices_cumulated WHERE date = DATE('2023-01-20')
),
    today AS (
        SELECT
            CAST(e.user_id AS TEXT),
            d.browser_type,
            CAST(e.event_time AS DATE) as event_time
        FROM events e
        JOIN devices d ON e.device_id = d.device_id
        WHERE user_id IS NOT NULL
        AND CAST(event_time AS DATE) = DATE('2023-01-21')
        GROUP BY e.user_id, d.browser_type, CAST(e.event_time AS DATE)
    )

SELECT
    COALESCE(y.user_id, t.user_id) as user_id,
    COALESCE(y.browser_type, t.browser_type) as browser_type,
    -- all edge cases are covered
    CASE WHEN y.device_activity_datelist IS NULL
        THEN ARRAY[event_time]
        WHEN t.event_time IS NULL THEN y.device_activity_datelist
        ELSE ARRAY[event_time] || y.device_activity_datelist
            END as device_activity_list,
    COALESCE(t.event_time, date + INTERVAL '1 day') as date
FROM today t
FULL OUTER JOIN yesterday y ON y.user_id = t.user_id AND y.browser_type = t.browser_type




