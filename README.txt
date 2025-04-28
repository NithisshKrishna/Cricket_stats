**README.txt - Cricket Statistics Database Project**

---

**Project Title:** Cricket Statistics Database

**Team Members:**
- Nithisshkrishna K S
- Harini Murugan

**Description:**
This project implements a relational database system for cricket statistics using PostgreSQL. It enables storing, querying, and analyzing cricket data including teams, players, match formats, stadiums, matches, and individual player statistics. Additionally, a Streamlit web application has been developed to interact with the database for visualization and querying.

---

**Data Source:**
- A single CSV file (`final_.csv`) was generated containing all the relevant cricket records.
- The `final_.csv` file includes information about players, teams, stadiums, matches, match formats, and player statistics.
- This file was loaded into a temporary staging table called `RawStats`.

**Database Tables:**

- RawStats (temporary staging table)
- Match_Format
- Teams
- Stadiums
- Players
- Matches
- Player_Stats

**Folder Structure:**
- `create.sql` - Contains SQL commands to create all the necessary tables including RawStats and normalized tables.
- `load.sql` - Contains COPY command to load data into RawStats from `final_.csv`, and SQL queries to insert and transform data into normalized tables.
- `final_.csv` - The single CSV file containing all records.
- `readme.txt` - (This file) Describes the database setup process and data handling steps.

---

**Instructions to Set Up Database:**


Data Source:

A single CSV file (final_.csv) was generated containing all the relevant cricket records.

The final_.csv file includes information about players, teams, stadiums, matches, match formats, and player statistics.

This file was loaded into a temporary staging table called RawStats.

Database Tables:

RawStats (temporary staging table)

Match_Format

Teams

Stadiums

Players

Matches

Player_Stats

1. **Create Tables:**
   - Execute the SQL script `create.sql` to create the RawStats staging table and all normalized tables.

2. **Load Data into RawStats:**
   - Execute the SQL script `load.sql`, which contains:
     - A COPY command to load `final_.csv` into RawStats.
     - Insert-select SQL statements to populate the normalized tables (Players, Teams, Stadiums, Matches, Match_Format, Player_Stats) from RawStats.

**Example:**
```sql
-- In load.sql
COPY RawStats FROM '/path_to/final_.csv' DELIMITER ',' CSV HEADER;

-- Insert data into Players from RawStats
INSERT INTO Players (player_id, player_name, team_id, role, age, nationality)
SELECT DISTINCT player_id, player_name, team_id, role, age, nationality FROM RawStats;
```

---

**Web Application:**
- A Streamlit application named `streamlit_cricket_app.py` has been developed.
- It connects to the PostgreSQL database hosted on a cloud platform (e.g., Railway or Supabase).
- Users can interact with the database through the web app by running various analytical queries.

**Deployment:**
- The web app has been deployed on Streamlit Cloud.
- The public link to the app is provided in the final report.

---

**Notes:**
- Ensure PostgreSQL service is running before executing SQL scripts.
- The environment variable `DATABASE_URL` must be set up for secure connections in Streamlit Cloud.
- Passwords and sensitive connection information must not be hardcoded.

---

**Team 44 **
- Nithisshkrishna K S
- Harini Murugan

---

**End of README**


