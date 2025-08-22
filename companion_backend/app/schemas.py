from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class UserCreate(BaseModel):
    external_id: str
    name: Optional[str] = None
    timezone: Optional[str] = None

class UserOut(BaseModel):
    id: int
    external_id: str
    name: Optional[str]
    timezone: str
    class Config:
        from_attributes = True

class ChatRequest(BaseModel):
    user_id: int
    user_input: str

class ChatResponse(BaseModel):
    response: str
    emotion: str

class NoteCreate(BaseModel):
    user_id: int
    title: str
    content: str

class NoteUpdate(BaseModel):
    title: Optional[str] = None
    content: Optional[str] = None

class NoteOut(BaseModel):
    id: int
    user_id: int
    title: str
    content: str
    created_at: datetime
    updated_at: datetime
    class Config:
        from_attributes = True

class ReminderCreate(BaseModel):
    user_id: int
    title: str
    description: Optional[str] = None
    due_at: datetime
    type: Optional[str] = "task"
    is_recurring: Optional[bool] = False
    recurrence_rule: Optional[str] = None

class ReminderOut(BaseModel):
    id: int
    user_id: int
    title: str
    description: Optional[str] = None
    due_at: datetime
    type: str
    is_recurring: bool
    recurrence_rule: Optional[str]
    status: str
    created_at: datetime
    class Config:
        from_attributes = True

class PreferenceUpdate(BaseModel):
    user_id: int
    tone: Optional[str] = None
    language: Optional[str] = None
    nudge_level: Optional[str] = None

class PreferenceOut(BaseModel):
    user_id: int
    tone: str
    language: str
    nudge_level: str
    class Config:
        from_attributes = True

class NotificationOut(BaseModel):
    id: int
    user_id: int
    reminder_id: Optional[int]
    content: str
    created_at: datetime
    sent_at: Optional[datetime]
    class Config:
        from_attributes = True
