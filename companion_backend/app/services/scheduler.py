from apscheduler.schedulers.background import BackgroundScheduler
from sqlalchemy.orm import Session
from ..config import REMINDER_CHECK_SECONDS
from ..database import SessionLocal
from .reminders_service import queue_due_notifications

_scheduler = None

def _job():
    db: Session = SessionLocal()
    try:
        queue_due_notifications(db, horizon_seconds=REMINDER_CHECK_SECONDS)
    finally:
        db.close()

def start_scheduler():
    global _scheduler
    if _scheduler is None:
        sched = BackgroundScheduler()
        sched.add_job(_job, "interval", seconds=REMINDER_CHECK_SECONDS, id="reminder_checker", replace_existing=True)
        sched.start()
        _scheduler = sched
    return _scheduler
