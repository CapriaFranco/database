-- ==========================================
-- SP 1: sp_existen_usuarios
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
-- SP 5: sp_asociar_usuario_a_fisica
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_asociar_usuario_a_fisica]
    @id_entidad_fisica INT,
    @id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1
            FROM [dbo].[usuarios]
            WHERE [id_usuario] = @id_usuario
        )
        BEGIN
            THROW 50002, 'El usuario indicado no existe.', 1;
        END;

        IF NOT EXISTS (
            SELECT 1
            FROM [dbo].[fisicas]
            WHERE [id_entidad] = @id_entidad_fisica
        )
        BEGIN
            THROW 50003, 'La persona fisica indicada no existe.', 1;
        END;

        UPDATE [dbo].[fisicas]
        SET [id_usuario] = @id_usuario
        WHERE [id_entidad] = @id_entidad_fisica;

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
-- SP 6: sp_agregar_documento
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
-- SP 7: sp_agregar_contacto
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
-- SP 8: sp_agregar_domicilio
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
-- SP 9: sp_listar_paises
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
-- SP 10: sp_listar_provincias
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
-- SP 11: sp_listar_localidades
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
-- SP 12: sp_listar_tipos_documento
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
-- SP 13: sp_listar_tipos_contacto
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
-- SP 14: sp_listar_tipos_entidad
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
-- SP 15: sp_listar_tipos_metodo_pago
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
-- SP 16: sp_listar_tipos_social
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

-- ==========================================
-- SP 17: sp_listar_permisos
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_listar_permisos]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        [id_permiso],
        [codigo],
        [descripcion],
        [modulo]
    FROM [dbo].[permisos]
    ORDER BY [modulo], [codigo];
END;
GO

-- ==========================================
-- SP 18: sp_listar_roles
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_listar_roles]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        [id_rol],
        [nombre],
        [descripcion],
        [activo]
    FROM [dbo].[roles]
    ORDER BY [nombre];
END;
GO

-- ==========================================
-- SP 19: sp_listar_familias
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_listar_familias]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        [id_familia],
        [nombre],
        [descripcion],
        [activo]
    FROM [dbo].[familias]
    ORDER BY [nombre];
END;
GO

-- ==========================================
-- SP 20: sp_listar_permisos_usuario
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_listar_permisos_usuario]
    @id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.[id_permiso],
        p.[codigo],
        p.[descripcion],
        p.[modulo],
        up.[fecha_asignacion],
        up.[fecha_expiracion]
    FROM [dbo].[usuario_permisos] AS up
    INNER JOIN [dbo].[permisos] AS p
        ON p.[id_permiso] = up.[id_permiso]
    WHERE up.[id_usuario] = @id_usuario
    ORDER BY p.[modulo], p.[codigo];
END;
GO

-- ==========================================
-- SP 21: sp_listar_roles_usuario
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_listar_roles_usuario]
    @id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        r.[id_rol],
        r.[nombre],
        r.[descripcion],
        r.[activo],
        ur.[fecha_asignacion],
        ur.[fecha_expiracion]
    FROM [dbo].[usuario_roles] AS ur
    INNER JOIN [dbo].[roles] AS r
        ON r.[id_rol] = ur.[id_rol]
    WHERE ur.[id_usuario] = @id_usuario
    ORDER BY r.[nombre];
END;
GO

-- ==========================================
-- SP 22: sp_listar_familias_usuario
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_listar_familias_usuario]
    @id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        f.[id_familia],
        f.[nombre],
        f.[descripcion],
        f.[activo],
        uf.[fecha_asignacion],
        uf.[fecha_expiracion]
    FROM [dbo].[usuario_familias] AS uf
    INNER JOIN [dbo].[familias] AS f
        ON f.[id_familia] = uf.[id_familia]
    WHERE uf.[id_usuario] = @id_usuario
    ORDER BY f.[nombre];
END;
GO

