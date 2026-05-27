DECLARE @id_entidad INT = 0; -- cambiar por el ID real

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @id_usuario INT = NULL;
    DECLARE @id_fisica INT = NULL;
    DECLARE @id_juridica INT = NULL;
    DECLARE @id_cliente INT = NULL;
    DECLARE @id_proveedor INT = NULL;

    SELECT @id_usuario = f.[id_usuario]
    FROM [dbo].[fisicas] AS f
    WHERE f.[id_entidad] = @id_entidad;

    IF EXISTS (SELECT 1 FROM [dbo].[fisicas] WHERE [id_entidad] = @id_entidad)
        SET @id_fisica = @id_entidad;

    IF EXISTS (SELECT 1 FROM [dbo].[juridicas] WHERE [id_entidad] = @id_entidad)
        SET @id_juridica = @id_entidad;

    SELECT @id_cliente = c.[id_cliente]
    FROM [dbo].[clientes] AS c
    WHERE c.[id_entidad] = @id_entidad;

    SELECT @id_proveedor = p.[id_proveedor]
    FROM [dbo].[proveedores] AS p
    WHERE p.[id_entidad] = @id_entidad;

    -- Seguridad del usuario
    IF @id_usuario IS NOT NULL
    BEGIN
        DELETE FROM [dbo].[password_historial]
        WHERE [id_usuario] = @id_usuario;

        DELETE FROM [dbo].[respuestas_seguridad]
        WHERE [id_usuario] = @id_usuario;

        DELETE FROM [dbo].[usuario_permisos]
        WHERE [id_usuario] = @id_usuario;

        DELETE FROM [dbo].[usuario_roles]
        WHERE [id_usuario] = @id_usuario;

        DELETE FROM [dbo].[usuario_familias]
        WHERE [id_usuario] = @id_usuario;
    END;

    -- Relaciones de la entidad
    DELETE FROM [dbo].[contactos]
    WHERE [id_entidad] = @id_entidad;

    DELETE FROM [dbo].[documentos]
    WHERE [id_entidad] = @id_entidad;

    DELETE FROM [dbo].[domicilios]
    WHERE [id_entidad] = @id_entidad;

    DELETE FROM [dbo].[entidad_tipos]
    WHERE [id_entidad] = @id_entidad;

    -- Subtipos de entidad
    DELETE FROM [dbo].[empleados]
    WHERE [id_entidad] = @id_entidad;

    DELETE FROM [dbo].[clientes]
    WHERE [id_entidad] = @id_entidad;

    DELETE FROM [dbo].[proveedores]
    WHERE [id_entidad] = @id_entidad;

    DELETE FROM [dbo].[fisicas_juridicas]
    WHERE [id_fisicas] = @id_entidad
       OR [id_juridica] = @id_entidad;

    -- Persona / empresa base
    IF @id_fisica IS NOT NULL
    BEGIN
        UPDATE [dbo].[fisicas]
        SET [id_usuario] = NULL
        WHERE [id_entidad] = @id_fisica;

        DELETE FROM [dbo].[fisicas]
        WHERE [id_entidad] = @id_fisica;
    END;

    IF @id_juridica IS NOT NULL
    BEGIN
        DELETE FROM [dbo].[juridicas]
        WHERE [id_entidad] = @id_juridica;
    END;

    -- Usuario
    IF @id_usuario IS NOT NULL
    BEGIN
        DELETE FROM [dbo].[usuarios]
        WHERE [id_usuario] = @id_usuario;
    END;

    -- Entidad base
    DELETE FROM [dbo].[entidades]
    WHERE [id_entidad] = @id_entidad;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;