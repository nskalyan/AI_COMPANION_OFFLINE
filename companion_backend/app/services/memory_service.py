from sqlalchemy.orm import Session
from ..models import Memory

def store_memory(db: Session, user_id: int, text: str, emotion: str):
    m = Memory(user_id=user_id, message=text, emotion=emotion)
    db.add(m)
    db.commit()
