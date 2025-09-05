import os
import requests
import pandas as pd
from firecrawl import FirecrawlApp
from dotenv import load_dotenv

# Load API keys
load_dotenv()
FIRECRAWL_KEY = os.getenv("FIRECRAWL_KEY")
HF_KEY = os.getenv("HF_KEY")

# Check if API keys are loaded
if not FIRECRAWL_KEY:
    raise ValueError("FIRECRAWL_KEY not found in environment variables")
if not HF_KEY:
    raise ValueError("HF_KEY not found in environment variables")

print(f"✅ Loaded API keys successfully")
print(f"🔑 Firecrawl key: {FIRECRAWL_KEY[:10]}...")
print(f"🔑 HuggingFace key: {HF_KEY[:10]}...")

# Init Firecrawl
app = FirecrawlApp(api_key=FIRECRAWL_KEY)

# Hugging Face endpoints
SUMMARIZER_URL = "https://api-inference.huggingface.co/models/facebook/bart-large-cnn"
TRANSLATOR_URL = "https://api-inference.huggingface.co/models/Helsinki-NLP/opus-mt-en-hi"
HEADERS = {"Authorization": f"Bearer {HF_KEY}"}

# Functions
def summarize_text(text):
    try:
        # Try HuggingFace first
        response = requests.post(SUMMARIZER_URL, headers=HEADERS, json={"inputs": text[:4000]})
        response.raise_for_status()
        result = response.json()
        if isinstance(result, list) and len(result) > 0:
            return result[0]["summary_text"]
        else:
            return create_simple_summary(text)
    except Exception as e:
        print(f"⚠️ HuggingFace summarization failed: {e}")
        print("📝 Using simple text summarization...")
        return create_simple_summary(text)

def create_simple_summary(text):
    """Create a simple summary by taking first few sentences"""
    sentences = text.split('. ')
    # Take first 3 meaningful sentences (longer than 20 chars)
    summary_sentences = []
    for sentence in sentences[:10]:
        if len(sentence.strip()) > 20:
            summary_sentences.append(sentence.strip())
        if len(summary_sentences) >= 3:
            break
    
    summary = '. '.join(summary_sentences)
    if not summary.endswith('.'):
        summary += '.'
    
    return summary if len(summary) > 50 else text[:500] + "..."

def translate_text(text):
    try:
        # Try HuggingFace first
        response = requests.post(TRANSLATOR_URL, headers=HEADERS, json={"inputs": text})
        response.raise_for_status()
        result = response.json()
        if isinstance(result, list) and len(result) > 0:
            return result[0]["translation_text"]
        else:
            return f"[Hindi translation not available] {text}"
    except Exception as e:
        print(f"⚠️ HuggingFace translation failed: {e}")
        print("📝 Translation service unavailable, keeping English...")
        return f"[Hindi translation not available] {text}"

def process_case_study(url):
    try:
        print(f"🔄 Scraping {url}...")
        # Try different Firecrawl method names
        if hasattr(app, 'scrape_url'):
            data = app.scrape_url(url)
        elif hasattr(app, 'scrape'):
            data = app.scrape(url)
        elif hasattr(app, 'scrape_website'):
            data = app.scrape_website(url)
        else:
            # List available methods
            methods = [method for method in dir(app) if not method.startswith('_')]
            print(f"Available methods: {methods}")
            raise ValueError("Could not find scraping method")
        
        # Check if scraping was successful
        if not data:
            raise ValueError("Failed to scrape URL - no data returned")
            
        # Handle different response formats
        if isinstance(data, dict):
            if "data" in data and "text" in data["data"]:
                raw_text = data["data"]["text"]
            elif "content" in data:
                raw_text = data["content"]
            elif "text" in data:
                raw_text = data["text"]
            else:
                print(f"Available keys in response: {list(data.keys())}")
                raw_text = str(data)
        else:
            raw_text = str(data)
            
        if not raw_text or len(raw_text.strip()) == 0:
            raise ValueError("No text content found")
            
        print(f"📄 Extracted {len(raw_text)} characters")
        
        print("🤖 Generating summary...")
        summary = summarize_text(raw_text)
        
        print("🔤 Translating to Hindi...")
        hindi = translate_text(summary)

        return {"url": url, "original": raw_text[:1000] + "...", "summary": summary, "hindi": hindi}
    
    except Exception as e:
        print(f"❌ Error processing {url}: {e}")
        return {"url": url, "original": "Error", "summary": "Error", "hindi": "Error"}

# Example SEBI/NISM pages (updated with working URLs)
urls = [
    "https://www.sebi.gov.in/investor-education.html",
    "https://www.nism.ac.in/about-us/",
    "https://www.sebi.gov.in/media/press-releases/",
    "https://www.sebi.gov.in/legal-framework/regulations/"
]

# Process all & save to CSV
records = []
for u in urls:
    try:
        records.append(process_case_study(u))
        print(f"✅ Processed {u}")
    except Exception as e:
        print(f"❌ Failed {u}: {e}")

df = pd.DataFrame(records)
df.to_csv("case_studies.csv", index=False, encoding="utf-8-sig")

print("📂 Saved as case_studies.csv")