-- ==========================================
-- SP 23: sp_asignar_permiso_usuario
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_asignar_permiso_usuario]
    @id_usuario INT,
    @id_permiso INT,
    @fecha_asignacion DATETIME2 = NULL,
    @fecha_expiracion DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM [dbo].[usuario_permisos]
        WHERE [id_usuario] = @id_usuario
          AND [id_permiso] = @id_permiso
    )
    BEGIN
        INSERT INTO [dbo].[usuario_permisos] (
            [id_usuario],
            [id_permiso],
            [fecha_asignacion],
            [fecha_expiracion]
        )
        VALUES (
            @id_usuario,
            @id_permiso,
            COALESCE(@fecha_asignacion, SYSDATETIME()),
            @fecha_expiracion
        );
    END;
END;
GO

-- ==========================================
-- SP 24: sp_asignar_rol_usuario
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_asignar_rol_usuario]
    @id_usuario INT,
    @id_rol INT,
    @fecha_asignacion DATETIME2 = NULL,
    @fecha_expiracion DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM [dbo].[usuario_roles]
        WHERE [id_usuario] = @id_usuario
          AND [id_rol] = @id_rol
    )
    BEGIN
        INSERT INTO [dbo].[usuario_roles] (
            [id_usuario],
            [id_rol],
            [fecha_asignacion],
            [fecha_expiracion]
        )
        VALUES (
            @id_usuario,
            @id_rol,
            COALESCE(@fecha_asignacion, SYSDATETIME()),
            @fecha_expiracion
        );
    END;
END;
GO

-- ==========================================
-- SP 25: sp_asignar_familia_usuario
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_asignar_familia_usuario]
    @id_usuario INT,
    @id_familia INT,
    @fecha_asignacion DATETIME2 = NULL,
    @fecha_expiracion DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM [dbo].[usuario_familias]
        WHERE [id_usuario] = @id_usuario
          AND [id_familia] = @id_familia
    )
    BEGIN
        INSERT INTO [dbo].[usuario_familias] (
            [id_usuario],
            [id_familia],
            [fecha_asignacion],
            [fecha_expiracion]
        )
        VALUES (
            @id_usuario,
            @id_familia,
            COALESCE(@fecha_asignacion, SYSDATETIME()),
            @fecha_expiracion
        );
    END;
END;
GO

-- ==========================================
-- SP 26: sp_es_primera_password_usuario
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_es_primera_password_usuario]
    @id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CAST(
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM [dbo].[password_historial]
                WHERE [id_usuario] = @id_usuario
            ) THEN 0
            ELSE 1
        END
    AS BIT) AS [es_primera_password];
END;
GO

-- ==========================================
-- SP 27: sp_guardar_pregunta_seguridad
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_guardar_pregunta_seguridad]
    @pregunta VARCHAR(255),
    @id_pregunta INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[preguntas_seguridad] ([pregunta])
    VALUES (@pregunta);

    SET @id_pregunta = CAST(SCOPE_IDENTITY() AS INT);
END;
GO

-- ==========================================
-- SP 28: sp_actualizar_estado_pregunta_seguridad
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_actualizar_estado_pregunta_seguridad]
    @id_pregunta INT,
    @estado BIT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[preguntas_seguridad]
    SET [estado] = @estado
    WHERE [id_pregunta] = @id_pregunta;
END;
GO

-- ==========================================
-- SP 29: sp_listar_preguntas_seguridad
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_listar_preguntas_seguridad]
    @solo_activas BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        [id_pregunta],
        [pregunta],
        [estado]
    FROM [dbo].[preguntas_seguridad]
    WHERE @solo_activas = 0 OR [estado] = 1
    ORDER BY [pregunta];
END;
GO

-- ==========================================
-- SP 30: sp_guardar_respuesta_seguridad
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_guardar_respuesta_seguridad]
    @id_usuario INT,
    @id_pregunta INT,
    @respuesta_hash VARCHAR(256),
    @pista VARCHAR(256) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (
            SELECT 1
            FROM [dbo].[respuestas_seguridad]
            WHERE [id_usuario] = @id_usuario
              AND [id_pregunta] = @id_pregunta
        )
        BEGIN
            UPDATE [dbo].[respuestas_seguridad]
            SET [respuesta_hash] = @respuesta_hash,
                [pista] = @pista
            WHERE [id_usuario] = @id_usuario
              AND [id_pregunta] = @id_pregunta;
        END
        ELSE
        BEGIN
            INSERT INTO [dbo].[respuestas_seguridad] (
                [id_usuario],
                [id_pregunta],
                [respuesta_hash],
                [pista]
            )
            VALUES (
                @id_usuario,
                @id_pregunta,
                @respuesta_hash,
                @pista
            );
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
-- SP 31: sp_actualizar_requiere_cambio_pass
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_actualizar_requiere_cambio_pass]
    @id_usuario INT,
    @requiere_cambio_pass BIT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[usuarios]
    SET [requiere_cambio_pass] = @requiere_cambio_pass
    WHERE [id_usuario] = @id_usuario;
