CREATE SCHEMA IF NOT EXISTS public;
CREATE SCHEMA IF NOT EXISTS conversation;
CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA public;

CREATE TABLE conversation.conversation_history (
    message_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL,
    client_id UUID NOT NULL,
    advisor_id UUID NOT NULL,
    transcript TEXT NOT NULL,
    embedding public.vector(1536),
    created_at TIMESTAMPTZ DEFAULT current_timestamp
);
