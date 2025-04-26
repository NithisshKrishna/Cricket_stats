

CREATE TABLE Match_Format (
    format_id INT PRIMARY KEY,
    format_name VARCHAR(50) NOT NULL
);

-- Teams Table
CREATE TABLE Teams (
    team_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    coach VARCHAR(100)
);

-- Stadiums Table
CREATE TABLE Stadiums (
    stadium_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    capacity INT
);

-- Players Table
CREATE TABLE Players (
    player_id INT PRIMARY KEY,
    player_name VARCHAR(100) NOT NULL,
    team_id INT REFERENCES Teams(team_id) ON DELETE SET NULL,
    role VARCHAR(50),
    age INT,
    nationality VARCHAR(50)
);

-- Matches Table
CREATE TABLE Matches (
    match_id INT PRIMARY KEY,
    date DATE NOT NULL,
    team1_id INT REFERENCES Teams(team_id) ON DELETE CASCADE,
    team2_id INT REFERENCES Teams(team_id) ON DELETE CASCADE,
    stadium_id INT REFERENCES Stadiums(stadium_id) ON DELETE SET NULL,
    winner_team_id INT REFERENCES Teams(team_id),
    format_id INT REFERENCES Match_Format(format_id),
    total_overs INT
);

-- Player Stats Table
CREATE TABLE Player_Stats (
    stat_id INT PRIMARY KEY,
    match_id INT REFERENCES Matches(match_id) ON DELETE CASCADE,
    player_id INT REFERENCES Players(player_id) ON DELETE CASCADE,
    stadium_id INT REFERENCES Stadiums(stadium_id),
    runs_scored INT,
    balls_faced INT,
    wickets_taken INT,
    overs_bowled FLOAT,
    catches_taken INT
);
