
-- Step 1: Create RawStats staging table
CREATE TABLE IF NOT EXISTS RawStats (
    record_id INT PRIMARY KEY,
    match_id INT,
    player_name VARCHAR(100),
    role VARCHAR(50),
    nationality VARCHAR(50),
    team_id INT,
    team_city VARCHAR(100),
    coach VARCHAR(100),
    opponent_team_id INT,
    stadium_id INT,
    stadium_name VARCHAR(100),
    stadium_location VARCHAR(100),
    stadium_capacity INT,
    format_id INT,
    match_date DATE,
    runs_scored INT,
    balls_faced INT,
    wickets_taken INT,
    overs_bowled FLOAT,
    catches_taken INT,
    age INT
);

-- Step 2: Load final_.csv into RawStats
COPY RawStats FROM '/tmp/final_.csv' DELIMITER ',' CSV HEADER;

-- Step 3: Populate normalized tables

-- Match Format
INSERT INTO Match_Format(format_id, format_name)
SELECT DISTINCT format_id,
    CASE format_id
        WHEN 1 THEN 'T20'
        WHEN 2 THEN 'ODI'
        WHEN 3 THEN 'Test'
    END
FROM RawStats
ON CONFLICT (format_id) DO NOTHING;

-- Teams
INSERT INTO Teams(team_id, name, city, coach)
SELECT DISTINCT team_id,
    CASE team_id
        WHEN 1 THEN 'India' WHEN 2 THEN 'Australia'
        WHEN 3 THEN 'England' WHEN 4 THEN 'New Zealand'
        WHEN 5 THEN 'Pakistan' WHEN 6 THEN 'South Africa'
        WHEN 7 THEN 'West Indies' WHEN 8 THEN 'Sri Lanka'
        WHEN 9 THEN 'Bangladesh' WHEN 10 THEN 'Afghanistan'
    END,
    team_city, coach
FROM RawStats
ON CONFLICT (team_id) DO NOTHING;

-- Stadiums
INSERT INTO Stadiums(stadium_id, name, location, capacity)
SELECT DISTINCT stadium_id, stadium_name, stadium_location, stadium_capacity
FROM RawStats
ON CONFLICT (stadium_id) DO NOTHING;

-- Temp mapping for player_id
DROP TABLE IF EXISTS PlayerMap;
CREATE TEMP TABLE PlayerMap AS
SELECT DISTINCT player_name,
       ROW_NUMBER() OVER (ORDER BY player_name) AS player_id,
       team_id, role, age, nationality
FROM RawStats;

-- Players
INSERT INTO Players(player_id, player_name, team_id, role, age, nationality)
SELECT player_id, player_name, team_id, role, age, nationality FROM PlayerMap
ON CONFLICT (player_id) DO NOTHING;

-- Matches
INSERT INTO Matches(match_id, date, team1_id, team2_id, stadium_id, winner_team_id, format_id, total_overs)
SELECT DISTINCT match_id, match_date, team_id, opponent_team_id, stadium_id, team_id, format_id, 50
FROM RawStats
ON CONFLICT (match_id) DO NOTHING;

-- Player Stats
INSERT INTO Player_Stats(stat_id, match_id, player_id, stadium_id, runs_scored, balls_faced, wickets_taken, overs_bowled, catches_taken)
SELECT r.record_id, r.match_id, p.player_id, r.stadium_id,
       r.runs_scored, r.balls_faced, r.wickets_taken, r.overs_bowled, r.catches_taken
FROM RawStats r
JOIN PlayerMap p ON r.player_name = p.player_name
ON CONFLICT (stat_id) DO NOTHING;
