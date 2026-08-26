#!/usr/bin/env node
/**
 * Minimal migration runner: executes every .sql file in ./migrations, in
 * filename order, inside a single connection. Good enough for a small
 * project; swap in a proper migration tool (node-pg-migrate, Flyway, etc.)
 * if this grows.
 */
const fs = require('fs');
const path = require('path');
const { createPool } = require('./pool');

async function migrate() {
  const migrationsDir = path.join(__dirname, 'migrations');
  const files = fs
    .readdirSync(migrationsDir)
    .filter((f) => f.endsWith('.sql'))
    .sort();

  if (files.length === 0) {
    console.log('No migration files found in', migrationsDir);
    return;
  }

  const pool = createPool();
  const client = await pool.connect();

  try {
    for (const file of files) {
      const filePath = path.join(migrationsDir, file);
      const sql = fs.readFileSync(filePath, 'utf8');
      console.log(`Applying migration: ${file}`);
      await client.query(sql);
    }
    console.log('Migrations complete.');
  } finally {
    client.release();
    await pool.end();
  }
}

migrate().catch((err) => {
  console.error('Migration failed:', err.message);
  process.exitCode = 1;
});
