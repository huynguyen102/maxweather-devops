// API Gateway (HTTP API) Lambda authorizer for Cognito access tokens.
//
// Dependency-free: uses Node's built-in `crypto` to verify the RS256 signature
// and `https` to fetch the JWKS. No npm install, no bundling — the whole function
// is this one file.
//
// It validates: signature (against Cognito's public keys), issuer, token_use,
// expiry, client_id, and the required scope. Returns the HTTP API simple-response
// shape { isAuthorized: boolean }.

import https from "node:https";
import crypto from "node:crypto";

const ISSUER = process.env.ISSUER;
const JWKS_URI = process.env.JWKS_URI;
const AUDIENCE = process.env.AUDIENCE; // Cognito app client_id
const REQUIRED_SCOPE = process.env.REQUIRED_SCOPE;

// Cached across warm invocations; Cognito signing keys rotate rarely.
let jwksCache = null;

function fetchJson(url) {
  return new Promise((resolve, reject) => {
    https
      .get(url, (res) => {
        let body = "";
        res.on("data", (chunk) => (body += chunk));
        res.on("end", () => {
          try {
            resolve(JSON.parse(body));
          } catch (err) {
            reject(err);
          }
        });
      })
      .on("error", reject);
  });
}

async function getKey(kid) {
  if (!jwksCache) {
    const jwks = await fetchJson(JWKS_URI);
    jwksCache = Object.fromEntries(jwks.keys.map((k) => [k.kid, k]));
  }
  return jwksCache[kid];
}

function decodeSegment(segment) {
  return JSON.parse(Buffer.from(segment, "base64url").toString("utf8"));
}

async function verify(token) {
  const [headerB64, payloadB64, sigB64] = token.split(".");
  if (!headerB64 || !payloadB64 || !sigB64) throw new Error("malformed token");

  const header = decodeSegment(headerB64);
  if (header.alg !== "RS256") throw new Error("unexpected alg");

  const jwk = await getKey(header.kid);
  if (!jwk) throw new Error("unknown key id");

  const key = crypto.createPublicKey({ key: jwk, format: "jwk" });
  const signatureValid = crypto.verify(
    "RSA-SHA256",
    Buffer.from(`${headerB64}.${payloadB64}`),
    key,
    Buffer.from(sigB64, "base64url")
  );
  if (!signatureValid) throw new Error("bad signature");

  const claims = decodeSegment(payloadB64);
  const now = Math.floor(Date.now() / 1000);
  if (claims.iss !== ISSUER) throw new Error("bad issuer");
  if (claims.token_use !== "access") throw new Error("not an access token");
  if (claims.exp <= now) throw new Error("expired");
  if (AUDIENCE && claims.client_id !== AUDIENCE) throw new Error("bad client_id");
  if (REQUIRED_SCOPE) {
    const scopes = (claims.scope || "").split(" ");
    if (!scopes.includes(REQUIRED_SCOPE)) throw new Error("missing scope");
  }
  return claims;
}

export const handler = async (event) => {
  try {
    const authHeader =
      event.headers?.authorization ||
      event.headers?.Authorization ||
      (event.identitySource && event.identitySource[0]) ||
      "";
    const token = authHeader.replace(/^Bearer\s+/i, "");
    if (!token) return { isAuthorized: false };

    const claims = await verify(token);
    return {
      isAuthorized: true,
      context: { client_id: claims.client_id, scope: claims.scope },
    };
  } catch (err) {
    console.log(
      JSON.stringify({ level: "WARN", message: "authorization denied", error: err.message })
    );
    return { isAuthorized: false };
  }
};