END;
GO

-- ==========================================
-- SP 32: sp_cambiar_password_usuario
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_cambiar_password_usuario]
    @id_usuario INT,
    @password_hash_nuevo VARCHAR(256),
    @requiere_cambio_pass BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO [dbo].[password_historial] (
            [id_usuario],
            [password_hash]
        )
        VALUES (
            @id_usuario,
            @password_hash_nuevo
        );

        UPDATE [dbo].[usuarios]
        SET [password_hash] = @password_hash_nuevo,
            [requiere_cambio_pass] = @requiere_cambio_pass,
            [intentos_fallidos] = 0,
            [bloqueado_hasta] = NULL
        WHERE [id_usuario] = @id_usuario;

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
-- SP 33: sp_obtener_entidad
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_obtener_entidad]
    @id_entidad INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.[id_entidad],
        e.[activo],
        e.[fecha_alta]
    FROM [dbo].[entidades] AS e
    WHERE e.[id_entidad] = @id_entidad;
END;
GO

-- ==========================================
-- SP 34: sp_obtener_fisica
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_obtener_fisica]
    @id_entidad INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        f.[id_entidad],
        f.[nombre],
        f.[apellido],
        f.[fecha_nacimiento],
        f.[id_usuario]
    FROM [dbo].[fisicas] AS f
    WHERE f.[id_entidad] = @id_entidad;
END;
GO

-- ==========================================
-- SP 35: sp_obtener_usuario
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_obtener_usuario]
    @id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        u.[id_usuario],
        u.[username],
        u.[password_hash],
        u.[email],
        u.[estado],
        u.[requiere_cambio_pass],
        u.[intentos_fallidos],
        u.[bloqueado_hasta],
        u.[ultimo_login],
        u.[fecha_alta],
        u.[idioma_iso],
        u.[twofa_habilitado]
    FROM [dbo].[usuarios] AS u
    WHERE u.[id_usuario] = @id_usuario;
END;
GO

-- ==========================================
-- SP 36: sp_listar_documentos_entidad
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_listar_documentos_entidad]
    @id_entidad INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        d.[id_documento],
        d.[id_entidad],
        d.[id_tipo_documento],
        td.[nombre] AS [tipo_documento],
        d.[valor],
        d.[es_principal]
    FROM [dbo].[documentos] AS d
    INNER JOIN [dbo].[tipo_documento] AS td
        ON td.[id_tipo_documento] = d.[id_tipo_documento]
    WHERE d.[id_entidad] = @id_entidad
    ORDER BY d.[es_principal] DESC, td.[nombre], d.[valor];
END;
GO

-- ==========================================
-- SP 37: sp_listar_contactos_entidad
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_listar_contactos_entidad]
    @id_entidad INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.[id_contacto],
        c.[id_entidad],
        c.[id_tipo_contacto],
        tc.[nombre] AS [tipo_contacto],
        c.[valor],
        c.[etiqueta],
        c.[es_principal]
    FROM [dbo].[contactos] AS c
    INNER JOIN [dbo].[tipo_contacto] AS tc
        ON tc.[id_tipo_contacto] = c.[id_tipo_contacto]
    WHERE c.[id_entidad] = @id_entidad
    ORDER BY c.[es_principal] DESC, tc.[nombre], c.[valor];
END;
GO

