from sqlalchemy.orm import Session
from ..models import Reminder, Notification
from datetime import datetime, timedelta

def create_reminder(db: Session, user_id: int, title: str, description: str, due_at, rtype: str, is_recurring: bool, recurrence_rule: str):
    r = Reminder(user_id=user_id, title=title, description=description or "", due_at=due_at,
                 type=rtype or "task", is_recurring=is_recurring or False, recurrence_rule=recurrence_rule)
    db.add(r); db.commit(); db.refresh(r)
    return r

def list_reminders(db: Session, user_id: int):
    return db.query(Reminder).filter(Reminder.user_id == user_id).order_by(Reminder.due_at.asc()).all()

def complete_reminder(db: Session, reminder_id: int) -> bool:
    r = db.query(Reminder).filter(Reminder.id == reminder_id).first()
    if not r: return False
    r.status = "done"
    db.commit()
    return True

def queue_due_notifications(db: Session, horizon_seconds: int = 60):
    now = datetime.utcnow()
    horizon = now + timedelta(seconds=horizon_seconds)
    due = db.query(Reminder).filter(Reminder.status == "pending").all()
    for r in due:
        if now <= r.due_at <= horizon:
            existing = db.query(Notification).filter(Notification.reminder_id == r.id).first()
            if not existing:
                content = f"Reminder: {r.title} due at {r.due_at.isoformat()}"
                n = Notification(user_id=r.user_id, reminder_id=r.id, content=content)
                db.add(n)
    db.commit()

def list_notifications(db: Session, user_id: int):
    return db.query(Notification).filter(Notification.user_id == user_id).order_by(Notification.created_at.desc()).all()

def ack_notification(db: Session, notif_id: int) -> bool:
    n = db.query(Notification).filter(Notification.id == notif_id).first()
    if not n: return False
    if n.sent_at is None:
        n.sent_at = datetime.utcnow()
        db.commit()
    return True


def delete_reminder(db: Session, reminder_id: int) -> bool:
    reminder = db.query(Reminder).filter(Reminder.id == reminder_id).first()
    if not reminder:
        return False
    db.delete(reminder)
    db.commit()
    return True
