-- select * from player_seasons;
--
-- CREATE TYPE season_stats as (
--     season INTEGER,
--     gp INTEGER,
--     pts REAL,
--     reb REAL,
--     ast REAL
--                              )
-- DROP TABLE IF EXISTS  players;
-- DROP type scoring_class;
-- CREATE TYPE scoring_class AS ENUM ('star', 'good', 'average', 'bad');
-- CREATE TABLE players (
--     player_name TEXT,
--     height TEXT,
--     college TEXT,
--     country TEXT,
--     draft_year TEXT,
--     draft_round TEXT,
--     draft_number TEXT,
--     season_stats season_stats[],
--     scoring_class scoring_class,
--     years_since_last_season INTEGER,
--     current_season INTEGER,
--     is_active BOOLEAN,
--
--     CONSTRAINT players_pkey PRIMARY KEY (player_name, current_season)
-- );




INSERT INTO players
WITH yesterday AS (
    SELECT * FROM players
             WHERE current_season = 2000
), today as (
    SELECT * FROM player_seasons
             WHERE season = 2001
)

SELECT
    coalesce(t.player_name, y.player_name) as player_name,
    coalesce(t.height, y.height) as height,
    coalesce(t.college, y.college) as college,
    coalesce(t.country, y.country) as country,
    coalesce(t.draft_year, y.draft_year) as draft_year,
    coalesce(t.draft_round, y.draft_round) as draft_round,
    coalesce(t.draft_number, y.draft_number) as draft_number,
    CASE
        WHEN y.season_stats IS NULL
            THEN ARRAY[ROW(t.season, t.gp, t.pts, t.reb, t.ast)::season_stats]
        WHEN t.season IS NOT NULL
            THEN y.season_stats || ROW(t.season, t.gp, t.pts, t.reb, t.ast)::season_stats
        ELSE y.season_stats
    END as season_stats,

    CASE
        WHEN t.season IS NOT NULL THEN
        CASE
            WHEN t.pts > 20 THEN 'star'
            WHEN t.pts > 15 THEN 'good'
            WHEN t.pts > 10 THEN 'average'
            ELSE 'bad'
            END::scoring_class
        ELSE y.scoring_class
    END as scoring_class,

    CASE
        WHEN t.season IS NOT NULL THEN 0
        ELSE y.years_since_last_season + 1
    END as years_since_last_season,

    COALESCE(t.season, y.current_season + 1) as current_season
FROM today t
    FULL OUTER JOIN yesterday y ON t.player_name = y.player_name;

SELECT
    player_name,
    season_stats[1].pts AS first_season,
    season_stats[cardinality(season_stats)].pts AS latest_season,
    season_stats[cardinality(season_stats)].pts / CASE WHEN season_stats[1].pts = 0 THEN 0 ELSE season_stats[1].pts END AS improvement
FROM players
WHERE scoring_class = 'star'
  AND current_season = 2001
ORDER BY improvement DESC;