-- ==========================================
-- SP 38: sp_listar_domicilios_entidad
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_listar_domicilios_entidad]
    @id_entidad INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        dom.[id_domicilio],
        dom.[id_entidad],
        dom.[id_localidad],
        l.[nombre] AS [localidad],
        p.[nombre] AS [provincia],
        pa.[nombre] AS [pais],
        dom.[calle],
        dom.[numero],
        dom.[piso],
        dom.[depto],
        dom.[referencia],
        dom.[tipo],
        dom.[es_principal]
    FROM [dbo].[domicilios] AS dom
    INNER JOIN [dbo].[localidades] AS l
        ON l.[id_localidad] = dom.[id_localidad]
    INNER JOIN [dbo].[provincias] AS p
        ON p.[id_provincia] = l.[id_provincia]
    INNER JOIN [dbo].[paises] AS pa
        ON pa.[id_pais] = p.[id_pais]
    WHERE dom.[id_entidad] = @id_entidad
    ORDER BY dom.[es_principal] DESC, pa.[nombre], p.[nombre], l.[nombre], dom.[calle];
END;
GO

-- ==========================================
-- SP 39: sp_listar_preguntas_seguridad_usuario
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_listar_preguntas_seguridad_usuario]
    @id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        rs.[id],
        rs.[id_usuario],
        rs.[id_pregunta],
        ps.[pregunta],
        rs.[respuesta_hash],
        rs.[pista],
        ps.[estado]
    FROM [dbo].[respuestas_seguridad] AS rs
    INNER JOIN [dbo].[preguntas_seguridad] AS ps
        ON ps.[id_pregunta] = rs.[id_pregunta]
    WHERE rs.[id_usuario] = @id_usuario
    ORDER BY ps.[pregunta];
END;
GO

