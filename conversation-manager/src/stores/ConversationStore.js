/**
 * @typedef {Object} Message
 * @property {string} role       - e.g. "user" | "assistant" | "system"
 * @property {string} content    - message text/content
 * @property {string} [timestamp] - ISO-8601 timestamp; defaulted if omitted
 */

/**
 * @typedef {Object} Conversation
 * @property {string} tin          - normalized (digits-only) taxpayer ID
 * @property {Message[]} messages
 * @property {Object} metadata
 * @property {string} createdAt    - ISO-8601
 * @property {string} updatedAt    - ISO-8601
 */

/**
 * ConversationStore is the contract every storage backend must implement.
 * Calling code (the ConversationManager consumers) should depend only on
 * this interface, never on a concrete backend, so storage mode can be
 * swapped via configuration alone.
 *
 * This class is not meant to be instantiated directly — extend it and
 * override every method below.
 */
class ConversationStore {
  /**
   * Fetch a conversation by TIN.
   * @param {string} tin
   * @returns {Promise<Conversation|null>}
   */
  async getConversation(_tin) {
    throw new Error('getConversation() not implemented');
  }

  /**
   * Append a single message to a conversation, creating it if it doesn't
   * exist yet.
   * @param {string} tin
   * @param {Message} message
   * @param {Object} [options]
   * @param {Object} [options.metadata] - shallow-merged into stored metadata
   * @returns {Promise<Conversation>} the conversation after the append
   */
  async appendMessage(_tin, _message, _options = {}) {
    throw new Error('appendMessage() not implemented');
  }

  /**
   * Replace (or create) the full conversation for a TIN.
   * @param {string} tin
   * @param {Object} data
   * @param {Message[]} [data.messages]
   * @param {Object} [data.metadata]
   * @returns {Promise<Conversation>}
   */
  async saveConversation(_tin, _data) {
    throw new Error('saveConversation() not implemented');
  }

  /**
   * Delete a conversation.
   * @param {string} tin
   * @returns {Promise<boolean>} true if a conversation was deleted
   */
  async deleteConversation(_tin) {
    throw new Error('deleteConversation() not implemented');
  }

  /**
   * List stored TINs (paginated). Intended for admin/ops tooling — think
   * carefully before exposing this to application code, since it returns
   * sensitive identifiers in bulk.
   * @param {Object} [options]
   * @param {number} [options.limit=50]
   * @param {number} [options.offset=0]
   * @returns {Promise<string[]>}
   */
  async listConversationKeys(_options = {}) {
    throw new Error('listConversationKeys() not implemented');
  }

  /**
   * Release any underlying resources (connection pools, timers, etc).
   * Safe to call multiple times.
   * @returns {Promise<void>}
   */
  async close() {
    throw new Error('close() not implemented');
  }
}

module.exports = ConversationStore;
