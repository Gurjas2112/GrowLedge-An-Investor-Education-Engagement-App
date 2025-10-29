# Vayu Drishti - Air Quality Visualizer App
## Complete Mermaid Diagrams Documentation

---

## 1. Entity-Relationship (ER) Diagram

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

    AQI_STATION {
        int station_id PK
        string station_name
        float latitude
        float longitude
        string state
        string city
        string station_type
        datetime last_update
        boolean is_active
        string data_source
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
        string data_source
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
        string model_version
    }

    USER {
        int user_id PK
        string username
        string email
        string phone
        datetime registration_date
        string health_profile
        boolean notifications_enabled
        string preferred_language
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
    }

    USER_LOCATION {
        int user_location_id PK
        int user_id FK
        int location_id FK
        boolean is_primary
        datetime added_date
    }

    HEALTH_ADVISORY {
        int advisory_id PK
        int forecast_id FK
        string aqi_category
        string general_advice
        string sensitive_group_advice
        string outdoor_activity_advice
        string commute_advice
        datetime created_at
    }
```

---

## 2. System Architecture Diagram

```mermaid
flowchart TB
    subgraph "Data Sources"
        A1[CPCB Ground Stations<br/>7 Pollutants]
        A2[MERRA-2 Meteorological<br/>8 Weather Parameters]
        A3[INSAT-3DR Satellite<br/>6 Aerosol Parameters]
    end

    subgraph "Data Ingestion Layer"
        B1[API Gateway]
        B2[Data Validators]
        B3[Quality Control]
    end

    subgraph "Data Processing"
        C1[Data Cleaning<br/>Unit Conversion]
        C2[Temporal Expansion<br/>503→84,504 records]
        C3[Feature Engineering<br/>23 Features]
        C4[StandardScaler<br/>Normalization]
    end

    subgraph "ML Pipeline"
        D1[(Integrated Dataset<br/>84,504 Records)]
        D2[Random Forest Model<br/>200 Trees, 8.3s Training]
        D3[Model Evaluation<br/>R²=0.9994]
        D4[(Trained Model<br/>327 MB)]
    end

    subgraph "Forecasting Engine"
        E1[Hyperlocal Forecaster<br/>1-72 Hour Horizon]
        E2[Rush Hour Detector<br/>Diurnal Patterns]
        E3[Confidence Calculator<br/>±4.57 AQI]
    end

    subgraph "Backend Services"
        F1[REST API<br/>FastAPI/Express]
        F2[Caching Layer<br/>Redis]
        F3[Database<br/>PostgreSQL/Supabase]
    end

    subgraph "Frontend Application"
        G1[Streamlit Dashboard]
        G2[Interactive Maps<br/>Folium]
        G3[Forecast Charts<br/>Plotly]
        G4[Mobile Interface<br/>Flutter]
    end

    subgraph "User Features"
        H1[Real-Time AQI]
        H2[72-Hour Forecast]
        H3[Health Advisories]
        H4[Custom Predictions]
        H5[Feature Importance]
    end

    A1 --> B1
    A2 --> B1
    A3 --> B1
    B1 --> B2
    B2 --> B3
    B3 --> C1
    C1 --> C2
    C2 --> C3
    C3 --> C4
    C4 --> D1
    D1 --> D2
    D2 --> D3
    D3 --> D4
    D4 --> E1
    E1 --> E2
    E2 --> E3
    E3 --> F1
    F1 --> F2
    F2 --> F3
    F3 --> G1
    G1 --> H1
    G1 --> H2
    G1 --> H3
    G1 --> H4
    G1 --> H5
    G2 --> G1
    G3 --> G1
    G4 --> F1

    style D2 fill:#90EE90
    style E1 fill:#FFD700
    style G1 fill:#87CEEB
    style H2 fill:#FFA500
