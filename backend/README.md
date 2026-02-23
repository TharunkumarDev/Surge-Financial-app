# Surge AI Backend Gateway

Secure AI gateway for Surge Financial App, powered by OpenAI GPT-4o mini.

## Features

- 🔐 Firebase Authentication
- 🚦 Redis-based rate limiting
- 🔒 Privacy-first data filtering
- 🤖 OpenAI GPT-4o mini integration
- 📊 Usage tracking
- 🎯 Pro/Free tier support

## Quick Start

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Get OpenAI API Key

1. Go to [platform.openai.com](https://platform.openai.com)
2. Sign up or log in
3. Navigate to API Keys
4. Create a new secret key
5. Copy the key (starts with `sk-`)

### 3. Configure Environment

```bash
cp .env.example .env
nano .env
```

**Required variables:**
```bash
# Firebase (from Firebase Console → Service Accounts)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@your-project.iam.gserviceaccount.com

# OpenAI (from platform.openai.com)
OPENAI_API_KEY=sk-your-api-key-here
OPENAI_MODEL=gpt-4o-mini
```

### 4. Start Redis (Optional for Development)

```bash
# Using Docker
docker run -d -p 6379:6379 redis:alpine

# Or using Homebrew (macOS)
brew install redis
brew services start redis
```

### 5. Run the Server

```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm start
```

You should see:
```
✅ OpenAI API connected
   Model: gpt-4o-mini
   Max tokens: 200
🚀 Surge AI Gateway started
   Environment: development
   Port: 3000
   AI Provider: OpenAI
```

## API Endpoints

### POST /api/v1/surge-ai/chat

Send a chat message and get AI response.

**Headers:**
```
Authorization: Bearer <firebase-id-token>
Content-Type: application/json
```

**Request:**
```json
{
  "message": "Where did my money go this month?",
  "sessionId": "optional-uuid"
}
```

**Response:**
```json
{
  "reply": "Most of your spending went to food (42%) and transport (28%)...",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "sessionId": "uuid"
}
```

**Error Response (Rate Limit):**
```json
{
  "error": "You've used all 5 AI chats today. Upgrade to Pro for unlimited conversations! 🚀",
  "retryAfter": 86400,
  "upgradePrompt": true
}
```

### GET /api/v1/surge-ai/health

Health check endpoint (no auth required).

### GET /api/v1/surge-ai/usage

Get user's AI usage stats (requires auth).

**Response:**
```json
{
  "tier": "free",
  "dailyLimit": 5,
  "dailyRemaining": 3,
  "dailyUsed": 2
}
```

## Rate Limits

| Tier | Daily Limit | Per-Minute Limit |
|------|-------------|------------------|
| Free | 5 requests  | 1 request        |
| Pro  | 100 requests| 10 requests      |

## Security

- ✅ All requests require Firebase authentication
- ✅ Rate limiting enforced per user
- ✅ PII automatically filtered before AI processing
- ✅ OpenAI API key server-side only
- ✅ No AI provider details exposed to clients

## Privacy Architecture

```
Flutter App
  ↓ (HTTPS + Firebase Token)
Backend Gateway
  ↓ (Privacy Filter)
Aggregated Data Only
  ↓ (OpenAI API)
GPT-4o mini
  ↓ (Response Sanitization)
Clean Text → Flutter
```

## Cost Estimation

**OpenAI GPT-4o mini pricing:**
- Input: $0.15 per 1M tokens
- Output: $0.60 per 1M tokens

**Example monthly costs:**
- 1,000 users × 5 chats/day × 30 days = 150,000 requests
- Average: 100 input tokens + 50 output tokens per request
- Cost: ~$3.75/month for AI

**Total infrastructure:**
- Backend hosting (Railway): $5-10/month
- Redis (Upstash free tier): $0
- OpenAI API: $3-10/month
- **Total: $8-20/month**

## Deployment

### Railway (Recommended)

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Initialize project
cd backend
railway init

# Add environment variables
railway variables set OPENAI_API_KEY=sk-your-key
railway variables set FIREBASE_PROJECT_ID=your-project
railway variables set FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----..."
railway variables set FIREBASE_CLIENT_EMAIL=your-email@project.iam.gserviceaccount.com
railway variables set NODE_ENV=production

# Add Redis (Upstash)
# Go to upstash.com, create database, get URL
railway variables set REDIS_URL=redis://default:password@host:port

# Deploy
railway up

# Get URL
railway domain
```

### Environment Variables (Production)

Set these in Railway:
- `OPENAI_API_KEY` - Your OpenAI API key
- `FIREBASE_PROJECT_ID` - Firebase project ID
- `FIREBASE_PRIVATE_KEY` - Firebase private key (with \n)
- `FIREBASE_CLIENT_EMAIL` - Firebase service account email
- `REDIS_URL` - Upstash Redis URL
- `NODE_ENV=production`
- `CORS_ORIGIN=*` (or your app domain)

## Testing

### Local Testing

```bash
# Start server
npm run dev

# In another terminal, test with curl
curl http://localhost:3000/api/v1/surge-ai/health

# Test chat (requires Firebase token)
curl -X POST http://localhost:3000/api/v1/surge-ai/chat \
  -H "Authorization: Bearer YOUR_FIREBASE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"message": "Hi"}'
```

### Production Testing

```bash
# Test deployed backend
curl https://your-backend.railway.app/api/v1/surge-ai/health
```

## Monitoring

### Logs

```bash
# Railway
railway logs --tail

# Check errors
railway logs | grep ERROR
```

### OpenAI Usage

Monitor your OpenAI usage at [platform.openai.com/usage](https://platform.openai.com/usage)

## Troubleshooting

**Problem:** "OpenAI API is not accessible"
```bash
# Check API key is set
echo $OPENAI_API_KEY

# Verify key is valid at platform.openai.com
```

**Problem:** "Firebase authentication failed"
```bash
# Verify Firebase credentials
railway variables | grep FIREBASE

# Check private key has \n characters
```

**Problem:** "Redis connection failed"
```bash
# Test Redis
redis-cli ping  # Should return PONG

# Or check Upstash dashboard
```

**Problem:** "Rate limiting not working"
```bash
# Check Redis is connected
railway logs | grep Redis

# Verify REDIS_URL is set
railway variables | grep REDIS
```

## Development

### Project Structure

```
backend/
├── src/
│   ├── config/
│   │   ├── index.js          # Environment configuration
│   │   └── firebase.js       # Firebase Admin SDK
│   ├── middleware/
│   │   ├── auth.js           # Firebase token verification
│   │   └── rate-limiter.js   # Redis rate limiting
│   ├── services/
│   │   ├── openai-client.js  # OpenAI API integration
│   │   ├── privacy-filter.js # PII removal
│   │   ├── prompt-builder.js # Prompt construction
│   │   └── ai-gateway.js     # Main orchestration
│   ├── routes/
│   │   └── surge-ai.js       # API endpoints
│   └── index.js              # Express server
├── package.json
├── .env.example
└── README.md
```

### Adding New Features

1. Update `prompt-builder.js` for new prompts
2. Add logic to `ai-gateway.js`
3. Create new routes in `routes/surge-ai.js`
4. Update Flutter `BackendAIService`

## License

MIT
