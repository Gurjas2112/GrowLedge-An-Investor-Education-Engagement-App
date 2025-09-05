# Configuration package for GrowLedge backend
from .breeze_config import BreezeConfig
from .settings import Settings

# Create settings instance
settings = Settings()

__all__ = ["BreezeConfig", "settings"]
