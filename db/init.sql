-- Combined from packages/relayer/migrations/
-- Postgres runs this automatically on first database initialization.

-- 20241008135456_init.up.sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_enum') THEN
        CREATE TYPE status_enum AS ENUM ('Request received', 'Email sent', 'Email response received', 'Proving', 'Performing on chain transaction', 'Finished');
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS requests (
    id UUID PRIMARY KEY NOT NULL DEFAULT (uuid_generate_v4()),
    status status_enum NOT NULL DEFAULT 'Request received',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    email_tx_auth JSONB NOT NULL
);

CREATE TABLE IF NOT EXISTS expected_replies (
    message_id VARCHAR(255) PRIMARY KEY,
    request_id VARCHAR(255),
    has_reply BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 20241128143748_create_email_auth_messages.up.sql
CREATE TABLE IF NOT EXISTS email_auth_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id TEXT NOT NULL,
    response JSONB NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_email_auth_messages_request_id ON email_auth_messages(request_id);
