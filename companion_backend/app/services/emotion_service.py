from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer
_analyzer = SentimentIntensityAnalyzer()

def detect_emotion(text: str) -> str:
    s = _analyzer.polarity_scores(text or "")
    if s['compound'] >= 0.5: return "positive"
    if s['compound'] <= -0.5: return "negative"
    return "neutral"
