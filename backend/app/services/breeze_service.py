import asyncio
import time
import random
import logging
from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
from dataclasses import dataclass, asdict
from app.config.breeze_config import BreezeConfig

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@dataclass
class StockQuote:
    """Stock quote data structure"""
    symbol: str
    name: str
    price: float
    change: float
    change_percent: float
    high: float
    low: float
    volume: int
    timestamp: datetime
    exchange: str = "NSE"

@dataclass
class HistoricalData:
    """Historical data point"""
    datetime: datetime
    open: float
    high: float
    low: float
    close: float
    volume: int

@dataclass
class SearchResult:
    """Stock search result"""
    symbol: str
    name: str
    exchange: str
    type: str
    currency: str

class BreezeConnectService:
    """Enhanced Breeze Connect service with demo mode fallback"""
    
    def __init__(self):
        self.breeze_client = None
        self.is_connected = False
        self.cache = {}
        self.last_request_time = 0
        self.demo_mode = BreezeConfig.DEMO_MODE
        
        # Initialize Breeze client if configured
        if not self.demo_mode and BreezeConfig.is_configured():
            self._initialize_breeze_client()
        else:
            logger.info("Running in demo mode - using mock data")
    
    def _initialize_breeze_client(self):
        """Initialize the Breeze Connect client"""
        try:
            from breeze_connect import BreezeConnect
            
            self.breeze_client = BreezeConnect(api_key=BreezeConfig.API_KEY)
            
            # Generate session
            self.breeze_client.generate_session(
                api_secret=BreezeConfig.API_SECRET,
                session_token=BreezeConfig.SESSION_TOKEN
            )
            
            self.is_connected = True
            logger.info("Breeze Connect client initialized successfully")
            
        except Exception as e:
            logger.error(f"Failed to initialize Breeze client: {e}")
            logger.info("Falling back to demo mode")
            self.demo_mode = True
            self.is_connected = False
    
    def _rate_limit(self):
        """Simple rate limiting"""
        current_time = time.time()
        time_diff = current_time - self.last_request_time
        min_interval = 1.0 / BreezeConfig.RATE_LIMIT_CALLS_PER_SECOND
        
        if time_diff < min_interval:
            sleep_time = min_interval - time_diff
            time.sleep(sleep_time)
        
        self.last_request_time = time.time()
    
    def _get_cache_key(self, operation: str, **kwargs) -> str:
        """Generate cache key for operations"""
        key_parts = [operation]
        key_parts.extend([f"{k}={v}" for k, v in sorted(kwargs.items())])
        return ":".join(key_parts)
    
    def _is_cache_valid(self, cache_key: str, ttl_seconds: int) -> bool:
        """Check if cached data is still valid"""
        if cache_key not in self.cache:
            return False
        
        cached_time = self.cache[cache_key].get("timestamp", 0)
        return time.time() - cached_time < ttl_seconds
    
    def _generate_mock_quote(self, symbol: str, name: str = None) -> StockQuote:
        """Generate realistic mock stock quote"""
        # Get base price and range from config
        price_config = BreezeConfig.MOCK_PRICE_RANGES.get(
            symbol, 
            {"base": 1000, "range": 50}
        )
        
        base_price = price_config["base"]
        price_range = price_config["range"]
        
        # Generate realistic price with some volatility
        volatility = random.uniform(-0.05, 0.05)  # ±5% volatility
        current_price = base_price * (1 + volatility)
        
        # Generate daily change
        daily_change = random.uniform(-price_range * 0.1, price_range * 0.1)
        change_percent = (daily_change / current_price) * 100
        
        # Generate high/low for the day
        high = current_price + random.uniform(0, price_range * 0.05)
        low = current_price - random.uniform(0, price_range * 0.05)
        
        # Generate volume
        volume = random.randint(100000, 5000000)
        
        return StockQuote(
            symbol=symbol,
            name=name or f"{symbol} Corporation",
            price=round(current_price, 2),
            change=round(daily_change, 2),
            change_percent=round(change_percent, 2),
            high=round(high, 2),
            low=round(low, 2),
            volume=volume,
            timestamp=datetime.now(),
            exchange="NSE"
        )
    
    async def get_stock_quote(self, symbol: str, exchange: str = "NSE") -> Optional[StockQuote]:
        """Get real-time stock quote"""
        cache_key = self._get_cache_key("quote", symbol=symbol, exchange=exchange)
        
        # Check cache first
        if self._is_cache_valid(cache_key, BreezeConfig.STOCK_QUOTE_CACHE_SECONDS):
            return StockQuote(**self.cache[cache_key]["data"])
        
        try:
            if self.demo_mode or not self.is_connected:
                # Generate mock data
                stock_info = next(
                    (s for s in BreezeConfig.DEFAULT_STOCKS if s["symbol"] == symbol),
                    None
                )
                name = stock_info["name"] if stock_info else None
                quote = self._generate_mock_quote(symbol, name)
            else:
                # Use real Breeze API
                self._rate_limit()
                
                response = self.breeze_client.get_quotes(
                    stock_code=symbol,
                    exchange_code=exchange,
                    product_type="cash"
                )
                
                if response and response.get("Success"):
                    data = response["Success"][0]
                    quote = StockQuote(
                        symbol=symbol,
                        name=data.get("long_name", symbol),
                        price=float(data.get("ltp", 0)),
                        change=float(data.get("change", 0)),
                        change_percent=float(data.get("change_percentage", 0)),
                        high=float(data.get("high", 0)),
                        low=float(data.get("low", 0)),
                        volume=int(data.get("volume", 0)),
                        timestamp=datetime.now(),
                        exchange=exchange
                    )
                else:
                    # Fallback to mock data if API fails
                    quote = self._generate_mock_quote(symbol)
            
            # Cache the result
            self.cache[cache_key] = {
                "data": asdict(quote),
                "timestamp": time.time()
            }
            
            return quote
            
        except Exception as e:
            logger.error(f"Error fetching quote for {symbol}: {e}")
            # Return mock data as fallback
            return self._generate_mock_quote(symbol)
    
    async def get_multiple_quotes(self, symbols: List[str], exchange: str = "NSE") -> Dict[str, StockQuote]:
        """Get quotes for multiple symbols"""
        quotes = {}
        
        # Process in batches to respect rate limits
        for symbol in symbols:
            quote = await self.get_stock_quote(symbol, exchange)
            if quote:
                quotes[symbol] = quote
                
        return quotes
    
    async def search_stocks(self, query: str) -> List[SearchResult]:
        """Search for stocks"""
        try:
            if self.demo_mode or not self.is_connected:
                # Mock search results
                results = []
                query_lower = query.lower()
                
                for stock in BreezeConfig.DEFAULT_STOCKS:
                    if (query_lower in stock["symbol"].lower() or 
                        query_lower in stock["name"].lower()):
                        results.append(SearchResult(
                            symbol=stock["symbol"],
                            name=stock["name"],
                            exchange=stock["exchange"],
                            type="Equity",
                            currency="INR"
                        ))
                
                # Add some international stocks for broader search
                international_stocks = [
                    {"symbol": "AAPL", "name": "Apple Inc.", "exchange": "NASDAQ"},
                    {"symbol": "GOOGL", "name": "Alphabet Inc.", "exchange": "NASDAQ"},
                    {"symbol": "MSFT", "name": "Microsoft Corporation", "exchange": "NASDAQ"},
                    {"symbol": "TSLA", "name": "Tesla Inc.", "exchange": "NASDAQ"},
                    {"symbol": "AMZN", "name": "Amazon.com Inc.", "exchange": "NASDAQ"},
                ]
                
                for stock in international_stocks:
                    if (query_lower in stock["symbol"].lower() or 
                        query_lower in stock["name"].lower()):
                        results.append(SearchResult(
                            symbol=stock["symbol"],
                            name=stock["name"],
                            exchange=stock["exchange"],
                            type="Equity",
                            currency="USD"
                        ))
                
                return results[:10]  # Limit results
            else:
                # Use real Breeze API search
                self._rate_limit()
                
                response = self.breeze_client.get_names(
                    exchange_code="NSE",
                    stock_code=query.upper()
                )
                
                results = []
                if response and response.get("Success"):
                    for item in response["Success"]:
                        results.append(SearchResult(
                            symbol=item.get("stock_code", ""),
                            name=item.get("long_name", ""),
                            exchange=item.get("exchange_code", "NSE"),
                            type="Equity",
                            currency="INR"
                        ))
                
                return results
                
        except Exception as e:
            logger.error(f"Error searching stocks for '{query}': {e}")
            return []
    
    async def get_historical_data(
        self, 
        symbol: str, 
        interval: str = "1day",
        from_date: datetime = None,
        to_date: datetime = None,
        exchange: str = "NSE"
    ) -> List[HistoricalData]:
        """Get historical stock data"""
        if from_date is None:
            from_date = datetime.now() - timedelta(days=30)
        if to_date is None:
            to_date = datetime.now()
        
        cache_key = self._get_cache_key(
            "historical",
            symbol=symbol,
            interval=interval,
            from_date=from_date.date(),
            to_date=to_date.date()
        )
        
        # Check cache
        if self._is_cache_valid(cache_key, BreezeConfig.HISTORICAL_DATA_CACHE_MINUTES * 60):
            cached_data = self.cache[cache_key]["data"]
            return [HistoricalData(**item) for item in cached_data]
        
        try:
            if self.demo_mode or not self.is_connected:
                # Generate mock historical data
                historical_data = []
                current_date = from_date
                base_price = BreezeConfig.MOCK_PRICE_RANGES.get(
                    symbol, {"base": 1000, "range": 50}
                )["base"]
                
                while current_date <= to_date:
                    # Generate OHLC data with some trend and volatility
                    open_price = base_price + random.uniform(-50, 50)
                    close_price = open_price + random.uniform(-20, 20)
                    high_price = max(open_price, close_price) + random.uniform(0, 10)
                    low_price = min(open_price, close_price) - random.uniform(0, 10)
                    volume = random.randint(100000, 1000000)
                    
                    historical_data.append(HistoricalData(
                        datetime=current_date,
                        open=round(open_price, 2),
                        high=round(high_price, 2),
                        low=round(low_price, 2),
                        close=round(close_price, 2),
                        volume=volume
                    ))
                    
                    current_date += timedelta(days=1)
                    base_price = close_price  # Use previous close as next base
                
            else:
                # Use real Breeze API
                self._rate_limit()
                
                from_date_str = from_date.strftime("%Y-%m-%dT%H:%M:%S.000Z")
                to_date_str = to_date.strftime("%Y-%m-%dT%H:%M:%S.000Z")
                
                response = self.breeze_client.get_historical_data_v2(
                    interval=interval,
                    from_date=from_date_str,
                    to_date=to_date_str,
                    stock_code=symbol,
                    exchange_code=exchange,
                    product_type="cash"
                )
                
                historical_data = []
                if response and response.get("Success"):
                    for item in response["Success"]:
                        historical_data.append(HistoricalData(
                            datetime=datetime.fromisoformat(item["datetime"].replace("Z", "+00:00")),
                            open=float(item["open"]),
                            high=float(item["high"]),
                            low=float(item["low"]),
                            close=float(item["close"]),
                            volume=int(item["volume"])
                        ))
            
            # Cache the result
            self.cache[cache_key] = {
                "data": [asdict(item) for item in historical_data],
                "timestamp": time.time()
            }
            
            return historical_data
            
        except Exception as e:
            logger.error(f"Error fetching historical data for {symbol}: {e}")
            return []
    
    def get_popular_stocks(self) -> List[Dict[str, Any]]:
        """Get list of popular stocks for trading"""
        return [
            {
                "symbol": stock["symbol"],
                "name": stock["name"],
                "exchange": stock["exchange"],
                "sector": self._get_sector(stock["symbol"]),
                "market_cap": self._get_market_cap(stock["symbol"])
            }
            for stock in BreezeConfig.DEFAULT_STOCKS[:10]
        ]
    
    def _get_sector(self, symbol: str) -> str:
        """Get sector for a stock (mock implementation)"""
        sector_map = {
            "RELIANCE": "Energy",
            "TCS": "Technology",
            "HDFCBANK": "Banking",
            "INFY": "Technology",
            "HINDUNILVR": "Consumer Goods",
            "ICICIBANK": "Banking",
            "KOTAKBANK": "Banking",
            "BHARTIARTL": "Telecommunications",
            "ITC": "Consumer Goods",
            "SBIN": "Banking",
            "BAJFINANCE": "Financial Services",
            "ASIANPAINT": "Consumer Discretionary",
            "MARUTI": "Automotive",
            "TITAN": "Consumer Discretionary",
            "WIPRO": "Technology",
        }
        return sector_map.get(symbol, "Unknown")
    
    def _get_market_cap(self, symbol: str) -> str:
        """Get market cap category for a stock"""
        large_cap = ["RELIANCE", "TCS", "HDFCBANK", "INFY", "HINDUNILVR"]
        if symbol in large_cap:
            return "Large Cap"
        else:
            return "Mid Cap"
    
    async def get_portfolio_performance(self, holdings: Dict[str, float]) -> Dict[str, Any]:
        """Calculate portfolio performance"""
        if not holdings:
            return {
                "total_value": 0,
                "total_gain_loss": 0,
                "total_gain_loss_percent": 0,
                "holdings_performance": []
            }
        
        holdings_performance = []
        total_current_value = 0
        
        for symbol, quantity in holdings.items():
            quote = await self.get_stock_quote(symbol)
            if quote:
                current_value = quote.price * quantity
                total_current_value += current_value
                
                holdings_performance.append({
                    "symbol": symbol,
                    "name": quote.name,
                    "quantity": quantity,
                    "current_price": quote.price,
                    "current_value": current_value,
                    "change": quote.change,
                    "change_percent": quote.change_percent
                })
        
        return {
            "total_value": total_current_value,
            "holdings_performance": holdings_performance
        }

# Global service instance
breeze_service = BreezeConnectService()
