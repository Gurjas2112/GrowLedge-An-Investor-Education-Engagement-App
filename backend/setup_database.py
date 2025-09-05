#!/usr/bin/env python3
"""
Standalone MongoDB Setup Script for GrowLedge
Run this script to set up your MongoDB database with the correct structure and sample data
"""

import asyncio
import logging
from datetime import datetime
import os
import sys

# Try to import required libraries
try:
    from motor.motor_asyncio import AsyncIOMotorClient
    from pymongo.errors import ConnectionFailure
except ImportError:
    print("Error: Required libraries not installed.")
    print("Please install them with: pip install motor pymongo")
    sys.exit(1)

# Database configuration
MONGODB_URL = "mongodb://localhost:27017"
DATABASE_NAME = "growledgedb"

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

async def setup_database():
    """Set up the MongoDB database with collections and sample data"""
    
    # Connect to MongoDB
    client = AsyncIOMotorClient(MONGODB_URL)
    db = client[DATABASE_NAME]
    
    try:
        # Test connection
        await client.admin.command('ping')
        logger.info(f"✓ Connected to MongoDB at {MONGODB_URL}")
        logger.info(f"✓ Using database: {DATABASE_NAME}")
        
        # Create collections with sample data
        await create_collections_with_data(db)
        
        # Create indexes for performance
        await create_database_indexes(db)
        
        # Display database status
        await show_database_status(db)
        
        logger.info("🎉 Database setup completed successfully!")
        
    except ConnectionFailure as e:
        logger.error(f"❌ Failed to connect to MongoDB: {e}")
        logger.error("Make sure MongoDB is running on localhost:27017")
        raise e
    except Exception as e:
        logger.error(f"❌ Database setup failed: {e}")
        raise e
    finally:
        client.close()

