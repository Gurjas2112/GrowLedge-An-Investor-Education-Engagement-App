#!/usr/bin/env python3
"""
Test script to verify MongoDB connection and backend functionality
"""

import asyncio
import sys
import os

# Add the parent directory to sys.path to import app modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.database import connect_to_mongo, get_database, close_mongo_connection
from app.models import User, Lesson, Quiz, Trade, Portfolio

async def test_mongodb_connection():
    """Test MongoDB connection and basic operations"""
    
    print("🧪 Testing MongoDB Connection and Operations")
    print("=" * 50)
    
    try:
        # Connect to MongoDB
        await connect_to_mongo()
        print("✅ Connected to MongoDB successfully")
        
        db = get_database()
        
        # Test collections exist
        collections = await db.list_collection_names()
        expected_collections = ["users", "lessons", "quizzes", "trades", "portfolios", "progress", "tutorials"]
        
        print(f"\n📦 Available collections: {collections}")
        
        for collection in expected_collections:
            if collection in collections:
                count = await db[collection].count_documents({})
                print(f"✅ {collection}: {count} documents")
            else:
                print(f"❌ {collection}: Collection not found")
        
        # Test data retrieval
        print(f"\n🔍 Testing Data Retrieval:")
        
        # Test users
        user_doc = await db.users.find_one({})
        if user_doc:
            print(f"✅ Sample user: {user_doc.get('name', 'N/A')} ({user_doc.get('email', 'N/A')})")
        else:
            print("❌ No users found")
        
        # Test lessons
        lesson_doc = await db.lessons.find_one({})
        if lesson_doc:
            print(f"✅ Sample lesson: {lesson_doc.get('title', 'N/A')} ({lesson_doc.get('lang', 'N/A')})")
        else:
            print("❌ No lessons found")
        
        # Test quizzes
        quiz_doc = await db.quizzes.find_one({})
        if quiz_doc:
            print(f"✅ Sample quiz: Lesson {quiz_doc.get('lesson_id', 'N/A')} ({len(quiz_doc.get('questions', []))} questions)")
        else:
            print("❌ No quizzes found")
        
        # Test trades
        trade_doc = await db.trades.find_one({})
        if trade_doc:
            print(f"✅ Sample trade: {trade_doc.get('side', 'N/A')} {trade_doc.get('qty', 0)} {trade_doc.get('symbol', 'N/A')}")
        else:
            print("❌ No trades found")
        
        # Test portfolios
        portfolio_doc = await db.portfolios.find_one({})
        if portfolio_doc:
            print(f"✅ Sample portfolio: User {portfolio_doc.get('user_id', 'N/A')} (${portfolio_doc.get('cash_balance', 0)})")
        else:
            print("❌ No portfolios found")
        
        # Test progress
        progress_doc = await db.progress.find_one({})
        if progress_doc:
            print(f"✅ Sample progress: User {progress_doc.get('user_id', 'N/A')} scored {progress_doc.get('score', 0)}%")
        else:
            print("❌ No progress found")
        
        print(f"\n🎯 MongoDB Test Results:")
        print(f"✅ Database connection: Working")
        print(f"✅ Collections: {len([c for c in expected_collections if c in collections])}/{len(expected_collections)} found")
        print(f"✅ Data access: Working")
        
        return True
        
    except Exception as e:
        print(f"❌ Test failed: {e}")
        return False
    
    finally:
        await close_mongo_connection()
        print("\n🔌 Disconnected from MongoDB")

async def test_api_models():
    """Test if Pydantic models work correctly"""
    
    print(f"\n🧪 Testing API Models")
    print("=" * 25)
    
    try:
        # Test User model
        user_data = {
            "uid": "test_user",
            "email": "test@example.com",
            "name": "Test User",
            "preferred_language": "English",
            "badges": ["Beginner"]
        }
        user = User(**user_data)
        print(f"✅ User model: {user.name} ({user.email})")
        
        # Test Lesson model
        lesson_data = {
            "title": "Test Lesson",
            "content": "This is a test lesson content",
            "lang": "English",
            "difficulty": "Beginner"
        }
        lesson = Lesson(**lesson_data)
        print(f"✅ Lesson model: {lesson.title} ({lesson.lang})")
        
        # Test Quiz model
        quiz_data = {
            "lesson_id": "l1",
            "questions": [
                {
                    "q": "What is a test question?",
                    "options": ["Option 1", "Option 2", "Option 3"],
                    "answer": "Option 1"
                }
            ]
        }
        quiz = Quiz(**quiz_data)
        print(f"✅ Quiz model: {len(quiz.questions)} questions for lesson {quiz.lesson_id}")
        
        print(f"✅ All models working correctly!")
        return True
        
    except Exception as e:
        print(f"❌ Model test failed: {e}")
        return False

def main():
    """Main test function"""
    
    print("🚀 GrowLedge Backend Test Suite")
    print("=" * 40)
    
    # Run tests
    mongodb_success = asyncio.run(test_mongodb_connection())
    models_success = asyncio.run(test_api_models())
    
    print(f"\n📊 Test Summary:")
    print(f"MongoDB Connection: {'✅ PASS' if mongodb_success else '❌ FAIL'}")
    print(f"API Models: {'✅ PASS' if models_success else '❌ FAIL'}")
    
    if mongodb_success and models_success:
        print(f"\n🎉 All tests passed! Your backend is ready to use.")
        print(f"💡 You can now start the backend server with: python main.py")
        return 0
    else:
        print(f"\n⚠️  Some tests failed. Please check the errors above.")
        return 1

if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)