```

---

## 3. Data Flow Diagram (DFD)

```mermaid
flowchart LR
    subgraph "External Sources"
        ES1[CPCB API]
        ES2[MERRA-2 Server]
        ES3[INSAT-3DR]
    end

    subgraph "Level 0 - Context"
        P1[Data Collection Process]
        P2[Data Processing Process]
        P3[Prediction Process]
        P4[Visualization Process]
    end

    subgraph "Data Stores"
        DS1[(Raw Data<br/>3,401 Records)]
        DS2[(Processed Data<br/>84,504 Records)]
        DS3[(Model Store<br/>RF + Scaler)]
        DS4[(Forecast Cache)]
    end

    subgraph "Users"
        U1[General Public]
        U2[Policymakers]
        U3[Researchers]
    end

    ES1 -->|Pollutant Data| P1
    ES2 -->|Weather Data| P1
    ES3 -->|Satellite Data| P1
    P1 -->|Store| DS1
    DS1 -->|Retrieve| P2
    P2 -->|Clean & Expand| DS2
    DS2 -->|Train| P3
    P3 -->|Save Model| DS3
    DS3 -->|Load Model| P3
    P3 -->|Predictions| DS4
    DS4 -->|Retrieve| P4
    P4 -->|Display| U1
    P4 -->|Analytics| U2
    P4 -->|Data Export| U3

    style P3 fill:#90EE90
    style DS3 fill:#FFD700
```

---

## 4. Class Diagram (UML)

```mermaid
classDiagram
    class AQIStation {
        +int stationId
        +string stationName
        +float latitude
        +float longitude
        +string city
        +string state
        +datetime lastUpdate
        +getCurrentAQI()
        +getHistoricalData()
        +updateReadings()
    }

    class PollutantReading {
        +int readingId
        +datetime timestamp
        +float pm25
        +float pm10
        +float no2
        +float so2
        +float co
        +float o3
        +float nh3
        +int aqi
        +calculateAQI()
        +getCategory()
        +validate()
    }

    class WeatherData {
        +int weatherId
        +float temperature
        +float humidity
        +float windSpeed
        +float boundaryLayerHeight
        +getDispersionFactor()
        +updateForecast()
    }

    class SatelliteData {
        +int satelliteId
        +float aod550
        +float aerosolIndex
        +float cloudFraction
        +processSatelliteImage()
        +correlateWithGround()
    }

    class RandomForestModel {
        +int nEstimators
        +int maxDepth
        +float r2Score
        +float rmse
        +train()
        +predict()
        +getFeatureImportance()
        +save()
        +load()
    }

    class TemporalExpander {
        +int baseRecords
        +int expandedRecords
        +int hoursPerStation
        +generateDiurnalPattern()
        +applySeasonalFactor()
        +injectRushHourPeaks()
        +expand()
    }

    class ForecastEngine {
        +int forecastHorizon
        +float confidenceInterval
        +generateHourlyForecast()
        +detectRushHours()
        +calculateUncertainty()
        +applyWeekendFactor()
    }

    class FeatureEngineer {
        +list features
        +int featureCount
        +extractCPCBFeatures()
        +extractMERRA2Features()
        +extractSatelliteFeatures()
        +normalize()
        +createFeatureVector()
    }

    class HealthAdvisor {
        +string aqiCategory
        +string userProfile
        +generateAdvice()
        +getSensitiveGroupWarning()
        +getActivityRecommendations()
    }

    class StreamlitDashboard {
        +string currentPage
        +dict selectedLocation
        +renderMap()
        +renderForecastChart()
        +renderFeatureImportance()
        +handleUserInput()
    }

    class User {
        +int userId
        +string username
        +string healthProfile
        +list locations
        +subscribe()
        +setAlerts()
        +viewForecast()
    }

    AQIStation "1" --> "*" PollutantReading : measures
    AQIStation "1" --> "*" WeatherData : hasWeather
    AQIStation "1" --> "*" SatelliteData : receivesSatellite
    PollutantReading --> FeatureEngineer : provides
    WeatherData --> FeatureEngineer : provides
    SatelliteData --> FeatureEngineer : provides
    FeatureEngineer --> TemporalExpander : feeds
    TemporalExpander --> RandomForestModel : trainsModel
    RandomForestModel --> ForecastEngine : usedBy
    ForecastEngine --> HealthAdvisor : triggersAdvisory
    ForecastEngine --> StreamlitDashboard : displays
    HealthAdvisor --> StreamlitDashboard : displays
    User --> StreamlitDashboard : interactsWith
    User "*" --> "*" AQIStation : monitors
