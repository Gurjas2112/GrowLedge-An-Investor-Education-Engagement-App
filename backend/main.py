from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from contextlib import asynccontextmanager
import os

from app.database import connect_to_mongo, close_mongo_connection
from app.config import settings
from app.auth.routes import router as auth_router
from app.lessons.routes import router as lessons_router
from app.quizzes.routes import router as quizzes_router
from app.trading.routes import router as trading_router
from app.ai.routes import router as ai_router

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    await connect_to_mongo()
    yield
    # Shutdown
    await close_mongo_connection()

app = FastAPI(
    title="GrowLedge API",
    description="Backend API for GrowLedge - An Investor Education & Engagement App",
    version="1.0.0",
    lifespan=lifespan
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth_router, prefix="/auth", tags=["Authentication"])
app.include_router(lessons_router, prefix="/lessons", tags=["Lessons"])
app.include_router(quizzes_router, prefix="/quizzes", tags=["Quizzes"])
app.include_router(trading_router, prefix="/trading", tags=["Trading"])
app.include_router(ai_router, prefix="/ai", tags=["AI Services"])

# Serve static files (for audio files)
static_dir = "static"
if not os.path.exists(static_dir):
    os.makedirs(static_dir)
app.mount("/static", StaticFiles(directory=static_dir), name="static")

@app.get("/")
async def root():
    return {
        "message": "Welcome to GrowLedge API",
        "version": "1.0.0",
        "description": "Learn. Simulate. Grow.",
        "database": "MongoDB"
    }

@app.options("/{path:path}")
async def options_handler(path: str):
    """Handle preflight requests"""
    return {"message": "OK"}

@app.get("/health")
async def health_check():
    return {
        "status": "healthy", 
        "service": "GrowLedge API",
        "database": "MongoDB"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=False)
