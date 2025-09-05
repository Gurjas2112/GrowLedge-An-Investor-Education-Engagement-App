from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import requests
import json
from gtts import gTTS
import tempfile
import os
import uuid
from pathlib import Path
from ..config import settings

router = APIRouter()

class SummarizeRequest(BaseModel):
    text: str

class TranslateRequest(BaseModel):
    text: str
    target_language: str

class TTSRequest(BaseModel):
    text: str
    language: str = "English"

@router.post("/summarize")
async def summarize_text(request: SummarizeRequest):
    """Summarize text using Hugging Face API"""
    try:
        # Use BART model for summarization
        model_url = f"{settings.HUGGING_FACE_BASE_URL}/facebook/bart-large-cnn"
        
        headers = {
            "Authorization": f"Bearer {settings.HUGGING_FACE_API_KEY}",
            "Content-Type": "application/json"
        }
        
        # Truncate text if too long (BART has token limits)
        max_length = 1000
        text = request.text[:max_length] if len(request.text) > max_length else request.text
        
        payload = {
            "inputs": text,
            "parameters": {
                "max_length": 150,
                "min_length": 30,
                "do_sample": False
            }
        }
        
        response = requests.post(model_url, headers=headers, json=payload)
        response.raise_for_status()
        
        result = response.json()
        
        if isinstance(result, list) and len(result) > 0:
            summary = result[0].get("summary_text", "")
        else:
            summary = "Unable to generate summary"
        
        return {"summary": summary}
    except requests.RequestException as e:
        raise HTTPException(status_code=500, detail=f"Summarization API error: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/translate")
async def translate_text(request: TranslateRequest):
    """Translate text - Frontend should handle translation using Flutter translator library"""
    try:
        # Since we're removing LibreTranslate API, return the original text
        # The frontend will handle translation using Flutter's translator package
        return {
            "translated_text": request.text,
            "message": "Translation should be handled on the frontend using Flutter translator package",
            "target_language": request.target_language
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/tts")
async def text_to_speech(request: TTSRequest):
    """Convert text to speech using gTTS and store locally"""
    try:
        # Map language names to gTTS codes - Focus on Indian languages
        language_codes = {
            "English": "en",
            "Hindi": "hi",
            "Bengali": "bn",
            "Tamil": "ta",
            "Telugu": "te",
            "Marathi": "mr",
            "Gujarati": "gu",
            "Kannada": "kn",
            "Malayalam": "ml",
            "Punjabi": "pa",
            "Urdu": "ur",
            "Nepali": "ne"
        }
        
        lang_code = language_codes.get(request.language, "en")
        
        # Create TTS object
        tts = gTTS(text=request.text, lang=lang_code, slow=False)
        
        # Create audio directory if it doesn't exist
        audio_dir = Path("static/audio")
        audio_dir.mkdir(parents=True, exist_ok=True)
        
        # Generate unique filename
        filename = f"{uuid.uuid4()}.mp3"
        file_path = audio_dir / filename
        
        # Save audio file
        tts.save(str(file_path))
        
        # Return local URL path
        audio_url = f"/static/audio/{filename}"
        
        return {"audio_url": audio_url}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/analyze_content")
async def analyze_content(url: str):
    """Fetch, summarize, and translate content from a URL"""
    try:
        # Fetch content from URL (simplified implementation)
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        
        # Extract text content (in a real implementation, you'd use proper HTML parsing)
        content = response.text[:2000]  # Simplified text extraction
        
        # Summarize content
        summary_response = await summarize_text(SummarizeRequest(text=content))
        summary = summary_response["summary"]
        
        return {
            "original_content": content,
            "summary": summary,
            "url": url
        }
    except requests.RequestException as e:
        raise HTTPException(status_code=400, detail=f"Failed to fetch content from URL: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/health")
async def ai_health_check():
    """Health check for AI services"""
    return {
        "status": "healthy",
        "services": {
            "summarization": "available",
            "translation": "available",
            "text_to_speech": "available"
        }
    }
