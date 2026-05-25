-- ==========================================
-- Seed data inicial para SQL Server 2019
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
