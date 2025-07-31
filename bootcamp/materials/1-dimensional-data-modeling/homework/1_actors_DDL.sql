DROP TYPE IF EXISTS film_info CASCADE;
CREATE TYPE film_info AS (
    film TEXT,
    votes INT,
    rating REAL,
    film_id TEXT
);

DROP TYPE IF EXISTS quality_class CASCADE ;
CREATE TYPE quality_class AS ENUM (
    'star',
    'good',
    'average',
    'bad'
);

DROP TABLE IF EXISTS actors;
CREATE TABLE actors (
    actor_id TEXT,
    actor_name TEXT,
    film_info film_info[],
    quality_class quality_class,
    is_active BOOLEAN,
    current_year INTEGER,

    PRIMARY KEY (actor_id, current_year)
);