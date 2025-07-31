DROP TABLE host_activity_reduced
CREATE TABLE host_activity_reduced (
    host TEXT,
    month_start DATE,
    metric_name TEXT,
    metric_array INTEGER[],
    PRIMARY KEY (host, metric_name, month_start)
);