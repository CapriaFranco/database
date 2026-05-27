-- ==========================================
-- MIGRATION 27-05-2026: tabla de codigos twofa por usuario
-- ==========================================

IF OBJECT_ID('[dbo].[usuarios_twofa_codigos]', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[usuarios_twofa_codigos] (
        [id_codigo] INT IDENTITY(1,1) NOT NULL,
        [id_usuario] INT NOT NULL,
        [codigo_hash] VARCHAR(256) NOT NULL,
        [fecha_creado] DATETIME2 NOT NULL CONSTRAINT [DF_usuarios_twofa_codigos_fecha_creado] DEFAULT (SYSDATETIME()),
        [fecha_expira] DATETIME2 NOT NULL,
        [estado] NVARCHAR(20) NOT NULL CONSTRAINT [DF_usuarios_twofa_codigos_estado] DEFAULT ('vigente'),
        [fecha_uso] DATETIME2 NULL,
        [intentos_verificacion] INT NOT NULL CONSTRAINT [DF_usuarios_twofa_codigos_intentos_verificacion] DEFAULT (0),
        CONSTRAINT [PK_usuarios_twofa_codigos] PRIMARY KEY ([id_codigo]),
        CONSTRAINT [FK_usuarios_twofa_codigos_usuarios] FOREIGN KEY ([id_usuario]) REFERENCES [dbo].[usuarios] ([id_usuario]) ON DELETE CASCADE,
        CONSTRAINT [CK_usuarios_twofa_codigos_estado] CHECK ([estado] IN ('vigente', 'usado', 'caducado'))
    );

    CREATE INDEX [idx_usuarios_twofa_codigos_usuario] ON [dbo].[usuarios_twofa_codigos] ([id_usuario]);
    CREATE INDEX [idx_usuarios_twofa_codigos_estado_expira] ON [dbo].[usuarios_twofa_codigos] ([estado], [fecha_expira]);
END;
GO
