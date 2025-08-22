from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ...schemas import ChatRequest, ChatResponse
from ...database import get_db
from ...services.emotion_service import detect_emotion
from ...services.context_service import memory_snippet, get_preferences, todays_agenda, save_chat
from ...services.llm_service import build_prompt, generate_response
from ...services.memory_service import store_memory

router = APIRouter(prefix="/chat", tags=["chat"])

SYSTEM_PROMPT = "You are an emotionally intelligent personal & productivity companion. Be empathetic, ethical, and helpful. Offer concise, actionable suggestions and respect user autonomy."

@router.post("", response_model=ChatResponse)
def chat(payload: ChatRequest, db: Session = Depends(get_db)):
    user_id = payload.user_id
    user_input = payload.user_input.strip()
    if not user_input:
        raise HTTPException(400, "Empty input")

    emotion = detect_emotion(user_input)
    store_memory(db, user_id, user_input, emotion)
    save_chat(db, user_id, role="user", content=user_input, emotion=emotion)

    mem = memory_snippet(db, user_id)
    prefs = get_preferences(db, user_id)
    agenda = todays_agenda(db, user_id)
    mem_plus = f"{mem}\n\nToday's agenda:\n{agenda}" if agenda else mem

    prompt = build_prompt(SYSTEM_PROMPT, emotion, mem_plus, prefs, user_input)
    reply = generate_response(prompt)

    save_chat(db, user_id, role="assistant", content=reply)
    return ChatResponse(response=reply, emotion=emotion)
