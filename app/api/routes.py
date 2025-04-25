import time
import logging
from fastapi import APIRouter, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse
from typing import Optional

from app.classifier.model import classifier
from app.classifier.utils import validate_image, format_prediction_result

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

        # Inference
        inference_start = time.time()
        predictions = classifier.predict(contents)
        inference_time = time.time() - inference_start
        logger.info(f"Model inference took {inference_time:.3f} seconds")

        # Limit results if top_k is specified
        if top_k is not None and 0 < top_k < len(predictions):
            predictions = predictions[:top_k]

        # Calculate total execution time
        execution_time = (time.time() - start_time) * 1000  # ms

        # Format response
        result = format_prediction_result(predictions, execution_time)

        return JSONResponse(content=result)

    except HTTPException:
        raise

    except Exception as e:
        logger.error(f"Error processing request: {e}")
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        await file.seek(0)