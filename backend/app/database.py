from motor.motor_asyncio import AsyncIOMotorClient
from pymongo.errors import ConnectionFailure
import logging
from .config import settings

logger = logging.getLogger(__name__)

class MongoDB:
    client: AsyncIOMotorClient = None
    database = None

mongodb = MongoDB()

async def connect_to_mongo():
    """Create database connection"""
    try:
        mongodb.client = AsyncIOMotorClient(settings.MONGODB_URL)
        mongodb.database = mongodb.client[settings.MONGODB_DATABASE]
        
        # Test the connection
        await mongodb.client.admin.command('ping')
        logger.info("Successfully connected to MongoDB")
        
        # Create indexes for better performance
        await create_indexes()
        
    except ConnectionFailure as e:
        logger.error(f"Failed to connect to MongoDB: {e}")
        raise e

async def close_mongo_connection():
    """Close database connection"""
    if mongodb.client:
        mongodb.client.close()
        logger.info("Disconnected from MongoDB")

async def create_indexes():
    """Create database indexes for better performance"""
    try:
        # Users collection indexes
        await mongodb.database.users.create_index("email", unique=True)
        await mongodb.database.users.create_index("uid", unique=True)
        
        # Lessons collection indexes
        await mongodb.database.lessons.create_index("lang")
        await mongodb.database.lessons.create_index("difficulty")
        await mongodb.database.lessons.create_index("id", unique=True)
        
        # Quizzes collection indexes
        await mongodb.database.quizzes.create_index("lesson_id")
        await mongodb.database.quizzes.create_index("id", unique=True)
        
        # Trades collection indexes
        await mongodb.database.trades.create_index("user_id")
        await mongodb.database.trades.create_index("symbol")
        await mongodb.database.trades.create_index("timestamp")
        await mongodb.database.trades.create_index("id", unique=True)
        
        # Portfolios collection indexes
        await mongodb.database.portfolios.create_index("user_id", unique=True)
        
        # Progress collection indexes
        await mongodb.database.progress.create_index("user_id")
        await mongodb.database.progress.create_index("lesson_id")
        await mongodb.database.progress.create_index([("user_id", 1), ("lesson_id", 1)], unique=True)
        
        # Tutorials collection indexes
        await mongodb.database.tutorials.create_index("difficulty")
        await mongodb.database.tutorials.create_index("id", unique=True)
        
        logger.info("Database indexes created successfully")
        
    except Exception as e:
        logger.error(f"Error creating indexes: {e}")

def get_database():
    """Get database instance"""
    return mongodb.database