```

---

## 5. Sequence Diagram - Forecast Generation

```mermaid
sequenceDiagram
    actor User
    participant UI as Streamlit UI
    participant API as Backend API
    participant Cache as Redis Cache
    participant Model as RF Model
    participant DB as Database
    participant FE as Forecast Engine

    User->>UI: Select Location & Forecast Hours (24/48/72)
    UI->>API: GET /forecast/{location}/{hours}
    API->>Cache: Check cached forecast
    
    alt Cache Hit
        Cache-->>API: Return cached data
        API-->>UI: Forecast data
    else Cache Miss
        API->>DB: Fetch station data
        DB-->>API: Station + Latest readings
        API->>Model: Load RF Model (327 MB)
        Model-->>API: Model ready
        
        loop For each forecast hour
            API->>FE: Generate feature vector (23 features)
            FE->>FE: Apply temporal patterns (rush hour, weekend)
            FE->>FE: Calculate meteorological evolution
            FE->>Model: Predict AQI
            Model-->>FE: Predicted AQI + Confidence
            FE->>FE: Apply uncertainty (±4.57 RMSE)
        end
        
        FE-->>API: Complete forecast array
        API->>Cache: Store forecast (TTL: 1 hour)
        API-->>UI: Forecast data with confidence bands
    end
    
    UI->>UI: Render Plotly chart
    UI->>UI: Display hourly breakdown table
    UI->>UI: Show forecast statistics
    UI-->>User: Interactive forecast visualization
    
    Note over User,FE: Entire process completes in <0.5 seconds
```

---

## 6. State Diagram - Model Training Lifecycle

```mermaid
stateDiagram-v2
    [*] --> DataCollection
    
    DataCollection --> DataValidation : Raw data received
    DataValidation --> DataCleaning : Validation passed
    DataValidation --> ErrorHandling : Validation failed
    ErrorHandling --> DataCollection : Retry
    
    DataCleaning --> TemporalExpansion : 3,401 records cleaned
    TemporalExpansion --> FeatureEngineering : 84,504 records generated
    
    FeatureEngineering --> ModelTraining : 23 features ready
    ModelTraining --> ModelEvaluation : Training complete (8.3s)
    
    ModelEvaluation --> ModelDeployed : R²≥0.999
    ModelEvaluation --> HyperparameterTuning : R²<0.999
    HyperparameterTuning --> ModelTraining : New params
    
    ModelDeployed --> Predicting : Model loaded
    Predicting --> Predicting : Continuous forecasting
    
    ModelDeployed --> ModelRetraining : New data available
    ModelRetraining --> ModelTraining : Update triggered
    
    Predicting --> MaintenanceMode : Performance degradation
    MaintenanceMode --> ModelRetraining : Scheduled retrain
    
    ModelDeployed --> [*] : Decommissioned
    
    note right of ModelTraining
        Random Forest: 200 trees
        Max Depth: 30
        12-core parallel processing
    end note
    
    note right of ModelDeployed
        Deployment metrics:
        - RMSE: 4.57 AQI
        - MAE: 2.33 AQI
        - Size: 327 MB
    end note
