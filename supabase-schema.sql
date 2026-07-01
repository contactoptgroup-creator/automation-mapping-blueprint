-- Automation Blueprint V3 - Supabase Schema
-- Execute ce SQL dans l'editeur SQL de Supabase (SQL Editor)

-- =====================================================
-- ETAPE 1: Creer la table
-- =====================================================
CREATE TABLE IF NOT EXISTS projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    state JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour ameliorer les performances
CREATE INDEX IF NOT EXISTS idx_projects_name ON projects(name);
CREATE INDEX IF NOT EXISTS idx_projects_updated_at ON projects(updated_at DESC);

-- =====================================================
-- ETAPE 2: IMPORTANT - Desactiver RLS pour acces anonyme
-- (Sinon Supabase bloque les requetes avec la cle anon)
-- =====================================================

-- Option A: Desactiver completement RLS (plus simple)
ALTER TABLE projects DISABLE ROW LEVEL SECURITY;

-- OU Option B: Activer RLS avec policy publique (plus secure)
-- Decommente ces lignes si tu preferes cette option:
-- ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
-- DROP POLICY IF EXISTS "Allow public access" ON projects;
-- CREATE POLICY "Allow public access" ON projects
--     FOR ALL
--     TO anon, authenticated
--     USING (true)
--     WITH CHECK (true);

-- =====================================================
-- ETAPE 3: Trigger pour auto-update updated_at
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_projects_updated_at ON projects;
CREATE TRIGGER update_projects_updated_at
    BEFORE UPDATE ON projects
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- VERIFICATION: Execute cette requete pour verifier
-- =====================================================
-- SELECT * FROM projects LIMIT 5;
