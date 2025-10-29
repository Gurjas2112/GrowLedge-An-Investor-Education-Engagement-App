# Vayu Drishti - Database Design Documentation

## Complete Database Schema with Mermaid Diagrams

---

## 1. Entity-Relationship Diagram (ERD)

```mermaid
erDiagram
    AQI_STATION ||--o{ POLLUTANT_READING : measures
    AQI_STATION ||--o{ WEATHER_DATA : has
    AQI_STATION ||--o{ SATELLITE_DATA : receives
    AQI_STATION ||--o{ AQI_FORECAST : generates
    LOCATION ||--|| AQI_STATION : located_at
    USER ||--o{ USER_ALERT : receives
    USER ||--o{ USER_LOCATION : monitors
    USER_LOCATION }o--|| LOCATION : references
    AQI_FORECAST }o--|| AQI_STATION : forecasts_for
    HEALTH_ADVISORY ||--o{ AQI_FORECAST : based_on
    MODEL_VERSION ||--o{ AQI_FORECAST : used_by
    DATA_SOURCE ||--o{ POLLUTANT_READING : from
    DATA_SOURCE ||--o{ WEATHER_DATA : from
    DATA_SOURCE ||--o{ SATELLITE_DATA : from

    AQI_STATION {
        int station_id PK
        string station_name
        float latitude
        float longitude
        string state
        string city
        string district
        string station_type
        datetime last_update
        boolean is_active
        string data_source
        int location_id FK
        datetime created_at
        datetime updated_at
    }

    POLLUTANT_READING {
        int reading_id PK
        int station_id FK
        datetime timestamp
        float pm25
        float pm10
        float no2
        float so2
        float co
        float o3
        float nh3
        int aqi
        string aqi_category
        float confidence_score
        int data_source_id FK
        datetime created_at
    }

    WEATHER_DATA {
        int weather_id PK
        int station_id FK
        datetime timestamp
        float temperature
        float humidity
        float wind_speed
        float wind_direction
        float surface_pressure
        float precipitation
        float boundary_layer_height
        float atmospheric_pressure
        int data_source_id FK
        datetime created_at
    }

    SATELLITE_DATA {
        int satellite_id PK
        int station_id FK
        datetime timestamp
        float aod550
        float aerosol_index
        float cloud_fraction
        float surface_reflectance
        float angstrom_exponent
        float single_scattering_albedo
        string satellite_name
        float spatial_resolution
        int data_source_id FK
        datetime created_at
    }

    LOCATION {
        int location_id PK
        float latitude
        float longitude
        string city
        string state
        string district
        string pincode
        int population
        string location_type
        geometry geom
        datetime created_at
        datetime updated_at
    }

    AQI_FORECAST {
        int forecast_id PK
        int station_id FK
        datetime forecast_time
        datetime prediction_time
        int predicted_aqi
        string aqi_category
        float confidence_score
        int forecast_horizon_hours
        float pm25_forecast
        float pm10_forecast
        float no2_forecast
        float upper_bound
        float lower_bound
        int model_version_id FK
        datetime created_at
    }

    USER {
        int user_id PK
        string username
        string email
        string phone
        string password_hash
        datetime registration_date
        string health_profile
        boolean notifications_enabled
        string preferred_language
        datetime last_login
        boolean is_active
        datetime created_at
        datetime updated_at
    }

    USER_ALERT {
        int alert_id PK
        int user_id FK
        datetime alert_time
        string alert_type
        string message
        int aqi_value
        string severity
        boolean is_read
        datetime read_at
        datetime created_at
    }

    USER_LOCATION {
        int user_location_id PK
        int user_id FK
        int location_id FK
        boolean is_primary
        int alert_threshold
        datetime added_date
        datetime updated_at
    }

    HEALTH_ADVISORY {
        int advisory_id PK
        int forecast_id FK
        string aqi_category
        string general_advice
        string sensitive_group_advice
        string outdoor_activity_advice
        string commute_advice
        string mask_recommendation
        datetime created_at
        datetime updated_at
    }

    MODEL_VERSION {
        int model_version_id PK
        string model_name
        string version_number
        float r2_score
        float rmse
        float mae
        int n_estimators
        int max_depth
        datetime trained_at
        int training_records
        string feature_list
        boolean is_active
        datetime deployed_at
    }

    DATA_SOURCE {
        int data_source_id PK
        string source_name
        string source_type
        string api_endpoint
        datetime last_fetch
        boolean is_active
        int fetch_frequency_minutes
        datetime created_at
    }
```

