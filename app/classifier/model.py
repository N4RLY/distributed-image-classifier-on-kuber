import tensorflow as tf
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input, decode_predictions
from tensorflow.keras.preprocessing import image
import numpy as np
import logging
from PIL import Image
import io

from app.config import IMAGE_SIZE, CONFIDENCE_THRESHOLD, MAX_RESULTS

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class ImageClassifier:
    def __init__(self):
        """Initialize the image classifier model"""
        logger.info("Loading MobileNetV2 model...")
        self.model = MobileNetV2(weights='imagenet')
        logger.info("Model loaded successfully")

    def preprocess_image(self, img_data):
        """
        Preprocess the image for model input

        Args:
            img_data: Raw image data (bytes)

        Returns:
            Preprocessed image as numpy array
        """
        try:
            # Load image from bytes
            img = Image.open(io.BytesIO(img_data))

            # Convert to RGB if necessary (e.g., for PNG with alpha channel)
            if img.mode != 'RGB':
                img = img.convert('RGB')

            # Resize image to expected dimensions
            img = img.resize(IMAGE_SIZE)

            # Convert to array and preprocess
            img_array = image.img_to_array(img)
            img_array = np.expand_dims(img_array, axis=0)
            img_array = preprocess_input(img_array)

            return img_array

        except Exception as e:
            logger.error(f"Error preprocessing image: {str(e)}")
            raise

    def predict(self, img_data):
        """
        Classify the image

        Args:
            img_data: Raw image data (bytes)

        Returns:
            List of (class_name, class_description, score) tuples
        """
        try:
            # Preprocess the image
            processed_img = self.preprocess_image(img_data)

            # Make prediction
            preds = self.model.predict(processed_img)

            # Decode and filter predictions
            results = decode_predictions(preds, top=MAX_RESULTS)[0]

            # Filter by confidence threshold and format results
            filtered_results = [
                {
                    "class_id": class_id,
                    "class_name": class_name,
                    "confidence": float(score)
                }
                for class_id, class_name, score in results
                if score >= CONFIDENCE_THRESHOLD
            ]

            return filtered_results

        except Exception as e:
            logger.error(f"Error classifying image: {str(e)}")
            raise


# Create singleton instance
classifier = ImageClassifier()