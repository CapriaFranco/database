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
