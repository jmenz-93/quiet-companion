require('dotenv').config();

const config = {
  storageMode: (process.env.STORAGE_MODE || 'memory').toLowerCase(),

  memory: {
    ttlMs: Number(process.env.MEMORY_TTL_MS || 30 * 60 * 1000), // 30 min default
  },

  postgres: {
    connectionString: process.env.DATABASE_URL || undefined,
    host: process.env.PGHOST || 'localhost',
    port: Number(process.env.PGPORT || 5432),
    database: process.env.PGDATABASE || 'conversations',
    user: process.env.PGUSER || 'postgres',
    password: process.env.PGPASSWORD || '',
    ssl: process.env.PGSSL === 'true' ? { rejectUnauthorized: false } : false,
  },
};

module.exports = config;
