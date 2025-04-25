import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# API Configuration
API_PREFIX = "/api/v1"
DEBUG = os.getenv("DEBUG", "False").lower() in ("true", "1", "t")
PROJECT_NAME = "Image Classification Service"
VERSION = "0.1.0"

# Model Configuration
MODEL_PATH = os.getenv("MODEL_PATH", "./classifier/model")
MODEL_NAME = os.getenv("MODEL_NAME", "mobilenet_v2")
IMAGE_SIZE = (224, 224)  # Default for MobileNet

# Server Configuration
HOST = os.getenv("HOST", "0.0.0.0")
PORT = int(os.getenv("PORT", "8000"))

# Prometheus Metrics
METRICS_PORT = int(os.getenv("METRICS_PORT", "8001"))
METRICS_HOST = os.getenv("METRICS_HOST", "0.0.0.0")

# Classification Configuration
CONFIDENCE_THRESHOLD = float(os.getenv("CONFIDENCE_THRESHOLD", "0.5"))
MAX_RESULTS = int(os.getenv("MAX_RESULTS", "5"))

# Images Configuration
ALLOWED_EXTENSIONS = {"jpg", "jpeg", "png"}
MAX_IMAGE_SIZE = int(os.getenv("MAX_IMAGE_SIZE", str(10 * 1024 * 1024)))  # 10MB