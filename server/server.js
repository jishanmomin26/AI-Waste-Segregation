#!/usr/bin/env node
/**
 * AI Waste Segregation - Gemini API Proxy Server (Node.js)
 * 
 * Runs with standard Node.js (v18+) without requiring external npm packages.
 */

const http = require('http');
const fs = require('fs');
const path = require('path');

const SUPPORTED_CATEGORIES = [
  'Cardboard',
  'Glass',
  'Metal',
  'Paper',
  'Plastic',
  'Trash',
];

const CLASSIFY_ROUTES = new Set([
  '/classify',
  '/api/classify',
  '/v1/classify',
]);

const HEALTH_ROUTES = new Set([
  '/',
  '/health',
  '/api/health',
]);

const GEMINI_SYSTEM_INSTRUCTION = `
You are an expert waste segregation and recycling AI assistant.
Analyze the provided image and classify the primary waste or discarded object into EXACTLY ONE of the six supported categories:
- Cardboard: Packaging boxes, corrugated cardboard, cardboard egg cartons, heavy paperboard cartons.
- Glass: Glass beverage bottles, food jars, glassware.
- Metal: Aluminum cans, steel/tin food cans, metal lids, clean foil trays, aerosol cans.
- Paper: Office paper, newspapers, magazines, mail, paper bags, unsoiled paper wrapping.
- Plastic: Plastic bottles, jugs, food tubs, plastic containers, rigid packaging plastics.
- Trash: General non-recyclable refuse, broken ceramics, dirty items, composite unrecyclable packaging, heavily food-soiled packaging, or items that must go to landfill.

Strict Guidelines:
1. Identify Primary Waste Item: Focus on the single prominent discarded item in the foreground. Ignore hands, tables, flooring, shadows, and background clutter.
2. Distinguish Material from Color and Background: Carefully distinguish actual material composition from color or reflection (e.g. silver plastic pouch is Plastic not Metal, transparent plastic is Plastic not Glass, metallic beverage can is Metal).
3. Identifiability Check: If the photo is too dark, blurry, does not contain an identifiable waste item, or shows a completely unrelated object/person:
   - Set "identifiable": false
   - Set "category": "Trash"
   - Set "confidence": 0.0
   - Set "recyclable": false
   - Set "description": "Unable to identify a waste item in this image. Please take a clearer photo in good lighting."
   - Set "disposalInstructions": ["Retake a clear photo focused on the waste item."]
4. When Identifiable:
   - Set "identifiable": true
   - Set "category" to exactly one of: ["Cardboard", "Glass", "Metal", "Paper", "Plastic", "Trash"]
   - Set "confidence": Realistic score between 0.0 and 1.0 (e.g. 0.85-0.98 for clear items). Do not fabricate 1.0 unless 100% certain.
   - Set "recyclable": true for standard curbside recyclables (Cardboard, Glass, Metal, Paper, clean Plastic), false for Trash.
   - Set "description": 1-2 concise, clear sentences explaining what the item is and its material.
   - Set "disposalInstructions": 3-4 specific, actionable bullet steps on how to prepare and properly dispose or recycle the item.
`;

function loadDotEnv(filePath) {
  try {
    if (fs.existsSync(filePath)) {
      const content = fs.readFileSync(filePath, 'utf8');
      for (const line of content.split(/\r?\n/)) {
        const trimmed = line.trim();
        if (!trimmed || trimmed.startsWith('#')) continue;
        const eqIdx = trimmed.indexOf('=');
        if (eqIdx > 0) {
          const key = trimmed.slice(0, eqIdx).trim();
          let val = trimmed.slice(eqIdx + 1).trim();
          if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'"))) {
            val = val.slice(1, -1);
          }
          if (!process.env[key]) {
            process.env[key] = val;
          }
        }
      }
    }
  } catch (_) {}
}

loadDotEnv(path.join(process.cwd(), '.env'));
loadDotEnv(path.join(__dirname, '.env'));

const PORT = parseInt(process.env.PORT || '8080', 10);
const HOST = process.env.HOST || '0.0.0.0';
const GEMINI_API_KEY = (process.env.GEMINI_API_KEY || '').trim();
let GEMINI_MODEL = (process.env.GEMINI_MODEL || 'gemini-flash-lite-latest').trim();

