#!/bin/bash

set -e

ROOT_DIR="$(pwd)"
SERVICES_DIR="$ROOT_DIR/services"

echo "Setting up microservices project..."

# Ensure services directory exists
mkdir -p "$SERVICES_DIR"

clone_or_pull () {
  REPO_URL="$1"
  TARGET_DIR="$SERVICES_DIR/$2"

  if [ -d "$TARGET_DIR/.git" ]; then
    echo "$2 is a git repo. Pulling latest..."
    git -C "$TARGET_DIR" pull origin main

  elif [ -d "$TARGET_DIR" ]; then
    echo "$2 exists but is NOT a git repo. Re-cloning..."
    rm -rf "$TARGET_DIR"
    git clone "$REPO_URL" "$TARGET_DIR"

  else
    echo "Cloning $2..."
    git clone "$REPO_URL" "$TARGET_DIR"
  fi

  # Create .env if missing
  if [ -f "$TARGET_DIR/.env.example" ] && [ ! -f "$TARGET_DIR/.env" ]; then
    echo "Creating .env for $2"
    cp "$TARGET_DIR/.env.example" "$TARGET_DIR/.env"
  fi
}

clone_or_pull https://github.com/kiber/lab-js-jwt-auth-api.git lab-js-jwt-auth-api
clone_or_pull https://github.com/kiber/lab-js-notes-crud-api.git lab-js-notes-crud-api
clone_or_pull https://github.com/kiber/lab-js-notes-frontend.git lab-js-notes-frontend

echo "Starting Docker..."
docker compose up --build
