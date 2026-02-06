from fastapi import FastAPI

app = FastAPI(title="HabitBet API", version="0.1.0")


@app.get("/api/v1/health")
def health():
    return {"status": "ok"}
