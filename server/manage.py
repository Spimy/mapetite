#!/usr/bin/env python
"""Django's command-line utility for administrative tasks."""
import os
import sys
from pathlib import Path

# --- DYNAMIC VERSION PARITY GUARDRAIL ---
try:
    BASE_DIR = Path(__file__).resolve().parent
    version_file = BASE_DIR / ".python-version"
    
    required_version_str = version_file.read_text().strip()
    req_major, req_minor = map(int, required_version_str.split('.')[:2])
    REQUIRED_VERSION = (req_major, req_minor)
    
    current_version = sys.version_info[:2]

    if current_version != REQUIRED_VERSION:
        sys.exit(
            f"\n🚨 FATAL ARCHITECTURE ERROR: Python Version Mismatch!\n"
            f"Mapetite requires Python {REQUIRED_VERSION[0]}.{REQUIRED_VERSION[1]}\n"
            f"You are running Python {current_version[0]}.{current_version[1]}\n"
            f"Please check the .python-version file and update your virtual environment.\n"
        )
except FileNotFoundError:
    sys.exit("\n🚨 FATAL: The .python-version file is missing from the server directory.\n")
except ValueError:
    sys.exit("\n🚨 FATAL: The .python-version file is formatted incorrectly.\n")
# ----------------------------------------

def main():
    """Run administrative tasks."""
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
    execute_from_command_line(sys.argv)

if __name__ == '__main__':
    main()