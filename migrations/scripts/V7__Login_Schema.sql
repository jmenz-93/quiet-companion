CREATE SCHEMA IF NOT EXISTS login;

CREATE TABLE IF NOT EXISTS login.users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_encrypted VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT current_timestamp
);

CREATE INDEX idx_users_email ON login.users (email);
