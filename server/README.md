# Waste Classification Backend (Gemini API Proxy)

This lightweight backend securely handles Gemini API calls for the **AI Waste Segregation** Flutter application.

### Why use a backend?

1. **Security**: Mobile apps are distributed binaries that can be decompiled. Storing the Gemini API key on a backend server keeps it completely confidential and prevents theft or abuse.
2. **Rate Limiting & Cost Control**: Centralizes request traffic, applies schema enforcement, and allows configuring quotas or caching if needed.
3. **Model Flexibility**: Lets you update model versions (e.g. from `gemini-1.5-flash` to `gemini-2.5-flash`) without requiring an app store update.

---

## 🚀 Quick Start

### 1. Obtain a Gemini API Key

1. Go to [Google AI Studio](https://aistudio.google.com/).
2. Create or select a project and generate an API key.

### 2. Configure Environment

Copy the example file to `.env`:

```bash
# Windows (PowerShell)
Copy-Item server/.env.example server/.env

# Linux / macOS
cp server/.env.example server/.env
```

Open `server/.env` and paste your key:

```env
GEMINI_API_KEY=AIzaSy...your_actual_api_key_here
GEMINI_MODEL=gemini-2.5-flash
PORT=8080
HOST=0.0.0.0
```

---

## 🏃 Running the Server

You can run either the **Dart** server (recommended for Flutter developers, no extra setup needed) or the **Node.js** server.

### Option A: Dart Server (Zero extra dependencies)

```bash
# From the project root:
dart run server/bin/server.dart
```

Or pass the key inline:
```powershell
# Windows PowerShell
$env:GEMINI_API_KEY="AIzaSy..."; dart run server/bin/server.dart
```
```bash
# Linux / macOS
GEMINI_API_KEY="AIzaSy..." dart run server/bin/server.dart
```

### Option B: Node.js Server (Node v18+)

```bash
# From the project root:
node server/server.js
```

Or pass the key inline:
```powershell
# Windows PowerShell
$env:GEMINI_API_KEY="AIzaSy..."; node server/server.js
```
```bash
# Linux / macOS
GEMINI_API_KEY="AIzaSy..." node server/server.js
```

---

## 🔍 Verification & Health Check

Test that the server is up and running:

```bash
# Windows PowerShell
Invoke-RestMethod http://localhost:8080/health

# curl
curl http://localhost:8080/health
```

Expected response:
```json
{
  "status": "ok",
  "service": "ai-waste-segregation-backend",
  "geminiConfigured": true,
  "model": "gemini-2.5-flash",
  "supportedCategories": [
    "Cardboard",
    "Glass",
    "Metal",
    "Paper",
    "Plastic",
    "Trash"
  ]
}
```

---

## 📱 Connecting from the Flutter Application

The Flutter application automatically resolves the backend URL based on platform:

- **Android Emulator**: `http://10.0.2.2:8080` (routes automatically to your host machine's `localhost:8080`)
- **iOS Simulator / Desktop / Web**: `http://localhost:8080`
- **Physical Device**: Connect phone to the same Wi-Fi network and pass your computer's local IP address:

```bash
flutter run --dart-define=CLASSIFIER_BACKEND_URL=http://192.168.1.100:8080
```

---

## 📋 API Specification

### `POST /classify`

**Request Body (`application/json`):**
```json
{
  "image": "<base64_encoded_image_bytes>",
  "mimeType": "image/jpeg"
}
```

**Success Response (`200 OK`):**
```json
{
  "identifiable": true,
  "category": "Metal",
  "confidence": 0.96,
  "description": "An aluminium beverage can with visible metallic sheen and recyclable tab.",
  "disposalInstructions": [
    "Empty any remaining liquid completely.",
    "Rinse with clean water.",
    "Crush if permitted locally to save bin space.",
    "Place into the metal recycling bin."
  ],
  "recyclable": true
}
```

**Unidentifiable Image Response (`200 OK`):**
```json
{
  "identifiable": false,
  "category": "Trash",
  "confidence": 0.0,
  "description": "Unable to identify a waste item in this image. Please take a clearer photo in good lighting.",
  "disposalInstructions": [
    "Retake a clear photo focused on the waste item."
  ],
  "recyclable": false
}
```