```

---

## 7. Use Case Diagram

```mermaid
graph TB
    subgraph "Vayu Drishti System"
        UC1((View Real-Time AQI))
        UC2((Get 72-Hour Forecast))
        UC3((View Interactive Map))
        UC4((Receive Health Advisory))
        UC5((Analyze Feature Importance))
        UC6((Compare Cities))
        UC7((Set Custom Alerts))
        UC8((Export Data))
        UC9((View Model Performance))
        UC10((Custom Prediction))
    end
    
    GP[General Public]
    SU[Sensitive Users<br/>Asthma, Elderly]
    PM[Policymakers]
    RS[Researchers]
    AD[Admin]
    
    GP --> UC1
    GP --> UC2
    GP --> UC3
    
    SU --> UC1
    SU --> UC2
    SU --> UC4
    SU --> UC7
    
    PM --> UC3
    PM --> UC6
    PM --> UC8
    PM --> UC9
    
    RS --> UC5
    RS --> UC8
    RS --> UC9
    RS --> UC10
    
    AD --> UC9
    
    UC2 -.includes.-> UC4
    UC3 -.extends.-> UC1
    UC6 -.includes.-> UC1
    UC10 -.uses.-> UC5

    style UC2 fill:#FFD700
    style UC4 fill:#FF6B6B
    style UC5 fill:#90EE90
```

---

## 8. Component Diagram

```mermaid
graph TB
    subgraph "Presentation Layer"
        C1[Streamlit Web App]
        C2[Flutter Mobile App]
        C3[REST API Client]
    end
    
    subgraph "Application Layer"
        C4[FastAPI Server]
        C5[Authentication Service]
        C6[Notification Service]
    end
    
    subgraph "Business Logic Layer"
        C7[Forecast Engine]
        C8[Data Processor]
        C9[Model Manager]
        C10[Health Advisory Generator]
    end
    
    subgraph "ML Layer"
        C11[Random Forest Model<br/>327 MB]
        C12[StandardScaler]
        C13[Feature Engineering Pipeline]
        C14[Temporal Expander]
    end
    
    subgraph "Data Layer"
        C15[PostgreSQL/Supabase]
        C16[Redis Cache]
        C17[File Storage<br/>Models & Logs]
    end
    
    subgraph "External Services"
        C18[CPCB API]
        C19[MERRA-2 Server]
        C20[INSAT-3DR]
    end
    
    C1 --> C4
    C2 --> C4
    C3 --> C4
    C4 --> C5
    C4 --> C6
    C4 --> C7
    C4 --> C8
    C7 --> C9
    C7 --> C10
    C9 --> C11
    C9 --> C12
    C8 --> C13
    C8 --> C14
    C13 --> C11
    C14 --> C11
    C7 --> C16
    C8 --> C15
    C9 --> C17
    C8 --> C18
    C8 --> C19
    C8 --> C20
    
    style C11 fill:#90EE90
    style C7 fill:#FFD700
    style C1 fill:#87CEEB
```

---

## 9. Deployment Diagram

```mermaid
graph TB
    subgraph "Client Devices"
        D1[Web Browser<br/>Chrome/Firefox/Safari]
        D2[Mobile Device<br/>Android/iOS]
        D3[Desktop Application]
    end
    
    subgraph "CDN Layer"
        D4[Cloudflare CDN]
    end
    
    subgraph "Load Balancer"
        D5[Nginx Load Balancer]
    end
    
    subgraph "Application Server Cluster"
        D6[Streamlit App Server 1]
        D7[Streamlit App Server 2]
        D8[FastAPI Server 1]
        D9[FastAPI Server 2]
    end
    
    subgraph "ML Inference Server"
        D10[Model Server<br/>Random Forest 327MB<br/>12-core CPU]
    end
    
    subgraph "Cache Layer"
        D11[Redis Cluster<br/>Forecast Cache]
    end
    
    subgraph "Database Cluster"
        D12[PostgreSQL Primary<br/>Historical Data]
        D13[PostgreSQL Replica<br/>Read-Only]
    end
    
    subgraph "Storage"
        D14[S3/Cloud Storage<br/>Models, Logs, Reports]
    end
    
    subgraph "Monitoring"
        D15[Prometheus + Grafana<br/>Performance Metrics]
    end
    
    subgraph "External APIs"
        D16[CPCB API Gateway]
        D17[MERRA-2 Data Server]
        D18[INSAT-3DR Satellite]
    end
    
    D1 --> D4
    D2 --> D4
    D3 --> D4
    D4 --> D5
    D5 --> D6
    D5 --> D7
    D5 --> D8
    D5 --> D9
    D6 --> D10
    D7 --> D10
    D8 --> D10
    D9 --> D10
    D8 --> D11
    D9 --> D11
    D8 --> D12
    D9 --> D12
    D12 --> D13
    D10 --> D14
    D6 --> D15
    D7 --> D15
    D8 --> D15
    D9 --> D15
    D8 --> D16
    D8 --> D17
    D8 --> D18
    
    style D10 fill:#90EE90
    style D11 fill:#FFD700
    style D12 fill:#87CEEB