if (GEMINI_MODEL === 'gemini-2.5-flash' || GEMINI_MODEL === 'gemini-1.5-flash' || GEMINI_MODEL === 'gemini-2.0-flash') {
  console.warn(`NOTE: ${GEMINI_MODEL} is deprecated by Google API. Using gemini-flash-lite-latest.`);
  GEMINI_MODEL = 'gemini-flash-lite-latest';
}

function normalizeRoutePath(rawPath) {
  let p = (rawPath || '').trim();
  const qIdx = p.indexOf('?');
  if (qIdx !== -1) p = p.slice(0, qIdx);
  p = p.replace(/\/+/g, '/');
  if (p.length > 1 && p.endsWith('/')) {
    p = p.slice(0, -1);
  }
  return p.toLowerCase();
}

function sendJson(res, statusCode, data) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization, X-Requested-With',
    'Access-Control-Max-Age': '86400',
  });
  res.end(JSON.stringify(data));
}

function normalizeCategory(cat) {
  const lower = (cat || '').trim().toLowerCase();
  for (const c of SUPPORTED_CATEGORIES) {
    if (c.toLowerCase() === lower) return c;
  }
  return 'Trash';
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  const rawPath = url.pathname;
  const normalizedPath = normalizeRoutePath(rawPath);

  const isClassify = CLASSIFY_ROUTES.has(normalizedPath);
  const isHealth = HEALTH_ROUTES.has(normalizedPath);
  const routeExists = isClassify || isHealth;

  console.log(`[${new Date().toISOString().slice(11, 19)}] ${req.method} ${rawPath} (matched: ${routeExists})`);

  // 1. If route does not exist, return 404 for all methods including OPTIONS
  // so preflight does not mask missing routes.
  if (!routeExists) {
    return sendJson(res, 404, {
      error: `Route not found: ${req.method} ${rawPath}`,
      requestedPath: rawPath,
      normalizedPath: normalizedPath,
      supportedRoutes: ['GET /health', 'POST /classify'],
    });
  }

  // 2. Handle CORS preflight OPTIONS
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization, X-Requested-With',
      'Access-Control-Max-Age': '86400',
    });
    return res.end();
  }

  if (req.method === 'GET') {
    if (isHealth) {
      return sendJson(res, 200, {
        status: 'ok',
        service: 'ai-waste-segregation-backend',
        geminiConfigured: Boolean(GEMINI_API_KEY),
        model: GEMINI_MODEL,
        supportedCategories: SUPPORTED_CATEGORIES,
        routes: ['GET /health', 'POST /classify'],
      });
    }
    return sendJson(res, 405, { error: `Method not allowed. Use POST for ${rawPath}` });
  }

  if (req.method === 'POST') {
    if (!isClassify) {
      return sendJson(res, 405, { error: `Method not allowed. Use GET for ${rawPath}` });
    }

    if (!GEMINI_API_KEY) {
      return sendJson(res, 500, {
        error: 'GEMINI_API_KEY is not configured on the backend server. Please set it in your environment or server/.env file.',
      });
    }

    const chunks = [];
    req.on('data', chunk => chunks.push(chunk));
    req.on('end', async () => {
      try {
        const bodyBuffer = Buffer.concat(chunks);
        let base64Image = '';
        let mimeType = 'image/jpeg';

        const contentType = req.headers['content-type'] || '';
        if (contentType.includes('application/json')) {
          const parsed = JSON.parse(bodyBuffer.toString('utf8') || '{}');
          base64Image = parsed.image || '';
          mimeType = parsed.mimeType || 'image/jpeg';
        } else {
          base64Image = bodyBuffer.toString('base64');
          if (contentType.includes('image/png')) mimeType = 'image/png';
          else if (contentType.includes('image/webp')) mimeType = 'image/webp';
        }

        if (base64Image.includes(',')) {
          const parts = base64Image.split(',');
          if (parts[0].includes('image/png')) mimeType = 'image/png';
          else if (parts[0].includes('image/webp')) mimeType = 'image/webp';
          base64Image = parts[1];
        }

        base64Image = base64Image.trim();

        if (!base64Image) {
          return sendJson(res, 400, { error: 'No image data provided. Please provide an image.' });
        }

        let activeModel = GEMINI_MODEL;
        let geminiRes = await executeGeminiRequest(activeModel, mimeType, base64Image);

        // Fallback to gemini-flash-lite-latest if active model returned 404 or 503
        if ((geminiRes.status === 404 || geminiRes.status === 503) && activeModel !== 'gemini-flash-lite-latest') {
          console.warn(`Model ${activeModel} returned ${geminiRes.status} from Gemini API. Retrying with gemini-flash-lite-latest...`);
          activeModel = 'gemini-flash-lite-latest';
          geminiRes = await executeGeminiRequest(activeModel, mimeType, base64Image);
        }

        if (geminiRes.status === 429) {
          return sendJson(res, 429, {
            error: 'Gemini API rate limit reached. Please wait a few seconds and try again.',
            upstreamStatusCode: 429,
          });
        }

        if (!geminiRes.ok) {
          const errText = await geminiRes.text();
          console.error(`Gemini API error [${geminiRes.status}]:`, errText);
          const clientStatus = geminiRes.status === 404 ? 502 : (geminiRes.status === 401 || geminiRes.status === 403) ? geminiRes.status : 502;
          return sendJson(res, clientStatus, {
            error: `Upstream Gemini API error (${geminiRes.status}).`,
            model: activeModel,
            upstreamStatusCode: geminiRes.status,
            details: errText,
          });
        }

        const geminiData = await geminiRes.json();
        const candidate = geminiData.candidates?.[0];
        const partText = candidate?.content?.parts?.[0]?.text;
        if (!partText) {
          return sendJson(res, 502, { error: 'Empty prediction returned by Gemini.' });
        }

        const structured = JSON.parse(partText);
        const normalizedCategory = normalizeCategory(structured.category);

        const result = {
          identifiable: structured.identifiable === true,
          category: normalizedCategory,
          confidence: Math.max(0.0, Math.min(1.0, Number(structured.confidence) || 0.0)),
          description: structured.description || '',
          disposalInstructions: Array.isArray(structured.disposalInstructions) ? structured.disposalInstructions : [],
          recyclable: Boolean(structured.recyclable),
        };

        return sendJson(res, 200, result);
      } catch (err) {
        console.error('Classification error:', err);
        return sendJson(res, 500, { error: `Internal error: ${err.message}` });
      }
    });
    return;
  }

  return sendJson(res, 405, { error: `Method not allowed: ${req.method} ${rawPath}` });
});

