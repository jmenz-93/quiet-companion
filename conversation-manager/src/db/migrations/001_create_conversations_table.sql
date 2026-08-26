-- Conversations table, keyed by taxpayer identification number (TIN).
--
-- SECURITY NOTE: `tin` holds sensitive PII. Consider, depending on your
-- compliance requirements:
--   * storing a keyed hash (HMAC-SHA256 with a server-side secret) instead
--     of the raw TIN, with the raw value held only in a more tightly
--     controlled system of record;
--   * enabling Postgres transparent data encryption / disk-level encryption;
--   * column-level encryption via pgcrypto if the raw value must live here;
--   * row-level security and least-privilege DB roles for anything that
--     queries this table.
-- The schema below stores the TIN in the clear for simplicity; treat that
-- as a starting point, not a production recommendation.

CREATE TABLE IF NOT EXISTS conversations (
    -- Normalized (digits-only, 9-char) taxpayer ID. Primary key: one
    -- conversation record per TIN.
    tin           VARCHAR(9)   PRIMARY KEY,

    -- Ordered array of {role, content, timestamp} objects.
    messages      JSONB        NOT NULL DEFAULT '[]'::jsonb,

    -- Free-form application metadata (channel, agent id, tags, etc).
    metadata      JSONB        NOT NULL DEFAULT '{}'::jsonb,

    created_at    TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT now(),

    CONSTRAINT conversations_tin_format CHECK (tin ~ '^\d{9}$')
);

-- Useful for "most recently active conversations" queries / admin tooling.
CREATE INDEX IF NOT EXISTS idx_conversations_updated_at
    ON conversations (updated_at DESC);

-- Keep updated_at correct even for any raw UPDATE statements that don't
-- go through the application's own updated_at assignment.
CREATE OR REPLACE FUNCTION set_conversations_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_conversations_updated_at ON conversations;

CREATE TRIGGER trg_conversations_updated_at
    BEFORE UPDATE ON conversations
    FOR EACH ROW
    EXECUTE FUNCTION set_conversations_updated_at();
