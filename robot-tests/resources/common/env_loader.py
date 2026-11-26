"""Load the repository .env file for local Robot Framework runs.

Robot Framework imports resource libraries before it resolves the ``%{...}``
variables of the importing resource, so the import-time ``load_dotenv`` call
below runs before ``common_variables.resource`` reads the environment.
Process environment variables are never overridden, which keeps CI and
Jenkins configuration authoritative.
"""

from pathlib import Path

from dotenv import load_dotenv

# Restrict the names Robot's ModuleLibrary exposes as keywords.
__all__ = ["local_env_file_path"]

REPOSITORY_ROOT = Path(__file__).resolve().parents[3]
ENV_FILE = REPOSITORY_ROOT / ".env"

load_dotenv(dotenv_path=ENV_FILE, override=False)


def local_env_file_path() -> str:
    """Return the path of the local .env file used by the suite."""
    return str(ENV_FILE)