---

## 2. Database Schema - Relational Model

```mermaid
graph TB
    subgraph "Core Tables"
        T1[(AQI_STATION<br/>Primary: station_id<br/>Foreign: location_id)]
        T2[(LOCATION<br/>Primary: location_id<br/>Geometry: geom)]
        T3[(DATA_SOURCE<br/>Primary: data_source_id)]
    end

    subgraph "Data Tables"
        T4[(POLLUTANT_READING<br/>Primary: reading_id<br/>Foreign: station_id, data_source_id)]
        T5[(WEATHER_DATA<br/>Primary: weather_id<br/>Foreign: station_id, data_source_id)]
        T6[(SATELLITE_DATA<br/>Primary: satellite_id<br/>Foreign: station_id, data_source_id)]
    end

    subgraph "Forecasting Tables"
        T7[(AQI_FORECAST<br/>Primary: forecast_id<br/>Foreign: station_id, model_version_id)]
        T8[(MODEL_VERSION<br/>Primary: model_version_id)]
        T9[(HEALTH_ADVISORY<br/>Primary: advisory_id<br/>Foreign: forecast_id)]
    end

    subgraph "User Management Tables"
        T10[(USER<br/>Primary: user_id)]
        T11[(USER_LOCATION<br/>Primary: user_location_id<br/>Foreign: user_id, location_id)]
        T12[(USER_ALERT<br/>Primary: alert_id<br/>Foreign: user_id)]
    end

    T2 -->|1:1| T1
    T3 -->|1:N| T4
    T3 -->|1:N| T5
    T3 -->|1:N| T6
    T1 -->|1:N| T4
    T1 -->|1:N| T5
    T1 -->|1:N| T6
    T1 -->|1:N| T7
    T8 -->|1:N| T7
    T7 -->|1:N| T9
    T10 -->|1:N| T11
    T10 -->|1:N| T12
    T2 -->|1:N| T11

    style T1 fill:#90EE90
    style T7 fill:#FFD700
    style T8 fill:#FF6B6B
    style T10 fill:#87CEEB
```

---

## 3. Data Flow - Database Operations

```mermaid
flowchart TD
    subgraph "Data Ingestion"
        A1[CPCB API Fetch] --> A2[Validate & Clean]
        A3[MERRA-2 Fetch] --> A2
        A4[INSAT-3DR Fetch] --> A2
        A2 --> A5{Data Quality Check}
    end

    subgraph "Database Write Operations"
        A5 -->|Pass| B1[INSERT POLLUTANT_READING]
        A5 -->|Pass| B2[INSERT WEATHER_DATA]
        A5 -->|Pass| B3[INSERT SATELLITE_DATA]
        A5 -->|Fail| B4[Log to ERROR_TABLE]
        B1 --> B5[UPDATE AQI_STATION.last_update]
        B2 --> B5
        B3 --> B5
    end

    subgraph "Forecasting Pipeline"
        C1[Trigger Forecast Job] --> C2[SELECT Latest Data<br/>JOIN 3 Tables]
        C2 --> C3[Load MODEL_VERSION]
        C3 --> C4[Generate Predictions]
        C4 --> C5[INSERT AQI_FORECAST]
        C5 --> C6[INSERT HEALTH_ADVISORY]
    end

    subgraph "User Interaction"
        D1[User Query] --> D2{Query Type}
        D2 -->|Real-Time| D3[SELECT from<br/>POLLUTANT_READING]
        D2 -->|Forecast| D4[SELECT from<br/>AQI_FORECAST]
        D2 -->|Map| D5[SELECT AQI_STATION<br/>JOIN LOCATION]
        D3 --> D6[Return Results]
        D4 --> D6
        D5 --> D6
        D6 --> D7[Check Alert Thresholds]
        D7 --> D8[INSERT USER_ALERT<br/>if threshold exceeded]
    end

    B5 --> C1
    C6 --> D7

    style C3 fill:#90EE90
    style C5 fill:#FFD700
    style D8 fill:#FF6B6B
```

---

## 4. Table Relationships - Detailed View

