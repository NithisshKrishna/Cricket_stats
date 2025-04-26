
import streamlit as st
import psycopg2
import pandas as pd
import socket

# PostgreSQL connection
original_getaddrinfo = socket.getaddrinfo
def force_ipv4(*args, **kwargs):
    return [ai for ai in original_getaddrinfo(*args, **kwargs) if ai[0] == socket.AF_INET]
socket.getaddrinfo = force_ipv4


try:
    conn = psycopg2.connect(
        host=st.secrets["database"]["host"],
        database=st.secrets["database"]["database"],
        user=st.secrets["database"]["user"],
        password=st.secrets["database"]["password"],
        port=st.secrets["database"]["port"]
    )
except Exception as e:
    st.error(f"❌ Failed to connect to database: {e}")


# Function to execute query
def run_query(query, params=None):
    with conn.cursor() as cur:
        cur.execute(query, params)
        rows = cur.fetchall()
        colnames = [desc[0] for desc in cur.description]
        return pd.DataFrame(rows, columns=colnames)

# Streamlit app title
st.title("🏏 Cricket Statistics Dashboard")

# Sidebar
option = st.sidebar.selectbox("Select Query to Explore", [
    "Player Search",
    "Top Run Scorers",
    "Match Overview",
    "Players from Team India",
    "T20 Match Details",
    "Total Runs by Player and Team",
    "Top Scorer in Each Match"
])

if option == "Player Search":
    st.subheader("Search Player Stats")
    player_name = st.text_input("Enter Player Name:")
    if player_name:
        df = run_query("""
            SELECT p.player_name, t.name AS team, s.runs_scored, s.wickets_taken, s.catches_taken
            FROM Player_Stats s
            JOIN Players p ON s.player_id = p.player_id
            JOIN Teams t ON p.team_id = t.team_id
            WHERE p.player_name ILIKE %s
        """, (f"%{player_name}%",))
        st.dataframe(df)
# Top Scorers View
elif option == "Top Run Scorers":
    st.subheader("Top 5 Run Scorers")
    df = run_query("""
        SELECT p.player_name, SUM(s.runs_scored) AS total_runs
        FROM Player_Stats s
        JOIN Players p ON s.player_id = p.player_id
        GROUP BY p.player_name
        ORDER BY total_runs DESC
        LIMIT 5;
    """)
    st.dataframe(df)

elif option == "Match Overview":
    st.subheader("Match Summary")
    match_id = st.number_input("Enter Match ID:", min_value=1, step=1)
    if match_id:
        df = run_query("""
            SELECT p.player_name, s.runs_scored, s.wickets_taken, s.overs_bowled, s.catches_taken
            FROM Player_Stats s
            JOIN Players p ON s.player_id = p.player_id
            WHERE s.match_id = %s
        """, (match_id,))
        st.dataframe(df)



# Query 1: Players from Team India
elif option == "Players from Team India":
    st.subheader("🇮🇳 Players from Team India (team_id = 1)")
    query = '''
        SELECT DISTINCT player_name, role, age, nationality
        FROM Players
        WHERE team_id = 1
    '''
    df = run_query(query)
    st.dataframe(df)

# Query 2: T20 Match Details
elif option == "T20 Match Details":
    st.subheader("🏏 T20 Match Details")
    query = '''
        SELECT m.match_id, m.date, 
               t1.name AS team1, 
               t2.name AS team2,
               s.name AS stadium_name,
               f.format_name
        FROM Matches m
        JOIN Teams t1 ON m.team1_id = t1.team_id
        JOIN Teams t2 ON m.team2_id = t2.team_id
        JOIN Stadiums s ON m.stadium_id = s.stadium_id
        JOIN Match_Format f ON m.format_id = f.format_id
        WHERE f.format_name = 'T20'
    '''
    df = run_query(query)
    st.dataframe(df)

# Query 3: Total Runs by Player and Team
elif option == "Total Runs by Player and Team":
    st.subheader("📊 Total Runs Scored by Player (Grouped by Team)")
    query = '''
        SELECT p.player_name, t.name AS team_name, SUM(s.runs_scored) AS total_runs
        FROM Player_Stats s
        JOIN Players p ON s.player_id = p.player_id
        JOIN Teams t ON p.team_id = t.team_id
        GROUP BY p.player_name, t.name
        ORDER BY total_runs DESC
    '''
    df = run_query(query)
    st.dataframe(df)

# Query 4: Top Scorer in Each Match
elif option == "Top Scorer in Each Match":
    st.subheader("🎯 Top Scorer in Each Match")
    query = '''
        SELECT p.player_name, s.match_id, s.runs_scored
        FROM Player_Stats s
        JOIN Players p ON s.player_id = p.player_id
        WHERE (s.match_id, s.runs_scored) IN (
            SELECT match_id, MAX(runs_scored)
            FROM Player_Stats
            GROUP BY match_id
        )
        ORDER BY s.match_id
    '''
    df = run_query(query)
    st.dataframe(df)
