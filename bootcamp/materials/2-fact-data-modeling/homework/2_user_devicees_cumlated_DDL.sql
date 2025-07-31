DROP TABLE user_devices_cumulated
CREATE TABLE user_devices_cumulated (
    user_id TEXT,
    browser_type TEXT,
    -- list of dates when the user was active with a certain browser
    device_activity_datelist DATE[],
    date DATE,
    PRIMARY KEY (user_id, browser_type, date)
);