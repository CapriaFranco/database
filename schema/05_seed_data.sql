-- ==========================================
-- Seed data inicial para SQL Server 2019
-- ==========================================

USE [theEnterprise7mo2da];
GO

-- ==========================================
-- PERMISOS
-- ==========================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[permisos] WHERE [codigo] = 'crearUsuarios')
BEGIN
    INSERT INTO [dbo].[permisos] ([codigo], [descripcion], [modulo])
    VALUES ('crearUsuarios', 'Permite crear usuarios del sistema', 'usuarios');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[permisos] WHERE [codigo] = 'crearEntidad')
BEGIN
    INSERT INTO [dbo].[permisos] ([codigo], [descripcion], [modulo])
    VALUES ('crearEntidad', 'Permite crear una entidad base', 'entidades');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[permisos] WHERE [codigo] = 'anadirContactosEntidad')
BEGIN
    INSERT INTO [dbo].[permisos] ([codigo], [descripcion], [modulo])
    VALUES ('anadirContactosEntidad', 'Permite agregar contactos a una entidad', 'entidades');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[permisos] WHERE [codigo] = 'anadirDocumentosEntidad')
BEGIN
    INSERT INTO [dbo].[permisos] ([codigo], [descripcion], [modulo])
    VALUES ('anadirDocumentosEntidad', 'Permite agregar documentos a una entidad', 'entidades');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[permisos] WHERE [codigo] = 'anadirUbicacionEntidad')
BEGIN
    INSERT INTO [dbo].[permisos] ([codigo], [descripcion], [modulo])
    VALUES ('anadirUbicacionEntidad', 'Permite agregar domicilios a una entidad', 'entidades');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[permisos] WHERE [codigo] = 'anadirRolUsuario')
BEGIN
    INSERT INTO [dbo].[permisos] ([codigo], [descripcion], [modulo])
    VALUES ('anadirRolUsuario', 'Permite asignar roles a un usuario', 'usuarios');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[permisos] WHERE [codigo] = 'anadirPermisoUsuario')
BEGIN
    INSERT INTO [dbo].[permisos] ([codigo], [descripcion], [modulo])
    VALUES ('anadirPermisoUsuario', 'Permite asignar permisos directos a un usuario', 'usuarios');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[permisos] WHERE [codigo] = 'anadirFamiliaUsuario')
BEGIN
    INSERT INTO [dbo].[permisos] ([codigo], [descripcion], [modulo])
    VALUES ('anadirFamiliaUsuario', 'Permite asignar familias a un usuario', 'usuarios');
END;

-- ==========================================
-- ROLES
-- ==========================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[roles] WHERE [nombre] = 'crearEntidad')
BEGIN
    INSERT INTO [dbo].[roles] ([nombre], [descripcion], [activo])
    VALUES ('crearEntidad', 'Rol base para gestionar entidades', 1);
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[roles] WHERE [nombre] = 'crearUsuario')
BEGIN
    INSERT INTO [dbo].[roles] ([nombre], [descripcion], [activo])
    VALUES ('crearUsuario', 'Rol base para gestionar usuarios', 1);
END;

-- ==========================================
-- FAMILIAS
-- ==========================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[familias] WHERE [nombre] = 'ADMIN')
BEGIN
    INSERT INTO [dbo].[familias] ([nombre], [descripcion], [activo])
    VALUES ('ADMIN', 'Familia administrativa principal del sistema', 1);
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[familias] WHERE [nombre] = 'USER')
BEGIN
    INSERT INTO [dbo].[familias] ([nombre], [descripcion], [activo])
    VALUES ('USER', 'Familia base de usuarios del sistema', 1);
END;

-- ==========================================
-- RELACIONES ENTRE FAMILIAS Y ROLES
-- ==========================================
DECLARE @id_familia_admin INT;
DECLARE @id_rol_crear_entidad INT;
DECLARE @id_rol_crear_usuario INT;

SELECT @id_familia_admin = [id_familia]
FROM [dbo].[familias]
WHERE [nombre] = 'ADMIN';

SELECT @id_rol_crear_entidad = [id_rol]
FROM [dbo].[roles]
WHERE [nombre] = 'crearEntidad';

SELECT @id_rol_crear_usuario = [id_rol]
FROM [dbo].[roles]
WHERE [nombre] = 'crearUsuario';

