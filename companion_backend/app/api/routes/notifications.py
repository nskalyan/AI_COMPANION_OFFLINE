from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from ...database import get_db
from ...services.reminders_service import list_notifications, ack_notification
from ...schemas import NotificationOut

router = APIRouter(prefix="/notifications", tags=["notifications"])

@router.get("/{user_id}", response_model=List[NotificationOut])
def get_notifications(user_id: int, db: Session = Depends(get_db)):
    return list_notifications(db, user_id)

@router.patch("/{notif_id}/ack")
def ack(notif_id: int, db: Session = Depends(get_db)):
    ok = ack_notification(db, notif_id)
    if not ok: raise HTTPException(404, "Notification not found")
    return {"acknowledged": True}
