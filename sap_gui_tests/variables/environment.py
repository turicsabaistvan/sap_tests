"""Robot Framework variable file for SAP connection settings.

Values come from environment variables, falling back to the project-level .env
file. Credentials are never hardcoded in test or resource files.
"""
import os
from pathlib import Path

from dotenv import load_dotenv

PROJECT_ROOT = Path(__file__).resolve().parents[1]
load_dotenv(PROJECT_ROOT / ".env")

DEFAULTS = {
    "SAPSHCUT_EXE": r"C:\Program Files\SAP\FrontEnd\SAPgui\sapshcut.exe",
    "SAP_LANG": "EN",
}


def _setting(name):
    value = os.getenv(name, DEFAULTS.get(name, ""))
    if not value:
        raise ValueError(
            f"Missing SAP connection setting '{name}'. Define it in the environment "
            f"or in {PROJECT_ROOT / '.env'}."
        )
    return value


def get_variables():
    return {
        "SAPSHCUT_EXE": _setting("SAPSHCUT_EXE"),
        "SAP_APP_SERVER": _setting("SAP_APP_SERVER"),
        "SAP_SYS_ID": _setting("SAP_SYS_ID"),
        "SAP_SYS_NUM": _setting("SAP_SYS_NUM"),
        "SAP_CLIENT": _setting("SAP_CLIENT"),
        "SAP_USER": _setting("SAP_USER"),
        "SAP_PASS": _setting("SAP_PASS"),
        "SAP_LANG": _setting("SAP_LANG"),
    }
