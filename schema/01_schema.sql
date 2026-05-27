-- ==========================================
-- SCHEMA DEFINICION
-- ==========================================

USE [theEnterprise7mo2da];
GO

-- ==========================================

DROP TABLE IF EXISTS [dbo].[proveedor_categoria];
DROP TABLE IF EXISTS [dbo].[categorias];
DROP TABLE IF EXISTS [dbo].[metodo_pago];
DROP TABLE IF EXISTS [dbo].[proveedores];
DROP TABLE IF EXISTS [dbo].[tipo_metodo_pago];
DROP TABLE IF EXISTS [dbo].[clientes];
DROP TABLE IF EXISTS [dbo].[fisicas_juridicas];
DROP TABLE IF EXISTS [dbo].[familia_roles];
DROP TABLE IF EXISTS [dbo].[usuario_familias];
DROP TABLE IF EXISTS [dbo].[familias];
DROP TABLE IF EXISTS [dbo].[usuario_permisos];
DROP TABLE IF EXISTS [dbo].[configuracion_sistema];
DROP TABLE IF EXISTS [dbo].[auditoria];
DROP TABLE IF EXISTS [dbo].[tipo_accion];
DROP TABLE IF EXISTS [dbo].[domicilios];
DROP TABLE IF EXISTS [dbo].[documentos];
DROP TABLE IF EXISTS [dbo].[tipo_documento];
DROP TABLE IF EXISTS [dbo].[contactos];
DROP TABLE IF EXISTS [dbo].[tipo_contacto];
DROP TABLE IF EXISTS [dbo].[empleados];
DROP TABLE IF EXISTS [dbo].[cargos];
DROP TABLE IF EXISTS [dbo].[entidad_tipos];
DROP TABLE IF EXISTS [dbo].[entidad_tipo];
DROP TABLE IF EXISTS [dbo].[juridicas];
DROP TABLE IF EXISTS [dbo].[tipo_social];
DROP TABLE IF EXISTS [dbo].[fisicas];
DROP TABLE IF EXISTS [dbo].[entidades];
DROP TABLE IF EXISTS [dbo].[localidades];
DROP TABLE IF EXISTS [dbo].[provincias];
DROP TABLE IF EXISTS [dbo].[paises];
DROP TABLE IF EXISTS [dbo].[usuario_roles];
DROP TABLE IF EXISTS [dbo].[rol_permisos];
DROP TABLE IF EXISTS [dbo].[roles];
DROP TABLE IF EXISTS [dbo].[permisos];
DROP TABLE IF EXISTS [dbo].[respuestas_seguridad];
DROP TABLE IF EXISTS [dbo].[usuarios_twofa_codigos];
DROP TABLE IF EXISTS [dbo].[preguntas_seguridad];
DROP TABLE IF EXISTS [dbo].[password_historial];
DROP TABLE IF EXISTS [dbo].[usuarios];

CREATE TABLE [dbo].[usuarios] (
    [id_usuario] INT IDENTITY(1,1) NOT NULL,
    [username] VARCHAR(100) NOT NULL,
    [password_hash] VARCHAR(256) NOT NULL,
    [email] VARCHAR(256) NOT NULL,
    [estado] NVARCHAR(50) NOT NULL CONSTRAINT [DF_usuarios_estado] DEFAULT ('activo'),
    [requiere_cambio_pass] BIT NOT NULL CONSTRAINT [DF_usuarios_requiere_cambio_pass] DEFAULT (1),
    [intentos_fallidos] INT NOT NULL CONSTRAINT [DF_usuarios_intentos_fallidos] DEFAULT (0),
    [bloqueado_hasta] DATETIME2 NULL,
    [ultimo_login] DATETIME2 NULL,
    [fecha_alta] DATETIME2 NOT NULL CONSTRAINT [DF_usuarios_fecha_alta] DEFAULT (SYSDATETIME()),
    [idioma_iso] VARCHAR(5) NOT NULL CONSTRAINT [DF_usuarios_idioma_iso] DEFAULT ('es'),
    [twofa_habilitado] BIT NOT NULL CONSTRAINT [DF_usuarios_twofa_habilitado] DEFAULT (0),
    CONSTRAINT [PK_usuarios] PRIMARY KEY ([id_usuario]),
    CONSTRAINT [UQ_usuarios_username] UNIQUE ([username]),
    CONSTRAINT [UQ_usuarios_email] UNIQUE ([email]),
    CONSTRAINT [CK_usuarios_estado] CHECK ([estado] IN ('activo', 'inactivo', 'bloqueado', 'suspendido'))
);

