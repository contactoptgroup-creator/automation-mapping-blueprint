-- Automation Blueprint V3 - Supabase Schema
-- Execute ce SQL dans l'editeur SQL de Supabase (SQL Editor)

-- =====================================================
-- ETAPE 1: Creer la table PROJECTS
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
-- ETAPE 2: Creer la table WIREFRAMES
-- =====================================================
CREATE TABLE IF NOT EXISTS wireframes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_name TEXT NOT NULL,
    automation_id TEXT NOT NULL,
    wireframe_data JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(project_name, automation_id)
);

-- Index pour les wireframes
CREATE INDEX IF NOT EXISTS idx_wireframes_project ON wireframes(project_name);
CREATE INDEX IF NOT EXISTS idx_wireframes_automation ON wireframes(automation_id);

-- =====================================================
-- ETAPE 3: IMPORTANT - Desactiver RLS pour acces anonyme
-- (Sinon Supabase bloque les requetes avec la cle anon)
-- =====================================================

-- Desactiver RLS pour les deux tables
ALTER TABLE projects DISABLE ROW LEVEL SECURITY;
ALTER TABLE wireframes DISABLE ROW LEVEL SECURITY;

-- =====================================================
-- ETAPE 4: Trigger pour auto-update updated_at
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger pour projects
DROP TRIGGER IF EXISTS update_projects_updated_at ON projects;
CREATE TRIGGER update_projects_updated_at
    BEFORE UPDATE ON projects
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger pour wireframes
DROP TRIGGER IF EXISTS update_wireframes_updated_at ON wireframes;
CREATE TRIGGER update_wireframes_updated_at
    BEFORE UPDATE ON wireframes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- VERIFICATION: Execute ces requetes pour verifier
-- =====================================================
-- SELECT * FROM projects LIMIT 5;
-- SELECT * FROM wireframes LIMIT 5;
