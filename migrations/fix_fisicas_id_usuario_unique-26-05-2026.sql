-- ==========================================
-- MIGRATION 2026-05-26: fix fisicas.id_usuario unique handling
-- ==========================================

IF EXISTS (
    SELECT 1
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[UQ_fisicas_id_usuario]')
      AND type = 'UQ'
)
BEGIN
    ALTER TABLE [dbo].[fisicas]
    DROP CONSTRAINT [UQ_fisicas_id_usuario];
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_fisicas_id_usuario'
      AND object_id = OBJECT_ID(N'[dbo].[fisicas]')
)
BEGIN
    CREATE UNIQUE INDEX [UX_fisicas_id_usuario]
    ON [dbo].[fisicas] ([id_usuario])
    WHERE [id_usuario] IS NOT NULL;
END;
GO