```mermaid
erDiagram
    USER ||--o{ USER_LOCATION : "has multiple"
    USER ||--o{ USER_ALERT : "receives"
    USER_LOCATION }o--|| LOCATION : "references"
    LOCATION ||--|| AQI_STATION : "contains"
    AQI_STATION ||--o{ POLLUTANT_READING : "generates"
    AQI_STATION ||--o{ WEATHER_DATA : "records"
    AQI_STATION ||--o{ SATELLITE_DATA : "receives"
    AQI_STATION ||--o{ AQI_FORECAST : "forecasts"
    AQI_FORECAST ||--|| HEALTH_ADVISORY : "triggers"
    MODEL_VERSION ||--o{ AQI_FORECAST : "predicts with"
    DATA_SOURCE ||--o{ POLLUTANT_READING : "provides"
    DATA_SOURCE ||--o{ WEATHER_DATA : "provides"
    DATA_SOURCE ||--o{ SATELLITE_DATA : "provides"

    USER {
        user_id INT PK "Auto-increment"
        username VARCHAR_50 UK "Unique username"
        email VARCHAR_100 UK "Unique email"
        phone VARCHAR_15 "Optional contact"
        password_hash VARCHAR_255 "Bcrypt hashed"
        health_profile ENUM "Normal/Sensitive/High-Risk"
        notifications_enabled BOOLEAN "Default TRUE"
        preferred_language VARCHAR_10 "Default 'en'"
        last_login TIMESTAMP "Activity tracking"
        is_active BOOLEAN "Soft delete flag"
    }

    LOCATION {
        location_id INT PK
        latitude DECIMAL "7 decimal places"
        longitude DECIMAL "7 decimal places"
        city VARCHAR_100
        state VARCHAR_50
        district VARCHAR_50
        pincode VARCHAR_6
        population INT
        location_type ENUM "Urban/Rural/Peri-urban"
        geom GEOMETRY "PostGIS point"
    }

    AQI_STATION {
        station_id INT PK
        station_name VARCHAR_200
        location_id INT FK
        station_type ENUM "CPCB/Manual/Satellite"
        data_source VARCHAR_50 "CPCB/IMD/ISRO"
        is_active BOOLEAN
        last_update TIMESTAMP "Last data received"
    }

    POLLUTANT_READING {
        reading_id BIGINT PK
        station_id INT FK
        timestamp TIMESTAMP "Indexed"
        pm25 FLOAT "μg/m³"
        pm10 FLOAT "μg/m³"
        no2 FLOAT "μg/m³"
        so2 FLOAT "μg/m³"
        co FLOAT "mg/m³"
        o3 FLOAT "μg/m³"
        nh3 FLOAT "μg/m³"
        aqi INT "0-500"
        aqi_category VARCHAR_20 "Good/Moderate/Poor..."
        confidence_score FLOAT "0.0-1.0"
        data_source_id INT FK
    }

    AQI_FORECAST {
        forecast_id BIGINT PK
        station_id INT FK
        forecast_time TIMESTAMP "When forecast made"
        prediction_time TIMESTAMP "For when"
        predicted_aqi INT "0-500"
        forecast_horizon_hours INT "1-72"
        confidence_score FLOAT "Model confidence"
        upper_bound FLOAT "AQI + RMSE"
        lower_bound FLOAT "AQI - RMSE"
        model_version_id INT FK
    }

    MODEL_VERSION {
        model_version_id INT PK
        model_name VARCHAR_50 "RandomForest/LSTM"
        version_number VARCHAR_20 "v1.0.0"
        r2_score FLOAT "0.9994"
        rmse FLOAT "4.57"
        mae FLOAT "2.33"
        n_estimators INT "200"
        max_depth INT "30"
        trained_at TIMESTAMP
        training_records INT "84504"
        is_active BOOLEAN "Production flag"
    }
```

---

## 5. Indexing Strategy

