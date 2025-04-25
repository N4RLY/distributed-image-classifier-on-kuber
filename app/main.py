import logging
import uvicorn
import threading
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from prometheus_client import start_http_server

from app.api.routes import router as api_router
from app.api.middleware import PrometheusMiddleware
from app.config import (
    API_PREFIX, DEBUG, PROJECT_NAME, VERSION,
    HOST, PORT, METRICS_HOST, METRICS_PORT
)

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

    # Add Prometheus middleware
    app.add_middleware(PrometheusMiddleware)

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
                "docs": "/docs",
                "metrics": f"http://{METRICS_HOST}:{METRICS_PORT}",
            }
        }

    @app.get("/health")
    async def health():
        """Health check endpoint"""
        return {"status": "ok"}

    return app


def start_metrics_server():
    """Start Prometheus metrics server in a separate thread"""
    start_http_server(METRICS_PORT, METRICS_HOST)
    logger.info(f"Metrics server running at http://{METRICS_HOST}:{METRICS_PORT}")


def main():
    """Main entry point"""
    # Start metrics server in a separate thread
    metrics_thread = threading.Thread(target=start_metrics_server, daemon=True)
    metrics_thread.start()

    # Create application
    app = create_app()

    # Start application
    logger.info(f"Starting server at http://{HOST}:{PORT}")
    uvicorn.run(
        app,
        host=HOST,
        port=PORT,
    )


if __name__ == "__main__":
    main()