CREATE TABLE [dbo].[password_historial] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [id_usuario] INT NOT NULL,
    [password_hash] VARCHAR(256) NOT NULL,
    [fecha] DATETIME2 NOT NULL CONSTRAINT [DF_password_historial_fecha] DEFAULT (SYSDATETIME()),
    CONSTRAINT [PK_password_historial] PRIMARY KEY ([id]),
    CONSTRAINT [FK_password_historial_usuarios] FOREIGN KEY ([id_usuario]) REFERENCES [dbo].[usuarios] ([id_usuario]) ON DELETE CASCADE
);
CREATE INDEX [idx_ph_usuario] ON [dbo].[password_historial] ([id_usuario]);

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

CREATE TABLE [dbo].[preguntas_seguridad] (
    [id_pregunta] INT IDENTITY(1,1) NOT NULL,
    [pregunta] VARCHAR(255) NOT NULL,
    [estado] BIT NOT NULL CONSTRAINT [DF_preguntas_seguridad_estado] DEFAULT (1),
    CONSTRAINT [PK_preguntas_seguridad] PRIMARY KEY ([id_pregunta])
);

CREATE TABLE [dbo].[respuestas_seguridad] (
    [id] INT IDENTITY(1,1) NOT NULL,
    [id_usuario] INT NOT NULL,
    [id_pregunta] INT NOT NULL,
    [respuesta_hash] VARCHAR(256) NOT NULL,
    [pista] VARCHAR(256) NULL,
    CONSTRAINT [PK_respuestas_seguridad] PRIMARY KEY ([id]),
    CONSTRAINT [UQ_respuestas_seguridad_usuario_pregunta] UNIQUE ([id_usuario], [id_pregunta]),
    CONSTRAINT [FK_respuestas_seguridad_usuarios] FOREIGN KEY ([id_usuario]) REFERENCES [dbo].[usuarios] ([id_usuario]) ON DELETE CASCADE,
    CONSTRAINT [FK_respuestas_seguridad_preguntas] FOREIGN KEY ([id_pregunta]) REFERENCES [dbo].[preguntas_seguridad] ([id_pregunta])
);
CREATE INDEX [fk_rs_pregunta] ON [dbo].[respuestas_seguridad] ([id_pregunta]);

CREATE TABLE [dbo].[permisos] (
    [id_permiso] INT IDENTITY(1,1) NOT NULL,
    [codigo] VARCHAR(100) NOT NULL,
    [descripcion] VARCHAR(256) NOT NULL,
    [modulo] VARCHAR(100) NOT NULL,
    CONSTRAINT [PK_permisos] PRIMARY KEY ([id_permiso]),
    CONSTRAINT [UQ_permisos_codigo] UNIQUE ([codigo])
);

CREATE TABLE [dbo].[roles] (
    [id_rol] INT IDENTITY(1,1) NOT NULL,
    [nombre] VARCHAR(128) NOT NULL,
    [descripcion] VARCHAR(256) NULL,
    [activo] BIT NOT NULL CONSTRAINT [DF_roles_activo] DEFAULT (1),
    CONSTRAINT [PK_roles] PRIMARY KEY ([id_rol]),
    CONSTRAINT [UQ_roles_nombre] UNIQUE ([nombre])
);

CREATE TABLE [dbo].[rol_permisos] (
    [id_rol] INT NOT NULL,
    [id_permiso] INT NOT NULL,
    CONSTRAINT [PK_rol_permisos] PRIMARY KEY ([id_rol], [id_permiso]),
    CONSTRAINT [FK_rol_permisos_roles] FOREIGN KEY ([id_rol]) REFERENCES [dbo].[roles] ([id_rol]) ON DELETE CASCADE,
    CONSTRAINT [FK_rol_permisos_permisos] FOREIGN KEY ([id_permiso]) REFERENCES [dbo].[permisos] ([id_permiso]) ON DELETE CASCADE
);
CREATE INDEX [fk_rp_permiso] ON [dbo].[rol_permisos] ([id_permiso]);

CREATE TABLE [dbo].[usuario_roles] (
    [id_usuario] INT NOT NULL,
    [id_rol] INT NOT NULL,
    [fecha_asignacion] DATETIME2 NOT NULL CONSTRAINT [DF_usuario_roles_fecha_asignacion] DEFAULT (SYSDATETIME()),
    [fecha_expiracion] DATETIME2 NULL,
    CONSTRAINT [PK_usuario_roles] PRIMARY KEY ([id_usuario], [id_rol]),
    CONSTRAINT [FK_usuario_roles_usuarios] FOREIGN KEY ([id_usuario]) REFERENCES [dbo].[usuarios] ([id_usuario]) ON DELETE CASCADE,
    CONSTRAINT [FK_usuario_roles_roles] FOREIGN KEY ([id_rol]) REFERENCES [dbo].[roles] ([id_rol]) ON DELETE CASCADE
);
CREATE INDEX [fk_ur_rol] ON [dbo].[usuario_roles] ([id_rol]);

