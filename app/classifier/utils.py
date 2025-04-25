import os
import logging

# Параметры приложения (настроить при необходимости)
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}
MAX_IMAGE_SIZE = 5 * 1024 * 1024  # 5 MB

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def allowed_file(filename):
    """
    Check if the file has an allowed extension

    Args:
        filename: Name of the file to check

    Returns:
        True if file extension is allowed, False otherwise
    """
    if '.' not in filename:
        return False
    return filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def validate_image(file_content, filename):
    """
    Validate image file size and format

    Args:
        file_content: Content of the file as bytes
        filename: Name of the file

    Returns:
        Tuple (is_valid, message)
    """
    # Check file size
    content_length = len(file_content)
    if content_length > MAX_IMAGE_SIZE:
        max_size_mb = MAX_IMAGE_SIZE / (1024 * 1024)
        return False, f"File too large. Maximum size is {max_size_mb} MB"

    # Check file extension
    if not allowed_file(filename):
        return False, f"File format not supported. Allowed formats: {', '.join(ALLOWED_EXTENSIONS)}"

    return True, "Image is valid"

def format_prediction_result(prediction_result, execution_time):
    """
    Format the prediction result for API response

    Args:
        prediction_result: List of prediction dictionaries
        execution_time: Time taken for inference in ms

    Returns:
        Formatted response dictionary
    """
    return {
        "predictions": prediction_result,
        "metadata": {
            "execution_time_ms": execution_time,
            "model": "mobilenet_v2",
            "count": len(prediction_result)
        }
    }
