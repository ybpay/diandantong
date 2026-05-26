-- PostgreSQL 18 initialization for diandantong
-- Run as superuser (postgres)

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "unaccent";

-- Application user (for production)
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'ddt_app') THEN
    CREATE ROLE ddt_app WITH LOGIN PASSWORD 'ddt_app_password';
  END IF;
END
$$;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE ddt_dev TO ddt_app;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ddt_app;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ddt_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO ddt_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO ddt_app;
