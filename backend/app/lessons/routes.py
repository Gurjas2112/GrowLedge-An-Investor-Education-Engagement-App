from fastapi import APIRouter, HTTPException, Query, Depends
from typing import List, Optional
from bson import ObjectId
from datetime import datetime
from ..models import Lesson, LessonCreate, User
from ..auth import get_current_user
from ..database import get_database

router = APIRouter()

@router.get("/", response_model=List[Lesson])
async def get_lessons(
    difficulty: Optional[str] = Query(None),
    lang: Optional[str] = Query(None),
    limit: int = Query(50, le=100)
):
    """Get lessons with optional filters"""
    try:
        db = get_database()
        
        # Build filter query
        filter_query = {}
        if difficulty:
            filter_query["difficulty"] = difficulty
        if lang:
            filter_query["lang"] = lang
        
        # Get lessons
        cursor = db.lessons.find(filter_query).limit(limit)
        lessons = []
        
        async for doc in cursor:
            lesson_data = {
                "id": str(doc.get("_id", doc.get("id", ""))),
                "title": doc["title"],
                "content": doc["content"],
                "lang": doc.get("lang", "English"),
                "difficulty": doc.get("difficulty", "Beginner"),
                "created_at": doc.get("created_at", datetime.utcnow()),
                "updated_at": doc.get("updated_at", datetime.utcnow())
            }
            lessons.append(Lesson(**lesson_data))
        
        return lessons
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{lesson_id}", response_model=Lesson)
async def get_lesson(lesson_id: str):
    """Get a specific lesson by ID"""
    try:
        db = get_database()
        
        # Try to find by custom id first, then by ObjectId
        lesson_doc = await db.lessons.find_one({"id": lesson_id})
        if not lesson_doc and ObjectId.is_valid(lesson_id):
            lesson_doc = await db.lessons.find_one({"_id": ObjectId(lesson_id)})
        
        if not lesson_doc:
            raise HTTPException(status_code=404, detail="Lesson not found")
        
        lesson_data = {
            "id": str(lesson_doc.get("_id", lesson_doc.get("id", ""))),
            "title": lesson_doc["title"],
            "content": lesson_doc["content"],
            "lang": lesson_doc.get("lang", "English"),
            "difficulty": lesson_doc.get("difficulty", "Beginner"),
            "created_at": lesson_doc.get("created_at", datetime.utcnow()),
            "updated_at": lesson_doc.get("updated_at", datetime.utcnow())
        }
        
        return Lesson(**lesson_data)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/", response_model=dict)
async def create_lesson(
    lesson: LessonCreate,
    current_user: User = Depends(get_current_user)
):
    """Create a new lesson"""
    try:
        db = get_database()
        
        lesson_doc = {
            "title": lesson.title,
            "content": lesson.content,
            "lang": lesson.lang,
            "difficulty": lesson.difficulty,
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow()
        }
        
        result = await db.lessons.insert_one(lesson_doc)
        
        return {
            "id": str(result.inserted_id),
            "message": "Lesson created successfully"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/{lesson_id}/progress")
async def update_lesson_progress(
    lesson_id: str,
    score: int,
    current_user: User = Depends(get_current_user)
):
    """Mark lesson as completed for the current user and record progress"""
    try:
        db = get_database()
        
        # Verify lesson exists
        lesson_doc = await db.lessons.find_one({"id": lesson_id})
        if not lesson_doc and ObjectId.is_valid(lesson_id):
            lesson_doc = await db.lessons.find_one({"_id": ObjectId(lesson_id)})
        
        if not lesson_doc:
            raise HTTPException(status_code=404, detail="Lesson not found")
        
        # Create or update progress record
        progress_doc = {
            "user_id": current_user.uid,
            "lesson_id": lesson_id,
            "score": score,
            "completed_at": datetime.utcnow()
        }
        
        await db.progress.update_one(
            {"user_id": current_user.uid, "lesson_id": lesson_id},
            {"$set": progress_doc},
            upsert=True
        )
        
        return {"message": "Lesson progress updated successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{lesson_id}")
async def delete_lesson(
    lesson_id: str,
    current_user: User = Depends(get_current_user)
):
    """Delete a lesson"""
    try:
        db = get_database()
        
        # Try to delete by custom id first, then by ObjectId
        result = await db.lessons.delete_one({"id": lesson_id})
        if result.deleted_count == 0 and ObjectId.is_valid(lesson_id):
            result = await db.lessons.delete_one({"_id": ObjectId(lesson_id)})
        
        if result.deleted_count == 0:
            raise HTTPException(status_code=404, detail="Lesson not found")
        
        return {"message": "Lesson deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
