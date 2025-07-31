WITH with_row_num AS (
    SELECT
        *,
        -- ordered by game_date_est to make sure that the first entry of potential duplicates is taken. If the dates are the same, then any is chosen
        ROW_NUMBER() OVER (PARTITION BY gd.game_id, gd.player_id, gd.team_id ORDER BY g.game_date_est) as row_num
    FROM game_details gd
             JOIN games g ON gd.game_id = g.game_id
)
SELECT
    *
FROM with_row_num
WHERE row_num = 1;