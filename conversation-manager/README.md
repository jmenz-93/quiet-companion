# conversation-manager

Stores and retrieves user conversations keyed by taxpayer identification
number (TIN). Supports two interchangeable storage backends behind one
shared API:

- **`memory`** — in-process `Map`, gone on restart, entries auto-evicted
  after an idle TTL. Good for short-lived sessions.
- **`postgres`** — durable storage in a `conversations` table, survives
  restarts.

Calling code depends only on the shared `ConversationStore` interface
(`getConversation`, `appendMessage`, `saveConversation`,
`deleteConversation`, `listConversationKeys`, `close`) and never has to
branch on which backend is active — the mode is chosen once, via config,
at startup.

## Install

```bash
npm install
cp .env.example .env
# edit .env: set STORAGE_MODE and, if using postgres, the PG* variables
```

## Postgres setup

```bash
createdb conversations         # or point PGDATABASE at an existing db
npm run migrate                # applies src/db/migrations/*.sql
```

The migration creates the `conversations` table, an index on
`updated_at`, and a trigger that keeps `updated_at` current. See the SQL
file for the full schema and PII-handling notes.

## Usage

```js
const { createConversationManager } = require('./src/index');

// mode comes from STORAGE_MODE in .env by default; can also be passed
// explicitly, e.g. createConversationManager({ mode: 'postgres' })
const manager = createConversationManager();

await manager.appendMessage('123-45-6789', {
  role: 'user',
  content: 'What is my refund status?',
});

const conversation = await manager.getConversation('123-45-6789');
// { tin, messages: [...], metadata: {...}, createdAt, updatedAt }

await manager.close(); // release DB pool / clear timers
```

Run the bundled example against either backend:

```bash
STORAGE_MODE=memory   npm run example
STORAGE_MODE=postgres npm run example   # after npm run migrate
```

Run tests (memory store only — Postgres needs a live DB, see below):

```bash
npm test
```

## API

Every method accepts a TIN as either 9 raw digits or a hyphenated string
(e.g. `"123456789"` or `"123-45-6789"`); it's normalized internally and
an invalid shape throws.

| Method | Description |
|---|---|
| `getConversation(tin)` | Returns the conversation or `null`. |
| `appendMessage(tin, message, { metadata })` | Creates the conversation if needed, appends a `{role, content, timestamp}` message, shallow-merges `metadata`. |
| `saveConversation(tin, { messages, metadata })` | Replaces the full conversation (upsert). |
| `deleteConversation(tin)` | Deletes it; returns `true`/`false`. |
| `listConversationKeys({ limit, offset })` | Paginated list of stored TINs — see the security note below before exposing this. |
| `close()` | Releases the pool (postgres) or clears timers (memory). Safe to call once at shutdown. |

## Project layout

```
src/
  config.js                    - reads STORAGE_MODE / PG* / MEMORY_TTL_MS from env
  index.js                     - createConversationManager() factory + exports
  util/tin.js                  - TIN normalize/validate/mask helpers
  stores/
    ConversationStore.js       - the shared interface (JSDoc contract)
    MemoryConversationStore.js - in-memory, TTL-evicted implementation
    PostgresConversationStore.js - Postgres implementation
  db/
    pool.js                    - pg Pool factory
    migrate.js                 - runs migrations/*.sql in order
    migrations/
      001_create_conversations_table.sql
examples/usage.js              - runnable demo, same code for either mode
test/memoryStore.test.js       - dependency-free tests for the memory store
```

## Security notes (please read before production use)

A TIN is sensitive PII. This project stores it as a normalized 9-digit
value and never logs it directly (use `maskTin()` from
`src/util/tin.js` for any logging/debug output). Before shipping this
against real data, consider:

- **Don't store raw TINs if you can avoid it.** A keyed hash (HMAC-SHA256
  with a secret pepper kept outside the database) as the lookup key, with
  the raw TIN held only in a more tightly controlled system of record, is
  usually preferable to storing it in the clear.
- **Encrypt at rest** — Postgres disk/volume encryption at minimum;
  column-level encryption (e.g. via `pgcrypto`) if the raw value must live
  in this table.
- **Encrypt in transit** — set `PGSSL=true` (or configure `sslmode` in
  `DATABASE_URL`) for any non-local Postgres connection.
- **Least privilege** — the DB role this app uses should only have access
  to the `conversations` table, not the whole database.
- **Access control & audit logging** at the application layer for any code
  path that reads a conversation or calls `listConversationKeys`.
- **Retention** — decide how long conversation content needs to be kept
  and delete or archive on a schedule; the memory-store TTL only helps
  with the non-durable mode.

None of the above is implemented here — this project gives you the
storage plumbing; the compliance posture (SOC 2, IRS Pub 4600A, GLBA, or
whatever applies to your context) is a decision for your team.