```

---

## 10. Activity Diagram - User Forecasting Workflow

```mermaid
flowchart TD
    Start([User Opens App]) --> A1{Logged In?}
    A1 -->|No| A2[Show Login Screen]
    A2 --> A3[User Authenticates]
    A3 --> A4[Load User Preferences]
    A1 -->|Yes| A4
    
    A4 --> A5[Display Dashboard]
    A5 --> A6{Select Feature}
    
    A6 -->|Real-Time AQI| B1[Fetch Current Location]
    B1 --> B2[Query Latest AQI]
    B2 --> B3[Display AQI Card]
    B3 --> B4[Show Health Advisory]
    
    A6 -->|Forecast| C1[Select Location]
    C1 --> C2[Choose Forecast Horizon<br/>24/48/72 hours]
    C2 --> C3{Check Cache}
    C3 -->|Hit| C4[Retrieve Cached Forecast]
    C3 -->|Miss| C5[Load RF Model]
    C5 --> C6[Generate 23-Feature Vectors]
    C6 --> C7[Apply Temporal Patterns]
    C7 --> C8[Predict Each Hour]
    C8 --> C9[Calculate Confidence Bands]
    C9 --> C10[Cache Results]
    C10 --> C4
    C4 --> C11[Render Plotly Chart]
    C11 --> C12[Display Statistics Table]
    
    A6 -->|Map| D1[Load Interactive Map]
    D1 --> D2[Show 503 Stations]
    D2 --> D3[Color by AQI Category]
    D3 --> D4[User Clicks Station]
    D4 --> D5[Display Station Details]
    
    A6 -->|Feature Importance| E1[Load Model Metrics]
    E1 --> E2[Display Top 15 Features]
    E2 --> E3[Show Category Breakdown]
    
    B4 --> A6
    C12 --> A6
    D5 --> A6
    E3 --> A6
    
    A6 -->|Logout| End([Exit App])
    
    style C5 fill:#90EE90
    style C8 fill:#FFD700
    style C11 fill:#87CEEB
```

---

## 11. Network Diagram

```mermaid
graph LR
    subgraph "Internet"
        I1[End Users]
    end
    
    subgraph "DMZ - Public Zone"
        N1[Firewall]
        N2[Web Application Firewall]
        N3[SSL Termination]
    end
    
    subgraph "Application Zone - Private Subnet"
        N4[Streamlit App<br/>Port 8501]
        N5[FastAPI Backend<br/>Port 8000]
        N6[Redis Cache<br/>Port 6379]
    end
    
    subgraph "ML Zone - Restricted Subnet"
        N7[Model Server<br/>RF Inference]
        N8[Training Pipeline<br/>Batch Jobs]
        N9[Model Storage<br/>S3/NFS]
    end
    
    subgraph "Data Zone - Highly Restricted"
        N10[PostgreSQL Primary<br/>Port 5432]
        N11[PostgreSQL Replica]
        N12[Backup Server]
    end
    
    subgraph "External Zone - Egress Only"
        N13[CPCB API Client]
        N14[MERRA-2 Fetcher]
        N15[INSAT-3DR Receiver]
    end
    
    I1 -->|HTTPS 443| N1
    N1 --> N2
    N2 --> N3
    N3 -->|HTTP| N4
    N4 -->|REST| N5
    N5 -->|Query| N6
    N5 -->|Request| N7
    N7 -->|Load| N9
    N8 -->|Save| N9
    N5 -->|Read/Write| N10
    N10 -->|Replicate| N11
    N10 -->|Backup| N12
    N5 -->|Fetch| N13
    N5 -->|Fetch| N14
    N5 -->|Fetch| N15
    
    style N7 fill:#90EE90
    style N10 fill:#87CEEB
    style N4 fill:#FFD700