```mermaid
graph TB
    subgraph "Primary Keys - Clustered Indexes"
        I1[AQI_STATION.station_id]
        I2[POLLUTANT_READING.reading_id]
        I3[AQI_FORECAST.forecast_id]
        I4[USER.user_id]
    end

    subgraph "Foreign Key Indexes"
        I5[POLLUTANT_READING.station_id]
        I6[AQI_FORECAST.station_id]
        I7[USER_LOCATION.user_id]
        I8[USER_LOCATION.location_id]
    end

    subgraph "Timestamp Indexes - Critical for Performance"
        I9[POLLUTANT_READING.timestamp<br/>DESC index for latest data]
        I10[AQI_FORECAST.prediction_time<br/>Range queries]
        I11[USER_ALERT.alert_time<br/>Sorting alerts]
    end

    subgraph "Composite Indexes - Query Optimization"
        I12[station_id, timestamp<br/>POLLUTANT_READING]
        I13[station_id, prediction_time<br/>AQI_FORECAST]
        I14[user_id, is_read<br/>USER_ALERT]
    end

    subgraph "Spatial Indexes - PostGIS"
        I15[LOCATION.geom<br/>GIST index]
        I16[Nearest neighbor queries<br/>KNN operations]
    end

    subgraph "Full-Text Indexes"
        I17[AQI_STATION.station_name<br/>Search functionality]
        I18[LOCATION.city, state<br/>Auto-complete]
    end

    I1 --> I5
    I1 --> I6
    I2 --> I9
    I3 --> I10
    I4 --> I7
    I5 --> I12
    I6 --> I13
    I7 --> I14
    I15 --> I16

    style I9 fill:#FFD700
    style I12 fill:#90EE90
    style I15 fill:#FF6B6B
```

---

## 6. Database Partitioning Strategy

```mermaid
graph TD
    subgraph "Time-Series Data Partitioning"
        P1[POLLUTANT_READING<br/>Partitioned by timestamp]
        P1 --> P2[Partition: 2024_Q4<br/>Oct-Dec 2024]
        P1 --> P3[Partition: 2025_Q1<br/>Jan-Mar 2025]
        P1 --> P4[Partition: 2025_Q2<br/>Apr-Jun 2025]
        P1 --> P5[Partition: 2025_Q3<br/>Jul-Sep 2025]
        P1 --> P6[Partition: 2025_Q4<br/>Oct-Dec 2025]
    end

    subgraph "Forecast Data Partitioning"
        P7[AQI_FORECAST<br/>Partitioned by prediction_time]
        P7 --> P8[Partition: Current_Month]
        P7 --> P9[Partition: Next_Month]
        P7 --> P10[Partition: Future_Months]
    end

    subgraph "Archival Strategy"
        P11[Archive: >6 months old<br/>Move to cold storage]
        P12[Compress: >3 months old<br/>PostgreSQL compression]
        P13[Hot data: Last 3 months<br/>Fast SSD storage]
    end

    P2 --> P11
    P3 --> P12
    P4 --> P13
    P5 --> P13
    P6 --> P13

    style P13 fill:#90EE90
    style P11 fill:#87CEEB
```

---

## 7. Data Consistency & Constraints

```mermaid
graph TB
    subgraph "Referential Integrity"
        C1[Foreign Key Constraints]
        C1 --> C2[CASCADE on UPDATE]
        C1 --> C3[RESTRICT on DELETE<br/>Prevent orphans]
        C1 --> C4[SET NULL on optional FKs]
    end

    subgraph "Data Validation Constraints"
        C5[CHECK Constraints]
        C5 --> C6[AQI BETWEEN 0 AND 500]
        C5 --> C7[pm25 >= 0]
        C5 --> C8[latitude BETWEEN -90 AND 90]
        C5 --> C9[confidence_score BETWEEN 0 AND 1]
    end

    subgraph "Unique Constraints"
        C10[UNIQUE Indexes]
        C10 --> C11[USER.email UNIQUE]
        C10 --> C12[USER.username UNIQUE]
        C10 --> C13[station_id, timestamp<br/>No duplicate readings]
    end

    subgraph "Default Values"
        C14[Column Defaults]
        C14 --> C15[created_at = NOW]
        C14 --> C16[is_active = TRUE]
        C14 --> C17[notifications_enabled = TRUE]
    end

    subgraph "Triggers"
        C18[Automated Triggers]
        C18 --> C19[AFTER INSERT on POLLUTANT_READING<br/>Update AQI_STATION.last_update]
        C18 --> C20[AFTER INSERT on AQI_FORECAST<br/>Check alert thresholds]
        C18 --> C21[BEFORE UPDATE on USER<br/>Hash password if changed]
    end

    style C19 fill:#FFD700
    style C20 fill:#FF6B6B
```

---

## 8. Query Performance Optimization

