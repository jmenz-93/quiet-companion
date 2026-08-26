const { Pool } = require('pg');
const config = require('../config');

let sharedPool = null;

/**
 * Builds a `pg` Pool from config/env. Callers can also construct and pass
 * their own Pool into PostgresConversationStore directly (e.g. to reuse a
 * pool already set up elsewhere in the app).
 * @returns {import('pg').Pool}
 */
function createPool() {
  const { connectionString, host, port, database, user, password, ssl } = config.postgres;

  if (connectionString) {
    return new Pool({ connectionString, ssl });
  }

  return new Pool({ host, port, database, user, password, ssl });
}

/**
 * Returns a process-wide shared pool, creating it on first call.
 * @returns {import('pg').Pool}
 */
function getSharedPool() {
  if (!sharedPool) {
    sharedPool = createPool();
  }
  return sharedPool;
}

module.exports = { createPool, getSharedPool };