CREATE TABLE [dbo].[paises] (
    [id_pais] INT IDENTITY(1,1) NOT NULL,
    [nombre] VARCHAR(100) NOT NULL,
    [codigo] CHAR(2) NOT NULL,
    CONSTRAINT [PK_paises] PRIMARY KEY ([id_pais]),
    CONSTRAINT [UQ_paises_codigo] UNIQUE ([codigo])
);

CREATE TABLE [dbo].[provincias] (
    [id_provincia] INT IDENTITY(1,1) NOT NULL,
    [id_pais] INT NOT NULL,
    [nombre] VARCHAR(100) NOT NULL,
    CONSTRAINT [PK_provincias] PRIMARY KEY ([id_provincia]),
    CONSTRAINT [FK_provincias_paises] FOREIGN KEY ([id_pais]) REFERENCES [dbo].[paises] ([id_pais])
);
CREATE INDEX [fk_prov_pais] ON [dbo].[provincias] ([id_pais]);

CREATE TABLE [dbo].[localidades] (
    [id_localidad] INT IDENTITY(1,1) NOT NULL,
    [id_provincia] INT NOT NULL,
    [nombre] VARCHAR(100) NOT NULL,
    [codigo_postal] VARCHAR(20) NULL,
    CONSTRAINT [PK_localidades] PRIMARY KEY ([id_localidad]),
    CONSTRAINT [FK_localidades_provincias] FOREIGN KEY ([id_provincia]) REFERENCES [dbo].[provincias] ([id_provincia])
);
CREATE INDEX [fk_loc_provincia] ON [dbo].[localidades] ([id_provincia]);

CREATE TABLE [dbo].[entidades] (
    [id_entidad] INT IDENTITY(1,1) NOT NULL,
    [activo] BIT NOT NULL CONSTRAINT [DF_entidades_activo] DEFAULT (1),
    [fecha_alta] DATETIME2 NOT NULL CONSTRAINT [DF_entidades_fecha_alta] DEFAULT (SYSDATETIME()),
    CONSTRAINT [PK_entidades] PRIMARY KEY ([id_entidad])
);

CREATE TABLE [dbo].[fisicas] (
    [id_entidad] INT NOT NULL,
    [nombre] VARCHAR(128) NOT NULL,
    [apellido] VARCHAR(128) NOT NULL,
    [fecha_nacimiento] DATE NULL,
    [id_usuario] INT NULL,
    CONSTRAINT [PK_fisicas] PRIMARY KEY ([id_entidad]),
    CONSTRAINT [FK_fisicas_entidades] FOREIGN KEY ([id_entidad]) REFERENCES [dbo].[entidades] ([id_entidad]) ON DELETE CASCADE,
    CONSTRAINT [FK_fisicas_usuarios] FOREIGN KEY ([id_usuario]) REFERENCES [dbo].[usuarios] ([id_usuario]) ON DELETE SET NULL
);
CREATE UNIQUE INDEX [UX_fisicas_id_usuario] ON [dbo].[fisicas] ([id_usuario]) WHERE [id_usuario] IS NOT NULL;

CREATE TABLE [dbo].[tipo_social] (
    [id_tipo_social] INT IDENTITY(1,1) NOT NULL,
    [nombre] VARCHAR(256) NOT NULL,
    CONSTRAINT [PK_tipo_social] PRIMARY KEY ([id_tipo_social])
);

CREATE TABLE [dbo].[juridicas] (
    [id_entidad] INT NOT NULL,
    [razon_social] VARCHAR(256) NOT NULL,
    [nombre_fantasia] VARCHAR(256) NULL,
    [id_tipo_social] INT NOT NULL,
    CONSTRAINT [PK_juridicas] PRIMARY KEY ([id_entidad]),
    CONSTRAINT [UQ_juridicas_id_entidad] UNIQUE ([id_entidad]),
    CONSTRAINT [FK_juridicas_entidades] FOREIGN KEY ([id_entidad]) REFERENCES [dbo].[entidades] ([id_entidad]) ON DELETE CASCADE,
    CONSTRAINT [FK_juridicas_tipo_social] FOREIGN KEY ([id_tipo_social]) REFERENCES [dbo].[tipo_social] ([id_tipo_social])
);
CREATE INDEX [id_tipo_social_idx] ON [dbo].[juridicas] ([id_tipo_social]);

CREATE TABLE [dbo].[entidad_tipo] (
    [id_tipo] INT IDENTITY(1,1) NOT NULL,
    [nombre] VARCHAR(100) NOT NULL,
    CONSTRAINT [PK_entidad_tipo] PRIMARY KEY ([id_tipo]),
    CONSTRAINT [UQ_entidad_tipo_nombre] UNIQUE ([nombre])
);

CREATE TABLE [dbo].[entidad_tipos] (
    [id_entidad] INT NOT NULL,
    [id_tipo] INT NOT NULL,
    [activo] BIT NOT NULL CONSTRAINT [DF_entidad_tipos_activo] DEFAULT (1),
    [fecha_alta] DATETIME2 NOT NULL CONSTRAINT [DF_entidad_tipos_fecha_alta] DEFAULT (SYSDATETIME()),
    CONSTRAINT [PK_entidad_tipos] PRIMARY KEY ([id_entidad], [id_tipo]),
    CONSTRAINT [FK_entidad_tipos_entidades] FOREIGN KEY ([id_entidad]) REFERENCES [dbo].[entidades] ([id_entidad]) ON DELETE CASCADE,
    CONSTRAINT [FK_entidad_tipos_entidad_tipo] FOREIGN KEY ([id_tipo]) REFERENCES [dbo].[entidad_tipo] ([id_tipo])
);
CREATE INDEX [fk_et_tipo] ON [dbo].[entidad_tipos] ([id_tipo]);

CREATE TABLE [dbo].[cargos] (
    [id_cargo] INT IDENTITY(1,1) NOT NULL,
    [nombre] VARCHAR(100) NOT NULL,
    [descripcion] VARCHAR(256) NULL,
    [activo] BIT NOT NULL CONSTRAINT [DF_cargos_activo] DEFAULT (1),
    CONSTRAINT [PK_cargos] PRIMARY KEY ([id_cargo]),
    CONSTRAINT [UQ_cargos_nombre] UNIQUE ([nombre])
);

CREATE TABLE [dbo].[empleados] (
    [id_empleado] INT IDENTITY(1,1) NOT NULL,
    [id_entidad] INT NOT NULL,
    [id_cargo] INT NOT NULL,
    [legajo] VARCHAR(100) NOT NULL,
    [fecha_ingreso] DATE NOT NULL,
    [fecha_egreso] DATE NULL,
    CONSTRAINT [PK_empleados] PRIMARY KEY ([id_empleado]),
    CONSTRAINT [UQ_empleados_legajo] UNIQUE ([legajo]),
    CONSTRAINT [FK_empleados_fisicas] FOREIGN KEY ([id_entidad]) REFERENCES [dbo].[fisicas] ([id_entidad]),
    CONSTRAINT [FK_empleados_cargos] FOREIGN KEY ([id_cargo]) REFERENCES [dbo].[cargos] ([id_cargo])
);
CREATE INDEX [fk_emp_persona] ON [dbo].[empleados] ([id_entidad]);
CREATE INDEX [fk_emp_cargo] ON [dbo].[empleados] ([id_cargo]);

CREATE TABLE [dbo].[tipo_contacto] (
    [id_tipo_contacto] INT IDENTITY(1,1) NOT NULL,
    [nombre] VARCHAR(75) NOT NULL,
    CONSTRAINT [PK_tipo_contacto] PRIMARY KEY ([id_tipo_contacto]),
    CONSTRAINT [UQ_tipo_contacto_nombre] UNIQUE ([nombre])
);

CREATE TABLE [dbo].[contactos] (
    [id_contacto] INT IDENTITY(1,1) NOT NULL,
    [id_entidad] INT NOT NULL,
    [id_tipo_contacto] INT NOT NULL,
    [valor] VARCHAR(256) NOT NULL,
    [etiqueta] VARCHAR(100) NULL,
    [es_principal] BIT NOT NULL CONSTRAINT [DF_contactos_es_principal] DEFAULT (0),
    CONSTRAINT [PK_contactos] PRIMARY KEY ([id_contacto]),
    CONSTRAINT [FK_contactos_entidades] FOREIGN KEY ([id_entidad]) REFERENCES [dbo].[entidades] ([id_entidad]) ON DELETE CASCADE,
    CONSTRAINT [FK_contactos_tipo_contacto] FOREIGN KEY ([id_tipo_contacto]) REFERENCES [dbo].[tipo_contacto] ([id_tipo_contacto])
);
CREATE INDEX [idx_con_entidad] ON [dbo].[contactos] ([id_entidad]);
CREATE INDEX [fk_con_tipo] ON [dbo].[contactos] ([id_tipo_contacto]);

CREATE TABLE [dbo].[tipo_documento] (
    [id_tipo_documento] INT IDENTITY(1,1) NOT NULL,
    [nombre] VARCHAR(50) NOT NULL,
    [aplica_a] NVARCHAR(50) NOT NULL CONSTRAINT [DF_tipo_documento_aplica_a] DEFAULT ('ambos'),
    CONSTRAINT [PK_tipo_documento] PRIMARY KEY ([id_tipo_documento]),
    CONSTRAINT [UQ_tipo_documento_nombre] UNIQUE ([nombre]),
    CONSTRAINT [CK_tipo_documento_aplica_a] CHECK ([aplica_a] IN ('persona', 'empresa', 'ambos'))
);

CREATE TABLE [dbo].[documentos] (
    [id_documento] INT IDENTITY(1,1) NOT NULL,
    [id_entidad] INT NOT NULL,
    [id_tipo_documento] INT NOT NULL,
    [valor] VARCHAR(128) NOT NULL,
    [es_principal] BIT NOT NULL CONSTRAINT [DF_documentos_es_principal] DEFAULT (0),
    CONSTRAINT [PK_documentos] PRIMARY KEY ([id_documento]),
    CONSTRAINT [FK_documentos_entidades] FOREIGN KEY ([id_entidad]) REFERENCES [dbo].[entidades] ([id_entidad]) ON DELETE CASCADE,
    CONSTRAINT [FK_documentos_tipo_documento] FOREIGN KEY ([id_tipo_documento]) REFERENCES [dbo].[tipo_documento] ([id_tipo_documento])
);
CREATE INDEX [idx_doc_entidad] ON [dbo].[documentos] ([id_entidad]);
CREATE INDEX [fk_doc_tipo] ON [dbo].[documentos] ([id_tipo_documento]);

CREATE TABLE [dbo].[domicilios] (
    [id_domicilio] INT IDENTITY(1,1) NOT NULL,
    [id_entidad] INT NOT NULL,
    [id_localidad] INT NOT NULL,
    [calle] VARCHAR(100) NOT NULL,
    [numero] VARCHAR(20) NULL,
    [piso] VARCHAR(20) NULL,
    [depto] VARCHAR(20) NULL,
    [referencia] VARCHAR(512) NULL,
    [tipo] VARCHAR(50) NULL,
    [es_principal] BIT NOT NULL CONSTRAINT [DF_domicilios_es_principal] DEFAULT (0),
    CONSTRAINT [PK_domicilios] PRIMARY KEY ([id_domicilio]),
    CONSTRAINT [FK_domicilios_entidades] FOREIGN KEY ([id_entidad]) REFERENCES [dbo].[entidades] ([id_entidad]) ON DELETE CASCADE,
    CONSTRAINT [FK_domicilios_localidades] FOREIGN KEY ([id_localidad]) REFERENCES [dbo].[localidades] ([id_localidad])
);
CREATE INDEX [idx_dom_entidad] ON [dbo].[domicilios] ([id_entidad]);
CREATE INDEX [fk_dom_localidad] ON [dbo].[domicilios] ([id_localidad]);

CREATE TABLE [dbo].[tipo_accion] (
    [id_accion] INT IDENTITY(1,1) NOT NULL,
    [nombre] VARCHAR(128) NOT NULL,
    CONSTRAINT [PK_tipo_accion] PRIMARY KEY ([id_accion])
);

CREATE TABLE [dbo].[auditoria] (
    [id] BIGINT IDENTITY(1,1) NOT NULL,
    [id_accion] INT NOT NULL,
    [tabla] VARCHAR(128) NULL,
    [id_registro] INT NULL,
    [valor_anterior] NVARCHAR(MAX) NULL,
    [valor_nuevo] NVARCHAR(MAX) NULL,
    [id_usuario_responsable] INT NULL,
    [motivo] VARCHAR(512) NULL,
    [fecha] DATETIME2 NOT NULL CONSTRAINT [DF_auditoria_fecha] DEFAULT (SYSDATETIME()),
    CONSTRAINT [PK_auditoria] PRIMARY KEY ([id]),
    CONSTRAINT [FK_auditoria_tipo_accion] FOREIGN KEY ([id_accion]) REFERENCES [dbo].[tipo_accion] ([id_accion])
);
CREATE INDEX [idx_aud_accion] ON [dbo].[auditoria] ([id_accion]);
CREATE INDEX [idx_aud_tabla] ON [dbo].[auditoria] ([tabla], [id_registro]);
CREATE INDEX [idx_aud_usuario] ON [dbo].[auditoria] ([id_usuario_responsable]);
CREATE INDEX [idx_aud_fecha] ON [dbo].[auditoria] ([fecha]);

CREATE TABLE [dbo].[configuracion_sistema] (
    [id_config] INT NOT NULL CONSTRAINT [DF_configuracion_sistema_id_config] DEFAULT (1),
    [pass_min_chars] INT NULL CONSTRAINT [DF_configuracion_sistema_pass_min_chars] DEFAULT (12),
    [pass_max_chars] INT NULL CONSTRAINT [DF_configuracion_sistema_pass_max_chars] DEFAULT (128),
    [pass_requiere_mayusculas] BIT NOT NULL CONSTRAINT [DF_configuracion_sistema_pass_requiere_mayusculas] DEFAULT (1),
    [pass_min_minusculas] INT NULL CONSTRAINT [DF_configuracion_sistema_pass_min_minusculas] DEFAULT (2),
    [pass_requiere_minusculas] BIT NOT NULL CONSTRAINT [DF_configuracion_sistema_pass_requiere_minusculas] DEFAULT (1),
    [pass_min_mayusculas] INT NULL CONSTRAINT [DF_configuracion_sistema_pass_min_mayusculas] DEFAULT (2),
    [pass_requiere_numeros] BIT NOT NULL CONSTRAINT [DF_configuracion_sistema_pass_requiere_numeros] DEFAULT (1),
    [pass_min_numeros] INT NULL CONSTRAINT [DF_configuracion_sistema_pass_min_numeros] DEFAULT (2),
    [pass_requiere_simbolos] BIT NOT NULL CONSTRAINT [DF_configuracion_sistema_pass_requiere_simbolos] DEFAULT (0),
    [pass_simbolos_permitidos] VARCHAR(100) NULL CONSTRAINT [DF_configuracion_sistema_pass_simbolos_permitidos] DEFAULT ('._-@#&*'),
    [pass_min_simbolos] INT NULL CONSTRAINT [DF_configuracion_sistema_pass_min_simbolos] DEFAULT (2),
    [pass_no_repetir_nunca] BIT NOT NULL CONSTRAINT [DF_configuracion_sistema_pass_no_repetir_nunca] DEFAULT (1),
    [pass_no_repetir_ultimas] INT NULL CONSTRAINT [DF_configuracion_sistema_pass_no_repetir_ultimas] DEFAULT (5),
    [pass_no_datos_personales] BIT NOT NULL CONSTRAINT [DF_configuracion_sistema_pass_no_datos_personales] DEFAULT (1),
    [pass_no_repetir_consecutivos] BIT NOT NULL CONSTRAINT [DF_configuracion_sistema_pass_no_repetir_consecutivos] DEFAULT (1),
    [pass_vigencia_dias] INT NOT NULL CONSTRAINT [DF_configuracion_sistema_pass_vigencia_dias] DEFAULT (90),
    [login_intentos_max] INT NOT NULL CONSTRAINT [DF_configuracion_sistema_login_intentos_max] DEFAULT (6),
    [login_bloqueo_minutos] INT NOT NULL CONSTRAINT [DF_configuracion_sistema_login_bloqueo_minutos] DEFAULT (15),
    [preguntas_cantidad] INT NOT NULL CONSTRAINT [DF_configuracion_sistema_preguntas_cantidad] DEFAULT (3),
    [twofa_digitos] INT NOT NULL CONSTRAINT [DF_configuracion_sistema_twofa_digitos] DEFAULT (6),
    [twofa_expiracion_min] INT NOT NULL CONSTRAINT [DF_configuracion_sistema_twofa_expiracion_min] DEFAULT (10),
    [id_usuario_modifico] INT NULL,
    [fecha_modificacion] DATETIME2 NOT NULL CONSTRAINT [DF_configuracion_sistema_fecha_modificacion] DEFAULT (SYSDATETIME()),
    CONSTRAINT [PK_configuracion_sistema] PRIMARY KEY ([id_config]),
    CONSTRAINT [FK_configuracion_sistema_usuarios] FOREIGN KEY ([id_usuario_modifico]) REFERENCES [dbo].[usuarios] ([id_usuario]) ON DELETE SET NULL
);
CREATE INDEX [fk_cs_usuario] ON [dbo].[configuracion_sistema] ([id_usuario_modifico]);

CREATE TABLE [dbo].[usuario_permisos] (
    [id_usuario] INT NOT NULL,
    [id_permiso] INT NOT NULL,
    [fecha_asignacion] DATETIME2 NOT NULL CONSTRAINT [DF_usuario_permisos_fecha_asignacion] DEFAULT (SYSDATETIME()),
    [fecha_expiracion] DATETIME2 NULL,
    CONSTRAINT [PK_usuario_permisos] PRIMARY KEY ([id_usuario], [id_permiso]),
    CONSTRAINT [FK_usuario_permisos_usuarios] FOREIGN KEY ([id_usuario]) REFERENCES [dbo].[usuarios] ([id_usuario]) ON DELETE CASCADE,
    CONSTRAINT [FK_usuario_permisos_permisos] FOREIGN KEY ([id_permiso]) REFERENCES [dbo].[permisos] ([id_permiso]) ON DELETE CASCADE
);
CREATE INDEX [id_permiso_idx] ON [dbo].[usuario_permisos] ([id_permiso]);

CREATE TABLE [dbo].[familias] (
    [id_familia] INT IDENTITY(1,1) NOT NULL,
    [nombre] VARCHAR(128) NOT NULL,
    [descripcion] VARCHAR(256) NULL,
    [activo] BIT NOT NULL CONSTRAINT [DF_familias_activo] DEFAULT (1),
    CONSTRAINT [PK_familias] PRIMARY KEY ([id_familia]),
    CONSTRAINT [UQ_familias_nombre] UNIQUE ([nombre])
);

CREATE TABLE [dbo].[usuario_familias] (
    [id_usuario] INT NOT NULL,
    [id_familia] INT NOT NULL,
    [fecha_asignacion] DATETIME2 NOT NULL CONSTRAINT [DF_usuario_familias_fecha_asignacion] DEFAULT (SYSDATETIME()),
    [fecha_expiracion] DATETIME2 NULL,
    CONSTRAINT [PK_usuario_familias] PRIMARY KEY ([id_usuario], [id_familia]),
    CONSTRAINT [FK_usuario_familias_usuarios] FOREIGN KEY ([id_usuario]) REFERENCES [dbo].[usuarios] ([id_usuario]) ON DELETE CASCADE,
    CONSTRAINT [FK_usuario_familias_familias] FOREIGN KEY ([id_familia]) REFERENCES [dbo].[familias] ([id_familia]) ON DELETE CASCADE
);
CREATE INDEX [id_familia_idx] ON [dbo].[usuario_familias] ([id_familia]);

CREATE TABLE [dbo].[familia_roles] (
    [id_familia] INT NOT NULL,
    [id_rol] INT NOT NULL,
    CONSTRAINT [PK_familia_roles] PRIMARY KEY ([id_familia], [id_rol]),
    CONSTRAINT [FK_familia_roles_roles] FOREIGN KEY ([id_rol]) REFERENCES [dbo].[roles] ([id_rol]) ON DELETE CASCADE,
    CONSTRAINT [FK_familia_roles_familias] FOREIGN KEY ([id_familia]) REFERENCES [dbo].[familias] ([id_familia]) ON DELETE CASCADE
);

CREATE TABLE [dbo].[fisicas_juridicas] (
    [id_fisicas] INT NOT NULL,
    [id_juridica] INT NOT NULL,
    [tipo_vinculo] VARCHAR(128) NOT NULL CONSTRAINT [DF_fisicas_juridicas_tipo_vinculo] DEFAULT ('-- ejemplo: empleado, responsable, socio, social, etc.'),
    [fecha_desde] DATE NULL,
    [fecha_hasta] DATE NULL,
    [activo] BIT NOT NULL,
    [detalle] VARCHAR(512) NULL,
    CONSTRAINT [PK_fisicas_juridicas] PRIMARY KEY ([id_fisicas], [id_juridica]),
    CONSTRAINT [FK_fisicas_juridicas_fisicas] FOREIGN KEY ([id_fisicas]) REFERENCES [dbo].[fisicas] ([id_entidad]),
    CONSTRAINT [FK_fisicas_juridicas_juridicas] FOREIGN KEY ([id_juridica]) REFERENCES [dbo].[juridicas] ([id_entidad])
);
CREATE INDEX [id_juridicas_idx] ON [dbo].[fisicas_juridicas] ([id_juridica]);

CREATE TABLE [dbo].[clientes] (
    [id_cliente] INT IDENTITY(1,1) NOT NULL,
    [id_entidad] INT NOT NULL,
    [limite_credito] INT NULL,
    CONSTRAINT [PK_clientes] PRIMARY KEY ([id_cliente]),
    CONSTRAINT [UQ_clientes_id_entidad] UNIQUE ([id_entidad]),
    CONSTRAINT [FK_clientes_entidades] FOREIGN KEY ([id_entidad]) REFERENCES [dbo].[entidades] ([id_entidad])
);
CREATE INDEX [id_entidad_idx] ON [dbo].[clientes] ([id_entidad]);

CREATE TABLE [dbo].[tipo_metodo_pago] (
    [id_tipo_metodo_pago] INT IDENTITY(1,1) NOT NULL,
    [nombre] VARCHAR(50) NOT NULL,
    CONSTRAINT [PK_tipo_metodo_pago] PRIMARY KEY ([id_tipo_metodo_pago])
);

CREATE TABLE [dbo].[proveedores] (
    [id_proveedor] INT IDENTITY(1,1) NOT NULL,
    [id_entidad] INT NOT NULL,
    [codigo] VARCHAR(5) NOT NULL,
    [notas] VARCHAR(2500) NULL,
    [fecha_alta] DATE NOT NULL CONSTRAINT [DF_proveedores_fecha_alta] DEFAULT (CONVERT(date, GETDATE())),
    [activo] BIT NOT NULL,
    CONSTRAINT [PK_proveedores] PRIMARY KEY ([id_proveedor]),
    CONSTRAINT [UQ_proveedores_id_entidad] UNIQUE ([id_entidad]),
    CONSTRAINT [FK_proveedores_entidades] FOREIGN KEY ([id_entidad]) REFERENCES [dbo].[entidades] ([id_entidad])
);
CREATE INDEX [id_entidad_idx_proveedores] ON [dbo].[proveedores] ([id_entidad]);

CREATE TABLE [dbo].[metodo_pago] (
    [id_metodo_pago] INT IDENTITY(1,1) NOT NULL,
    [id_tipo_metodo_pago] INT NOT NULL,
    [id_entidad] INT NOT NULL,
    [valor] VARCHAR(250) NOT NULL,
    [es_principal] BIT NOT NULL,
    [detalle] VARCHAR(250) NULL,
    [fecha_creado] DATE NOT NULL,
    CONSTRAINT [PK_metodo_pago] PRIMARY KEY ([id_metodo_pago]),
    CONSTRAINT [FK_metodo_pago_tipo_metodo_pago] FOREIGN KEY ([id_tipo_metodo_pago]) REFERENCES [dbo].[tipo_metodo_pago] ([id_tipo_metodo_pago]),
    CONSTRAINT [FK_metodo_pago_clientes] FOREIGN KEY ([id_entidad]) REFERENCES [dbo].[clientes] ([id_entidad]),
    CONSTRAINT [FK_metodo_pago_proveedores] FOREIGN KEY ([id_entidad]) REFERENCES [dbo].[proveedores] ([id_entidad])
);
CREATE INDEX [id_tipo_metodo_pago_idx] ON [dbo].[metodo_pago] ([id_tipo_metodo_pago]);
CREATE INDEX [id_entidad_idx_metodo_pago] ON [dbo].[metodo_pago] ([id_entidad]);

CREATE TABLE [dbo].[categorias] (
    [id_categoria] INT IDENTITY(1,1) NOT NULL,
    [nombre] VARCHAR(75) NOT NULL,
    [desripcion] VARCHAR(2500) NULL,
    [activo] BIT NOT NULL,
    CONSTRAINT [PK_categorias] PRIMARY KEY ([id_categoria])
);

CREATE TABLE [dbo].[proveedor_categoria] (
    [id_proveedor] INT NOT NULL,
    [id_categoria] INT NOT NULL,
    [calidad] BIT NOT NULL CONSTRAINT [DF_proveedor_categoria_calidad] DEFAULT (0),
    [es_principal] BIT NOT NULL CONSTRAINT [DF_proveedor_categoria_es_principal] DEFAULT (0),
    CONSTRAINT [PK_proveedor_categoria] PRIMARY KEY ([id_proveedor], [id_categoria]),
    CONSTRAINT [FK_proveedor_categoria_categorias] FOREIGN KEY ([id_categoria]) REFERENCES [dbo].[categorias] ([id_categoria]),
    CONSTRAINT [FK_proveedor_categoria_proveedores] FOREIGN KEY ([id_proveedor]) REFERENCES [dbo].[proveedores] ([id_proveedor])
);
CREATE INDEX [id_categoria_idx] ON [dbo].[proveedor_categoria] ([id_categoria]);
