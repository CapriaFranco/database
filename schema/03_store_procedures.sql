-- ==========================================
-- SP 1: sp_existen_usuarios
-- ==========================================

USE [theEnterprise7mo2da];
GO

-- ==========================================

GO
CREATE OR ALTER PROCEDURE [dbo].[sp_existen_usuarios]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CAST(CASE WHEN EXISTS (
        SELECT 1
        FROM [dbo].[usuarios]
    ) THEN 1 ELSE 0 END AS BIT) AS [existen_usuarios];
END;
GO

-- ==========================================
-- SP 2: sp_crear_entidad
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_crear_entidad]
    @activo BIT = 1,
    @id_entidad INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[entidades] ([activo])
    VALUES (@activo);

    SET @id_entidad = CAST(SCOPE_IDENTITY() AS INT);
END;
GO

-- ==========================================
-- SP 3: sp_crear_fisica
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_crear_fisica]
    @id_entidad INT,
    @nombre VARCHAR(128),
    @apellido VARCHAR(128),
    @fecha_nacimiento DATE = NULL,
    @id_usuario INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[fisicas] (
        [id_entidad],
        [nombre],
        [apellido],
        [fecha_nacimiento],
        [id_usuario]
    )
    VALUES (
        @id_entidad,
        @nombre,
        @apellido,
        @fecha_nacimiento,
        @id_usuario
    );
END;
GO

-- ==========================================
-- SP 4: sp_crear_usuario_desde_fisica
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_crear_usuario_desde_fisica]
    @id_entidad_fisica INT,
    @username VARCHAR(100),
    @password_hash VARCHAR(256),
    @email VARCHAR(256),
    @estado NVARCHAR(50) = N'activo',
    @requiere_cambio_pass BIT = 1,
    @intentos_fallidos INT = 0,
    @bloqueado_hasta DATETIME2 = NULL,
    @ultimo_login DATETIME2 = NULL,
    @idioma_iso VARCHAR(5) = 'es',
    @twofa_habilitado BIT = 0,
    @id_usuario INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO [dbo].[usuarios] (
            [username],
            [password_hash],
            [email],
            [estado],
            [requiere_cambio_pass],
            [intentos_fallidos],
            [bloqueado_hasta],
            [ultimo_login],
            [idioma_iso],
            [twofa_habilitado]
        )
        VALUES (
            @username,
            @password_hash,
            @email,
            @estado,
            @requiere_cambio_pass,
            @intentos_fallidos,
            @bloqueado_hasta,
            @ultimo_login,
            @idioma_iso,
            @twofa_habilitado
        );

        SET @id_usuario = CAST(SCOPE_IDENTITY() AS INT);

        UPDATE [dbo].[fisicas]
        SET [id_usuario] = @id_usuario
        WHERE [id_entidad] = @id_entidad_fisica;

        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50001, 'No existe la persona fisica indicada para asociar el usuario.', 1;
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

-- ==========================================
-- SP 5: sp_agregar_documento
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_agregar_documento]
    @id_entidad INT,
    @id_tipo_documento INT,
    @valor VARCHAR(128),
    @es_principal BIT = 0,
    @id_documento INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[documentos] (
        [id_entidad],
        [id_tipo_documento],
        [valor],
        [es_principal]
    )
    VALUES (
        @id_entidad,
        @id_tipo_documento,
        @valor,
        @es_principal
    );

    SET @id_documento = CAST(SCOPE_IDENTITY() AS INT);
END;
GO

-- ==========================================
-- SP 6: sp_agregar_contacto
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_agregar_contacto]
    @id_entidad INT,
    @id_tipo_contacto INT,
    @valor VARCHAR(256),
    @etiqueta VARCHAR(100) = NULL,
    @es_principal BIT = 0,
    @id_contacto INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[contactos] (
        [id_entidad],
        [id_tipo_contacto],
        [valor],
        [etiqueta],
        [es_principal]
    )
    VALUES (
        @id_entidad,
        @id_tipo_contacto,
        @valor,
        @etiqueta,
        @es_principal
    );

    SET @id_contacto = CAST(SCOPE_IDENTITY() AS INT);
END;
GO

-- ==========================================
-- SP 7: sp_agregar_domicilio
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_agregar_domicilio]
    @id_entidad INT,
    @id_localidad INT,
    @calle VARCHAR(100),
    @numero VARCHAR(20) = NULL,
    @piso VARCHAR(20) = NULL,
    @depto VARCHAR(20) = NULL,
    @referencia VARCHAR(512) = NULL,
    @tipo VARCHAR(50) = NULL,
    @es_principal BIT = 0,
    @id_domicilio INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[domicilios] (
        [id_entidad],
        [id_localidad],
        [calle],
        [numero],
        [piso],
        [depto],
        [referencia],
        [tipo],
        [es_principal]
    )
    VALUES (
        @id_entidad,
        @id_localidad,
        @calle,
        @numero,
        @piso,
        @depto,
        @referencia,
        @tipo,
        @es_principal
    );

    SET @id_domicilio = CAST(SCOPE_IDENTITY() AS INT);
END;
GO

-- ==========================================
-- SP 8: sp_listar_paises
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_listar_paises]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        [id_pais],
        [nombre],
        [codigo]
    FROM [dbo].[paises]
    ORDER BY [nombre];
END;
GO

-- ==========================================
-- SP 9: sp_listar_provincias
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_listar_provincias]
    @id_pais INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        [id_provincia],
        [id_pais],
        [nombre]
    FROM [dbo].[provincias]
    WHERE @id_pais IS NULL OR [id_pais] = @id_pais
    ORDER BY [nombre];
END;
GO

-- ==========================================
-- SP 10: sp_listar_localidades
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_listar_localidades]
    @id_provincia INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        [id_localidad],
        [id_provincia],
        [nombre],
        [codigo_postal]
    FROM [dbo].[localidades]
    WHERE @id_provincia IS NULL OR [id_provincia] = @id_provincia
    ORDER BY [nombre];
END;
GO

-- ==========================================
-- SP 11: sp_listar_tipos_documento
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_listar_tipos_documento]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        [id_tipo_documento],
        [nombre],
        [aplica_a]
    FROM [dbo].[tipo_documento]
    ORDER BY [nombre];
END;
GO

-- ==========================================
-- SP 12: sp_listar_tipos_contacto
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_listar_tipos_contacto]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        [id_tipo_contacto],
        [nombre]
    FROM [dbo].[tipo_contacto]
    ORDER BY [nombre];
END;
GO

-- ==========================================
-- SP 13: sp_listar_tipos_entidad
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_listar_tipos_entidad]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        [id_tipo],
        [nombre]
    FROM [dbo].[entidad_tipo]
    ORDER BY [nombre];
END;
GO

-- ==========================================
-- SP 14: sp_listar_tipos_metodo_pago
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_listar_tipos_metodo_pago]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        [id_tipo_metodo_pago],
        [nombre]
    FROM [dbo].[tipo_metodo_pago]
    ORDER BY [nombre];
END;
GO

-- ==========================================
-- SP 15: sp_listar_tipos_social
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_listar_tipos_social]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        [id_tipo_social],
        [nombre]
    FROM [dbo].[tipo_social]
    ORDER BY [nombre];
END;
GO
