# Breeze Connect Configuration
import os
from typing import Optional

class BreezeConfig:
    """Configuration for Breeze Connect API"""
    
    # API Credentials (Should be set as environment variables in production)
    API_KEY: Optional[str] = os.getenv("BREEZE_API_KEY", "")
    API_SECRET: Optional[str] = os.getenv("BREEZE_API_SECRET", "")
    SESSION_TOKEN: Optional[str] = os.getenv("BREEZE_SESSION_TOKEN", "")
    
    # Demo mode for testing without actual API credentials
    DEMO_MODE: bool = os.getenv("BREEZE_DEMO_MODE", "true").lower() == "true"
    
    # Rate limiting settings
    RATE_LIMIT_CALLS_PER_MINUTE: int = 60
    RATE_LIMIT_CALLS_PER_SECOND: int = 2
    
    # Cache settings for stock data
    STOCK_QUOTE_CACHE_SECONDS: int = 10  # Cache stock quotes for 10 seconds
    HISTORICAL_DATA_CACHE_MINUTES: int = 60  # Cache historical data for 1 hour
    
    # Default Indian stock symbols for demo
    DEFAULT_STOCKS = [
        {"symbol": "RELIANCE", "exchange": "NSE", "name": "Reliance Industries Ltd."},
        {"symbol": "TCS", "exchange": "NSE", "name": "Tata Consultancy Services Ltd."},
        {"symbol": "HDFCBANK", "exchange": "NSE", "name": "HDFC Bank Ltd."},
        {"symbol": "INFY", "exchange": "NSE", "name": "Infosys Ltd."},
        {"symbol": "HINDUNILVR", "exchange": "NSE", "name": "Hindustan Unilever Ltd."},
        {"symbol": "ICICIBANK", "exchange": "NSE", "name": "ICICI Bank Ltd."},
        {"symbol": "KOTAKBANK", "exchange": "NSE", "name": "Kotak Mahindra Bank Ltd."},
        {"symbol": "BHARTIARTL", "exchange": "NSE", "name": "Bharti Airtel Ltd."},
        {"symbol": "ITC", "exchange": "NSE", "name": "ITC Ltd."},
        {"symbol": "SBIN", "exchange": "NSE", "name": "State Bank of India"},
        {"symbol": "BAJFINANCE", "exchange": "NSE", "name": "Bajaj Finance Ltd."},
        {"symbol": "ASIANPAINT", "exchange": "NSE", "name": "Asian Paints Ltd."},
        {"symbol": "MARUTI", "exchange": "NSE", "name": "Maruti Suzuki India Ltd."},
        {"symbol": "TITAN", "exchange": "NSE", "name": "Titan Company Ltd."},
        {"symbol": "WIPRO", "exchange": "NSE", "name": "Wipro Ltd."},
    ]
    
    # Mock price ranges for demo mode (in INR)
    MOCK_PRICE_RANGES = {
        "RELIANCE": {"base": 2500, "range": 100},
        "TCS": {"base": 3800, "range": 150},
        "HDFCBANK": {"base": 1650, "range": 80},
        "INFY": {"base": 1500, "range": 75},
        "HINDUNILVR": {"base": 2400, "range": 120},
        "ICICIBANK": {"base": 950, "range": 50},
        "KOTAKBANK": {"base": 1800, "range": 90},
        "BHARTIARTL": {"base": 850, "range": 40},
        "ITC": {"base": 450, "range": 25},
        "SBIN": {"base": 650, "range": 30},
        "BAJFINANCE": {"base": 7500, "range": 300},
        "ASIANPAINT": {"base": 3200, "range": 160},
        "MARUTI": {"base": 11000, "range": 500},
        "TITAN": {"base": 3000, "range": 150},
        "WIPRO": {"base": 450, "range": 25},
        # International stocks (converted to INR for simulation)
        "AAPL": {"base": 15000, "range": 500},
        "GOOGL": {"base": 145000, "range": 5000},
        "MSFT": {"base": 34000, "range": 1200},
        "TSLA": {"base": 21000, "range": 1000},
        "AMZN": {"base": 15500, "range": 800},
        "META": {"base": 50000, "range": 2000},
        "NVDA": {"base": 13000, "range": 600},
    }
    
    @classmethod
    def is_configured(cls) -> bool:
        """Check if Breeze API is properly configured with credentials"""
        return (
            bool(cls.API_KEY) and 
            bool(cls.API_SECRET) and 
            bool(cls.SESSION_TOKEN) and 
            not cls.DEMO_MODE
        )
    
    @classmethod
    def get_login_url(cls) -> str:
        """Generate Breeze API login URL for session token"""
        if cls.API_KEY:
            import urllib.parse
            encoded_key = urllib.parse.quote_plus(cls.API_KEY)
            return f"https://api.icicidirect.com/apiuser/login?api_key={encoded_key}"
        return ""
