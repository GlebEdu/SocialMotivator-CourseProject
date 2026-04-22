from fastapi import APIRouter

from app.api.routes import arbitration, auth, bets, evidence, goals, health, profile, users

api_router = APIRouter()
api_router.include_router(health.router)
api_router.include_router(auth.router, prefix="/auth")
api_router.include_router(profile.router, prefix="/profile")
api_router.include_router(users.router, prefix="/users")
api_router.include_router(goals.router, prefix="/goals")
api_router.include_router(bets.router, prefix="/bets")
api_router.include_router(evidence.router, prefix="/evidence")
api_router.include_router(arbitration.router, prefix="/arbitration")
