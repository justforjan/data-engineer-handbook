INSERT INTO hosts_cumulated
WITH yesterday AS (
    SELECT * FROM hosts_cumulated WHERE date = DATE('2023-01-02')
), today AS (
    SELECT
        host,
        CAST(event_time AS DATE) as event_time
    FROM events
    WHERE CAST(event_time AS DATE) = DATE('2023-01-03')
    GROUP BY host, CAST(event_time AS DATE)
)

SELECT
    COALESCE(y.host, t.host),
    CASE WHEN y.host_activity_datelist IS NULL
        THEN ARRAY[CAST(t.event_time AS DATE)]
        WHEN t.event_time IS NULL THEN y.host_activity_datelist
            ELSE ARRAY[CAST(t.event_time AS DATE)] || y.host_activity_datelist
                END as host_activity_datelist,
    COALESCE(CAST(t.event_time AS DATE), y.date + 1) as date
FROM yesterday y
FULL OUTER JOIN today t ON y.host = t.host;

SELECT * FROM hosts_cumulated