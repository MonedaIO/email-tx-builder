/**
 * HMAC-SHA256 request verification for nginx njs module.
 *
 * Clients must send:
 *   X-Timestamp: <unix epoch seconds>
 *   X-Signature: <hex-encoded HMAC-SHA256(secret, timestamp.body)>
 *
 * The signature is verified against the HMAC_SECRET environment variable.
 * Requests with timestamps older than 5 minutes are rejected.
 */

var REPLAY_WINDOW_SECONDS = 300; // 5 minutes

/**
 * Called by js_set to expose the HMAC_SECRET env var as an nginx variable.
 */
function getSecret(r) {
    return process.env.HMAC_SECRET || "";
}

function verify(r) {
    var secret = r.variables.hmac_secret;
    if (!secret) {
        r.error("HMAC_SECRET environment variable is not set");
        r.return(500, "Server misconfiguration\n");
        return;
    }

    var timestamp = r.headersIn["X-Timestamp"];
    var signature = r.headersIn["X-Signature"];

    if (!timestamp || !signature) {
        r.return(401, "Missing X-Timestamp or X-Signature header\n");
        return;
    }

    // Reject timestamps outside the replay window
    var now = Math.floor(Date.now() / 1000);
    var ts = parseInt(timestamp, 10);
    if (isNaN(ts) || Math.abs(now - ts) > REPLAY_WINDOW_SECONDS) {
        r.return(401, "Timestamp expired or invalid\n");
        return;
    }

    var body = r.requestText || "";
    var payload = timestamp + "." + body;

    var hmac = require("crypto")
        .createHmac("sha256", secret)
        .update(payload)
        .digest("hex");

    if (hmac.length !== signature.length || !timingSafeEqual(hmac, signature)) {
        r.return(401, "Invalid signature\n");
        return;
    }

    // Signature is valid — proxy the request by issuing an internal redirect
    r.internalRedirect("@backend");
}

/**
 * Constant-time string comparison to prevent timing attacks.
 */
function timingSafeEqual(a, b) {
    if (a.length !== b.length) {
        return false;
    }
    var result = 0;
    for (var i = 0; i < a.length; i++) {
        result |= a.charCodeAt(i) ^ b.charCodeAt(i);
    }
    return result === 0;
}

export default { verify, getSecret };
