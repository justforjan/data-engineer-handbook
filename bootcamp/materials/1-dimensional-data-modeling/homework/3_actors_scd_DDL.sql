CREATE TABLE actors_history_scd(
    actor_id TEXT,
    actor_name TEXT,
    quality_class quality_class,
    is_active BOOLEAN,
    start_year INTEGER,
    end_year INTEGER,
    PRIMARY KEY (actor_id, start_year)
);
