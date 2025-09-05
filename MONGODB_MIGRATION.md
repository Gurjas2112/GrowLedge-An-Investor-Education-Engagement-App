# GrowLedge MongoDB Migration Guide

## 🔄 Migration from Firebase to MongoDB

This guide explains the complete migration from Firebase to MongoDB for the GrowLedge backend.

## 📋 What Changed

### 🔥 **Removed (Firebase)**
- Firebase Admin SDK
- Firebase Authentication
- Firestore Database
- Firebase Storage

### 🍃 **Added (MongoDB)**
- MongoDB with Motor (async driver)
- JWT-based authentication
- Pydantic models with BSON support
- Password hashing with bcrypt
- Local file storage for TTS

## 🛠 Setup Instructions

### 1. Install MongoDB

**Option A: Local MongoDB**
```bash
# Windows (using Chocolatey)
choco install mongodb

# macOS (using Homebrew)
brew tap mongodb/brew
brew install mongodb-community

# Ubuntu/Debian
sudo apt-get install mongodb
```

**Option B: MongoDB Atlas (Cloud)**
1. Sign up at [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Create a new cluster
3. Get your connection string

### 2. Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 3. Configure Environment

Copy `.env.example` to `.env` and update:

```bash
# MongoDB Configuration
MONGODB_URL=mongodb://localhost:27017/growledgedb
# For MongoDB Atlas: mongodb+srv://username:password@cluster.mongodb.net/growledgedb
MONGODB_DATABASE=growledgedb

# JWT Configuration
JWT_SECRET_KEY=your-super-secret-key-change-this-in-production
JWT_ALGORITHM=HS256
JWT_EXPIRATION_HOURS=24

# API Keys (keep your existing values)
ALPHA_VANTAGE_API_KEY=your-alpha-vantage-key
HUGGING_FACE_API_KEY=your-hugging-face-key

```

### 4. Initialize Database

```bash
cd backend
python setup_mongodb.py
```

This will:
- Create database indexes
- Insert sample lessons and quizzes
- Set up collections

### 5. Start the Server

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## 🔐 Authentication Changes

### Old (Firebase)
```javascript
// Frontend had to use Firebase SDK
import { signInWithEmailAndPassword } from 'firebase/auth';
```

### New (JWT)
```dart
// Frontend now uses standard HTTP requests
final response = await http.post(
  Uri.parse('$baseUrl/auth/login'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'email': email,
    'password': password,
  }),
);
```

## 📊 Database Structure

### Collections

1. **users**
   ```json
   {
     "_id": ObjectId,
     "uid": "unique_user_id",
     "email": "user@example.com",
     "name": "User Name",
     "password_hash": "bcrypt_hash",
     "preferred_language": "English",
     "xp_points": 0,
     "badges": [],
     "completed_lessons": [],
     "quiz_scores": {},
     "created_at": Date,
     "updated_at": Date
   }
   ```

2. **lessons**
   ```json
   {
     "_id": ObjectId,
     "title": "Lesson Title",
     "description": "Lesson Description",
     "category": "Basics",
     "difficulty": "Beginner",
     "duration_minutes": 15,
     "content": [
       {
         "language": "English",
         "title": "English Title",
         "description": "English Description",
         "content": "Lesson content..."
       }
     ],
     "prerequisites": [],
     "learning_objectives": [],
     "created_at": Date,
     "updated_at": Date
   }
   ```

3. **quizzes**
   ```json
   {
     "_id": ObjectId,
     "lesson_id": "lesson_object_id",
     "title": "Quiz Title",
     "questions": [
       {
         "question": "Question text?",
         "options": [
           {"text": "Option 1", "is_correct": false},
           {"text": "Option 2", "is_correct": true}
         ],
         "explanation": "Explanation text"
       }
     ],
     "pass_score": 70,
     "time_limit_minutes": 15
   }
   ```

4. **portfolios**
   ```json
   {
     "_id": ObjectId,
     "user_id": "user_uid",
     "cash_balance": 10000.0,
     "holdings": {"AAPL": 10, "GOOGL": 5},
     "total_value": 12500.0,
     "created_at": Date,
     "updated_at": Date
   }
   ```

5. **trades**
   ```json
   {
     "_id": ObjectId,
     "user_id": "user_uid",
     "symbol": "AAPL",
     "type": "BUY",
     "quantity": 10,
     "price": 150.0,
     "total_amount": 1500.0,
     "timestamp": Date
   }
   ```

## 🔧 API Endpoints

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user
- `GET /auth/me` - Get current user
- `PUT /auth/me` - Update current user
- `POST /auth/verify-token` - Verify JWT token

### Lessons
- `GET /lessons/` - Get all lessons (with filters)
- `GET /lessons/{id}` - Get specific lesson
- `POST /lessons/` - Create lesson (admin)
- `PUT /lessons/{id}/progress` - Mark lesson complete
- `DELETE /lessons/{id}` - Delete lesson (admin)

### Quizzes
- `GET /quizzes/lesson/{lesson_id}` - Get lesson quizzes
- `POST /quizzes/{quiz_id}/submit` - Submit quiz answers

### Trading
- `GET /trading/portfolio/{user_id}` - Get user portfolio
- `POST /trading/trade` - Execute trade
- `GET /trading/stock/{symbol}` - Get stock quote

### AI Services
- `POST /ai/summarize` - Summarize text
- `POST /ai/translate` - Translate text
- `POST /ai/tts` - Generate speech audio

## 🚀 Frontend Updates Needed

### 1. Remove Firebase Dependencies

Remove from `pubspec.yaml`:
```yaml
# Remove these
firebase_core: ^x.x.x
firebase_auth: ^x.x.x
cloud_firestore: ^x.x.x
```

### 2. Update Authentication Service

Replace Firebase auth with HTTP requests:

```dart
class ApiService {
  static const String baseUrl = 'http://localhost:8000';
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login failed');
    }
  }
  
  Future<Map<String, dynamic>> register(
    String email, 
    String password, 
    String name,
    String preferredLanguage,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'preferred_language': preferredLanguage,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Registration failed');
    }
  }
}
```

### 3. Update Data Models

Update models to work with MongoDB ObjectId strings instead of Firebase document IDs.

## 🔒 Security Features

- **Password Hashing**: Uses bcrypt for secure password storage
- **JWT Tokens**: Stateless authentication with configurable expiration
- **Input Validation**: Pydantic models validate all API inputs
- **CORS Configuration**: Configurable allowed origins
- **Database Indexing**: Optimized queries with proper indexes

## 🧪 Testing

### Manual Testing

1. **Register a user**:
   ```bash
   curl -X POST "http://localhost:8000/auth/register" \
     -H "Content-Type: application/json" \
     -d '{
       "email": "test@example.com",
       "password": "password123",
       "name": "Test User",
       "preferred_language": "English"
     }'
   ```

2. **Login**:
   ```bash
   curl -X POST "http://localhost:8000/auth/login" \
     -H "Content-Type: application/json" \
     -d '{
       "email": "test@example.com",
       "password": "password123"
     }'
   ```

3. **Get lessons**:
   ```bash
   curl "http://localhost:8000/lessons/"
   ```

### API Documentation

Visit `http://localhost:8000/docs` for interactive API documentation.

## 🔄 Migration Benefits

1. **Cost Reduction**: No Firebase usage costs
2. **Full Control**: Complete control over database and authentication
3. **Flexibility**: Easy to modify database schema
4. **Performance**: Optimized queries with custom indexes
5. **Portability**: Can run on any server or cloud provider
6. **Open Source**: No vendor lock-in

## 🛠 Troubleshooting

### Common Issues

1. **MongoDB Connection Failed**
   - Ensure MongoDB is running: `sudo systemctl start mongod`
   - Check connection string in `.env`

2. **Import Errors**
   - Ensure all dependencies are installed: `pip install -r requirements.txt`
   - Check Python path and virtual environment

3. **JWT Token Issues**
   - Verify JWT_SECRET_KEY is set in `.env`
   - Check token expiration settings

### Logs

Check server logs for detailed error information:
```bash
uvicorn main:app --reload --log-level debug
```

## 📞 Support

For migration support or issues:
1. Check the logs for detailed error messages
2. Verify all environment variables are set correctly
3. Ensure MongoDB is running and accessible
4. Test API endpoints using the provided curl commands

---

**🎉 Migration Complete!** Your GrowLedge app now runs on MongoDB with enhanced security and flexibility.
