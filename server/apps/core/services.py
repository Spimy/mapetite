import logging
from typing import Literal
from google import genai

logger = logging.getLogger(__name__)


class GeminiService:
    _instance = None

    MODEL_FAST = "gemini-3.1-flash-lite"
    MODEL_ACCURATE = "gemini-3.5-flash"  # Have to stick to flash model which is the most accurate one available on free tier
    MODEL_EMBEDDING = "gemini-embedding-2"

    @classmethod
    def get_client(cls) -> genai.Client:
        if cls._instance is None:
            cls._instance = genai.Client()
            logger.info("Initialised Gemini API Client Singleton.")
        return cls._instance

    @classmethod
    def get_model(cls, model_type: Literal["fast", "accurate", "embedding"]) -> str:
        model = {
            "fast": cls.MODEL_FAST,
            "accurate": cls.MODEL_ACCURATE,
            "embedding": cls.MODEL_EMBEDDING,
        }.get(model_type)

        assert model is not None
        return model
