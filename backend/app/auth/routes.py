from fastapi import APIRouter, HTTPException, Depends, status
from fastapi.security import OAuth2PasswordRequestForm
from datetime import timedelta
from ..models import UserCreate, UserLogin, User, UserUpdate
from ..auth import (
    authenticate_user, 
    create_user, 
    create_access_token, 
    get_current_user,
    get_password_hash
)
from ..database import get_database

router = APIRouter()

@router.post("/register", response_model=dict)
async def register(user_data: UserCreate):
    """Register a new user"""
    try:
        user = await create_user(
            email=user_data.email,
            password=user_data.password,
            name=user_data.name,
            preferred_language=user_data.preferred_language
        )
        
        # Create access token
        access_token = create_access_token(data={"sub": user.uid})
        
        return {
            "message": "User registered successfully",
            "access_token": access_token,
            "token_type": "bearer",
            "user": {
                "uid": user.uid,
                "email": user.email,
                "name": user.name,
                "preferred_language": user.preferred_language
            }
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/login", response_model=dict)
async def login(user_data: UserLogin):
    """Login user"""
    try:
        user = await authenticate_user(user_data.email, user_data.password)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password",
                headers={"WWW-Authenticate": "Bearer"},
            )
        
        # Create access token
        access_token = create_access_token(data={"sub": user.uid})
        
        return {
            "message": "Login successful",
            "access_token": access_token,
            "token_type": "bearer",
            "user": {
                "uid": user.uid,
                "email": user.email,
                "name": user.name,
                "preferred_language": user.preferred_language,
                "xp_points": user.xp_points,
                "badges": user.badges
            }
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/me", response_model=User)
async def get_current_user_info(current_user: User = Depends(get_current_user)):
    """Get current user information"""
    return current_user

@router.put("/me", response_model=dict)
async def update_current_user(
    user_data: UserUpdate,
    current_user: User = Depends(get_current_user)
):
    """Update current user information"""
    try:
        db = get_database()
        
        # Prepare update data
        update_data = {}
        if user_data.name is not None:
            update_data["name"] = user_data.name
        if user_data.preferred_language is not None:
            update_data["preferred_language"] = user_data.preferred_language
        if user_data.xp_points is not None:
            update_data["xp_points"] = user_data.xp_points
        if user_data.badges is not None:
            update_data["badges"] = user_data.badges
        if user_data.completed_lessons is not None:
            update_data["completed_lessons"] = user_data.completed_lessons
        if user_data.quiz_scores is not None:
            update_data["quiz_scores"] = user_data.quiz_scores
        
        update_data["updated_at"] = user_data.updated_at
        
        if update_data:
            await db.users.update_one(
                {"uid": current_user.uid},
                {"$set": update_data}
            )
            return {"message": "User updated successfully"}
        else:
            return {"message": "No fields to update"}
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/verify-token")
async def verify_token(current_user: User = Depends(get_current_user)):
    """Verify JWT token"""
    return {
        "valid": True,
        "uid": current_user.uid,
        "email": current_user.email
    }
