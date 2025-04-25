import time
from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
from fastapi.responses import JSONResponse
from typing import Optional
import logging

from app.classifier.model import classifier
from app.classifier.utils import validate_image, format_prediction_result
from app.api.middleware import INFERENCE_LATENCY

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create router
router = APIRouter()


@router.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "ok"}


@router.post("/classify")
async def classify_image(
        file: UploadFile = File(...),
        top_k: Optional[int] = None
):
    """
    Classify an image

    Args:
        file: Image file to classify
        top_k: Optional number of top predictions to return

    Returns:
        Classification results
    """
    try:
        start_time = time.time()

        # Read file content
        contents = await file.read()
        filename = file.filename

        # Validate image
        is_valid, message = validate_image(contents, filename)
        if not is_valid:
            raise HTTPException(status_code=400, detail=message)

        # Start inference timer
        inference_start = time.time()

        # Classify image
        predictions = classifier.predict(contents)

        # Record inference latency
        inference_time = time.time() - inference_start
        INFERENCE_LATENCY.observe(inference_time)

        # Limit results if top_k is specified
        if top_k is not None and 0 < top_k < len(predictions):
            predictions = predictions[:top_k]

        # Calculate total execution time
        execution_time = (time.time() - start_time) * 1000  # Convert to ms

        # Format response
        result = format_prediction_result(predictions, execution_time)

        return JSONResponse(content=result)

    except HTTPException as e:
        # Re-raise HTTP exceptions
        raise

    except Exception as e:
        logger.error(f"Error processing request: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        # Reset file position
        await file.seek(0)


@router.get("/metrics/summary")
async def get_metrics_summary():
    """
    Get a summary of application metrics

    Returns:
        Summary of request and inference metrics
    """
    # This is a simplified example. In a real application,
    # you would get actual metrics from Prometheus
    return {
        "status": "ok",
        "metrics": {
            "total_requests": "Use Prometheus endpoint for actual metrics",
            "average_latency": "Use Prometheus endpoint for actual metrics",
            "inference_time": "Use Prometheus endpoint for actual metrics"
        }
    }