from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .database import engine, Base
from .services.scheduler import start_scheduler
from .api.routes import users, chat, notes, reminders, preferences, notifications
from .config import CORS_ORIGINS

app = FastAPI(title="Companion Backend (Offline)")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create tables at startup
Base.metadata.create_all(bind=engine)

# Routes
app.include_router(users.router)
app.include_router(chat.router)
app.include_router(notes.router)
app.include_router(reminders.router)
app.include_router(preferences.router)
app.include_router(notifications.router)

@app.on_event("startup")
def on_startup():
    start_scheduler()

@app.get("/")
def root():
    return {"message": "Companion Backend running. See /docs for API."}
