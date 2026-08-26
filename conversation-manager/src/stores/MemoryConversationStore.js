const ConversationStore = require('./ConversationStore');
const { assertValidTin } = require('../util/tin');

/**
 * In-process, non-persistent conversation store. Data lives only for the
 * lifetime of the Node process and is lost on restart — intended for
 * short-lived conversations (e.g. a single support session) where
 * durability isn't required.
 *
 * Each conversation carries its own idle timer: any read or write resets
 * it, and if a conversation goes untouched for `ttlMs` it's evicted
 * automatically so memory doesn't grow unbounded.
 */
class MemoryConversationStore extends ConversationStore {
  /**
   * @param {Object} [options]
   * @param {number} [options.ttlMs=1800000] - idle TTL in ms (default 30 min)
   */
  constructor({ ttlMs = 30 * 60 * 1000 } = {}) {
    super();
    this.ttlMs = ttlMs;
    /** @type {Map<string, {conversation: import('./ConversationStore').Conversation, timer: NodeJS.Timeout}>} */
    this._store = new Map();
  }

  _scheduleEviction(tin) {
    const entry = this._store.get(tin);
    if (!entry) return;
    clearTimeout(entry.timer);
    entry.timer = setTimeout(() => {
      this._store.delete(tin);
    }, this.ttlMs);
    // Don't let this timer keep the process alive on its own.
    if (typeof entry.timer.unref === 'function') entry.timer.unref();
  }

  async getConversation(tin) {
    const key = assertValidTin(tin);
    const entry = this._store.get(key);
    if (!entry) return null;
    this._scheduleEviction(key);
    return this._clone(entry.conversation);
  }

  async appendMessage(tin, message, { metadata } = {}) {
    const key = assertValidTin(tin);
    const now = new Date().toISOString();
    const entry = this._store.get(key);

    const normalizedMessage = {
      role: message.role,
      content: message.content,
      timestamp: message.timestamp || now,
    };

    if (!entry) {
      const conversation = {
        tin: key,
        messages: [normalizedMessage],
        metadata: metadata || {},
        createdAt: now,
        updatedAt: now,
      };
      this._store.set(key, { conversation, timer: null });
      this._scheduleEviction(key);
      return this._clone(conversation);
    }

    entry.conversation.messages.push(normalizedMessage);
    entry.conversation.updatedAt = now;
    if (metadata) {
      entry.conversation.metadata = { ...entry.conversation.metadata, ...metadata };
    }
    this._scheduleEviction(key);
    return this._clone(entry.conversation);
  }

  async saveConversation(tin, data) {
    const key = assertValidTin(tin);
    const now = new Date().toISOString();
    const existing = this._store.get(key);

    const conversation = {
      tin: key,
      messages: data.messages || [],
      metadata: data.metadata || {},
      createdAt: existing ? existing.conversation.createdAt : now,
      updatedAt: now,
    };

    this._store.set(key, { conversation, timer: null });
    this._scheduleEviction(key);
    return this._clone(conversation);
  }

  async deleteConversation(tin) {
    const key = assertValidTin(tin);
    const entry = this._store.get(key);
    if (!entry) return false;
    clearTimeout(entry.timer);
    this._store.delete(key);
    return true;
  }

  async listConversationKeys({ limit = 50, offset = 0 } = {}) {
    const keys = Array.from(this._store.keys());
    return keys.slice(offset, offset + limit);
  }

  async close() {
    for (const entry of this._store.values()) {
      clearTimeout(entry.timer);
    }
    this._store.clear();
  }

  _clone(conversation) {
    // Defensive copy so callers can't mutate internal state directly.
    return {
      ...conversation,
      messages: conversation.messages.map((m) => ({ ...m })),
      metadata: { ...conversation.metadata },
    };
  }
}

module.exports = MemoryConversationStore;
