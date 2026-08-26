const config = require('./config');
const ConversationStore = require('./stores/ConversationStore');
const MemoryConversationStore = require('./stores/MemoryConversationStore');
const PostgresConversationStore = require('./stores/PostgresConversationStore');

/**
 * Creates a conversation manager backed by either the in-memory store or
 * the Postgres store. Calling code should only ever interact with the
 * returned object through the ConversationStore contract
 * (getConversation / appendMessage / saveConversation / deleteConversation
 * / listConversationKeys / close) — it never needs to know or check which
 * mode is active.
 *
 * @param {Object} [options]
 * @param {'memory'|'postgres'} [options.mode] - defaults to STORAGE_MODE env var, then 'memory'
 * @param {number} [options.ttlMs] - memory mode only: idle TTL in ms
 * @param {import('pg').Pool} [options.pool] - postgres mode only: inject an existing pool
 * @returns {ConversationStore}
 */
function createConversationManager(options = {}) {
  const mode = (options.mode || config.storageMode || 'memory').toLowerCase();

  switch (mode) {
    case 'postgres':
      return new PostgresConversationStore({ pool: options.pool });
    case 'memory':
      return new MemoryConversationStore({ ttlMs: options.ttlMs ?? config.memory.ttlMs });
    default:
      throw new Error(`Unknown storage mode "${mode}". Expected "memory" or "postgres".`);
  }
}

module.exports = {
  createConversationManager,
  ConversationStore,
  MemoryConversationStore,
  PostgresConversationStore,
};
