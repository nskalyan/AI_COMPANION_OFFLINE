from sqlalchemy.orm import Session
from ..models import Note
from datetime import datetime

def create_note(db: Session, user_id: int, title: str, content: str):
    note = Note(user_id=user_id, title=title, content=content)
    db.add(note); db.commit(); db.refresh(note)
    return note

def list_notes(db: Session, user_id: int):
    return (db.query(Note)
            .filter(Note.user_id == user_id)
            .order_by(Note.updated_at.desc())
            .all())

def update_note(db: Session, note_id: int, title: str = None, content: str = None):
    note = db.query(Note).filter(Note.id == note_id).first()
    if not note: return None
    if title is not None: note.title = title
    if content is not None: note.content = content
    note.updated_at = datetime.utcnow()
    db.commit(); db.refresh(note)
    return note

def delete_note(db: Session, note_id: int) -> bool:
    note = db.query(Note).filter(Note.id == note_id).first()
    if not note: return False
    db.delete(note); db.commit()
    return True
