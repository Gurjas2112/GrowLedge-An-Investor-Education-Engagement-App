from pydantic import BaseModel, Field, EmailStr, ConfigDict
from typing import Optional, List, Dict, Any
from datetime import datetime
try:
    from bson import ObjectId
except ImportError:
    # Mock ObjectId for development without MongoDB
    class ObjectId:
        @staticmethod
        def is_valid(v):
            return isinstance(v, str) and len(v) == 24
        
        def __init__(self, v=None):
            self.value = v or "000000000000000000000000"
            
        def __str__(self):
            return str(self.value)

class PyObjectId(ObjectId):
    @classmethod
    def __get_pydantic_core_schema__(cls, _source_type, _handler):
        from pydantic_core import core_schema
        return core_schema.json_or_python_schema(
            json_schema=core_schema.str_schema(),
            python_schema=core_schema.union_schema([
                core_schema.is_instance_schema(ObjectId),
                core_schema.chain_schema([
                    core_schema.str_schema(),
                    core_schema.no_info_plain_validator_function(cls.validate),
                ])
            ]),
            serialization=core_schema.plain_serializer_function_ser_schema(
                lambda x: str(x)
            ),
        )

    @classmethod
    def validate(cls, v):
        if not ObjectId.is_valid(v):
            raise ValueError("Invalid objectid")
        return ObjectId(v)

# User Models
class UserCreate(BaseModel):
    email: EmailStr
    password: str
    name: str
    preferred_language: str = "English"

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class User(BaseModel):
    model_config = ConfigDict(populate_by_name=True, arbitrary_types_allowed=True)
    
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    uid: str
    email: str
    name: str
    preferred_language: str = "English"
    xp_points: int = 0
    badges: List[str] = []
    completed_lessons: List[str] = []
    quiz_scores: Dict[str, int] = {}
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

class UserUpdate(BaseModel):
    name: Optional[str] = None
    preferred_language: Optional[str] = None
    xp_points: Optional[int] = None
    badges: Optional[List[str]] = None
    completed_lessons: Optional[List[str]] = None
    quiz_scores: Optional[Dict[str, int]] = None
    updated_at: datetime = Field(default_factory=datetime.utcnow)

# Lesson Models
class Lesson(BaseModel):
    model_config = ConfigDict(populate_by_name=True, arbitrary_types_allowed=True)
    
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    title: str
    content: str
    lang: str = "English"
    difficulty: str = "Beginner"
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

class LessonCreate(BaseModel):
    title: str
    content: str
    lang: str = "English"
    difficulty: str = "Beginner"

# Quiz Models
class QuizQuestion(BaseModel):
    q: str  # question text
    options: List[str]  # answer options
    answer: str  # correct answer

class Quiz(BaseModel):
    model_config = ConfigDict(populate_by_name=True, arbitrary_types_allowed=True)
    
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    lesson_id: str
    questions: List[QuizQuestion]
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

class QuizCreate(BaseModel):
    lesson_id: str
    questions: List[QuizQuestion]

class QuizSubmission(BaseModel):
    quiz_id: str
    answers: List[str]  # List of selected answers

# Progress Models
class Progress(BaseModel):
    model_config = ConfigDict(populate_by_name=True, arbitrary_types_allowed=True)
    
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    user_id: str
    lesson_id: str
    score: int
    completed_at: datetime = Field(default_factory=datetime.utcnow)

# Trading Models
class Portfolio(BaseModel):
    model_config = ConfigDict(populate_by_name=True, arbitrary_types_allowed=True)
    
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    user_id: str
    cash_balance: float = 10000.0
    holdings: Dict[str, float] = {}  # symbol: quantity
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

class Trade(BaseModel):
    model_config = ConfigDict(populate_by_name=True, arbitrary_types_allowed=True)
    
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    user_id: str
    symbol: str
    side: str  # "BUY" or "SELL"
    qty: float  # quantity
    price: float
    timestamp: datetime = Field(default_factory=datetime.utcnow)

class TradeRequest(BaseModel):
    symbol: str
    side: str  # "BUY" or "SELL"
    qty: float
    price: float

# Tutorial Models (for tutorials collection)
class Tutorial(BaseModel):
    model_config = ConfigDict(populate_by_name=True, arbitrary_types_allowed=True)
    
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    title: str
    content: str
    difficulty: str = "Beginner"
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

class TutorialCreate(BaseModel):
    title: str
    content: str
    difficulty: str = "Beginner"
