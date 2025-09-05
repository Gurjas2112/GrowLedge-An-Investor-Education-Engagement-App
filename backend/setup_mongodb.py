"""
MongoDB Setup Script for GrowLedge
Run this script to initialize the database with sample data
"""

import asyncio
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime
from app.config import settings

async def create_sample_data():
    """Create sample lessons, quizzes, and other data"""
    client = AsyncIOMotorClient(settings.MONGODB_URL)
    db = client[settings.MONGODB_DATABASE]
    
    # Sample lessons
    lessons = [
        {
            "title": "Introduction to Investing",
            "description": "Learn the basics of investing and financial markets",
            "category": "Basics",
            "difficulty": "Beginner",
            "duration_minutes": 15,
            "content": [
                {
                    "language": "English",
                    "title": "Introduction to Investing",
                    "description": "Learn the basics of investing and financial markets",
                    "content": "Investing is the act of committing money or capital to an endeavor with the expectation of obtaining additional income or profit..."
                },
                {
                    "language": "Hindi",
                    "title": "निवेश का परिचय",
                    "description": "निवेश और वित्तीय बाजारों की मूल बातें सीखें",
                    "content": "निवेश एक ऐसा कार्य है जिसमें अतिरिक्त आय या लाभ प्राप्त करने की अपेक्षा के साथ पैसा या पूंजी लगाई जाती है..."
                }
            ],
            "prerequisites": [],
            "learning_objectives": [
                "Understand what investing means",
                "Learn about different types of investments",
                "Understand risk and return concepts"
            ],
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow()
        },
        {
            "title": "Stock Market Fundamentals",
            "description": "Understanding how the stock market works",
            "category": "Stocks",
            "difficulty": "Beginner",
            "duration_minutes": 20,
            "content": [
                {
                    "language": "English",
                    "title": "Stock Market Fundamentals",
                    "description": "Understanding how the stock market works",
                    "content": "The stock market is a platform where shares of publicly traded companies are bought and sold..."
                }
            ],
            "prerequisites": ["Introduction to Investing"],
            "learning_objectives": [
                "Understand what stocks are",
                "Learn how stock exchanges work",
                "Understand market indices"
            ],
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow()
        }
    ]
    
    # Insert lessons
    await db.lessons.delete_many({})  # Clear existing
    lesson_result = await db.lessons.insert_many(lessons)
    print(f"Inserted {len(lesson_result.inserted_ids)} lessons")
    
    # Sample quizzes
    quizzes = [
        {
            "lesson_id": str(lesson_result.inserted_ids[0]),
            "title": "Introduction to Investing Quiz",
            "description": "Test your knowledge of basic investing concepts",
            "questions": [
                {
                    "question": "What is the primary goal of investing?",
                    "options": [
                        {"text": "To lose money", "is_correct": False},
                        {"text": "To generate returns over time", "is_correct": True},
                        {"text": "To gamble", "is_correct": False},
                        {"text": "To spend money", "is_correct": False}
                    ],
                    "explanation": "The primary goal of investing is to generate returns over time by putting money to work in various financial instruments."
                },
                {
                    "question": "Which of the following is considered a lower-risk investment?",
                    "options": [
                        {"text": "Government bonds", "is_correct": True},
                        {"text": "Cryptocurrency", "is_correct": False},
                        {"text": "Penny stocks", "is_correct": False},
                        {"text": "Options trading", "is_correct": False}
                    ],
                    "explanation": "Government bonds are generally considered lower-risk investments because they are backed by the government's ability to tax and print money."
                }
            ],
            "pass_score": 70,
            "time_limit_minutes": 10,
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow()
        }
    ]
    
    # Insert quizzes
    await db.quizzes.delete_many({})  # Clear existing
    quiz_result = await db.quizzes.insert_many(quizzes)
    print(f"Inserted {len(quiz_result.inserted_ids)} quizzes")
    
    print("Sample data created successfully!")
    
    client.close()

async def create_indexes():
    """Create database indexes"""
    client = AsyncIOMotorClient(settings.MONGODB_URL)
    db = client[settings.MONGODB_DATABASE]
    
    # Users collection indexes
    await db.users.create_index("email", unique=True)
    await db.users.create_index("uid", unique=True)
    
    # Lessons collection indexes
    await db.lessons.create_index("category")
    await db.lessons.create_index("difficulty")
    
    # Quizzes collection indexes
    await db.quizzes.create_index("lesson_id")
    
    # Trades collection indexes
    await db.trades.create_index("user_id")
    await db.trades.create_index("symbol")
    
    # Portfolios collection indexes
    await db.portfolios.create_index("user_id", unique=True)
    
    print("Database indexes created successfully!")
    
    client.close()

async def main():
    print("Setting up GrowLedge MongoDB database...")
    print(f"MongoDB URL: {settings.MONGODB_URL}")
    print(f"Database: {settings.MONGODB_DATABASE}")
    
    try:
        await create_indexes()
        await create_sample_data()
        print("\n✅ Database setup completed successfully!")
        print("\nYou can now start the FastAPI server with:")
        print("uvicorn main:app --reload")
    except Exception as e:
        print(f"\n❌ Error setting up database: {e}")

if __name__ == "__main__":
    asyncio.run(main())