-- ==========================================
-- SP 40: sp_login_usuario
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_login_usuario]
    @usuario_o_email VARCHAR(256),
    @password_hash VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @id_usuario INT = NULL;
    DECLARE @username VARCHAR(100) = NULL;
    DECLARE @email VARCHAR(256) = NULL;
    DECLARE @estado NVARCHAR(50) = NULL;
    DECLARE @requiere_cambio_pass BIT = NULL;
    DECLARE @intentos_fallidos INT = NULL;
    DECLARE @bloqueado_hasta DATETIME2 = NULL;
    DECLARE @ultimo_login DATETIME2 = NULL;
    DECLARE @fecha_alta DATETIME2 = NULL;
    DECLARE @idioma_iso VARCHAR(5) = NULL;
    DECLARE @twofa_habilitado BIT = NULL;
    DECLARE @password_hash_db VARCHAR(256) = NULL;
    DECLARE @login_intentos_max INT = COALESCE((SELECT TOP (1) [login_intentos_max] FROM [dbo].[configuracion_sistema] WHERE [id_config] = 1), 6);
    DECLARE @login_bloqueo_minutos INT = COALESCE((SELECT TOP (1) [login_bloqueo_minutos] FROM [dbo].[configuracion_sistema] WHERE [id_config] = 1), 15);
    DECLARE @ahora DATETIME2 = SYSDATETIME();
    DECLARE @password_correcta BIT = 0;
    DECLARE @usuario_encontrado BIT = 0;
    DECLARE @login_valido BIT = 0;
    DECLARE @bloqueado BIT = 0;

    SELECT TOP (1)
        @id_usuario = u.[id_usuario],
        @username = u.[username],
        @email = u.[email],
        @estado = u.[estado],
        @requiere_cambio_pass = u.[requiere_cambio_pass],
        @intentos_fallidos = u.[intentos_fallidos],
        @bloqueado_hasta = u.[bloqueado_hasta],
        @ultimo_login = u.[ultimo_login],
        @fecha_alta = u.[fecha_alta],
        @idioma_iso = u.[idioma_iso],
        @twofa_habilitado = u.[twofa_habilitado],
        @password_hash_db = u.[password_hash]
    FROM [dbo].[usuarios] AS u
    WHERE u.[username] = @usuario_o_email
       OR u.[email] = @usuario_o_email;

    IF @id_usuario IS NULL
    BEGIN
        SELECT
            CAST(0 AS BIT) AS [login_valido],
            CAST(0 AS BIT) AS [usuario_encontrado],
            CAST(0 AS BIT) AS [password_correcta],
            CAST(NULL AS INT) AS [id_usuario],
            CAST(NULL AS VARCHAR(100)) AS [username],
            CAST(NULL AS VARCHAR(256)) AS [email],
            CAST(NULL AS NVARCHAR(50)) AS [estado],
            CAST(NULL AS BIT) AS [requiere_cambio_pass],
            CAST(NULL AS INT) AS [intentos_fallidos],
            CAST(NULL AS DATETIME2) AS [bloqueado_hasta],
            CAST(NULL AS DATETIME2) AS [ultimo_login],
            CAST(NULL AS DATETIME2) AS [fecha_alta],
            CAST(NULL AS VARCHAR(5)) AS [idioma_iso],
            CAST(NULL AS BIT) AS [twofa_habilitado];
        RETURN;
    END;

    SET @usuario_encontrado = 1;

    IF @estado <> N'activo'
    BEGIN
        SELECT
            CAST(0 AS BIT) AS [login_valido],
            CAST(1 AS BIT) AS [usuario_encontrado],
            CAST(0 AS BIT) AS [password_correcta],
            @id_usuario AS [id_usuario],
            @username AS [username],
            @email AS [email],
            @estado AS [estado],
            @requiere_cambio_pass AS [requiere_cambio_pass],
            @intentos_fallidos AS [intentos_fallidos],
            @bloqueado_hasta AS [bloqueado_hasta],
            @ultimo_login AS [ultimo_login],
            @fecha_alta AS [fecha_alta],
            @idioma_iso AS [idioma_iso],
            @twofa_habilitado AS [twofa_habilitado];
        RETURN;
    END;

    IF @bloqueado_hasta IS NOT NULL AND @bloqueado_hasta > @ahora
    BEGIN
        SET @bloqueado = 1;

        SELECT
            CAST(0 AS BIT) AS [login_valido],
            CAST(1 AS BIT) AS [usuario_encontrado],
            CAST(0 AS BIT) AS [password_correcta],
            @id_usuario AS [id_usuario],
            @username AS [username],
            @email AS [email],
            @estado AS [estado],
            @requiere_cambio_pass AS [requiere_cambio_pass],
            @intentos_fallidos AS [intentos_fallidos],
            @bloqueado_hasta AS [bloqueado_hasta],
            @ultimo_login AS [ultimo_login],
            @fecha_alta AS [fecha_alta],
            @idioma_iso AS [idioma_iso],
            @twofa_habilitado AS [twofa_habilitado];
        RETURN;
    END;

    IF @password_hash_db = @password_hash
    BEGIN
        SET @password_correcta = 1;
        SET @login_valido = 1;
        SET @intentos_fallidos = 0;
        SET @bloqueado_hasta = NULL;

        UPDATE [dbo].[usuarios]
        SET [intentos_fallidos] = 0,
            [bloqueado_hasta] = NULL,
            [ultimo_login] = @ahora
        WHERE [id_usuario] = @id_usuario;

        SELECT
            CAST(1 AS BIT) AS [login_valido],
            CAST(1 AS BIT) AS [usuario_encontrado],
            CAST(1 AS BIT) AS [password_correcta],
            @id_usuario AS [id_usuario],
            @username AS [username],
            @email AS [email],
            @estado AS [estado],
            @requiere_cambio_pass AS [requiere_cambio_pass],
            @intentos_fallidos AS [intentos_fallidos],
            @bloqueado_hasta AS [bloqueado_hasta],
            @ahora AS [ultimo_login],
            @fecha_alta AS [fecha_alta],
            @idioma_iso AS [idioma_iso],
            @twofa_habilitado AS [twofa_habilitado];
        RETURN;
    END;

    SET @intentos_fallidos = ISNULL(@intentos_fallidos, 0) + 1;
    SET @bloqueado_hasta = CASE
        WHEN @intentos_fallidos >= @login_intentos_max THEN DATEADD(MINUTE, @login_bloqueo_minutos, @ahora)
        ELSE NULL
    END;

    UPDATE [dbo].[usuarios]
    SET [intentos_fallidos] = @intentos_fallidos,
        [bloqueado_hasta] = @bloqueado_hasta
    WHERE [id_usuario] = @id_usuario;

    SELECT
        CAST(0 AS BIT) AS [login_valido],
        CAST(1 AS BIT) AS [usuario_encontrado],
        CAST(0 AS BIT) AS [password_correcta],
        @id_usuario AS [id_usuario],
        @username AS [username],
        @email AS [email],
        @estado AS [estado],
        @requiere_cambio_pass AS [requiere_cambio_pass],
        @intentos_fallidos AS [intentos_fallidos],
        @bloqueado_hasta AS [bloqueado_hasta],
        @ultimo_login AS [ultimo_login],
        @fecha_alta AS [fecha_alta],
        @idioma_iso AS [idioma_iso],
        @twofa_habilitado AS [twofa_habilitado];
