# Campus Spatiotemporal Delivery Engine (Milestones M1–M3)

An Advanced Database Systems (CS G516) project demonstrating physical spatiotemporal database design, geometric entity modeling, and spatial query mechanics using PostgreSQL and PostGIS.

---

## 1. Project Overview

This repository contains the mid-semester foundational implementation (M1–M3) for a campus last-mile delivery system. The primary goal is to establish a spatiotemporal database schema that separates relational transactional entities from high-frequency spatial telemetry, enabling spatial joins, proximity filtering, and spatial containment checks natively inside PostGIS.

### Key Capabilities (M1–M3 Scope)
* **Spatial Entity Modeling:** Storing spatial boundaries (`POLYGON`) and point entities (`POINT`) using WGS 84 (`EPSG:4326`) coordinate reference systems.
* **Spatial Indexing:** Implementation of Generalized Search Tree (**GiST**) indexes on geographic columns.
* **PostGIS Spatial Operator Workload:** Executing spatial containment (`ST_Contains`), range filtering (`ST_DWithin`), direct spherical distance measurement (`ST_Distance`), and K-Nearest Neighbor (`<->`) driver proximity sorting.
* **Interactive Visualizer:** Streamlit + Folium map interface for inspecting polygon geofences and driver points.

---

## 2. Entity-Relationship (ER) Diagram

```mermaid
erDiagram
    CAMPUS_ZONE {
        int zone_id PK
        string zone_name
        geometry boundary "POLYGON"
    }
    DELIVERY_LOCATION {
        int location_id PK
        string name
        int zone_id FK
        geometry point "POINT"
    }
    DRIVER {
        int driver_id PK
        string name
        string status
    }
    ORDER {
        int order_id PK
        int driver_id FK
        int destination_id FK
        string status
        timestamp created_at
    }
    LOCATION_TRACE {
        bigint trace_id PK
        int driver_id FK
        geometry location "POINT"
        timestamp recorded_at
    }

    CAMPUS_ZONE ||--o{ DELIVERY_LOCATION : "contains"
    DRIVER ||--o{ ORDER : "assigned to"
    DELIVERY_LOCATION ||--o{ ORDER : "destination"
    DRIVER ||--o{ LOCATION_TRACE : "emits telemetry"