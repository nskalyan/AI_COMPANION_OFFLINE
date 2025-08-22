from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ...database import get_db
from ...schemas import ReminderCreate, ReminderOut
from ...services.reminders_service import create_reminder, list_reminders, complete_reminder,delete_reminder
from typing import List

router = APIRouter(prefix="/reminders", tags=["reminders"])

@router.post("", response_model=ReminderOut)
def create(payload: ReminderCreate, db: Session = Depends(get_db)):
    r = create_reminder(db, payload.user_id, payload.title, payload.description or "", payload.due_at, payload.type, payload.is_recurring, payload.recurrence_rule)
    return r

@router.get("/{user_id}", response_model=List[ReminderOut])
def list_all(user_id: int, db: Session = Depends(get_db)):
    return list_reminders(db, user_id)

@router.post("/{reminder_id}/complete")
def complete(reminder_id: int, db: Session = Depends(get_db)):
    ok = complete_reminder(db, reminder_id)
    if not ok: raise HTTPException(404, "Reminder not found")
    return {"completed": True}

@router.delete("/{reminder_id}")
def delete(reminder_id: int, db: Session = Depends(get_db)):
    ok = delete_reminder(db, reminder_id)
    if not ok:
        raise HTTPException(404, "Reminder not found")
    return {"deleted": True}
