-- Delego initial schema
-- TODO: Add migrations tooling (e.g. node-pg-migrate, Drizzle, Prisma)

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Users
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255),
    stellar_address VARCHAR(56) UNIQUE,
    display_name VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Wallets
CREATE TABLE IF NOT EXISTS wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    stellar_address VARCHAR(56) UNIQUE NOT NULL,
    public_key TEXT NOT NULL,
    encrypted_private_key TEXT,
    network VARCHAR(20) DEFAULT 'testnet',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_wallets_user_id ON wallets(user_id);
CREATE INDEX IF NOT EXISTS idx_wallets_stellar_address ON wallets(stellar_address);

-- Delegations
CREATE TABLE IF NOT EXISTS delegations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    agent_id VARCHAR(64) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'pending',
    policy JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_delegations_user_id ON delegations(user_id);

-- Orders
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    delegation_id UUID REFERENCES delegations(id) ON DELETE SET NULL,
    merchant_id VARCHAR(64) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'draft',
    line_items JSONB NOT NULL DEFAULT '[]',
    total_stroops BIGINT NOT NULL DEFAULT 0,
    escrow_contract_id VARCHAR(64),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);

-- Spend Limits
CREATE TABLE IF NOT EXISTS spend_limits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    wallet_id UUID REFERENCES wallets(id) ON DELETE SET NULL,
    delegation_id UUID REFERENCES delegations(id) ON DELETE CASCADE,
    limit_per_transaction BIGINT,
    limit_daily BIGINT,
    limit_weekly BIGINT,
    limit_lifetime BIGINT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_spend_limits_user_id ON spend_limits(user_id);
CREATE INDEX IF NOT EXISTS idx_spend_limits_wallet_id ON spend_limits(wallet_id);
CREATE INDEX IF NOT EXISTS idx_spend_limits_delegation_id ON spend_limits(delegation_id);

-- Delegation Policies
CREATE TABLE IF NOT EXISTS delegation_policies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    delegation_id UUID NOT NULL REFERENCES delegations(id) ON DELETE CASCADE,
    restricted_merchants TEXT[] DEFAULT '{}',
    restricted_categories TEXT[] DEFAULT '{}',
    allowed_merchants TEXT[] DEFAULT '{}',
    allowed_categories TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_delegation_policies_delegation_id ON delegation_policies(delegation_id);

-- Permission Levels
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'permission_type') THEN
        CREATE TYPE permission_type AS ENUM ('VIEW_ONLY', 'AUTO_APPROVE', 'SIGNER', 'ADMIN');
    END IF;
END$$;

CREATE TABLE IF NOT EXISTS permission_levels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    delegation_id UUID NOT NULL REFERENCES delegations(id) ON DELETE CASCADE,
    level permission_type DEFAULT 'VIEW_ONLY'::permission_type,
    description VARCHAR(255),
    can_sign BOOLEAN DEFAULT false,
    can_mutate_policy BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_permission_levels_delegation_id ON permission_levels(delegation_id);

