"""
Database initialization script for GrowLedge MongoDB
This script creates the database collections and inserts sample data
"""

from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime
import asyncio
import logging
from .config import settings

logger = logging.getLogger(__name__)

async def initialize_database():
    """Initialize the database with collections and sample data"""
    
    # Connect to MongoDB
    client = AsyncIOMotorClient(settings.MONGODB_URL)
    db = client[settings.MONGODB_DATABASE]
    
    try:
        # Test connection
        await client.admin.command('ping')
        logger.info("Connected to MongoDB successfully")
        
        # Create collections (this creates them if they don't exist)
        collections_to_create = [
            "users", "lessons", "quizzes", "trades", 
            "portfolios", "progress", "tutorials"
        ]
        
        for collection_name in collections_to_create:
            # MongoDB creates collections automatically when first document is inserted
            # But we can explicitly create them for better structure
            collection_names = await db.list_collection_names()
            if collection_name not in collection_names:
                await db.create_collection(collection_name)
                logger.info(f"Created collection: {collection_name}")
        
        # Insert sample data
        await insert_sample_data(db)
        
        # Create indexes
        await create_indexes(db)
        
        logger.info("Database initialization completed successfully")
        
    except Exception as e:
        logger.error(f"Database initialization failed: {e}")
        raise e
    finally:
        client.close()

async def insert_sample_data(db):
    """Insert sample data into collections"""
    
    # Sample Users
    users_data = [
        {
            "uid": "u1",
            "name": "Test User",
            "email": "test@example.com",
            "preferred_language": "English",
            "created_at": datetime.utcnow(),
            "badges": ["Beginner"]
        },
        {
            "uid": "u2", 
            "name": "राहुल शर्मा",
            "email": "rahul@example.com",
            "preferred_language": "Hindi",
            "created_at": datetime.utcnow(),
            "badges": ["Beginner", "Active Learner"]
        }
    ]
    
    # Check if users already exist
    existing_users = await db.users.count_documents({})
    if existing_users == 0:
        await db.users.insert_many(users_data)
        logger.info("Inserted sample users")
    
    # Sample Lessons
    lessons_data = [
        {
            "id": "l1",
            "title": "Stock Market Basics",
            "content": "Introduction to stock markets and how they work...",
            "lang": "English",
            "difficulty": "Beginner"
        },
        {
            "id": "l2",
            "title": "शेयर बाजार की मूल बातें",
            "content": "शेयर बाजार का परिचय और यह कैसे काम करता है...",
            "lang": "Hindi", 
            "difficulty": "Beginner"
        },
        {
            "id": "l3",
            "title": "Mutual Funds Explained",
            "content": "Understanding mutual funds, types, and benefits...",
            "lang": "English",
            "difficulty": "Intermediate"
        }
    ]
    
    existing_lessons = await db.lessons.count_documents({})
    if existing_lessons == 0:
        await db.lessons.insert_many(lessons_data)
        logger.info("Inserted sample lessons")
    
    # Sample Quizzes
    quizzes_data = [
        {
            "id": "q1",
            "lesson_id": "l1",
            "questions": [
                {
                    "q": "What is a stock?",
                    "options": ["Asset", "Debt", "Currency", "Bond"],
                    "answer": "Asset"
                },
                {
                    "q": "What does IPO stand for?",
                    "options": ["Initial Public Offering", "International Private Offering", "Internal Public Option", "Individual Portfolio Option"],
                    "answer": "Initial Public Offering"
                }
            ]
        },
        {
            "id": "q2",
            "lesson_id": "l2", 
            "questions": [
                {
                    "q": "शेयर क्या है?",
                    "options": ["संपत्ति", "कर्ज", "मुद्रा", "बॉन्ड"],
                    "answer": "संपत्ति"
                }
            ]
        }
    ]
    
    existing_quizzes = await db.quizzes.count_documents({})
    if existing_quizzes == 0:
        await db.quizzes.insert_many(quizzes_data)
        logger.info("Inserted sample quizzes")
    
    # Sample Trades
    trades_data = [
        {
            "id": "t1",
            "user_id": "u1",
            "symbol": "AAPL",
            "side": "BUY",
            "qty": 10,
            "price": 180.5,
            "timestamp": datetime.utcnow()
        },
        {
            "id": "t2",
            "user_id": "u1", 
            "symbol": "MSFT",
            "side": "BUY",
            "qty": 5,
            "price": 320.75,
            "timestamp": datetime.utcnow()
        }
    ]
    
    existing_trades = await db.trades.count_documents({})
    if existing_trades == 0:
        await db.trades.insert_many(trades_data)
        logger.info("Inserted sample trades")
    
    # Sample Portfolios
    portfolios_data = [
        {
            "user_id": "u1",
            "holdings": {"AAPL": 10, "MSFT": 5},
            "cash_balance": 5000.0
        },
        {
            "user_id": "u2",
            "holdings": {"GOOGL": 3},
            "cash_balance": 8500.0
        }
    ]
    
    existing_portfolios = await db.portfolios.count_documents({})
    if existing_portfolios == 0:
        await db.portfolios.insert_many(portfolios_data)
        logger.info("Inserted sample portfolios")
    
    # Sample Progress
    progress_data = [
        {
            "user_id": "u1",
            "lesson_id": "l1", 
            "score": 90,
            "completed_at": datetime.utcnow()
        },
        {
            "user_id": "u2",
            "lesson_id": "l2",
            "score": 85,
            "completed_at": datetime.utcnow()
        }
    ]
    
    existing_progress = await db.progress.count_documents({})
    if existing_progress == 0:
        await db.progress.insert_many(progress_data)
        logger.info("Inserted sample progress")
    
    # Sample Tutorials
    tutorials_data = [
        {
            "id": "t1",
            "title": "How to Read Stock Charts",
            "content": "Learn to interpret candlestick charts, volume, and technical indicators...",
            "difficulty": "Intermediate"
        },
        {
            "id": "t2", 
            "title": "Portfolio Diversification",
            "content": "Understanding the importance of diversifying your investment portfolio...",
            "difficulty": "Beginner"
        }
    ]
    
    existing_tutorials = await db.tutorials.count_documents({})
    if existing_tutorials == 0:
        await db.tutorials.insert_many(tutorials_data)
        logger.info("Inserted sample tutorials")