IF NOT EXISTS (
    SELECT 1
    FROM [dbo].[familia_roles]
    WHERE [id_familia] = @id_familia_admin
      AND [id_rol] = @id_rol_crear_entidad
)
BEGIN
    INSERT INTO [dbo].[familia_roles] ([id_familia], [id_rol])
    VALUES (@id_familia_admin, @id_rol_crear_entidad);
END;

IF NOT EXISTS (
    SELECT 1
    FROM [dbo].[familia_roles]
    WHERE [id_familia] = @id_familia_admin
      AND [id_rol] = @id_rol_crear_usuario
)
BEGIN
    INSERT INTO [dbo].[familia_roles] ([id_familia], [id_rol])
    VALUES (@id_familia_admin, @id_rol_crear_usuario);
END;

-- ==========================================
-- RELACIONES ENTRE ROLES Y PERMISOS
-- ==========================================
DECLARE @id_perm_crear_usuarios INT;
DECLARE @id_perm_crear_entidad INT;
DECLARE @id_perm_contactos INT;
DECLARE @id_perm_documentos INT;
DECLARE @id_perm_ubicacion INT;
DECLARE @id_perm_rol_usuario INT;
DECLARE @id_perm_permiso_usuario INT;
DECLARE @id_perm_familia_usuario INT;

SELECT @id_perm_crear_usuarios = [id_permiso] FROM [dbo].[permisos] WHERE [codigo] = 'crearUsuarios';
SELECT @id_perm_crear_entidad = [id_permiso] FROM [dbo].[permisos] WHERE [codigo] = 'crearEntidad';
SELECT @id_perm_contactos = [id_permiso] FROM [dbo].[permisos] WHERE [codigo] = 'anadirContactosEntidad';
SELECT @id_perm_documentos = [id_permiso] FROM [dbo].[permisos] WHERE [codigo] = 'anadirDocumentosEntidad';
SELECT @id_perm_ubicacion = [id_permiso] FROM [dbo].[permisos] WHERE [codigo] = 'anadirUbicacionEntidad';
SELECT @id_perm_rol_usuario = [id_permiso] FROM [dbo].[permisos] WHERE [codigo] = 'anadirRolUsuario';
SELECT @id_perm_permiso_usuario = [id_permiso] FROM [dbo].[permisos] WHERE [codigo] = 'anadirPermisoUsuario';
SELECT @id_perm_familia_usuario = [id_permiso] FROM [dbo].[permisos] WHERE [codigo] = 'anadirFamiliaUsuario';

IF NOT EXISTS (
    SELECT 1 FROM [dbo].[rol_permisos]
    WHERE [id_rol] = @id_rol_crear_entidad AND [id_permiso] = @id_perm_crear_entidad
)
BEGIN
    INSERT INTO [dbo].[rol_permisos] ([id_rol], [id_permiso])
    VALUES (@id_rol_crear_entidad, @id_perm_crear_entidad);
END;

IF @id_perm_contactos IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM [dbo].[rol_permisos]
    WHERE [id_rol] = @id_rol_crear_entidad AND [id_permiso] = @id_perm_contactos
)
BEGIN
    INSERT INTO [dbo].[rol_permisos] ([id_rol], [id_permiso])
    VALUES (@id_rol_crear_entidad, @id_perm_contactos);
END;

IF @id_perm_documentos IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM [dbo].[rol_permisos]
    WHERE [id_rol] = @id_rol_crear_entidad AND [id_permiso] = @id_perm_documentos
)
BEGIN
    INSERT INTO [dbo].[rol_permisos] ([id_rol], [id_permiso])
    VALUES (@id_rol_crear_entidad, @id_perm_documentos);
END;

IF @id_perm_ubicacion IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM [dbo].[rol_permisos]
    WHERE [id_rol] = @id_rol_crear_entidad AND [id_permiso] = @id_perm_ubicacion
)
BEGIN
    INSERT INTO [dbo].[rol_permisos] ([id_rol], [id_permiso])
    VALUES (@id_rol_crear_entidad, @id_perm_ubicacion);
END;

IF @id_perm_crear_usuarios IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM [dbo].[rol_permisos]
    WHERE [id_rol] = @id_rol_crear_usuario AND [id_permiso] = @id_perm_crear_usuarios
)
BEGIN
    INSERT INTO [dbo].[rol_permisos] ([id_rol], [id_permiso])
    VALUES (@id_rol_crear_usuario, @id_perm_crear_usuarios);
END;

IF @id_perm_rol_usuario IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM [dbo].[rol_permisos]
    WHERE [id_rol] = @id_rol_crear_usuario AND [id_permiso] = @id_perm_rol_usuario
)
BEGIN
    INSERT INTO [dbo].[rol_permisos] ([id_rol], [id_permiso])
    VALUES (@id_rol_crear_usuario, @id_perm_rol_usuario);
END;

IF @id_perm_permiso_usuario IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM [dbo].[rol_permisos]
    WHERE [id_rol] = @id_rol_crear_usuario AND [id_permiso] = @id_perm_permiso_usuario
)
BEGIN
    INSERT INTO [dbo].[rol_permisos] ([id_rol], [id_permiso])
    VALUES (@id_rol_crear_usuario, @id_perm_permiso_usuario);
END;

IF @id_perm_familia_usuario IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM [dbo].[rol_permisos]
    WHERE [id_rol] = @id_rol_crear_usuario AND [id_permiso] = @id_perm_familia_usuario
)
BEGIN
    INSERT INTO [dbo].[rol_permisos] ([id_rol], [id_permiso])
    VALUES (@id_rol_crear_usuario, @id_perm_familia_usuario);
END;

-- ==========================================
-- PAISES / PROVINCIAS / LOCALIDADES
-- ==========================================

IF NOT EXISTS (SELECT 1 FROM [dbo].[paises] WHERE [codigo] = 'AR')
BEGIN
    INSERT INTO [dbo].[paises] ([nombre], [codigo])
    VALUES ('Argentina', 'AR');
END;

DECLARE @id_pais_ar INT;
SELECT @id_pais_ar = [id_pais]
FROM [dbo].[paises]
WHERE [codigo] = 'AR';

IF NOT EXISTS (SELECT 1 FROM [dbo].[provincias] WHERE [nombre] = 'Buenos Aires' AND [id_pais] = @id_pais_ar)
BEGIN
    INSERT INTO [dbo].[provincias] ([id_pais], [nombre])
    VALUES (@id_pais_ar, 'Buenos Aires');
END;

DECLARE @id_provincia_ba INT;
SELECT @id_provincia_ba = [id_provincia]
FROM [dbo].[provincias]
WHERE [nombre] = 'Buenos Aires' AND [id_pais] = @id_pais_ar;

IF NOT EXISTS (SELECT 1 FROM [dbo].[localidades] WHERE [nombre] = 'Temperley' AND [id_provincia] = @id_provincia_ba)
BEGIN
    INSERT INTO [dbo].[localidades] ([id_provincia], [nombre], [codigo_postal])
    VALUES (@id_provincia_ba, 'Temperley', '1834');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[localidades] WHERE [nombre] = 'Lomas de Zamora' AND [id_provincia] = @id_provincia_ba)
BEGIN
    INSERT INTO [dbo].[localidades] ([id_provincia], [nombre], [codigo_postal])
    VALUES (@id_provincia_ba, 'Lomas de Zamora', '1832');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[localidades] WHERE [nombre] = 'Quilmes' AND [id_provincia] = @id_provincia_ba)
BEGIN
    INSERT INTO [dbo].[localidades] ([id_provincia], [nombre], [codigo_postal])
    VALUES (@id_provincia_ba, 'Quilmes', '1878');
END;

-- ==========================================
-- TIPOS DE DOCUMENTOS
-- ==========================================

IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_documento] WHERE [nombre] = 'DNI')
BEGIN
    INSERT INTO [dbo].[tipo_documento] ([nombre], [aplica_a])
    VALUES ('DNI', 'persona');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_documento] WHERE [nombre] = 'CUIL')
BEGIN
    INSERT INTO [dbo].[tipo_documento] ([nombre], [aplica_a])
    VALUES ('CUIL', 'persona');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_documento] WHERE [nombre] = 'Pasaporte')
BEGIN
    INSERT INTO [dbo].[tipo_documento] ([nombre], [aplica_a])
    VALUES ('Pasaporte', 'persona');
END;

-- ==========================================
-- PREGUNTAS DE SEGURIDAD
-- ==========================================

IF NOT EXISTS (SELECT 1 FROM [dbo].[preguntas_seguridad] WHERE [pregunta] = '¿Cuál fue el nombre de tu primera mascota?')
BEGIN
    INSERT INTO [dbo].[preguntas_seguridad] ([pregunta], [estado])
    VALUES ('¿Cuál fue el nombre de tu primera mascota?', 1);
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[preguntas_seguridad] WHERE [pregunta] = '¿Cuál es tu comida favorita?')
BEGIN
    INSERT INTO [dbo].[preguntas_seguridad] ([pregunta], [estado])
    VALUES ('¿Cuál es tu comida favorita?', 1);
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[preguntas_seguridad] WHERE [pregunta] = '¿Cómo se llamaba tu mejor amigo de la infancia?')
BEGIN
    INSERT INTO [dbo].[preguntas_seguridad] ([pregunta], [estado])
    VALUES ('¿Cómo se llamaba tu mejor amigo de la infancia?', 1);
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[preguntas_seguridad] WHERE [pregunta] = '¿En qué ciudad naciste?')
BEGIN
    INSERT INTO [dbo].[preguntas_seguridad] ([pregunta], [estado])
    VALUES ('¿En qué ciudad naciste?', 1);
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[preguntas_seguridad] WHERE [pregunta] = '¿Cuál era el nombre de tu escuela primaria?')
BEGIN
    INSERT INTO [dbo].[preguntas_seguridad] ([pregunta], [estado])
    VALUES ('¿Cuál era el nombre de tu escuela primaria?', 1);
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[preguntas_seguridad] WHERE [pregunta] = '¿Cuál es el segundo nombre de tu madre?')
BEGIN
    INSERT INTO [dbo].[preguntas_seguridad] ([pregunta], [estado])
    VALUES ('¿Cuál es el segundo nombre de tu madre?', 1);
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[preguntas_seguridad] WHERE [pregunta] = '¿Cuál es el apellido de soltera de tu madre?')
BEGIN
    INSERT INTO [dbo].[preguntas_seguridad] ([pregunta], [estado])
    VALUES ('¿Cuál es el apellido de soltera de tu madre?', 1);
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[preguntas_seguridad] WHERE [pregunta] = '¿Cuál fue tu primer auto?')
BEGIN
    INSERT INTO [dbo].[preguntas_seguridad] ([pregunta], [estado])
    VALUES ('¿Cuál fue tu primer auto?', 1);
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[preguntas_seguridad] WHERE [pregunta] = '¿Cuál es tu libro favorito?')
BEGIN
    INSERT INTO [dbo].[preguntas_seguridad] ([pregunta], [estado])
    VALUES ('¿Cuál es tu libro favorito?', 1);
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[preguntas_seguridad] WHERE [pregunta] = '¿Cuál era tu apodo de niño?')
BEGIN
    INSERT INTO [dbo].[preguntas_seguridad] ([pregunta], [estado])
    VALUES ('¿Cuál era tu apodo de niño?', 1);
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[preguntas_seguridad] WHERE [pregunta] = '¿Cómo se llamaba tu primera maestra?')
BEGIN
    INSERT INTO [dbo].[preguntas_seguridad] ([pregunta], [estado])
    VALUES ('¿Cómo se llamaba tu primera maestra?', 1);
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[preguntas_seguridad] WHERE [pregunta] = '¿Cuál es tu color favorito?')
BEGIN
    INSERT INTO [dbo].[preguntas_seguridad] ([pregunta], [estado])
    VALUES ('¿Cuál es tu color favorito?', 1);
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[preguntas_seguridad] WHERE [pregunta] = '¿En qué barrio viviste de chico?')
BEGIN
    INSERT INTO [dbo].[preguntas_seguridad] ([pregunta], [estado])
    VALUES ('¿En qué barrio viviste de chico?', 1);
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[preguntas_seguridad] WHERE [pregunta] = '¿Cuál fue el nombre de tu primer jefe?')
BEGIN
    INSERT INTO [dbo].[preguntas_seguridad] ([pregunta], [estado])
    VALUES ('¿Cuál fue el nombre de tu primer jefe?', 1);
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[preguntas_seguridad] WHERE [pregunta] = '¿Cuál es tu película favorita?')
BEGIN
    INSERT INTO [dbo].[preguntas_seguridad] ([pregunta], [estado])
    VALUES ('¿Cuál es tu película favorita?', 1);
END;

-- ==========================================
-- TIPOS DE CONTACTO
-- ==========================================

IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_contacto] WHERE [nombre] = 'Email')
BEGIN
    INSERT INTO [dbo].[tipo_contacto] ([nombre])
    VALUES ('Email');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_contacto] WHERE [nombre] = 'Telefono')
BEGIN
    INSERT INTO [dbo].[tipo_contacto] ([nombre])
    VALUES ('Telefono');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_contacto] WHERE [nombre] = 'WhatsApp')
BEGIN
    INSERT INTO [dbo].[tipo_contacto] ([nombre])
    VALUES ('WhatsApp');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_contacto] WHERE [nombre] = 'Instagram')
BEGIN
    INSERT INTO [dbo].[tipo_contacto] ([nombre])
    VALUES ('Instagram');
END;

-- ==========================================
-- TIPOS DE ENTIDAD
-- ==========================================

IF NOT EXISTS (SELECT 1 FROM [dbo].[entidad_tipo] WHERE [nombre] = 'Proveedor')
BEGIN
    INSERT INTO [dbo].[entidad_tipo] ([nombre])
    VALUES ('Proveedor');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[entidad_tipo] WHERE [nombre] = 'Cliente')
BEGIN
    INSERT INTO [dbo].[entidad_tipo] ([nombre])
    VALUES ('Cliente');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[entidad_tipo] WHERE [nombre] = 'Empleado')
BEGIN
    INSERT INTO [dbo].[entidad_tipo] ([nombre])
    VALUES ('Empleado');
END;

-- ==========================================
-- MEDIOS DE PAGO
-- ==========================================

IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_metodo_pago] WHERE [nombre] = 'Efectivo')
BEGIN
    INSERT INTO [dbo].[tipo_metodo_pago] ([nombre])
    VALUES ('Efectivo');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_metodo_pago] WHERE [nombre] = 'Tarjeta')
BEGIN
    INSERT INTO [dbo].[tipo_metodo_pago] ([nombre])
    VALUES ('Tarjeta');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_metodo_pago] WHERE [nombre] = 'Digital')
BEGIN
    INSERT INTO [dbo].[tipo_metodo_pago] ([nombre])
    VALUES ('Digital');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_metodo_pago] WHERE [nombre] = 'Cheque')
BEGIN
    INSERT INTO [dbo].[tipo_metodo_pago] ([nombre])
    VALUES ('Cheque');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_metodo_pago] WHERE [nombre] = 'Transferencia')
BEGIN
    INSERT INTO [dbo].[tipo_metodo_pago] ([nombre])
    VALUES ('Transferencia');
END;

-- ==========================================
-- TIPOS DE SOCIEDAD
-- ==========================================

IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_social] WHERE [nombre] = 'S.A.')
BEGIN
    INSERT INTO [dbo].[tipo_social] ([nombre])
    VALUES ('S.A.');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_social] WHERE [nombre] = 'S.R.L.')
BEGIN
    INSERT INTO [dbo].[tipo_social] ([nombre])
    VALUES ('S.R.L.');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_social] WHERE [nombre] = 'S.A.S.')
BEGIN
    INSERT INTO [dbo].[tipo_social] ([nombre])
    VALUES ('S.A.S.');
END;

-- ==========================================
-- TIPOS DE ACCION
-- ==========================================

IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_accion] WHERE [nombre] = 'INSERT')
BEGIN
    INSERT INTO [dbo].[tipo_accion] ([nombre])
    VALUES ('INSERT');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_accion] WHERE [nombre] = 'UPDATE')
BEGIN
    INSERT INTO [dbo].[tipo_accion] ([nombre])
    VALUES ('UPDATE');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_accion] WHERE [nombre] = 'DELETE')
BEGIN
    INSERT INTO [dbo].[tipo_accion] ([nombre])
    VALUES ('DELETE');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_accion] WHERE [nombre] = 'LOGIN')
BEGIN
    INSERT INTO [dbo].[tipo_accion] ([nombre])
    VALUES ('LOGIN');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_accion] WHERE [nombre] = 'LOGOUT')
BEGIN
    INSERT INTO [dbo].[tipo_accion] ([nombre])
    VALUES ('LOGOUT');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_accion] WHERE [nombre] = 'CAMBIO_ESTADO')
BEGIN
    INSERT INTO [dbo].[tipo_accion] ([nombre])
    VALUES ('CAMBIO_ESTADO');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_accion] WHERE [nombre] = 'CAMBIO_PASS')
BEGIN
    INSERT INTO [dbo].[tipo_accion] ([nombre])
    VALUES ('CAMBIO_PASS');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_accion] WHERE [nombre] = 'BLOQUEO')
BEGIN
    INSERT INTO [dbo].[tipo_accion] ([nombre])
    VALUES ('BLOQUEO');
END;
