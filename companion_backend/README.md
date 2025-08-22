# Companion Backend (Offline, FastAPI + SQLite + Ollama)

Offline-first backend for a personal & productivity companion.

Features:
- Emotion-aware chat (local LLM via Ollama)
- User-specific memory (SQLite)
- Notes (CRUD), Reminders (with scheduler), Notifications queue
- Preferences (tone/language/nudge)
- CORS enabled (for Flutter)
- Notification ACK endpoint to prevent duplicates

## Quick Start
```bash
python -m venv .venv && source .venv/bin/activate     # Windows: .venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env                                   # edit if needed
ollama serve                                           # ensure your model is available
uvicorn app.main:app --reload
# Open http://127.0.0.1:8000/docs
```
