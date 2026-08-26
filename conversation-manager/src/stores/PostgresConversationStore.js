const ConversationStore = require('./ConversationStore');
const { assertValidTin } = require('../util/tin');
const { getSharedPool } = require('../db/pool');

/**
 * Postgres-backed conversation store. Conversations survive process
 * restarts; run the migration in src/db/migrations before using this
 * (see README / `npm run migrate`).
 */
class PostgresConversationStore extends ConversationStore {
  /**
   * @param {Object} [options]
   * @param {import('pg').Pool} [options.pool] - inject an existing pool;
   *   defaults to a shared pool built from env/config.
   */
  constructor({ pool } = {}) {
    super();
    this.pool = pool || getSharedPool();
  }

  _rowToConversation(row) {
    if (!row) return null;
    return {
      tin: row.tin,
      messages: row.messages,
      metadata: row.metadata,
      createdAt: row.created_at instanceof Date ? row.created_at.toISOString() : row.created_at,
      updatedAt: row.updated_at instanceof Date ? row.updated_at.toISOString() : row.updated_at,
    };
  }

  async getConversation(tin) {
    const key = assertValidTin(tin);
    const { rows } = await this.pool.query(
      'SELECT tin, messages, metadata, created_at, updated_at FROM conversations WHERE tin = $1',
      [key]
    );
    return this._rowToConversation(rows[0]);
  }

  async appendMessage(tin, message, { metadata } = {}) {
    const key = assertValidTin(tin);
    const normalizedMessage = {
      role: message.role,
      content: message.content,
      timestamp: message.timestamp || new Date().toISOString(),
    };

    // Upsert: create the row with a one-element messages array if it
    // doesn't exist yet, otherwise append to the existing jsonb array.
    // metadata is shallow-merged (new keys win on conflict).
    const { rows } = await this.pool.query(
      `INSERT INTO conversations (tin, messages, metadata)
       VALUES ($1, $2::jsonb, $3::jsonb)
       ON CONFLICT (tin) DO UPDATE
         SET messages = conversations.messages || EXCLUDED.messages,
             metadata = conversations.metadata || EXCLUDED.metadata,
             updated_at = now()
       RETURNING tin, messages, metadata, created_at, updated_at`,
      [key, JSON.stringify([normalizedMessage]), JSON.stringify(metadata || {})]
    );

    return this._rowToConversation(rows[0]);
  }

  async saveConversation(tin, data) {
    const key = assertValidTin(tin);
    const { rows } = await this.pool.query(
      `INSERT INTO conversations (tin, messages, metadata)
       VALUES ($1, $2::jsonb, $3::jsonb)
       ON CONFLICT (tin) DO UPDATE
         SET messages = EXCLUDED.messages,
             metadata = EXCLUDED.metadata,
             updated_at = now()
       RETURNING tin, messages, metadata, created_at, updated_at`,
      [key, JSON.stringify(data.messages || []), JSON.stringify(data.metadata || {})]
    );

    return this._rowToConversation(rows[0]);
  }

  async deleteConversation(tin) {
    const key = assertValidTin(tin);
    const { rowCount } = await this.pool.query('DELETE FROM conversations WHERE tin = $1', [key]);
    return rowCount > 0;
  }

  async listConversationKeys({ limit = 50, offset = 0 } = {}) {
    const { rows } = await this.pool.query(
      'SELECT tin FROM conversations ORDER BY updated_at DESC LIMIT $1 OFFSET $2',
      [limit, offset]
    );
    return rows.map((r) => r.tin);
  }

  async close() {
    await this.pool.end();
  }
}

module.exports = PostgresConversationStore;