```mermaid
graph LR
    subgraph "Common Queries"
        Q1[Get Latest AQI<br/>for City]
        Q2[72-Hour Forecast<br/>for Station]
        Q3[Nearby Stations<br/>within 50km]
        Q4[User Alerts<br/>Last 7 Days]
    end

    subgraph "Optimization Strategies"
        O1[Materialized Views]
        O2[Query Result Caching]
        O3[Connection Pooling]
        O4[Read Replicas]
    end

    subgraph "Materialized Views"
        M1[latest_aqi_by_station<br/>Refreshed every 5 min]
        M2[daily_aqi_summary<br/>Aggregated statistics]
        M3[station_metadata_enriched<br/>Pre-joined location data]
    end

    subgraph "Caching Layer"
        R1[Redis Cache<br/>TTL: 5 minutes]
        R2[Key Pattern:<br/>aqi:station:123]
        R3[Forecast Cache<br/>TTL: 1 hour]
    end

    Q1 --> M1
    Q2 --> R3
    Q3 --> M3
    Q4 --> O2
    O1 --> M1
    O1 --> M2
    O1 --> M3
    O2 --> R1
    R1 --> R2
    R1 --> R3

    style M1 fill:#90EE90
    style R1 fill:#FFD700
```

---

## 9. Backup & Recovery Strategy

```mermaid
flowchart TD
    subgraph "Backup Types"
        B1[Full Backup<br/>Weekly - Sunday 2 AM]
        B2[Incremental Backup<br/>Daily - 3 AM]
        B3[Transaction Log Backup<br/>Hourly]
    end

    subgraph "Backup Storage"
        B4[Primary Storage<br/>Local NAS]
        B5[Secondary Storage<br/>Cloud S3]
        B6[Offsite Backup<br/>Different Region]
    end

    subgraph "Recovery Scenarios"
        R1[Point-in-Time Recovery<br/>Last 30 days]
        R2[Table-Level Recovery<br/>Restore single table]
        R3[Complete Restore<br/>Disaster recovery]
    end

    subgraph "Retention Policy"
        RP1[Daily Backups: 7 days]
        RP2[Weekly Backups: 4 weeks]
        RP3[Monthly Backups: 12 months]
        RP4[Yearly Backups: 7 years]
    end

    B1 --> B4
    B2 --> B4
    B3 --> B4
    B4 --> B5
    B5 --> B6
    B4 --> R1
    B4 --> R2
    B6 --> R3

    style R1 fill:#90EE90
    style B6 fill:#FF6B6B
```

---

## 10. Database Security Architecture

```mermaid
graph TB
    subgraph "Authentication Layer"
        S1[Connection Authentication]
        S1 --> S2[SSL/TLS Encryption<br/>All connections]
        S1 --> S3[Certificate-Based Auth<br/>Service accounts]
        S1 --> S4[Password Policy<br/>Minimum 12 chars + complexity]
    end

    subgraph "Authorization - Role-Based Access Control"
        S5[Database Roles]
        S5 --> S6[admin_role<br/>Full access]
        S5 --> S7[app_role<br/>CRUD on data tables]
        S5 --> S8[readonly_role<br/>SELECT only]
        S5 --> S9[analyst_role<br/>SELECT + aggregate queries]
    end

    subgraph "Row-Level Security"
        S10[RLS Policies]
        S10 --> S11[USER_LOCATION<br/>Users see only their data]
        S10 --> S12[USER_ALERT<br/>Users see only their alerts]
        S10 --> S13[AQI_STATION<br/>Filter by region permissions]
    end

    subgraph "Data Encryption"
        S14[Encryption at Rest]
        S14 --> S15[AES-256 encryption<br/>Sensitive columns]
        S14 --> S16[Transparent Data Encryption<br/>Entire database]
        S17[Encryption in Transit]
        S17 --> S18[TLS 1.3<br/>Client-Server]
    end

    subgraph "Audit Logging"
        S19[Audit Trail]
        S19 --> S20[Log all DDL statements]
        S19 --> S21[Log failed login attempts]
        S19 --> S22[Track sensitive data access]
    end

    S2 --> S5
    S6 --> S10
    S7 --> S10
    S14 --> S19

    style S2 fill:#FF6B6B
    style S11 fill:#90EE90
    style S15 fill:#FFD700
```

---

## 11. Database Monitoring & Alerts

