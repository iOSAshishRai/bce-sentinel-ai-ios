from fastapi import FastAPI


app = FastAPI(
    title="BCE Sentinel AI Backend",
    description="Backend API for autonomous incident analysis",
    version="1.0.0"
)


@app.get("/")
def root():
    return {
        "service": "BCE Sentinel AI Backend",
        "status": "running",
        "version": "1.0.0"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }
