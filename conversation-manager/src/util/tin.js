/**
 * Helpers for validating and normalizing a Taxpayer Identification Number (TIN).
 *
 * A TIN covers several US identifier formats: SSN, EIN, and ITIN. This module
 * only does a basic structural sanity check (9 digits, optionally with
 * separators) — it does NOT verify the number is a real, issued identifier.
 * Do not treat a "valid" result here as proof the TIN belongs to anyone.
 *
 * SECURITY NOTE: a TIN is sensitive PII. Callers of this library are
 * responsible for:
 *   - transporting it only over encrypted channels (TLS)
 *   - not logging raw TINs (this module and the stores in this project never do)
 *   - considering field-level encryption or a keyed hash (HMAC-SHA256 with a
 *     secret pepper) before persisting it, rather than storing it in the clear
 *   - restricting database/application access on a least-privilege basis
 */

/**
 * Strips whitespace and common separators (hyphens) from a TIN.
 * @param {string} tin
 * @returns {string}
 */
function normalizeTin(tin) {
  if (typeof tin !== 'string') {
    throw new TypeError('TIN must be a string');
  }
  return tin.replace(/[\s-]/g, '');
}

/**
 * Basic structural check: 9 digits after normalization.
 * @param {string} tin
 * @returns {boolean}
 */
function isValidTin(tin) {
  try {
    const normalized = normalizeTin(tin);
    return /^\d{9}$/.test(normalized);
  } catch {
    return false;
  }
}

/**
 * Normalizes and validates in one step; throws on invalid input.
 * @param {string} tin
 * @returns {string} the normalized (digits-only) TIN
 */
function assertValidTin(tin) {
  const normalized = normalizeTin(tin);
  if (!/^\d{9}$/.test(normalized)) {
    throw new Error('Invalid TIN: expected 9 digits, optionally hyphenated');
  }
  return normalized;
}

/**
 * Masks a TIN for safe display/logging, e.g. "123456789" -> "*****6789".
 * @param {string} tin
 * @returns {string}
 */
function maskTin(tin) {
  const normalized = normalizeTin(tin);
  if (normalized.length < 4) return '****';
  return '*'.repeat(normalized.length - 4) + normalized.slice(-4);
}

module.exports = { normalizeTin, isValidTin, assertValidTin, maskTin };
