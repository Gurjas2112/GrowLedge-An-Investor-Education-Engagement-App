import os
from dotenv import load_dotenv

load_dotenv()

class Settings:
    # MongoDB Configuration
    MONGODB_URL: str = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
    MONGODB_DATABASE: str = os.getenv("MONGODB_DATABASE", "growledgedb")
    
    # JWT Configuration
    JWT_SECRET_KEY: str = os.getenv("JWT_SECRET_KEY", "ce9234ace33230edfcfe4853eb2c701d91708d5be56e01190bfc233cea388142")
    JWT_ALGORITHM: str = os.getenv("JWT_ALGORITHM", "HS256")
    JWT_EXPIRATION_HOURS: int = int(os.getenv("JWT_EXPIRATION_HOURS", "24"))
    
    # Alpha Vantage API
    ALPHA_VANTAGE_API_KEY = os.getenv("ALPHA_VANTAGE_API_KEY", "UZM1C6A1HIOG9G0L")
    ALPHA_VANTAGE_BASE_URL = "https://www.alphavantage.co/query"
    
    # Hugging Face API
    HUGGING_FACE_API_KEY = os.getenv("HUGGING_FACE_API_KEY", "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")
    HUGGING_FACE_BASE_URL = "https://api-inference.huggingface.co/models"
    
    # CORS
    CORS_ORIGINS: list = [
        "http://localhost:3000",
        "http://localhost:8080", 
        "http://localhost:8000",
        "http://127.0.0.1:8000",
        "http://10.0.2.2:8000",
        "http://localhost:*",  # Allow any port on localhost
        "http://127.0.0.1:*",  # Allow any port on 127.0.0.1
        "*"  # Allow all origins for development
    ]
    
    # Other settings
    DEBUG = os.getenv("DEBUG", "True").lower() == "true"
    SECRET_KEY = os.getenv("SECRET_KEY", "ce9234ace33230edfcfe4853eb2c701d91708d5be56e01190bfc233cea388142")

settings = Settings()
