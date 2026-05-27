-- ==========================================
-- MIGRATION 27-05-2026: security questions status and hint
-- ==========================================

IF COL_LENGTH('[dbo].[preguntas_seguridad]', 'estado') IS NULL
BEGIN
    ALTER TABLE [dbo].[preguntas_seguridad]
    ADD [estado] BIT NOT NULL CONSTRAINT [DF_preguntas_seguridad_estado] DEFAULT (1);
END;
GO

IF COL_LENGTH('[dbo].[respuestas_seguridad]', 'pista') IS NULL
BEGIN
    ALTER TABLE [dbo].[respuestas_seguridad]
    ADD [pista] VARCHAR(256) NULL;
END;
GO
