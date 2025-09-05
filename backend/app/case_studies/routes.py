from fastapi import APIRouter, HTTPException, Depends, Query
from typing import List, Optional
from datetime import datetime
import csv
import os

from ..models.case_study import CaseStudy, CaseStudyResponse
from ..auth.dependencies import get_current_user
from ..database import get_database

router = APIRouter()

def parse_sebi_content(content: str) -> dict:
    """Parse SEBI content to extract meaningful information"""
    # Extract key topics from SEBI announcements
    topics = []
    categories = []
    
    content_lower = content.lower()
    
    # Identify key topics
    if "arth yatra" in content_lower:
        topics.append("Financial Literacy Contest")
    if "pacl" in content_lower:
        topics.append("Recovery Proceedings")
    if "insolvency" in content_lower:
        topics.append("Insolvency & Bankruptcy")
    if "hackathon" in content_lower:
        topics.append("Innovation in Securities Markets")
    if "cybersecurity" in content_lower:
        topics.append("Cybersecurity Framework")
    if "algo" in content_lower or "algorithm" in content_lower:
        topics.append("Algorithmic Trading")
    if "settlement" in content_lower:
        topics.append("Settlement Schemes")
    if "aif" in content_lower:
        topics.append("Alternative Investment Funds")
    
    # Determine categories
    if any(word in content_lower for word in ["contest", "quiz", "education"]):
        categories.append("investor-education")
    if any(word in content_lower for word in ["notice", "refund", "recovery"]):
        categories.append("notices")
    if any(word in content_lower for word in ["regulation", "framework", "guideline"]):
        categories.append("regulations")
    if any(word in content_lower for word in ["innovation", "hackathon", "sandbox"]):
        categories.append("innovation")
    
    return {
        "topics": topics,
        "categories": categories if categories else ["general"]
    }

def determine_difficulty(content: str) -> str:
    """Determine difficulty level based on content complexity"""
    content_lower = content.lower()
    
    # Advanced topics
    if any(word in content_lower for word in [
        "algorithmic", "cybersecurity", "framework", "compliance", 
        "settlement", "recovery proceedings", "aif"
    ]):
        return "advanced"
    
    # Intermediate topics
    if any(word in content_lower for word in [
        "insolvency", "bankruptcy", "regulations", "guidelines",
        "investment fund", "trading"
    ]):
        return "intermediate"
    
    # Beginner topics
    if any(word in content_lower for word in [
        "contest", "quiz", "education", "awareness", "basic"
    ]):
        return "beginner"
    
    return "intermediate"  # default

