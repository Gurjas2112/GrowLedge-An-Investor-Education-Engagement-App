from fastapi import APIRouter, HTTPException, Depends
from typing import List, Dict, Any
from bson import ObjectId
from datetime import datetime, timedelta
from ..models import TradeRequest, Trade, Portfolio, User
from ..auth import get_current_user
from ..database import get_database
from ..services.breeze_service import breeze_service
import uuid

router = APIRouter()

@router.post("/place_trade")
async def place_trade(
    trade: TradeRequest,
    current_user: User = Depends(get_current_user)
):
    """Place a virtual trade"""
    try:
        db = get_database()
        
        # Get user's portfolio
        portfolio_doc = await db.portfolios.find_one({"user_id": current_user.uid})
        
        if not portfolio_doc:
            # Create initial portfolio with ₹5,00,000 starting cash
            portfolio_data = {
                "user_id": current_user.uid,
                "holdings": {},
                "cash_balance": 500000.0,
                "created_at": datetime.utcnow(),
                "updated_at": datetime.utcnow()
            }
            await db.portfolios.insert_one(portfolio_data)
            portfolio_doc = portfolio_data
        
        # Calculate trade value
        trade_value = trade.qty * trade.price
        
        # Validate trade
        if trade.side == "BUY":
            if portfolio_doc["cash_balance"] < trade_value:
                raise HTTPException(status_code=400, detail="Insufficient funds")
        elif trade.side == "SELL":
            current_holdings = portfolio_doc["holdings"].get(trade.symbol, 0)
            if current_holdings < trade.qty:
                raise HTTPException(status_code=400, detail="Insufficient shares to sell")
        
        # Execute trade
        new_cash_balance = portfolio_doc["cash_balance"]
        new_holdings = portfolio_doc["holdings"].copy()
        
        if trade.side == "BUY":
            # Deduct cash and add shares
            new_cash_balance -= trade_value
            new_holdings[trade.symbol] = new_holdings.get(trade.symbol, 0) + trade.qty
        elif trade.side == "SELL":
            # Add cash and remove shares
            new_cash_balance += trade_value
            new_holdings[trade.symbol] -= trade.qty
            if new_holdings[trade.symbol] == 0:
                del new_holdings[trade.symbol]
        
        # Update portfolio
        await db.portfolios.update_one(
            {"user_id": current_user.uid},
            {
                "$set": {
                    "cash_balance": new_cash_balance,
                    "holdings": new_holdings,
                    "updated_at": datetime.utcnow()
                }
            }
        )
        
        # Record trade
        trade_doc = {
            "id": str(uuid.uuid4()),
            "user_id": current_user.uid,
            "symbol": trade.symbol,
            "side": trade.side,
            "qty": trade.qty,
            "price": trade.price,
            "timestamp": datetime.utcnow()
        }
        
        result = await db.trades.insert_one(trade_doc)
        
        return {
            "trade_id": str(result.inserted_id),
            "message": f"Trade executed: {trade.side} {trade.qty} {trade.symbol} at ₹{trade.price}",
            "remaining_cash": new_cash_balance
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/portfolio", response_model=Portfolio)
async def get_portfolio(current_user: User = Depends(get_current_user)):
    """Get user's portfolio"""
    try:
        db = get_database()
        
        portfolio_doc = await db.portfolios.find_one({"user_id": current_user.uid})
        
        if not portfolio_doc:
            # Create initial portfolio
            portfolio_data = {
                "user_id": current_user.uid,
                "holdings": {},
                "cash_balance": 500000.0,
                "created_at": datetime.utcnow(),
                "updated_at": datetime.utcnow()
            }
            result = await db.portfolios.insert_one(portfolio_data)
            portfolio_data["id"] = str(result.inserted_id)
            return Portfolio(**portfolio_data)
        
        portfolio_data = {
            "id": str(portfolio_doc["_id"]),
            "user_id": portfolio_doc["user_id"],
            "cash_balance": portfolio_doc["cash_balance"],
            "holdings": portfolio_doc["holdings"],
            "created_at": portfolio_doc.get("created_at", datetime.utcnow()),
            "updated_at": portfolio_doc.get("updated_at", datetime.utcnow())
        }
        
        return Portfolio(**portfolio_data)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/trades", response_model=List[Trade])
async def get_user_trades(current_user: User = Depends(get_current_user)):
    """Get user's trade history"""
    try:
        db = get_database()
        
        cursor = db.trades.find({"user_id": current_user.uid}).sort("timestamp", -1)
        trades = []
        
        async for doc in cursor:
            trade_data = {
                "id": str(doc.get("_id", doc.get("id", ""))),
                "user_id": doc["user_id"],
                "symbol": doc["symbol"],
                "side": doc["side"],
                "qty": doc["qty"],
                "price": doc["price"],
                "timestamp": doc["timestamp"]
            }
            trades.append(Trade(**trade_data))
        
        return trades
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/stock/{symbol}")
async def get_stock_quote(symbol: str, exchange: str = "NSE"):
    """Get real-time stock quote using Breeze Connect API"""
    try:
        quote = await breeze_service.get_stock_quote(symbol, exchange)
        
        if not quote:
            raise HTTPException(status_code=404, detail=f"Stock {symbol} not found")
        
        return {
            "symbol": quote.symbol,
            "name": quote.name,
            "price": quote.price,
            "change": quote.change,
            "change_percent": f"{quote.change_percent:.2f}%",
            "high": quote.high,
            "low": quote.low,
            "volume": quote.volume,
            "exchange": quote.exchange,
            "timestamp": quote.timestamp.isoformat(),
            "currency": "INR" if exchange == "NSE" else "USD"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching stock data: {str(e)}")

@router.get("/stocks/multiple")
async def get_multiple_quotes(symbols: str, exchange: str = "NSE"):
    """Get quotes for multiple stocks (comma-separated symbols)"""
    try:
        symbol_list = [s.strip().upper() for s in symbols.split(",") if s.strip()]
        
        if not symbol_list:
            raise HTTPException(status_code=400, detail="No symbols provided")
        
        quotes = await breeze_service.get_multiple_quotes(symbol_list, exchange)
        
        result = {}
        for symbol, quote in quotes.items():
            result[symbol] = {
                "symbol": quote.symbol,
                "name": quote.name,
                "price": quote.price,
                "change": quote.change,
                "change_percent": f"{quote.change_percent:.2f}%",
                "high": quote.high,
                "low": quote.low,
                "volume": quote.volume,
                "exchange": quote.exchange,
                "timestamp": quote.timestamp.isoformat()
            }
        
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/stocks/popular")
async def get_popular_stocks():
    """Get list of popular stocks for trading"""
    try:
        popular_stocks = breeze_service.get_popular_stocks()
        
        # Get current quotes for popular stocks
        quotes = {}
        for stock in popular_stocks:
            quote = await breeze_service.get_stock_quote(stock["symbol"])
            if quote:
                quotes[stock["symbol"]] = {
                    "symbol": quote.symbol,
                    "name": quote.name,
                    "price": quote.price,
                    "change": quote.change,
                    "change_percent": f"{quote.change_percent:.2f}%",
                    "sector": stock["sector"],
                    "market_cap": stock["market_cap"],
                    "exchange": quote.exchange
                }
        
        return quotes
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/stocks/historical/{symbol}")
async def get_historical_data(
    symbol: str,
    interval: str = "1day",
    days: int = 30,
    exchange: str = "NSE"
):
    """Get historical stock data"""
    try:
        if interval not in ["1day", "1minute", "5minute", "30minute"]:
            raise HTTPException(
                status_code=400, 
                detail="Invalid interval. Use: 1day, 1minute, 5minute, or 30minute"
            )
        
        if days > 365:
            raise HTTPException(status_code=400, detail="Maximum 365 days of history allowed")
        
        to_date = datetime.now()
        from_date = to_date - timedelta(days=days)
        
        historical_data = await breeze_service.get_historical_data(
            symbol=symbol,
            interval=interval,
            from_date=from_date,
            to_date=to_date,
            exchange=exchange
        )
        
        return {
            "symbol": symbol,
            "interval": interval,
            "from_date": from_date.isoformat(),
            "to_date": to_date.isoformat(),
            "data": [
                {
                    "datetime": item.datetime.isoformat(),
                    "open": item.open,
                    "high": item.high,
                    "low": item.low,
                    "close": item.close,
                    "volume": item.volume
                }
                for item in historical_data
            ]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/search/{keywords}")
async def search_stocks(keywords: str):
    """Search for stocks using Breeze Connect API"""
    try:
        if len(keywords.strip()) < 2:
            raise HTTPException(status_code=400, detail="Search query must be at least 2 characters")
        
        search_results = await breeze_service.search_stocks(keywords)
        
        # Format results for frontend
        formatted_results = []
        for result in search_results:
            formatted_results.append({
                "symbol": result.symbol,
                "name": result.name,
                "type": result.type,
                "exchange": result.exchange,
                "currency": result.currency,
                "region": "India" if result.exchange == "NSE" else "International"
            })
        
        return formatted_results
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/portfolio/performance")
async def get_portfolio_performance(current_user: User = Depends(get_current_user)):
    """Get detailed portfolio performance analysis"""
    try:
        db = get_database()
        portfolio_doc = await db.portfolios.find_one({"user_id": current_user.uid})
        
        if not portfolio_doc:
            return {
                "total_value": 500000.0,  # Initial amount
                "cash_balance": 500000.0,
                "total_invested": 0.0,
                "total_gain_loss": 0.0,
                "total_gain_loss_percent": 0.0,
                "holdings_performance": [],
                "portfolio_distribution": []
            }
        
        holdings = portfolio_doc.get("holdings", {})
        cash_balance = portfolio_doc.get("cash_balance", 0.0)
        
        # Get performance data from Breeze service
        performance = await breeze_service.get_portfolio_performance(holdings)
        
        total_invested_value = performance["total_value"]
        total_portfolio_value = total_invested_value + cash_balance
        
        # Calculate portfolio distribution
        portfolio_distribution = []
        if total_portfolio_value > 0:
            # Cash percentage
            cash_percent = (cash_balance / total_portfolio_value) * 100
            portfolio_distribution.append({
                "name": "Cash",
                "value": cash_balance,
                "percentage": round(cash_percent, 2)
            })
            
            # Stock holdings
            for holding in performance["holdings_performance"]:
                value_percent = (holding["current_value"] / total_portfolio_value) * 100
                portfolio_distribution.append({
                    "name": holding["symbol"],
                    "value": holding["current_value"],
                    "percentage": round(value_percent, 2)
                })
        
        return {
            "total_value": round(total_portfolio_value, 2),
            "cash_balance": round(cash_balance, 2),
            "total_invested": round(total_invested_value, 2),
            "holdings_performance": performance["holdings_performance"],
            "portfolio_distribution": portfolio_distribution,
            "last_updated": datetime.now().isoformat()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/market/status")
async def get_market_status():
    """Get current market status and trading hours"""
    try:
        now = datetime.now()
        
        # NSE trading hours: 9:15 AM to 3:30 PM IST (Monday to Friday)
        # For demo purposes, we'll show market as open during these hours
        weekday = now.weekday()  # 0 = Monday, 6 = Sunday
        hour = now.hour
        minute = now.minute
        
        is_market_open = (
            weekday < 5 and  # Monday to Friday
            ((hour == 9 and minute >= 15) or (10 <= hour <= 14) or (hour == 15 and minute <= 30))
        )
        
        market_status = "OPEN" if is_market_open else "CLOSED"
        
        # Next market session
        if is_market_open:
            next_session = "Market closes at 3:30 PM IST"
        else:
            if weekday < 5:  # Same day or next weekday
                if hour < 9 or (hour == 9 and minute < 15):
                    next_session = "Market opens at 9:15 AM IST"
                else:
                    next_session = "Market opens tomorrow at 9:15 AM IST"
            else:  # Weekend
                days_until_monday = (7 - weekday) % 7
                if days_until_monday == 0:
                    days_until_monday = 1
                next_session = f"Market opens on Monday at 9:15 AM IST"
        
        return {
            "status": market_status,
            "is_open": is_market_open,
            "current_time": now.isoformat(),
            "timezone": "IST",
            "next_session": next_session,
            "trading_hours": "9:15 AM - 3:30 PM IST (Monday to Friday)"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