async def create_collections_with_data(db):
    """Create collections and insert sample data"""
    
    logger.info("📦 Setting up collections with sample data...")
    
    # Users collection
    users_sample = [
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
    
    # Check if collection exists and has data
    user_count = await db.users.count_documents({})
    if user_count == 0:
        await db.users.insert_many(users_sample)
        logger.info("  ✓ Users collection created with sample data")
    else:
        logger.info(f"  ✓ Users collection already exists ({user_count} documents)")
    
    # Lessons collection
    lessons_sample = [
        {
            "id": "l1",
            "title": "Stock Market Basics",
            "content": "Introduction to stock markets and how they work. Learn about shares, market mechanisms, and basic investment principles.",
            "lang": "English",
            "difficulty": "Beginner"
        },
        {
            "id": "l2", 
            "title": "शेयर बाजार की मूल बातें",
            "content": "शेयर बाजार का परिचय और यह कैसे काम करता है। शेयर, बाजार तंत्र और बुनियादी निवेश सिद्धांतों के बारे में जानें।",
            "lang": "Hindi",
            "difficulty": "Beginner"
        },
        {
            "id": "l3",
            "title": "Mutual Funds Explained", 
            "content": "Understanding mutual funds, their types, benefits, and how to invest in them effectively.",
            "lang": "English",
            "difficulty": "Intermediate"
        }
    ]
    
    lesson_count = await db.lessons.count_documents({})
    if lesson_count == 0:
        await db.lessons.insert_many(lessons_sample)
        logger.info("  ✓ Lessons collection created with sample data")
    else:
        logger.info(f"  ✓ Lessons collection already exists ({lesson_count} documents)")
    
    # Quizzes collection
    quizzes_sample = [
        {
            "id": "q1",
            "lesson_id": "l1",
            "questions": [
                {
                    "q": "What is a stock?",
                    "options": ["A piece of ownership in a company", "A type of bond", "A currency", "A bank account"],
                    "answer": "A piece of ownership in a company"
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
                    "options": ["कंपनी में स्वामित्व का हिस्सा", "एक प्रकार का बॉन्ड", "एक मुद्रा", "एक बैंक खाता"],
                    "answer": "कंपनी में स्वामित्व का हिस्सा"
                }
            ]
        }
    ]
    
    quiz_count = await db.quizzes.count_documents({})
    if quiz_count == 0:
        await db.quizzes.insert_many(quizzes_sample)
        logger.info("  ✓ Quizzes collection created with sample data")
    else:
        logger.info(f"  ✓ Quizzes collection already exists ({quiz_count} documents)")
    
    # Trades collection
    trades_sample = [
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
    
    trade_count = await db.trades.count_documents({})
    if trade_count == 0:
        await db.trades.insert_many(trades_sample)
        logger.info("  ✓ Trades collection created with sample data")
    else:
        logger.info(f"  ✓ Trades collection already exists ({trade_count} documents)")
    
    # Portfolios collection
    portfolios_sample = [
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
    
    portfolio_count = await db.portfolios.count_documents({})
    if portfolio_count == 0:
        await db.portfolios.insert_many(portfolios_sample)
        logger.info("  ✓ Portfolios collection created with sample data")
    else:
        logger.info(f"  ✓ Portfolios collection already exists ({portfolio_count} documents)")
    
    # Progress collection
    progress_sample = [
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
    
    progress_count = await db.progress.count_documents({})
    if progress_count == 0:
        await db.progress.insert_many(progress_sample)
        logger.info("  ✓ Progress collection created with sample data")
    else:
        logger.info(f"  ✓ Progress collection already exists ({progress_count} documents)")
    
    # Tutorials collection
    tutorials_sample = [
        {
            "id": "tut1",
            "title": "How to Read Stock Charts",
            "content": "Learn to interpret candlestick charts, volume indicators, and technical analysis patterns.",
            "difficulty": "Intermediate"
        },
        {
            "id": "tut2",
            "title": "Portfolio Diversification Strategy",
            "content": "Understanding the importance of diversifying your investment portfolio across different asset classes.",
            "difficulty": "Beginner"
        }
    ]
    
    tutorial_count = await db.tutorials.count_documents({})
    if tutorial_count == 0:
        await db.tutorials.insert_many(tutorials_sample)
        logger.info("  ✓ Tutorials collection created with sample data")
    else:
        logger.info(f"  ✓ Tutorials collection already exists ({tutorial_count} documents)")

async def create_database_indexes(db):
    """Create indexes for better query performance"""
    
    logger.info("⚡ Creating database indexes...")
    
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
        
        logger.info("  ✓ All indexes created successfully")
        
    except Exception as e:
        logger.error(f"  ❌ Error creating indexes: {e}")

async def show_database_status(db):
    """Display the current status of the database"""
    
    logger.info("📊 Database Status:")
    
    collections = ["users", "lessons", "quizzes", "trades", "portfolios", "progress", "tutorials"]
    
    for collection_name in collections:
        count = await db[collection_name].count_documents({})
        logger.info(f"  • {collection_name}: {count} documents")

def main():
    """Main function to run the database setup"""
    
    print("🚀 GrowLedge MongoDB Setup Script")
    print("=" * 40)
    
    # Check if MongoDB URL is accessible
    print(f"📡 Connecting to MongoDB at: {MONGODB_URL}")
    print(f"🗄️  Database name: {DATABASE_NAME}")
    print()
    
    # Run the async setup
    try:
        asyncio.run(setup_database())
        print()
        print("✅ Setup completed! Your GrowLedge database is ready to use.")
        print(f"🌐 Database URL: {MONGODB_URL}")
        print(f"📂 Database Name: {DATABASE_NAME}")
        
    except KeyboardInterrupt:
        print("\n⚠️  Setup interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Setup failed: {e}")
        print("\n💡 Troubleshooting tips:")
        print("  1. Make sure MongoDB is running: 'mongod' or start MongoDB service")
        print("  2. Check if MongoDB is accessible at localhost:27017")
        print("  3. Install required packages: pip install motor pymongo")
        sys.exit(1)

if __name__ == "__main__":
    main()