```mermaid
graph LR
    subgraph "Performance Monitoring"
        M1[Query Performance<br/>Slow query log >1s]
        M2[Connection Pool<br/>Monitor usage]
        M3[Cache Hit Ratio<br/>Target >90%]
        M4[Table Bloat<br/>Vacuum required]
    end

    subgraph "Capacity Monitoring"
        M5[Disk Usage<br/>Alert at 80%]
        M6[Table Size Growth<br/>Partition planning]
        M7[Index Size<br/>Optimize if oversized]
        M8[Memory Usage<br/>Buffer cache efficiency]
    end

    subgraph "Availability Monitoring"
        M9[Replication Lag<br/>Alert if >10s]
        M10[Connection Failures<br/>Network issues]
        M11[Backup Success<br/>Daily verification]
        M12[Deadlock Detection<br/>Transaction conflicts]
    end

    subgraph "Alerting System"
        A1[Prometheus + Grafana]
        A2[Email Alerts<br/>Critical issues]
        A3[Slack Webhooks<br/>Team notifications]
        A4[PagerDuty<br/>On-call escalation]
    end

    M1 --> A1
    M2 --> A1
    M5 --> A2
    M9 --> A3
    M10 --> A4

    style M1 fill:#FFD700
    style M9 fill:#FF6B6B
    style A1 fill:#90EE90
```

---

## 12. Sample SQL Schema - PostgreSQL

