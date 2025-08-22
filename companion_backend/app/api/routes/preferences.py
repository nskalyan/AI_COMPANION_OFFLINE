from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ...database import get_db
from ...schemas import PreferenceUpdate, PreferenceOut
from ...services.preferences_service import upsert_preferences

router = APIRouter(prefix="/preferences", tags=["preferences"])

@router.post("", response_model=PreferenceOut)
def upsert(payload: PreferenceUpdate, db: Session = Depends(get_db)):
    pref = upsert_preferences(db, payload.user_id, payload.tone, payload.language, payload.nudge_level)
    return PreferenceOut(user_id=pref.user_id, tone=pref.tone, language=pref.language, nudge_level=pref.nudge_level)