@router.get("/case-studies", response_model=CaseStudyResponse)
async def get_case_studies(
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1, le=50),
    category: Optional[str] = Query(None),
    difficulty: Optional[str] = Query(None),
    source: Optional[str] = Query(None),
    current_user = Depends(get_current_user)
):
    """Get paginated case studies with optional filters"""
    try:
        # Load case studies from CSV file
        csv_path = os.path.join(os.path.dirname(__file__), "..", "..", "..", "case_studies.csv")
        case_studies = []
        
        if os.path.exists(csv_path):
            with open(csv_path, 'r', encoding='utf-8') as file:
                reader = csv.DictReader(file)
                for i, row in enumerate(reader):
                    if row['url'] and not any(error in row['summary'].lower() for error in ['error', 'forbidden', 'not found']):
                        # Parse content for better categorization
                        parsed_info = parse_sebi_content(row['summary'])
                        
                        # Determine source from URL
                        source_name = "SEBI" if "sebi.gov.in" in row['url'] else "NISM" if "nism.ac.in" in row['url'] else "Other"
                        
                        # Create title from URL
                        title = row['url'].split('/')[-2].replace('-', ' ').title() if '/' in row['url'] else f"Case Study {i+1}"
                        
                        case_study = CaseStudy(
                            id=str(i+1),
                            title=title,
                            url=row['url'],
                            content=row['original'][:2000] + "..." if len(row['original']) > 2000 else row['original'],
                            summary=row['summary'],
                            hindi_translation=row['hindi'] if row['hindi'] and not row['hindi'].startswith('[Hindi translation not available]') else None,
                            source=source_name,
                            category=parsed_info['categories'][0] if parsed_info['categories'] else "general",
                            difficulty_level=determine_difficulty(row['summary']),
                            tags=parsed_info['topics'],
                            created_at=datetime.utcnow(),
                            updated_at=datetime.utcnow()
                        )
                        case_studies.append(case_study)
        
        # Apply filters
        filtered_studies = case_studies
        
        if category:
            filtered_studies = [cs for cs in filtered_studies if cs.category == category]
        
        if difficulty:
            filtered_studies = [cs for cs in filtered_studies if cs.difficulty_level == difficulty]
        
        if source:
            filtered_studies = [cs for cs in filtered_studies if cs.source.lower() == source.lower()]
        
        # Pagination
        total_count = len(filtered_studies)
        start_idx = (page - 1) * page_size
        end_idx = start_idx + page_size
        paginated_studies = filtered_studies[start_idx:end_idx]
        
        return CaseStudyResponse(
            case_studies=paginated_studies,
            total_count=total_count,
            page=page,
            page_size=page_size
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching case studies: {str(e)}")

@router.get("/case-studies/{case_id}")
async def get_case_study(
    case_id: str,
    current_user = Depends(get_current_user)
):
    """Get a specific case study by ID"""
    try:
        # Load case studies from CSV file
        csv_path = os.path.join(os.path.dirname(__file__), "..", "..", "..", "case_studies.csv")
        
        if os.path.exists(csv_path):
            with open(csv_path, 'r', encoding='utf-8') as file:
                reader = csv.DictReader(file)
                for i, row in enumerate(reader):
                    if str(i+1) == case_id and row['url'] and not any(error in row['summary'].lower() for error in ['error', 'forbidden', 'not found']):
                        # Parse content for better categorization
                        parsed_info = parse_sebi_content(row['summary'])
                        
                        # Determine source from URL
                        source_name = "SEBI" if "sebi.gov.in" in row['url'] else "NISM" if "nism.ac.in" in row['url'] else "Other"
                        
                        # Create title from URL
                        title = row['url'].split('/')[-2].replace('-', ' ').title() if '/' in row['url'] else f"Case Study {i+1}"
                        
                        return CaseStudy(
                            id=str(i+1),
                            title=title,
                            url=row['url'],
                            content=row['original'],
                            summary=row['summary'],
                            hindi_translation=row['hindi'] if row['hindi'] and not row['hindi'].startswith('[Hindi translation not available]') else None,
                            source=source_name,
                            category=parsed_info['categories'][0] if parsed_info['categories'] else "general",
                            difficulty_level=determine_difficulty(row['summary']),
                            tags=parsed_info['topics'],
                            created_at=datetime.utcnow(),
                            updated_at=datetime.utcnow()
                        )
        
        raise HTTPException(status_code=404, detail="Case study not found")
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching case study: {str(e)}")

@router.get("/case-studies/categories")
async def get_case_study_categories(current_user = Depends(get_current_user)):
    """Get available case study categories"""
    return {
        "categories": [
            {"value": "investor-education", "label": "Investor Education"},
            {"value": "regulations", "label": "Regulations & Guidelines"},
            {"value": "notices", "label": "Public Notices"},
            {"value": "innovation", "label": "Innovation & Technology"},
            {"value": "general", "label": "General"}
        ],
        "difficulty_levels": [
            {"value": "beginner", "label": "Beginner"},
            {"value": "intermediate", "label": "Intermediate"},
            {"value": "advanced", "label": "Advanced"}
        ],
        "sources": [
            {"value": "SEBI", "label": "Securities and Exchange Board of India"},
            {"value": "NISM", "label": "National Institute of Securities Markets"}
        ]
    }
