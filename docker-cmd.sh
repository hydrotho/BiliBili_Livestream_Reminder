#!/usr/bin/env bash

pip install -r requirements.txt

NUITKA_CACHE_DIR=".nuitka_cache" python -m nuitka --onefile --output-filename=BiliBili_Livestream_Reminder main.py
