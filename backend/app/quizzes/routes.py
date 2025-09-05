from fastapi import APIRouter, HTTPException, Depends
from typing import List
from bson import ObjectId
from datetime import datetime
from ..models import Quiz, QuizCreate, QuizSubmission, Progress, User
from ..auth import get_current_user
from ..database import get_database

router = APIRouter()

@router.get("/", response_model=List[Quiz])
async def get_quizzes(lesson_id: str = None):
    """Get quizzes, optionally filtered by lesson_id"""
    try:
        db = get_database()
        
        filter_query = {}
        if lesson_id:
            filter_query["lesson_id"] = lesson_id
        
        cursor = db.quizzes.find(filter_query)
        quizzes = []
        
        async for doc in cursor:
            quiz_data = {
                "id": str(doc.get("_id", doc.get("id", ""))),
                "lesson_id": doc["lesson_id"],
                "questions": doc["questions"],
                "created_at": doc.get("created_at", datetime.utcnow()),
                "updated_at": doc.get("updated_at", datetime.utcnow())
            }
            quizzes.append(Quiz(**quiz_data))
        
        return quizzes
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{quiz_id}", response_model=Quiz)
async def get_quiz(quiz_id: str):
    """Get a specific quiz by ID"""
    try:
        db = get_database()
        
        # Try to find by custom id first, then by ObjectId
        quiz_doc = await db.quizzes.find_one({"id": quiz_id})
        if not quiz_doc and ObjectId.is_valid(quiz_id):
            quiz_doc = await db.quizzes.find_one({"_id": ObjectId(quiz_id)})
        
        if not quiz_doc:
            raise HTTPException(status_code=404, detail="Quiz not found")
        
        quiz_data = {
            "id": str(quiz_doc.get("_id", quiz_doc.get("id", ""))),
            "lesson_id": quiz_doc["lesson_id"],
            "questions": quiz_doc["questions"],
            "created_at": quiz_doc.get("created_at", datetime.utcnow()),
            "updated_at": quiz_doc.get("updated_at", datetime.utcnow())
        }
        
        return Quiz(**quiz_data)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/", response_model=dict)
async def create_quiz(
    quiz: QuizCreate,
    current_user: User = Depends(get_current_user)
):
    """Create a new quiz"""
    try:
        db = get_database()
        
        quiz_doc = {
            "lesson_id": quiz.lesson_id,
            "questions": [q.dict() for q in quiz.questions],
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow()
        }
        
        result = await db.quizzes.insert_one(quiz_doc)
        
        return {
            "id": str(result.inserted_id),
            "message": "Quiz created successfully"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/submit")
async def submit_quiz(
    submission: QuizSubmission,
    current_user: User = Depends(get_current_user)
):
    """Submit quiz answers and calculate score"""
    try:
        db = get_database()
        
        # Get quiz data
        quiz_doc = await db.quizzes.find_one({"id": submission.quiz_id})
        if not quiz_doc and ObjectId.is_valid(submission.quiz_id):
            quiz_doc = await db.quizzes.find_one({"_id": ObjectId(submission.quiz_id)})
        
        if not quiz_doc:
            raise HTTPException(status_code=404, detail="Quiz not found")
        
        questions = quiz_doc["questions"]
        
        # Calculate score
        score = 0
        total_questions = len(questions)
        
        for i, user_answer in enumerate(submission.answers):
            if i < len(questions) and user_answer == questions[i]["answer"]:
                score += 1
        
        # Save progress
        progress_doc = {
            "user_id": current_user.uid,
            "lesson_id": quiz_doc["lesson_id"],
            "score": int((score / total_questions) * 100) if total_questions > 0 else 0,
            "completed_at": datetime.utcnow()
        }
        
        await db.progress.update_one(
            {"user_id": current_user.uid, "lesson_id": quiz_doc["lesson_id"]},
            {"$set": progress_doc},
            upsert=True
        )
        
        return {
            "score": score,
            "total_questions": total_questions,
            "percentage": (score / total_questions) * 100 if total_questions > 0 else 0,
            "lesson_id": quiz_doc["lesson_id"]
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/progress/{user_id}")
async def get_user_quiz_progress(user_id: str):
    """Get quiz progress for a user"""
    try:
        db = get_database()
        
        cursor = db.progress.find({"user_id": user_id})
        progress_data = []
        
        async for doc in cursor:
            progress = {
                "id": str(doc["_id"]),
                "user_id": doc["user_id"],
                "lesson_id": doc["lesson_id"],
                "score": doc["score"],
                "completed_at": doc["completed_at"]
            }
            progress_data.append(progress)
        
        return progress_data
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