END;
GO

-- ==========================================
-- SP 41: sp_resumen_accesos_usuario
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_resumen_accesos_usuario]
    @id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        CAST('familia' AS VARCHAR(20)) AS [tipo_acceso],
        f.[id_familia] AS [id_acceso],
        f.[nombre] AS [nombre_acceso],
        f.[descripcion],
        f.[activo],
        uf.[fecha_asignacion],
        uf.[fecha_expiracion]
    FROM [dbo].[usuario_familias] AS uf
    INNER JOIN [dbo].[familias] AS f
        ON f.[id_familia] = uf.[id_familia]
    WHERE uf.[id_usuario] = @id_usuario

    UNION ALL

    SELECT
        CAST('rol' AS VARCHAR(20)) AS [tipo_acceso],
        r.[id_rol] AS [id_acceso],
        r.[nombre] AS [nombre_acceso],
        r.[descripcion],
        r.[activo],
        ur.[fecha_asignacion],
        ur.[fecha_expiracion]
    FROM [dbo].[usuario_roles] AS ur
    INNER JOIN [dbo].[roles] AS r
        ON r.[id_rol] = ur.[id_rol]
    WHERE ur.[id_usuario] = @id_usuario

    UNION ALL

    SELECT
        CAST('permiso' AS VARCHAR(20)) AS [tipo_acceso],
        p.[id_permiso] AS [id_acceso],
        p.[codigo] AS [nombre_acceso],
        p.[descripcion],
        CAST(1 AS BIT) AS [activo],
        up.[fecha_asignacion],
        up.[fecha_expiracion]
    FROM [dbo].[usuario_permisos] AS up
    INNER JOIN [dbo].[permisos] AS p
        ON p.[id_permiso] = up.[id_permiso]
    WHERE up.[id_usuario] = @id_usuario
    ORDER BY [tipo_acceso], [nombre_acceso];
END;
GO

-- ==========================================
-- SP 42: sp_guardar_codigo_twofa_usuario
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_guardar_codigo_twofa_usuario]
    @id_usuario INT,
    @codigo_hash VARCHAR(256),
    @minutos_vigencia INT = 10,
    @id_codigo INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ahora DATETIME2 = SYSDATETIME();
    DECLARE @fecha_expira DATETIME2 = DATEADD(MINUTE, @minutos_vigencia, @ahora);

    UPDATE [dbo].[usuarios_twofa_codigos]
    SET [estado] = 'caducado'
    WHERE [id_usuario] = @id_usuario
      AND [estado] = 'vigente';

    INSERT INTO [dbo].[usuarios_twofa_codigos]
        ([id_usuario], [codigo_hash], [fecha_creado], [fecha_expira], [estado])
    VALUES
        (@id_usuario, @codigo_hash, @ahora, @fecha_expira, 'vigente');

    SET @id_codigo = SCOPE_IDENTITY();

    SELECT
        @id_codigo AS [id_codigo],
        @id_usuario AS [id_usuario],
        @ahora AS [fecha_creado],
        @fecha_expira AS [fecha_expira],
        CAST('vigente' AS NVARCHAR(20)) AS [estado];
END;
GO

-- ==========================================
-- SP 43: sp_obtener_codigos_twofa_usuario
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_obtener_codigos_twofa_usuario]
    @id_usuario INT,
    @estado NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.[id_codigo],
        c.[id_usuario],
        c.[codigo_hash],
        c.[fecha_creado],
        c.[fecha_expira],
        c.[estado],
        c.[fecha_uso],
        c.[intentos_verificacion]
    FROM [dbo].[usuarios_twofa_codigos] AS c
    WHERE c.[id_usuario] = @id_usuario
      AND (@estado IS NULL OR c.[estado] = @estado)
    ORDER BY c.[fecha_creado] DESC;
