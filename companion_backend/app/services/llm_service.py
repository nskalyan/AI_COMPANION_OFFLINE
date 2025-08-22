import requests
from ..config import OLLAMA_BASE_URL, OLLAMA_MODEL

def generate_response(prompt: str) -> str:
    try:
        r = requests.post(f"{OLLAMA_BASE_URL}/api/generate",
                          json={"model": OLLAMA_MODEL, "prompt": prompt, "stream": False},
                          timeout=60)
        if r.status_code == 200:
            return r.json().get("response", "").strip()
        return f"[LLM error {r.status_code}] {r.text}"
    except Exception as e:
        return f"[LLM unavailable] {e}"

def build_prompt(system: str, emotion: str, memory_snippet: str, preferences: dict, user_input: str) -> str:
    tone = preferences.get("tone", "friendly")
    language = preferences.get("language", "en")
    return f"""{system}

Tone: {tone}
Language: {language}
[Emotion]: {emotion}
[Memory]:
{memory_snippet}

User: {user_input}
Assistant:"""
