from sqlalchemy.orm import Session
from ..config import CONTEXT_WINDOW_MESSAGES
from ..models import Memory, Preference, Reminder, ChatMessage
from datetime import datetime
from typing import Dict

def memory_snippet(db: Session, user_id: int) -> str:
    msgs = (db.query(Memory)
            .filter(Memory.user_id == user_id)
            .order_by(Memory.created_at.desc())
            .limit(CONTEXT_WINDOW_MESSAGES)
            .all())
    lines = [f"- {m.message} ({m.emotion or 'neutral'})" for m in reversed(msgs)]
    return "\n".join(lines)

def get_preferences(db: Session, user_id: int) -> Dict:
    pref = db.query(Preference).filter(Preference.user_id == user_id).first()
    if not pref:
        return {"tone": "friendly", "language": "en", "nudge_level": "gentle"}
    return {"tone": pref.tone, "language": pref.language, "nudge_level": pref.nudge_level}

def todays_agenda(db: Session, user_id: int) -> str:
    today = datetime.utcnow().date()
    reminders = (db.query(Reminder).filter(Reminder.user_id == user_id).all())
    todays = [r for r in reminders if r.due_at.date() == today and r.status == "pending"]
    if not todays:
        return "No scheduled items for today."
    return "\n".join([f"* {r.title} at {r.due_at.isoformat()} ({r.type})" for r in todays])

def save_chat(db: Session, user_id: int, role: str, content: str, emotion: str = None):
    msg = ChatMessage(user_id=user_id, role=role, content=content, emotion=emotion)
    db.add(msg)
    db.commit()
