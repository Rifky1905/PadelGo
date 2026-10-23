#!/bin/bash
# ============================================================
# Build script Vercel untuk PadelGo (Flutter web).
# Vercel tidak punya preset Flutter — script ini mengunduh
# Flutter SDK stable lalu build release ke build/web.
# ============================================================
set -e

echo "== Mengunduh Flutter SDK (stable) =="
git clone https://github.com/flutter/flutter.git \
  -b stable --depth 1 flutter_sdk

export PATH="$PWD/flutter_sdk/bin:$PATH"

flutter config --no-analytics --suppress-analytics
flutter precache --web

echo "== flutter doctor =="
flutter --version

echo "== Install dependencies =="
flutter pub get

echo "== Build web release =="
flutter build web --release

echo "== Selesai — output di build/web =="