END;
GO

-- ==========================================
-- SP 44: sp_actualizar_estado_codigo_twofa_usuario
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_actualizar_estado_codigo_twofa_usuario]
    @id_codigo INT,
    @estado NVARCHAR(20),
    @fecha_uso DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @fecha_uso_final DATETIME2 = @fecha_uso;

    IF @estado = 'usado' AND @fecha_uso_final IS NULL
    BEGIN
        SET @fecha_uso_final = SYSDATETIME();
    END;

    UPDATE [dbo].[usuarios_twofa_codigos]
    SET [estado] = @estado,
        [fecha_uso] = @fecha_uso_final
    WHERE [id_codigo] = @id_codigo;

    SELECT
        c.[id_codigo],
        c.[id_usuario],
        c.[fecha_creado],
        c.[fecha_expira],
        c.[estado],
        c.[fecha_uso],
        c.[intentos_verificacion]
    FROM [dbo].[usuarios_twofa_codigos] AS c
    WHERE c.[id_codigo] = @id_codigo;
END;
GO

-- ==========================================
-- SP 45: sp_validar_codigo_twofa_usuario
-- ==========================================
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_validar_codigo_twofa_usuario]
    @id_usuario INT,
    @codigo_hash VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ahora DATETIME2 = SYSDATETIME();
    DECLARE @id_codigo INT = NULL;
    DECLARE @codigo_vigente VARCHAR(256) = NULL;
    DECLARE @fecha_expira DATETIME2 = NULL;

    SELECT TOP (1)
        @id_codigo = c.[id_codigo],
        @codigo_vigente = c.[codigo_hash],
        @fecha_expira = c.[fecha_expira]
    FROM [dbo].[usuarios_twofa_codigos] AS c
    WHERE c.[id_usuario] = @id_usuario
      AND c.[estado] = 'vigente'
    ORDER BY c.[fecha_creado] DESC;

    IF @id_codigo IS NULL
    BEGIN
        SELECT
            CAST(0 AS BIT) AS [codigo_valido],
            CAST(0 AS BIT) AS [codigo_encontrado],
            CAST(NULL AS INT) AS [id_codigo],
            CAST(NULL AS DATETIME2) AS [fecha_expira],
            CAST(NULL AS NVARCHAR(20)) AS [estado];
        RETURN;
    END;

    IF @fecha_expira IS NOT NULL AND @fecha_expira < @ahora
    BEGIN
        UPDATE [dbo].[usuarios_twofa_codigos]
        SET [estado] = 'caducado'
        WHERE [id_codigo] = @id_codigo;

        SELECT
            CAST(0 AS BIT) AS [codigo_valido],
            CAST(1 AS BIT) AS [codigo_encontrado],
            @id_codigo AS [id_codigo],
            @fecha_expira AS [fecha_expira],
            CAST('caducado' AS NVARCHAR(20)) AS [estado];
        RETURN;
    END;

    IF @codigo_vigente = @codigo_hash
    BEGIN
        UPDATE [dbo].[usuarios_twofa_codigos]
        SET [estado] = 'usado',
            [fecha_uso] = @ahora
        WHERE [id_codigo] = @id_codigo;

        SELECT
            CAST(1 AS BIT) AS [codigo_valido],
            CAST(1 AS BIT) AS [codigo_encontrado],
            @id_codigo AS [id_codigo],
            @fecha_expira AS [fecha_expira],
            CAST('usado' AS NVARCHAR(20)) AS [estado];
        RETURN;
    END;

    UPDATE [dbo].[usuarios_twofa_codigos]
    SET [intentos_verificacion] = ISNULL([intentos_verificacion], 0) + 1
    WHERE [id_codigo] = @id_codigo;

    SELECT
        CAST(0 AS BIT) AS [codigo_valido],
        CAST(1 AS BIT) AS [codigo_encontrado],
        @id_codigo AS [id_codigo],
        @fecha_expira AS [fecha_expira],
        CAST('vigente' AS NVARCHAR(20)) AS [estado];
END;
GO
