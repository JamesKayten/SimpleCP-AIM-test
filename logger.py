"""
Comprehensive logging system for SimpleCP.

Provides structured logging with file output, console output,
and log rotation for debugging and monitoring.
"""

import logging
import logging.handlers
import os
from pathlib import Path
from typing import Optional
from datetime import datetime


class SimpleCPLogger:
    """
    Centralized logging system for SimpleCP.

    Features:
    - Multiple log levels (DEBUG, INFO, WARNING, ERROR, CRITICAL)
    - File-based logging with rotation
    - Console output
    - Structured formatting
    - Per-module loggers
    """

    def __init__(
        self,
        log_dir: Optional[str] = None,
        log_level: str = "INFO",
        max_file_size: int = 10 * 1024 * 1024,  # 10MB
        backup_count: int = 5,
    ):
        """
        Initialize logging system.

        Args:
            log_dir: Directory for log files (default: ./logs)
            log_level: Logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
            max_file_size: Maximum size of each log file before rotation
            backup_count: Number of backup log files to keep
        """
        self.log_dir = log_dir or os.path.join(
            os.path.dirname(__file__), "logs"
        )
        Path(self.log_dir).mkdir(parents=True, exist_ok=True)

        self.log_level = getattr(logging, log_level.upper(), logging.INFO)
        self.max_file_size = max_file_size
        self.backup_count = backup_count

        # Create main logger
        self.logger = logging.getLogger("SimpleCP")
        self.logger.setLevel(self.log_level)

        # Clear existing handlers
        self.logger.handlers.clear()

        # Set up handlers
        self._setup_file_handler()
        self._setup_console_handler()
        self._setup_error_handler()

    def _setup_file_handler(self):
        """Set up rotating file handler for general logs."""
        log_file = os.path.join(self.log_dir, "simplecp.log")
        file_handler = logging.handlers.RotatingFileHandler(
            log_file,
            maxBytes=self.max_file_size,
            backupCount=self.backup_count,
        )
        file_handler.setLevel(self.log_level)

        formatter = logging.Formatter(
            "%(asctime)s - %(name)s - %(levelname)s - %(module)s:%(lineno)d - %(message)s",
            datefmt="%Y-%m-%d %H:%M:%S",
        )
        file_handler.setFormatter(formatter)
        self.logger.addHandler(file_handler)

    def _setup_console_handler(self):
        """Set up console handler for real-time output."""
        console_handler = logging.StreamHandler()
        console_handler.setLevel(logging.WARNING)  # Only warnings+ to console

        formatter = logging.Formatter(
            "%(levelname)s: %(message)s",
        )
        console_handler.setFormatter(formatter)
        self.logger.addHandler(console_handler)

    def _setup_error_handler(self):
        """Set up separate handler for errors."""
        error_log = os.path.join(self.log_dir, "errors.log")
        error_handler = logging.handlers.RotatingFileHandler(
            error_log,
            maxBytes=self.max_file_size,
            backupCount=self.backup_count,
        )
        error_handler.setLevel(logging.ERROR)

        formatter = logging.Formatter(
            "%(asctime)s - %(levelname)s - %(module)s:%(lineno)d\n"
            "%(message)s\n"
            "%(exc_info)s\n",
            datefmt="%Y-%m-%d %H:%M:%S",
        )
        error_handler.setFormatter(formatter)
        self.logger.addHandler(error_handler)

    def get_logger(self, module_name: Optional[str] = None) -> logging.Logger:
        """
        Get logger for a specific module.

        Args:
            module_name: Name of the module (e.g., 'api.endpoints')

        Returns:
            Logger instance
        """
        if module_name:
            return logging.getLogger(f"SimpleCP.{module_name}")
        return self.logger

    def debug(self, message: str, **kwargs):
        """Log debug message."""
        self.logger.debug(message, **kwargs)

    def info(self, message: str, **kwargs):
        """Log info message."""
        self.logger.info(message, **kwargs)

    def warning(self, message: str, **kwargs):
        """Log warning message."""
        self.logger.warning(message, **kwargs)

    def error(self, message: str, exc_info=False, **kwargs):
        """Log error message."""
        self.logger.error(message, exc_info=exc_info, **kwargs)

    def critical(self, message: str, exc_info=True, **kwargs):
        """Log critical message."""
        self.logger.critical(message, exc_info=exc_info, **kwargs)

    def log_api_request(self, method: str, endpoint: str, status_code: int):
        """Log API request."""
        self.logger.info(
            f"API {method} {endpoint} - Status: {status_code}"
        )

    def log_clipboard_event(self, event_type: str, details: str = ""):
        """Log clipboard-related events."""
        self.logger.debug(f"Clipboard: {event_type} - {details}")

    def log_performance(self, operation: str, duration_ms: float):
        """Log performance metrics."""
        self.logger.info(f"Performance: {operation} took {duration_ms:.2f}ms")


# Global logger instance
_global_logger: Optional[SimpleCPLogger] = None


def get_logger(module_name: Optional[str] = None) -> logging.Logger:
    """
    Get global logger instance.

    Args:
        module_name: Optional module name for scoped logger

    Returns:
        Logger instance
    """
    global _global_logger
    if _global_logger is None:
        _global_logger = SimpleCPLogger()
    return _global_logger.get_logger(module_name)


def initialize_logging(log_dir: Optional[str] = None, log_level: str = "INFO"):
    """
    Initialize global logging system.

    Args:
        log_dir: Directory for log files
        log_level: Logging level
    """
    global _global_logger
    _global_logger = SimpleCPLogger(log_dir=log_dir, log_level=log_level)