async function executeGeminiRequest(model, mimeType, base64Image) {
  const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`;

  const geminiPayload = {
    contents: [
      {
        parts: [
          { text: GEMINI_SYSTEM_INSTRUCTION },
          {
            inline_data: {
              mime_type: mimeType,
              data: base64Image,
            },
          },
        ],
      },
    ],
    generationConfig: {
      response_mime_type: 'application/json',
      response_schema: {
        type: 'OBJECT',
        properties: {
          identifiable: {
            type: 'BOOLEAN',
            description: 'True if an identifiable waste item is present; false if blurry or no waste found.',
          },
          category: {
            type: 'STRING',
            enum: SUPPORTED_CATEGORIES,
          },
          confidence: {
            type: 'NUMBER',
            description: 'Confidence score between 0.0 and 1.0.',
          },
          description: {
            type: 'STRING',
            description: '1-2 sentence description of the item and its material.',
          },
          disposalInstructions: {
            type: 'ARRAY',
            items: { type: 'STRING' },
            description: 'Actionable steps for proper recycling or disposal.',
          },
          recyclable: {
            type: 'BOOLEAN',
            description: 'Whether the item is recyclable in municipal collection.',
          },
        },
        required: ['identifiable', 'category', 'confidence', 'description', 'disposalInstructions', 'recyclable'],
      },
      temperature: 0.1,
    },
  };

  return fetch(geminiUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-goog-api-key': GEMINI_API_KEY,
    },
    body: JSON.stringify(geminiPayload),
  });
}

server.listen(PORT, HOST, () => {
  console.log('====================================================');
  console.log('AI Waste Segregation - Gemini Proxy Server (Node.js)');
  console.log('====================================================');
  console.log(`Listening on http://${HOST}:${PORT}`);
  console.log(`  - Health check:     http://localhost:${PORT}/health`);
  console.log(`  - Classify API:     http://localhost:${PORT}/classify`);
  console.log(`  - Android emulator: http://10.0.2.2:${PORT}/classify`);
  console.log(`Gemini Model: ${GEMINI_MODEL}`);
  if (!GEMINI_API_KEY) {
    console.warn('WARNING: GEMINI_API_KEY is not set!');
    console.warn('Set GEMINI_API_KEY in your environment or server/.env file.');
  } else {
    console.log(`GEMINI_API_KEY configured (length: ${GEMINI_API_KEY.length}).`);
  }
  console.log('====================================================');
});
