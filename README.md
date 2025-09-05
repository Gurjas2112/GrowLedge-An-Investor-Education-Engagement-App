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
- **Trading API**: Real-time stock data via Alpha Vantage
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
- **Firebase Admin SDK** (Authentication & Database)
- **Alpha Vantage API** (Stock Market Data)
- **Hugging Face API** (AI Summarization)
- **LibreTranslate** (Text Translation)
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
- Firebase Project
- API Keys (Alpha Vantage, Hugging Face)

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
   - Firebase service account credentials
   - Alpha Vantage API key
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
- Real-time stock data from Alpha Vantage API
- Portfolio management with buy/sell operations
- Performance analytics and profit/loss tracking

### AI-Powered Features
- Content summarization using Hugging Face models
- Multi-language translation support
- Text-to-speech for accessibility

### Gamification
- XP (Experience Points) system
- Achievement badges
- Leaderboards and progress tracking

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