```sql
-- Create Extensions
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pg_trgm; -- For text search

-- ============================================
-- CORE TABLES
-- ============================================

CREATE TABLE data_source (
    data_source_id SERIAL PRIMARY KEY,
    source_name VARCHAR(100) NOT NULL,
    source_type VARCHAR(50) CHECK (source_type IN ('CPCB', 'MERRA2', 'INSAT3DR', 'Manual')),
    api_endpoint VARCHAR(500),
    last_fetch TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    fetch_frequency_minutes INT DEFAULT 60,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE location (
    location_id SERIAL PRIMARY KEY,
    latitude DECIMAL(10, 7) NOT NULL CHECK (latitude BETWEEN -90 AND 90),
    longitude DECIMAL(10, 7) NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    city VARCHAR(100),
    state VARCHAR(50),
    district VARCHAR(50),
    pincode VARCHAR(6),
    population INT,
    location_type VARCHAR(20) CHECK (location_type IN ('Urban', 'Rural', 'Peri-urban')),
    geom GEOMETRY(Point, 4326), -- PostGIS spatial column
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Spatial index for location
CREATE INDEX idx_location_geom ON location USING GIST (geom);

CREATE TABLE aqi_station (
    station_id SERIAL PRIMARY KEY,
    station_name VARCHAR(200) NOT NULL,
    latitude DECIMAL(10, 7) NOT NULL,
    longitude DECIMAL(10, 7) NOT NULL,
    state VARCHAR(50),
    city VARCHAR(100),
    district VARCHAR(50),
    station_type VARCHAR(50) CHECK (station_type IN ('CPCB', 'Manual', 'Satellite', 'Hybrid')),
    last_update TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    data_source VARCHAR(50),
    location_id INT REFERENCES location(location_id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_aqi_station_location ON aqi_station(location_id);
CREATE INDEX idx_aqi_station_active ON aqi_station(is_active) WHERE is_active = TRUE;

-- ============================================
-- DATA TABLES (PARTITIONED)
-- ============================================

CREATE TABLE pollutant_reading (
    reading_id BIGSERIAL,
    station_id INT NOT NULL REFERENCES aqi_station(station_id) ON DELETE CASCADE,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    pm25 FLOAT CHECK (pm25 >= 0),
    pm10 FLOAT CHECK (pm10 >= 0),
    no2 FLOAT CHECK (no2 >= 0),
    so2 FLOAT CHECK (so2 >= 0),
    co FLOAT CHECK (co >= 0),
    o3 FLOAT CHECK (o3 >= 0),
    nh3 FLOAT CHECK (nh3 >= 0),
    aqi INT CHECK (aqi BETWEEN 0 AND 500),
    aqi_category VARCHAR(20) CHECK (aqi_category IN ('Good', 'Moderate', 'Unhealthy for Sensitive', 'Unhealthy', 'Very Unhealthy', 'Hazardous')),
    confidence_score FLOAT CHECK (confidence_score BETWEEN 0 AND 1),
    data_source_id INT REFERENCES data_source(data_source_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (reading_id, timestamp)
) PARTITION BY RANGE (timestamp);

-- Create partitions for each quarter
CREATE TABLE pollutant_reading_2025_q4 PARTITION OF pollutant_reading
    FOR VALUES FROM ('2025-10-01') TO ('2026-01-01');

-- Indexes on partitioned table
CREATE INDEX idx_pollutant_station_time ON pollutant_reading(station_id, timestamp DESC);
CREATE INDEX idx_pollutant_timestamp ON pollutant_reading(timestamp DESC);
CREATE INDEX idx_pollutant_aqi ON pollutant_reading(aqi) WHERE aqi > 150;

CREATE TABLE weather_data (
    weather_id BIGSERIAL PRIMARY KEY,
    station_id INT NOT NULL REFERENCES aqi_station(station_id) ON DELETE CASCADE,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    temperature FLOAT,
    humidity FLOAT CHECK (humidity BETWEEN 0 AND 100),
    wind_speed FLOAT CHECK (wind_speed >= 0),
    wind_direction FLOAT CHECK (wind_direction BETWEEN 0 AND 360),
    surface_pressure FLOAT,
    precipitation FLOAT CHECK (precipitation >= 0),
    boundary_layer_height FLOAT CHECK (boundary_layer_height >= 0),
    atmospheric_pressure FLOAT,
    data_source_id INT REFERENCES data_source(data_source_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_weather_station_time ON weather_data(station_id, timestamp DESC);

CREATE TABLE satellite_data (
    satellite_id BIGSERIAL PRIMARY KEY,
    station_id INT NOT NULL REFERENCES aqi_station(station_id) ON DELETE CASCADE,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    aod550 FLOAT CHECK (aod550 >= 0),
    aerosol_index FLOAT,
    cloud_fraction FLOAT CHECK (cloud_fraction BETWEEN 0 AND 1),
    surface_reflectance FLOAT CHECK (surface_reflectance BETWEEN 0 AND 1),
    angstrom_exponent FLOAT,
    single_scattering_albedo FLOAT CHECK (single_scattering_albedo BETWEEN 0 AND 1),
    satellite_name VARCHAR(50) DEFAULT 'INSAT-3DR',
    spatial_resolution FLOAT,
    data_source_id INT REFERENCES data_source(data_source_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_satellite_station_time ON satellite_data(station_id, timestamp DESC);

-- ============================================
-- FORECASTING TABLES
-- ============================================

CREATE TABLE model_version (
    model_version_id SERIAL PRIMARY KEY,
    model_name VARCHAR(50) NOT NULL,
    version_number VARCHAR(20) NOT NULL,
    r2_score FLOAT,
    rmse FLOAT,
    mae FLOAT,
    n_estimators INT,
    max_depth INT,
    trained_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    training_records INT,
    feature_list TEXT,
    is_active BOOLEAN DEFAULT FALSE,
    deployed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(model_name, version_number)
);

CREATE TABLE aqi_forecast (
    forecast_id BIGSERIAL,
    station_id INT NOT NULL REFERENCES aqi_station(station_id) ON DELETE CASCADE,
    forecast_time TIMESTAMP WITH TIME ZONE NOT NULL,
    prediction_time TIMESTAMP WITH TIME ZONE NOT NULL,
    predicted_aqi INT CHECK (predicted_aqi BETWEEN 0 AND 500),
    aqi_category VARCHAR(20),
    confidence_score FLOAT CHECK (confidence_score BETWEEN 0 AND 1),
    forecast_horizon_hours INT CHECK (forecast_horizon_hours BETWEEN 1 AND 72),
    pm25_forecast FLOAT,
    pm10_forecast FLOAT,
    no2_forecast FLOAT,
    upper_bound FLOAT,
    lower_bound FLOAT,
    model_version_id INT REFERENCES model_version(model_version_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (forecast_id, prediction_time)
) PARTITION BY RANGE (prediction_time);

CREATE TABLE aqi_forecast_current PARTITION OF aqi_forecast
    FOR VALUES FROM (CURRENT_DATE) TO (CURRENT_DATE + INTERVAL '1 month');

CREATE INDEX idx_forecast_station_pred ON aqi_forecast(station_id, prediction_time);
CREATE INDEX idx_forecast_time ON aqi_forecast(prediction_time);

CREATE TABLE health_advisory (
    advisory_id SERIAL PRIMARY KEY,
    forecast_id BIGINT NOT NULL,
    aqi_category VARCHAR(20) NOT NULL,
    general_advice TEXT,
    sensitive_group_advice TEXT,
    outdoor_activity_advice TEXT,
    commute_advice TEXT,
    mask_recommendation TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- USER MANAGEMENT TABLES
-- ============================================

CREATE TABLE app_user (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    password_hash VARCHAR(255) NOT NULL,
    registration_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    health_profile VARCHAR(20) CHECK (health_profile IN ('Normal', 'Sensitive', 'High-Risk')),
    notifications_enabled BOOLEAN DEFAULT TRUE,
    preferred_language VARCHAR(10) DEFAULT 'en',
    last_login TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_email ON app_user(email);
CREATE INDEX idx_user_active ON app_user(is_active) WHERE is_active = TRUE;

CREATE TABLE user_location (
    user_location_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES app_user(user_id) ON DELETE CASCADE,
    location_id INT NOT NULL REFERENCES location(location_id) ON DELETE CASCADE,
    is_primary BOOLEAN DEFAULT FALSE,
    alert_threshold INT DEFAULT 150 CHECK (alert_threshold BETWEEN 0 AND 500),
    added_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, location_id)
);

CREATE INDEX idx_user_location_user ON user_location(user_id);
CREATE INDEX idx_user_location_primary ON user_location(user_id, is_primary) WHERE is_primary = TRUE;

CREATE TABLE user_alert (
    alert_id BIGSERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES app_user(user_id) ON DELETE CASCADE,
    alert_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    alert_type VARCHAR(50) CHECK (alert_type IN ('Threshold', 'Forecast', 'Health', 'System')),
    message TEXT NOT NULL,
    aqi_value INT CHECK (aqi_value BETWEEN 0 AND 500),
    severity VARCHAR(20) CHECK (severity IN ('Info', 'Warning', 'Critical')),
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_alert_user_time ON user_alert(user_id, alert_time DESC);
CREATE INDEX idx_alert_unread ON user_alert(user_id, is_read) WHERE is_read = FALSE;

-- ============================================
-- MATERIALIZED VIEWS
-- ============================================

CREATE MATERIALIZED VIEW latest_aqi_by_station AS
SELECT DISTINCT ON (station_id)
    station_id,
    timestamp,
    aqi,
    aqi_category,
    pm25,
    pm10,
    confidence_score
FROM pollutant_reading
ORDER BY station_id, timestamp DESC;

CREATE UNIQUE INDEX idx_latest_aqi_station ON latest_aqi_by_station(station_id);

-- Refresh materialized view every 5 minutes (scheduled job)
-- SELECT refresh_materialized_view_job();

-- ============================================
-- TRIGGERS
-- ============================================

CREATE OR REPLACE FUNCTION update_station_last_update()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE aqi_station
    SET last_update = NEW.timestamp
    WHERE station_id = NEW.station_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_station_last_update
AFTER INSERT ON pollutant_reading
FOR EACH ROW
EXECUTE FUNCTION update_station_last_update();

-- ============================================
-- ROW-LEVEL SECURITY
-- ============================================

ALTER TABLE user_location ENABLE ROW LEVEL SECURITY;

CREATE POLICY user_location_isolation ON user_location
    FOR ALL
    TO app_role
    USING (user_id = current_setting('app.current_user_id')::INT);

ALTER TABLE user_alert ENABLE ROW LEVEL SECURITY;

CREATE POLICY user_alert_isolation ON user_alert
    FOR ALL
    TO app_role
    USING (user_id = current_setting('app.current_user_id')::INT);
```