async def create_indexes(db):
    """Create database indexes for better performance"""
    try:
        # Users collection indexes
        await db.users.create_index("email", unique=True)
        await db.users.create_index("uid", unique=True)
        
        # Lessons collection indexes
        await db.lessons.create_index("lang")
        await db.lessons.create_index("difficulty")
        await db.lessons.create_index("id", unique=True)
        
        # Quizzes collection indexes
        await db.quizzes.create_index("lesson_id")
        await db.quizzes.create_index("id", unique=True)
        
        # Trades collection indexes
        await db.trades.create_index("user_id")
        await db.trades.create_index("symbol")
        await db.trades.create_index("timestamp")
        await db.trades.create_index("id", unique=True)
        
        # Portfolios collection indexes
        await db.portfolios.create_index("user_id", unique=True)
        
        # Progress collection indexes
        await db.progress.create_index("user_id")
        await db.progress.create_index("lesson_id")
        await db.progress.create_index([("user_id", 1), ("lesson_id", 1)], unique=True)
        
        # Tutorials collection indexes
        await db.tutorials.create_index("difficulty")
        await db.tutorials.create_index("id", unique=True)
        
        logger.info("Database indexes created successfully")
        
    except Exception as e:
        logger.error(f"Error creating indexes: {e}")

# Standalone script execution
if __name__ == "__main__":
    import os
    import sys
    
    # Add the parent directory to sys.path to import config
    sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    
    from app.config import settings
    
    logging.basicConfig(level=logging.INFO)
    asyncio.run(initialize_database())