```

---

## 12. Data Pipeline Diagram

```mermaid
flowchart LR
    subgraph "Ingestion Stage"
        P1[CPCB Scraper<br/>7 Pollutants<br/>3,401 Records]
        P2[MERRA-2 Fetcher<br/>8 Weather Params<br/>100% Coverage]
        P3[INSAT-3DR Receiver<br/>6 Aerosol Params<br/>100% Coverage]
    end
    
    subgraph "Validation Stage"
        P4[Schema Validator]
        P5[Unit Converter<br/>NOx to μg/m³]
        P6[Outlier Detector<br/>Stuck Sensor Flagging]
    end
    
    subgraph "Processing Stage"
        P7[Data Merger<br/>Join by Station+Time]
        P8[Temporal Expander<br/>503 × 168 Hours<br/>= 84,504 Records]
        P9[Feature Engineer<br/>23 Features Total]
    end
    
    subgraph "Transformation Stage"
        P10[Diurnal Pattern Injector<br/>Rush Hour Peaks]
        P11[Seasonal Adjuster<br/>October 1.3× Factor]
        P12[StandardScaler<br/>Zero Mean, Unit Variance]
    end
    
    subgraph "Storage Stage"
        P13[(Raw Data Lake<br/>Parquet Format)]
        P14[(Processed Dataset<br/>CSV 41.69 MB)]
        P15[(Model Registry<br/>RF 327 MB + Scaler)]
    end
    
    subgraph "Training Stage"
        P16[Train/Validation/Test Split<br/>70% / 15% / 15%]
        P17[Random Forest Training<br/>200 Trees, 8.3 Seconds]
        P18[Model Evaluation<br/>R²=0.9994]
    end
    
    P1 --> P4
    P2 --> P4
    P3 --> P4
    P4 --> P5
    P5 --> P6
    P6 --> P13
    P13 --> P7
    P7 --> P8
    P8 --> P9
    P9 --> P10
    P10 --> P11
    P11 --> P12
    P12 --> P14
    P14 --> P16
    P16 --> P17
    P17 --> P18
    P18 --> P15
    
    style P8 fill:#FFD700
    style P17 fill:#90EE90
    style P14 fill:#87CEEB
```

---

## Key Metrics Summary

| Component | Metric | Value |
|-----------|--------|-------|
| **Data** | Original Records | 3,401 |
| **Data** | Expanded Records | 84,504 |
| **Data** | Total Stations | 503 |
| **Data** | Features | 23 |
| **Model** | Type | Random Forest |
| **Model** | Trees | 200 |
| **Model** | Training Time | 8.3 seconds |
| **Model** | Model Size | 327 MB |
| **Performance** | R² Score | 0.9994 |
| **Performance** | RMSE | 4.57 AQI |
| **Performance** | MAE | 2.33 AQI |
| **Forecast** | Horizon | 1-72 hours |
| **Forecast** | Accuracy (24hr) | 96.5% within ±10 |
| **Forecast** | Speed | <0.5s for 72hr |

---

## Diagram Usage Guide

1. **ER Diagram**: Database schema design and relationships
2. **System Architecture**: High-level component overview
3. **Data Flow Diagram**: Data movement through system
4. **Class Diagram**: Object-oriented structure
5. **Sequence Diagram**: Forecast generation process timing
6. **State Diagram**: Model lifecycle management
7. **Use Case Diagram**: User interactions and features
8. **Component Diagram**: Technical component dependencies
9. **Deployment Diagram**: Infrastructure and deployment
10. **Activity Diagram**: User workflow and decision points
11. **Network Diagram**: Network topology and security zones
12. **Data Pipeline Diagram**: End-to-end data processing

---

*Document Last Updated: October 30, 2025*  
*Vayu Drishti - Real-Time Air Quality Visualizer App*