---

## Database Statistics

| Component | Count/Size | Description |
|-----------|-----------|-------------|
| **Total Tables** | 13 | Core + Data + User tables |
| **Partitioned Tables** | 2 | pollutant_reading, aqi_forecast |
| **Materialized Views** | 1+ | latest_aqi_by_station, daily_summary |
| **Indexes** | 25+ | Primary, Foreign, Composite, Spatial |
| **Triggers** | 3+ | Auto-updates, alerting, auditing |
| **Database Size (Est.)** | 50-100 GB | With 6 months historical data |
| **Daily Growth** | ~500 MB | 503 stations × 24 hours × 3 tables |
| **Partitions** | Quarterly | 3-month rotation for time-series |
| **Backup Size** | ~200 GB | Full + incremental backups |
| **Read Replicas** | 2 | For load balancing |

---

## Performance Benchmarks

| Query Type | Expected Time | Optimization |
|------------|---------------|--------------|
| Latest AQI (single station) | <10ms | Materialized view |
| 72-hour forecast | <50ms | Cached in Redis |
| Nearby stations (50km) | <100ms | Spatial index |
| Historical data (6 months) | <500ms | Partition pruning |
| Aggregate statistics | <200ms | Materialized view |
| User alerts (unread) | <20ms | Composite index |
| Map markers (all stations) | <150ms | Cached + indexed |

---

*Database Design Document - Vayu Drishti Air Quality Visualizer*  
*Last Updated: October 30, 2025*
