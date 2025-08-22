import os
from dotenv import load_dotenv
load_dotenv()

OLLAMA_BASE_URL = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "phi3:mini-4k")

APP_ENV = os.getenv("APP_ENV", "dev")
DEFAULT_TIMEZONE = os.getenv("DEFAULT_TIMEZONE", "Asia/Kolkata")
CONTEXT_WINDOW_MESSAGES = int(os.getenv("CONTEXT_WINDOW_MESSAGES", "5"))
REMINDER_CHECK_SECONDS = int(os.getenv("REMINDER_CHECK_SECONDS", "30"))
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./memory.db")
CORS_ORIGINS = [o.strip() for o in os.getenv("CORS_ORIGINS", "*").split(",")]
