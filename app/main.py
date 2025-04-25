import logging
import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes import router as api_router
from app.config import API_PREFIX, DEBUG, PROJECT_NAME, VERSION, HOST, PORT

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


def create_app() -> FastAPI:
    """Create FastAPI application"""
    app = FastAPI(
        title=PROJECT_NAME,
        description="Image Classification API",
        version=VERSION,
        debug=DEBUG,
    )

    # # Add CORS middleware
    # app.add_middleware(
    #     CORSMiddleware,
    #     allow_origins=["*"],
    #     allow_credentials=True,
    #     allow_methods=["*"],
    #     allow_headers=["*"],
    # )

    # Include API routes
    app.include_router(api_router, prefix=API_PREFIX)

    @app.get("/")
    async def root():
        """Root endpoint"""
        return {
            "name": PROJECT_NAME,
            "version": VERSION,
            "status": "running",
            "endpoints": {
                "api": f"{API_PREFIX}",
                "docs": "/docs"
            }
        }

    @app.get("/health")
    async def health():
        """Health check endpoint"""
        return {"status": "ok"}

    return app


def main():
    """Main entry point"""
    app = create_app()

    logger.info(f"Starting server at http://{HOST}:{PORT}")
    uvicorn.run(
        app,
        host=HOST,
        port=PORT,
    )


if __name__ == "__main__":
    main()
