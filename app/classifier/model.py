import os
import tensorflow as tf
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input, decode_predictions
from tensorflow.keras.preprocessing import image
import numpy as np
import logging
from PIL import Image
import io

from app.config import MODEL_PATH, MODEL_NAME, IMAGE_SIZE, CONFIDENCE_THRESHOLD, MAX_RESULTS

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class ImageClassifier:
    def __init__(self):
        """Initialize the image classifier model"""
        logger.info("Loading model...")
        model_dir = os.path.join(MODEL_PATH, MODEL_NAME)
        if os.path.isdir(model_dir):
            logger.info(f"Loading saved model from {model_dir}")
            self.model = tf.keras.models.load_model(model_dir)
        else:
            logger.info("Saved model not found; loading pretrained MobileNetV2")
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
            img = Image.open(io.BytesIO(img_data))
            if img.mode != 'RGB':
                img = img.convert('RGB')
            img = img.resize(IMAGE_SIZE)
            img_array = image.img_to_array(img)
            img_array = np.expand_dims(img_array, axis=0)
            return preprocess_input(img_array)
        except Exception as e:
            logger.error(f"Error preprocessing image: {e}")
            raise

    def predict(self, img_data):
        """
        Classify the image

        Args:
            img_data: Raw image data (bytes)

        Returns:
            List of dicts with keys class_id, class_name, confidence
        """
        try:
            processed_img = self.preprocess_image(img_data)
            preds = self.model.predict(processed_img)
            results = decode_predictions(preds, top=MAX_RESULTS)[0]
            filtered = [
                {"class_id": cid, "class_name": name, "confidence": float(score)}
                for cid, name, score in results
                if score >= CONFIDENCE_THRESHOLD
            ]
            return filtered
        except Exception as e:
            logger.error(f"Error classifying image: {e}")
            raise


# Singleton instance
classifier = ImageClassifier()
