# GrowLedge - Learn. Simulate. Grow.

A comprehensive investor education and engagement app built with Flutter frontend and FastAPI backend.

## Features

### Frontend (Flutter)
- **Authentication**: Splash screen, login/signup with Firebase Auth
- **Onboarding**: Interactive tutorial for new users
- **Dashboard**: Progress tracking, XP, badges, and quick actions
- **Lessons**: Multi-language investment education content
- **Quizzes**: Interactive assessments with scoring
- **Trading Simulator**: Virtual portfolio management with real stock data
- **AI Content Simplifier**: Text summarization and translation
- **Gamification**: XP system, badges, and achievements
- **Multi-language Support**: English, Hindi, Tamil, Spanish, French, German

### Backend (FastAPI)
- **Authentication**: JWT-based auth with Firebase integration
- **CRUD Operations**: Full data management for users, lessons, quizzes
- **Trading API**: Real-time stock data via Breeze Connect (ICICI Securities)
- **AI Services**: Content summarization, translation, text-to-speech
- **Cloud Storage**: Firebase Firestore and Storage integration

## Tech Stack

### Frontend
- **Flutter** (Dart)
- **Riverpod** (State Management)
- **Firebase SDK** (Auth, Firestore, Cloud Messaging, Storage)
- **Lottie** (Animations)
- **FL Chart** (Data Visualization)
- **Flutter TTS** (Text-to-Speech)
- **Glassmorphism UI** (Modern Design)

### Backend
- **FastAPI** (Python 3.11)
- **Mongo DB and JWT** (Authentication & Database)
- **Breeze Connect API** (ICICI Securities Trading & Market Data)
- **Hugging Face API** (AI Summarization)
- **Flutter translate library** (Text Translation)
- **gTTS** (Text-to-Speech Generation)

## Project Structure

```
GrowLedge/
├── frontend/                 # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart        # App entry point
│   │   ├── models/          # Data models
│   │   ├── services/        # External service integrations
│   │   ├── providers/       # State management
│   │   ├── screens/         # UI screens
│   │   └── widgets/         # Reusable components
│   ├── assets/              # Images, animations, icons
│   └── pubspec.yaml         # Dependencies
├── backend/                 # FastAPI backend
│   ├── app/
│   │   ├── main.py         # FastAPI application
│   │   ├── config.py       # Configuration
│   │   ├── auth/           # Authentication routes
│   │   ├── lessons/        # Lesson management
│   │   ├── quizzes/        # Quiz functionality
│   │   ├── trading/        # Trading simulator
│   │   └── ai/             # AI services
│   ├── requirements.txt    # Python dependencies
│   └── .env.example        # Environment template
└── README.md
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0+)
- Python 3.11+
- Breeze Connect API credentials (ICICI Securities)
- API Keys (Hugging Face)

### Backend Setup

1. **Navigate to backend directory**:
   ```bash
   cd backend
   ```

2. **Create virtual environment**:
   ```bash
   python -m venv venv
   venv\Scripts\activate  # Windows
   # source venv/bin/activate  # Linux/Mac
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure environment**:
   ```bash
   copy .env.example .env  # Windows
   # cp .env.example .env  # Linux/Mac
   ```

5. **Update .env file** with your:

   - Breeze Connect API credentials (API key, secret key, session token)
   - Hugging Face API key
   - JWT secret key

6. **Run the server**:
   ```bash
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

### Frontend Setup

1. **Navigate to frontend directory**:
   ```bash
   cd frontend
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Update Firebase configuration in the app

4. **Run the app**:
   ```bash
   flutter run
   ```

## API Documentation

Once the backend is running, visit:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## Key Features Detail

### Authentication System
- Firebase Auth integration for secure user management
- JWT token-based API authentication
- Support for email/password and social login

### Investment Education
- Structured lesson modules from basic to advanced topics
- Interactive quizzes with immediate feedback
- Progress tracking and gamification elements

### Virtual Trading
- Real-time stock data from Breeze Connect API (ICICI Securities)
- Portfolio management with buy/sell operations
- Performance analytics and profit/loss tracking
- Support for Indian stock market (NSE/BSE)
- Historical data analysis and charting

### AI-Powered Features
- Content summarization using Hugging Face models
- Multi-language translation support
- Text-to-speech for accessibility

### Gamification
- XP (Experience Points) system
- Achievement badges
- Leaderboards and progress tracking

## Breeze Connect Integration

GrowLedge integrates with **Breeze Connect API** from ICICI Securities to provide real-time Indian stock market data. This integration offers:

### Features
- **Real-time Stock Quotes**: Live prices for NSE and BSE stocks
- **Historical Data**: Access to historical price data for analysis
- **Stock Search**: Search functionality for Indian stocks
- **Popular Stocks**: Curated list of popular Indian stocks (RELIANCE, TCS, HDFCBANK, etc.)
- **Portfolio Performance**: Real-time portfolio valuation and P&L tracking
- **Market Status**: Live market status (open/closed) information
- **Demo Mode**: Fallback to mock data when API credentials are not available

### Configuration
The Breeze Connect integration supports both production and demo modes:
- **Production**: Uses real API credentials for live market data
- **Demo Mode**: Uses simulated data for development and testing
- **Rate Limiting**: Built-in rate limiting to respect API quotas
- **Caching**: Intelligent caching to optimize API usage

### Breeze API Capabilities
- Real-time stock quotes with bid/ask prices
- Historical data with configurable time periods
- Stock search with fuzzy matching
- Portfolio performance analytics
- Market status monitoring

## API Endpoints

### Authentication
- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `GET /auth/me` - Get current user

### Lessons
- `GET /lessons/` - List all lessons
- `GET /lessons/{lesson_id}` - Get specific lesson
- `PUT /lessons/{lesson_id}/progress` - Update progress

### Quizzes
- `GET /quizzes/lesson/{lesson_id}` - Get lesson quizzes
- `POST /quizzes/{quiz_id}/submit` - Submit quiz answers

### Trading
- `GET /trading/portfolio/{user_id}` - Get user portfolio
- `POST /trading/trade` - Execute trade
- `GET /trading/stock/{symbol}` - Get stock quote
- `GET /trading/quotes` - Get multiple stock quotes
- `GET /trading/historical/{symbol}` - Get historical data
- `GET /trading/search` - Search stocks
- `GET /trading/popular` - Get popular Indian stocks
- `GET /trading/portfolio/{user_id}/performance` - Get portfolio performance
- `GET /trading/market/status` - Get market status

### AI Services
- `POST /ai/summarize` - Summarize text content
- `POST /ai/translate` - Translate text
- `POST /ai/tts` - Generate speech audio

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the GitHub repository
- Contact the development team

---

**GrowLedge** - Empowering the next generation of investors through education, simulation, and growth.
Growledge is an innovative fintech learning app designed to empower retail investors with financial literacy. It offers interactive tutorials, gamified quizzes, vernacular translations, and a virtual trading simulator using delayed market data. Users can learn stock basics, risk assessment, algo trading, and portfolio diversification.
