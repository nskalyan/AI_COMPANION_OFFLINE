from sqlalchemy.orm import Session
from ..models import Preference

def upsert_preferences(db: Session, user_id: int, tone: str = None, language: str = None, nudge_level: str = None):
    pref = db.query(Preference).filter(Preference.user_id == user_id).first()
    if not pref:
        pref = Preference(user_id=user_id)
        db.add(pref); db.commit(); db.refresh(pref)
    if tone is not None: pref.tone = tone
    if language is not None: pref.language = language
    if nudge_level is not None: pref.nudge_level = nudge_level
    db.commit(); db.refresh(pref)
    return pref
