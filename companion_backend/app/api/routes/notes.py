from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ...database import get_db
from ...schemas import NoteCreate, NoteOut, NoteUpdate
from ...services.notes_service import create_note, list_notes, update_note, delete_note
from typing import List

router = APIRouter(prefix="/notes", tags=["notes"])

@router.post("", response_model=NoteOut)
def create(payload: NoteCreate, db: Session = Depends(get_db)):
    note = create_note(db, payload.user_id, payload.title, payload.content)
    return note

@router.get("/{user_id}", response_model=List[NoteOut])
def list_all(user_id: int, db: Session = Depends(get_db)):
    return list_notes(db, user_id)

@router.patch("/{note_id}", response_model=NoteOut)
def update(note_id: int, payload: NoteUpdate, db: Session = Depends(get_db)):
    note = update_note(db, note_id, payload.title, payload.content)
    if not note: raise HTTPException(404, "Note not found")
    return note

@router.delete("/{note_id}")
def remove(note_id: int, db: Session = Depends(get_db)):
    ok = delete_note(db, note_id)
    if not ok: raise HTTPException(404, "Note not found")
    return {"deleted": True}
