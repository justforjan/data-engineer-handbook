INSERT INTO vertices
SELECT
    game_id AS identifier,
    'game'::vertex_type AS type,
    json_build_object(
        'pts_home', pts_home,
        'pts_away', pts_away,
        'winning_team', CASE WHEN home_team_wins = 1 THEN home_team_id ELSE visitor_team_id END
    ) as properties

FROM games;

INSERT INTO vertices
WITH players_agg as (
SELECT
    player_id AS identifier,
    MAX(player_name) AS name,
    'player'::vertex_type AS type,
    COUNT(1) as number_of_games,
    SUM(pts) as total_points,
    ARRAY_AGG(DISTINCT team_id) AS teams
FROM game_details
GROUP BY player_id
    )
SELECT
    identifier,
    type,
    json_build_object(
        'name', name,
        'number_of_games', number_of_games,
        'total_points', total_points,
        'teams', teams
    ) as properties
FROM players_agg;

INSERT INTO vertices
WITH teams_deduped AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY team_id ) AS row_num
    FROM teams
)
SELECT
    team_id AS identifier,
    'team'::vertex_type AS type,
    json_build_object(
        'abbreviation', abbreviation,
        'nickname', nickname,
        'arena', arena,
        'city', city,
        'year_founded', yearfounded
    ) as properties
FROM teams_deduped
WHERE row_num = 1;

-- edges
-- player plays in game
INSERT INTO edges
WITH deduped AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY player_id, game_id) AS row_num
    FROM game_details)
SELECT
    player_id AS subject_identifier,
    'player'::vertex_type AS subject_type,
    game_id AS object_identifier,
    'game'::vertex_type AS object_type,
    'plays_in'::edge_type AS edge_type,
    json_build_object(
            'start_position', start_position,
            'pts', pts,
            'team_id', team_id,
            'team_abbreviation', team_abbreviation
    ) as properties
FROM deduped
WHERE row_num = 1;

-- player plays with/against another player
INSERT INTO edges
WITH deduped AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY player_id, game_id) AS row_num
    FROM game_details),
    filtered AS (
        SELECT * FROM deduped
        WHERE row_num = 1
    ),
    aggregated AS(
        SELECT
            f1.player_id as subject_player_id,
            f2.player_id as object_player_id,
            MAX(f1.player_name) as subject_player_name,
            MAX(f2.player_name) as object_player_name,
            CASE WHEN f1.team_abbreviation = f2.team_abbreviation
                     THEN 'shares_team'::edge_type
                 ELSE 'plays_against'::edge_type
                END AS edge_type,
            COUNT(1) AS num_games,
            SUM(f1.pts) AS subject_points,
            SUM(f2.pts) AS object_points

        FROM filtered f1, filtered f2
        WHERE f1.game_id = f2.game_id
          AND f1.player_id > f2.player_id
        GROUP BY
            f1.player_id,
            f2.player_id,
            edge_type
    )
SELECT
    subject_player_id as subject_identifier,
    'player'::vertex_type AS subject_type,
    object_player_id as object_identifier,
    'player'::vertex_type AS object_type,
    edge_type as edge_type,
    json_build_object(
            'num_games', num_games,
            'subject_points', subject_points,
            'object_points', object_points
    )
FROM aggregated;

SELECT
    v.properties->>'player_name' AS player_name,
    CAST(v.properties->>'number_of_games' AS REAL) /
    CASE WHEN CAST(v.properties->>'total_points'AS REAL) = 0
        THEN 1
        ELSE CAST(v.properties->>'total_points'AS REAL) END
FROM vertices v
JOIN edges e
ON v.identifier = e.subject_identifier
AND v.type = e.subject_type
WHERE e.object_type = 'player'



