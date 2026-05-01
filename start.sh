#!/bin/bash
set -e
cd "$(dirname "$0")"

if [ ! -f .env ]; then
  echo "No .env file found. Copy .env.example and fill in your ANTHROPIC_API_KEY."
  exit 1
fi

if ! python3 -c "import fastapi" 2>/dev/null; then
  echo "Installing dependencies..."
  pip3 install -r backend/requirements.txt -q
fi

echo "Mosaic running at http://localhost:8000"
python3 -m uvicorn backend.main:app --reload --port 8000
