import streamlit as st
import folium
from streamlit_folium import st_folium
import psycopg2
import os

st.set_page_config(page_title="Campus Spatial DB (M1-M3)", layout="wide")
st.title("Campus Spatial Delivery Engine — M1-M3 Inspection")

# Database Connection
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_NAME = os.getenv("DB_NAME", "campus_delivery")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASS = os.getenv("DB_PASS", "postgrespassword")

def get_connection():
    return psycopg2.connect(host=DB_HOST, database=DB_NAME, user=DB_USER, password=DB_PASS)

try:
    conn = get_connection()
    cur = conn.cursor()

    # Map Setup (Centered on Campus)
    m = folium.Map(location=[17.456, 78.352], zoom_start=16)

    # Fetch Zones
    cur.execute("SELECT zone_name, ST_AsGeoJSON(boundary) FROM campus_zone;")
    for zone_name, geojson_str in cur.fetchall():
        folium.GeoJson(geojson_str, name=zone_name, tooltip=zone_name).add_to(m)

    # Fetch Drivers
    cur.execute("SELECT d.name, ST_X(l.location), ST_Y(l.location) FROM location_trace l JOIN driver d ON l.driver_id = d.driver_id;")
    for name, lon, lat in cur.fetchall():
        folium.Marker([lat, lon], popup=f"Driver: {name}", icon=folium.Icon(color="blue", icon="info-sign")).add_to(m)

    st_folium(m, width=900, height=500)
    st.success("PostGIS Spatial Schema loaded successfully.")

except Exception as e:
    st.error(f"Database Connection Error: {e}")