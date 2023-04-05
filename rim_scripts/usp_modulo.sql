USE SIRIM
GO

/*» CREATE-CREDENTIAL'S  */
/*-----------------------------------------------------------------------------------------------------------------------------*/
/*► Create User ... */
-- SELECT * FROM SidUsuario
-- [dbo].[RrhhFormatoPermisos]
-- DELETE FROM SidUsuario WHERE uIdUsuario = '14BC83D0-04EF-4F7C-A171-16DD1C2982BB'
INSERT INTO SidUsuario(uIdUsuario, sArea, sCargo, sDni, sLogin, sNombres, xPassword, sRegimenLaboral, sDependencia) VALUES(NEWID(),'RIM', 'Asistente de Registro', '70184240', 'EGOLIVERA', 'Olivera Barrientos, Edgar Guillermo', '$2a$10$SmgP1tGoOkTJdRfuo71ew.sUO4oCIA1h2Vtji1kJJhiPSYXgyrEZO', 'CAS', 'LIMA')
INSERT INTO SidUsuario(uIdUsuario, sArea, sCargo, sDni, sLogin, sNombres, xPassword, sRegimenLaboral, sDependencia) VALUES(NEWID(),'RIM', 'Asistente de Registro', '46879472', 'SBRAVO', 'Bravo Trujillo, Stephanie', '$2a$10$SmgP1tGoOkTJdRfuo71ew.sUO4oCIA1h2Vtji1kJJhiPSYXgyrEZO', 'CAS', 'LIMA')
INSERT INTO SidUsuario(uIdUsuario, sArea, sCargo, sDni, sLogin, sNombres, xPassword, sRegimenLaboral, sDependencia) VALUES(NEWID(),'RIM', 'Asistente de Registro', '45878442', 'NPASTOR', 'Pastor Silva, Nataly Milagros Isabel', '$2a$10$SmgP1tGoOkTJdRfuo71ew.sUO4oCIA1h2Vtji1kJJhiPSYXgyrEZO', 'CAS', 'LIMA')
INSERT INTO SidUsuario(uIdUsuario, sArea, sCargo, sDni, sLogin, sNombres, xPassword, sRegimenLaboral, sDependencia) 
VALUES(NEWID(),'RIM', 'Asistente de Registro', '46392613', 'rguevarav_c', 'Rooy Cristopher, Guevara Villegas', '$2a$10$SmgP1tGoOkTJdRfuo71ew.sUO4oCIA1h2Vtji1kJJhiPSYXgyrEZO', 'Locador de Servicios', 'LIMA')

/*► 
	Create: Perfil ... 
	--► MOD: 69, 70, 73, 74
	--► SUBMOD: 84(BUSCAR INTERPOL), 98(EXTRACCIÓN DE DATOS), 99(DEPURAR EXTRACCIÓN), 100(ASIGNAR EXTRACCIÓN), 101(BUSCAR DNV), 102(ANALIZAR EXTRACCIÓN)
*/
--► Admin:
-- SELECT * FROM SidUsuario
-- SELECT * FROM SidUsuarioProcedimiento
-- SELECT * FROM SidProcedimiento
INSERT 
	INTO SidUsuarioProcedimiento(bDenegado, dFechaRegistro, nIdProcedimiento, uIdUsuario)
	VALUES (1, GETDATE(), 60, '74260A42-F392-4564-9B9F-A744A32D219A')

/*► 
	→ Cordinador | Analista ... 
	--► MOD: 69, 70, 73, 74
	--► SUBMOD: 84(BUSCAR INTERPOL), 98(EXTRACCIÓN DE DATOS), 99(DEPURAR EXTRACCIÓN), 100(ASIGNAR EXTRACCIÓN), 101(BUSCAR DNV), 102(ANALIZAR EXTRACCIÓN)
	--► 5ED651A0-9040-4F3B-80A9-1E8B94FCF612 | 354FAEA3-5585-4BB4-93F3-D409926F94BA
	--► 4E385A8B-4C1E-4F76-8851-668A63FCA0CE
*/
-- SELECT * FROM SidUsuario
SELECT * FROM SidProcedimiento
-- DELETE FROM SidUsuarioProcedimiento WHERE uIdUsuario = '5143488D-2370-464A-A0A8-DB0181FBB497'
-- Dep's 
SELECT [value] INTO #tmp_idProc 
FROM 
	STRING_SPLIT('69, 70, 73, 74, 75, 84, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 111, 113', ',') -- Cordinador
	-- STRING_SPLIT('69, 70, 73, 74, 84, 101, 102', ',') -- Analista

WHILE((SELECT COUNT(1) FROM #tmp_idProc) > 0)
BEGIN
	DECLARE @idProc INT = (SELECT TOP 1 [value] FROM #tmp_idProc ORDER BY [value])

	INSERT 
		INTO SidUsuarioProcedimiento(bDenegado, dFechaRegistro, nIdProcedimiento, uIdUsuario)
		VALUES (1, GETDATE(), @idProc, '5143488D-2370-464A-A0A8-DB0181FBB497')

	-- Clean-up ...
	DELETE FROM #tmp_idProc WHERE [value] = @idProc
END

-- Clean-up
DROP TABLE IF EXISTS #tmp_idProc
SELECT * FROM SidProcedimiento
/*-----------------------------------------------------------------------------------------------------------------------------*/
	
/*» MOD'S: */
INSERT INTO SidProcedimiento
	(
		bActivo, sNombre, sInformacion, sDescripcion, sIcono, sRutaMod, sTipo, sDisposicion
	)
	VALUES
	   (1, 'HOME', 'Home', '', 'Home', '/', 'MODULO', 'appbar'),
	   (1, 'PERFIL', 'Mis credenciales', 'Puede actulizar sus credenciales', 'Person', '/perfil', 'MODULO', 'appbar'),
	   (1, 'ACTIVIDADES', 'Registro de actividades', '', 'SupervisorAccount', '/actividades', 'MODULO', 'appbar'),
	   (1, 'LINEAMIENTOS', 'Lineamientos Generales', '', 'AddBox', '/lineamientos', 'MODULO', 'sidebar'),
	   (1, 'PROCESOS', 'Procesos', '', 'Settings', '/procesos', 'MODULO', 'sidebar'),
	   (1, 'UTILIDADES', 'Utilidades', '', 'LiveHelp', '/utilidades', 'MODULO', 'sidebar'),
	   (1, 'REPORTES', 'Reportes', '', 'BarChartRounded', '/reportes', 'MODULO', 'sidebar'),
	   (1, 'GESTIÓN TRÁMITES', 'Gestión de Trámites', '', 'AccountTree', '/gestion-tramites', 'MODULO', 'sidebar'),
	   (1, 'MANTENIMIENTO', 'Mantenimiento', '', 'EngineeringRounded', '/mantenimiento', 'MODULO', 'sidebar')

/*» SUB-MOD'S: */
SELECT * FROM SidProcedimiento
UPDATE SidProcedimiento SET sRutaSubmod = '' WHERE nIdProcedimiento = 105

INSERT INTO SidProcedimiento
	(
		bActivo, sNombre, sInformacion, sDescripcion, sIcono, sRutaMod, sRutaSubmod, sTipo
	)
	VALUES
		(1, 'NUEVO INTERPOL', 'Nuevo interpol emitidos', 'Registro de fichas de interpol emitida.', 'Create', '/procesos', '/nuevo-interpol', 'SUB_MODULO'),
		(1, 'BUSCAR INTERPOL', 'Interpol Emitidos', 'Fichas de interpol registradas y emitida.', 'FindInPage', '/utilidades', '/buscar-interpol', 'SUB_MODULO'),
		(1, 'EXTRACCIÓN DE DATOS', 'Extracción de Datos', 'Extracción de datos de los módulos de datos de Migraciones.', 'StorageRounded', '/procesos', '/extraccion-datos', 'SUB_MODULO'),
		(1, 'DEPURAR EXTRACCIÓN', 'Depuración de datos', 'Nueva extracción de datos para analizar.', 'CleaningServicesRounded', '/procesos', '/nueva-depuracion', 'SUB_MODULO'),
		(1, 'ASIGNAR EXTRACCIÓN', 'Asignar Extracción', 'Asignar extracción de datos para analizar.', 'GroupsRounded', '/procesos', '/asignar-extraccion', 'SUB_MODULO'),
		(1, 'BUSCAR DNV', 'Documento no Válidos', 'Invalidación de documentos de cudadanos Extranjeros.', 'FindInPage', '/utilidades', '/buscar-dnv', 'SUB_MODULO'),
		(1, 'ANALIZAR EXTRACCIÓN', 'analizar Extracción', 'Analizar extracción de datos.', 'QueryStatsRounded', '/procesos', '/analizar-extraccion', 'SUB_MODULO'),
		(1, 'CONTROL DE CALIDAD', 'Control de calidad', 'Control de calidad, para el analisis de datos extraidos.', 'GradingRounded', '/procesos', '/control-calidad', 'SUB_MODULO'),
		(1, 'REPORTE DIARIO DE PRODUCCIÓN', 'Reporte diario de analisis de datos', 'Reporte diario de producción de analisis y depuración de datos.', 'TrendingUp', '/reportes', '/produccion-diario', 'SUB_MODULO'),
		(1, 'CREAR TIPO LÓGICO', 'Crear, actualizar y eliminar tipo de dato lógico.', 'Crear, actualizar y eliminar tipo de dato lógico.', 'DataObjectRounded', '/mantenimiento', '/tipo-logico', 'SUB_MODULO'),
		(1, 'EVENTO', 'Crear, actualizar y eliminar eventos.', 'Crear, actualizar y eliminar eventos.', 'EventNoteRounded', '/utilidades', '/evento', 'SUB_MODULO'),
		(1, 'REPORTE DE HORAS TRABAJADAS', 'Reporte de registros analizados por horas.', 'Reporte de registros analizados por horas.', 'QueryBuilderRounded', '/reportes', '/produccion-horas', 'SUB_MODULO'),
		(1, 'REPORTE CONTROL MIGRATORIO', 'Reporte de Control Migratorio.', 'Reporte de Control Migratorio.', 'StackedLineChartRounded', '/reportes', '/control-migratorio', 'SUB_MODULO'),
		(1, 'REPORTE PASAPORTES', 'Reporte de Pasaportes.', 'Reporte de Pasaportes.', 'StyleRounded', '/reportes', '/pasaportes', 'SUB_MODULO'),
		(1, 'REPORTE REGISTROS ANALIZADOS', 'Reporte de Registros Analizados.', 'Reporte de Registros Analizados.', 'KeyboardDoubleArrowDownRounded', '/reportes', '/analizados', 'SUB_MODULO'),
		(1, 'REGISTRAR FORMATO DE AUTORIZACIÓN', 'Formato de Autorización de Permisos o licencias', 'Formato de Autorización de Permisos o licencias.', 'ReceiptLongRounded', '/utilidades', '/formato-autorizacion', 'SUB_MODULO'),
		(1, 'VALIDAR PERMISOS O LICENCIAS', 'Validar Autorización de Permisos o licencias', 'Validar de Autorización de Permisos o licencias.', 'FactCheckRounded', '/utilidades', '/validar-autorizacion', 'SUB_MODULO'),
		(1, 'REPORTE PROYECCIÓN ANALISIS', 'Reporte de Proyección de Registros Analizados.', 'Reporte de Proyección de Registros Analizados.', 'MultilineChartRounded', '/reportes', '/proyeccion-analisis', 'SUB_MODULO')
		

/*► Update: SUBMOD secuencia ... */
-- SELECT * FROM SidProcedimiento WHERE nIdProcedimiento = 51
USE [BDSidtefim-Test]
GO

SELECT * FROM SidProcedimiento
UPDATE SidProcedimiento
SET sNombre = 'REGISTRAR FORMATO DE AUTORIZACIÓN'
WHERE nIdProcedimiento = 10113
		
/*» ITEM'S */
INSERT INTO SidProcedimiento
	(
		bActivo, sNombre, sInformacion, sDescripcion, sIcono, sRutaMod, sRutaSubmod, sRefItem, sTipo
	)
	VALUES
		(1, 'INCONSISTENCIAS', 'Procedimientos inconsistentes', 'Procedimiento no registrados en SIM-NAC', 'Person', '/reportes', '/nacionalizacion', 'Inconsistencias', 'ITEM'),
		(1, 'PENDIENTES', 'Procedimientos pendientes', 'Reporte de procedimientos pendientes 2016 al 2021', 'Person', '/reportes', '/nacionalizacion', 'Pendientes', 'ITEM'),
		(1, 'NACIONALIZADOS', 'Procedimientos pendientes', 'Reporte de procedimientos pendientes 2016 al 2021', 'Person', '/reportes', '/nacionalizacion', 'Nacionalizados', 'ITEM'),
		(1, 'ATENDIDOS', 'Procedimientos pendientes', 'Reporte de procedimientos pendientes 2016 al 2021', 'Person', '/reportes', '/nacionalizacion', 'Atendidos', 'ITEM')

/*» SUB-ITEM'S */
INSERT INTO SidProcedimiento
	(
		bActivo, sNombre, sIcono, sRutaMod, sRutaSubmod, sRefItem, sTipo
	)
	VALUES
		(1, 'PIURA', 'LocationCity', '/reportes', '/nacionalizacion', 'Pendientes', 'SUB_ITEM'),
		(1, 'ILO', 'LocationCity', '/reportes', '/nacionalizacion', 'Pendientes', 'SUB_ITEM'),
		(1, 'BREÑA', 'LocationCity', '/reportes', '/nacionalizacion', 'Pendientes', 'SUB_ITEM'),
		(1, 'LIMA', 'LocationCity', '/reportes', '/nacionalizacion', 'Pendientes', 'SUB_ITEM'),
		(1, 'AREQUIPA', 'LocationCity', '/reportes', '/nacionalizacion', 'Pendientes', 'SUB_ITEM'),
		(1, 'LIM', 'LocationCity', '/reportes', '/nacionalizacion', 'Pendientes', 'SUB_ITEM'),
		(1, 'CHIMBOTE', 'LocationCity', '/reportes', '/nacionalizacion', 'Pendientes', 'SUB_ITEM'),
		(1, 'TARAPOTO', 'LocationCity', '/reportes', '/nacionalizacion', 'Pendientes', 'SUB_ITEM'),
		(1, 'TACNA', 'LocationCity', '/reportes', '/nacionalizacion', 'Pendientes', 'SUB_ITEM'),
		(1, 'IQUITOS', 'LocationCity', '/reportes', '/nacionalizacion', 'Pendientes', 'SUB_ITEM'),
		(1, 'PTO', 'LocationCity', '/reportes', '/nacionalizacion', 'Pendientes', 'SUB_ITEM'),
		(1, 'TRUJILLO', 'LocationCity', '/reportes', '/nacionalizacion', 'Pendientes', 'SUB_ITEM'),
		(1, 'PUCALLPA', 'LocationCity', '/reportes', '/nacionalizacion', 'Pendientes', 'SUB_ITEM'),
		(1, 'TUMBES', 'LocationCity', '/reportes', '/nacionalizacion', 'Pendientes', 'SUB_ITEM'),
		(1, 'CHICLAYO', 'LocationCity', '/reportes', '/nacionalizacion', 'Pendientes', 'SUB_ITEM'),
		(1, 'CUSCO', 'LocationCity', '/reportes', '/nacionalizacion', 'Pendientes', 'SUB_ITEM')


/*» RESET ROLES */
--DELETE FROM SidUsuarioProcedimiento
--DELETE FROM SidProcedimiento
--DBCC CHECKIDENT ('[SidProcedimiento]', RESEED,0)
--TRUNCATE TABLE SidProcedimiento
/*
ALTER TABLE SidProcedimiento
	ALTER COLUMN sIcono VARCHAR(25) NULL */

/*» Test ...*/
SELECT * FROM SidUsuario
	--WHERE uIdUsuario = '6B234CBC-FBC8-4EBC-85AA-E4B3A3807828'
	WHERE sLogin = 'egolivera'
SELECT * FROM SidUsuarioProcedimiento 
	WHERE uIdUsuario = 'A12E06BB-4BC7-4E92-A4B5-79F0967B1A58'

SELECT * FROM SidProcedimiento
-- 5 | Procedimiento 
-- 51 | Depuración de datos → CleaningServicesRounded
-- 53 | ASIGNAR EXTRACCIÓN → GroupsRounded

-- SELECT * FROM SidUsuario
UPDATE SidProcedimiento SET nSecuencia = 0

/*
DELETE FROM SidUsuarioProcedimiento 
WHERE 
	uIdUsuario = '74260A42-F392-4564-9B9F-A744A32D219A'
	AND nIdProcedimiento = 52
*/
-- SELECT * FROM SidUsuario
-- 104 | REPORTE DE PRODUCCIÓN DIARIO
-- 110 | REPORTE PASAPORTES
INSERT
	INTO SidUsuarioProcedimiento(bDenegado, dFechaRegistro, nIdProcedimiento, uIdUsuario)
	VALUES (1, GETDATE(), 10113, '354FAEA3-5585-4BB4-93F3-D409926F94BA')

--» ROL: ADMIN ...
/*--------------------------------------------------------------------------------------------*/
-- SELECT * FROM SidUsuario
SELECT sp.nIdProcedimiento, sp.sNombre FROM SidProcedimiento sp ORDER BY sp.nIdProcedimiento

--DELETE FROM SidUsuarioProcedimiento WHERE uIdUsuario = 'A12E06BB-4BC7-4E92-A4B5-79F0967B1A58'
SELECT nIdProcedimiento INTO #tmp FROM SidProcedimiento
DECLARE @count_tmp INT = (SELECT COUNT(1) FROM #tmp),
		@idProc INT
WHILE (@count_tmp > 0)
BEGIN
	SET @idProc = (SELECT TOP 1 nIdProcedimiento FROM #tmp ORDER BY nIdProcedimiento ASC)
	INSERT 
		INTO SidUsuarioProcedimiento(bDenegado, dFechaRegistro, nIdProcedimiento, uIdUsuario)
		VALUES (1, GETDATE(), @idProc, 'A12E06BB-4BC7-4E92-A4B5-79F0967B1A58')
	
	DELETE FROM #tmp WHERE nIdProcedimiento = @idProc
	SET @count_tmp = (SELECT COUNT(1) FROM #tmp)
END
--DELETE FROM SidUsuarioProcedimiento WHERE uIdUsuario = '4B0383AD-D59C-9F40-83FA-76E1FB5E5F93'
/*--------------------------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------------------------------------------------------------
» ROL		: USER-SFM
» MOD		: 1 | 2 | 3
» SUBMOD	: 8
---------------------------------------------------------------------------------------------------------------------------------*/
DECLARE @uId UNIQUEIDENTIFIER = '6B6E1B18-12BC-4D38-B5ED-F8C6CE058C79'
INSERT 
	INTO SidUsuarioProcedimiento(bDenegado, dFechaRegistro, nIdProcedimiento, uIdUsuario)
	VALUES 
		(1, GETDATE(), 1, @uId),
		(1, GETDATE(), 2, @uId),
		(1, GETDATE(), 3, @uId),
		(1, GETDATE(), 8, @uId)
/*» 25 ...*/
SELECT * FROM SidUsuario WHERE sArea = 'SFM'
/*---------------------------------------------------------------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------------------------------------------------------------*/
/*
» ROL		: ADMIN-SFM 
» MOD		: 1 | 2 | 3 | 5 | 7
» SUBMOD	: 8 | 9 | 16
*/
/*--------------------------------------------------------------------------------------------*/
SELECT sp.nIdProcedimiento, sp.sNombre FROM SidProcedimiento sp ORDER BY sp.nIdProcedimiento DESC
SELECT * FROM SidProcedimiento
-- LFLORES | 23013539-706D-4EF7-9AE2-66839583E7C8
-- rguevarav | A12E06BB-4BC7-4E92-A4B5-79F0967B1A58
-- RMENDOZAM | 70A740D3-EAA0-4D79-9FB5-DB17DCE88F70

INSERT
	INTO SidUsuarioProcedimiento(bDenegado, dFechaRegistro, nIdProcedimiento, uIdUsuario)
	VALUES (1, GETDATE(), 113, '70A740D3-EAA0-4D79-9FB5-DB17DCE88F70')
	
/*--------------------------------------------------------------------------------------------*/

/*
» ROL		: CORDINADOR-SGTM
» MOD		: 1 | 2 | 6 | 7
» SUBMOD	: 12 | 14 | 17
» ITEM		: 18 | 19 | 20 | 21
*/
/*--------------------------------------------------------------------------------------------*/
INSERT 
	INTO SidUsuarioProcedimiento(bDenegado, dFechaRegistro, nIdProcedimiento, uIdUsuario)
	VALUES (1, GETDATE(), 21, 'F5ADDF9A-31C9-471A-8885-0E82E2657790')

	SELECT * FROM SidUsuario WHERE sNombres LIKE '%palma%'
	SELECT * FROM SidProcedimiento WHERE sTipo = 'ITEM'
	SELECT * FROM SidUsuarioProcedimiento WHERE uIdUsuario = 'F5ADDF9A-31C9-471A-8885-0E82E2657790'
/*--------------------------------------------------------------------------------------------*/

/*
» ROL		: EVALUADOR
» MOD		: 1 | 6
» SUBMOD	: 12 | 13
*/
INSERT 
	INTO SidUsuarioProcedimiento(bDenegado, dFechaRegistro, nIdProcedimiento, uIdUsuario)
	VALUES (1, GETDATE(), 41, '4B0383AD-D59C-9F40-83FA-76E1FB5E5F93')

SELECT * FROM SidUsuarioProcedimiento WHERE uIdUsuario = '4BCCEE09-BFF8-6742-B5E4-0771A87BADCB'

/*» Test...*/
DELETE FROM SidUsuarioProcedimiento WHERE uIdUsuario = 'A1F2C292-61F8-9141-BAB5-43D77D44681F'
UPDATE SidUsuarioProcedimiento 
	SET nIdProcedimiento = 6 
	WHERE 
		uIdUsuario = 'A1F2C292-61F8-9141-BAB5-43D77D44681F'
		AND nIdProcedimiento = 5

SELECT * FROM SidProcedimiento sp
	WHERE sp.sTipo = 'MODULO'
SELECT * FROM SidProcedimiento sp
	WHERE 
		sp.sTipo = 'SUB_MODULO'
		AND sp.sRutaMod = (SELECT sRutaMod FROM SidProcedimiento WHERE sTipo = 'MODULO' AND sNombre = 'ACTIVIDADES')



SELECT * FROM SidProcedimiento
SELECT * FROM SidUsuarioProcedimiento WHERE uIdUsuario = '2DE78A3B-7C8C-4E30-917B-A676FE57911A'
SELECT * FROM SidUsuario WHERE uIdUsuario = '2DE78A3B-7C8C-4E30-917B-A676FE57911A'
/*---------------------------------------------------------------------------------------------------------------------------------*/

/* ░ Actualizar sGrupo en SidUsuario
	» 
*/
/*---------------------------------------------------------------------------------*/
-- SELECT * FROM SidUsuario
-- SELECT * FROM SidProcedimiento
-- UPDATE SidProcedimiento SET nSecuencia = 5 WHERE nIdProcedimiento = 60

UPDATE SidUsuario
SET sGrupo = 'ANALISIS'
WHERE uIdUsuario = 'A35F0D9F-A4DE-8D43-9029-ED305D4E2C9B'

-- DEPURACION
-- ANALISIS
/*---------------------------------------------------------------------------------*/

ALTER TABLE RimProduccionAnalisis
ALTER COLUMN dFechaFin DATETIME NOT NULL

UPDATE RimProduccionAnalisis
SET dFechaFin = CONVERT(DATETIME, dFechaFin)


SELECT * FROM RimProduccionAnalisis rp
WHERE
	rp.dFechaFin >= '2022-08-31 00:00:00.000'

USE [BDSidtefim-Test]
GO

SELECT * FROM SidUsuario
SELECT * FROM RimGrupoCamposAnalisis rg WHERE rg.nIdGrupo = 5
SELECT TOP 1000 * FROM Rim_Test_2022 WHERE nId >= 51


DROP TABLE IF EXISTS #tmp_cols_a
DECLARE @table VARCHAR(MAX) = 'RUMANIA_ABRIL_AGOSTO'

DECLARE @csv VARCHAR(MAX) = (
	SELECT 
		[field] = STRING_AGG(s.COLUMN_NAME, '|')
	FROM INFORMATION_SCHEMA.COLUMNS s
	WHERE 
		s.TABLE_NAME = @table
		AND s.COLUMN_NAME LIKE '%_a'
)

SELECT [field] = value INTO #tmp_cols_a FROM STRING_SPLIT(@csv, '|')

WHILE EXISTS(SELECT 1 FROM #tmp_cols_a)
BEGIN
	DECLARE @field VARCHAR(MAX) = (SELECT TOP 1 field FROM #tmp_cols_a ORDER BY field)

	DECLARE @sql NVARCHAR(MAX) = N'ALTER TABLE ' + @table + ' ALTER COLUMN ' + @field + ' VARCHAR(MAX) NULL'
	EXEC sp_executesql @sql

	DELETE FROM #tmp_cols_a WHERE field = @field
END



/* ► Test ... */
SELECT * FROM RimTablaDinamica

SELECT * FROM INPE_AGO_22
SELECT * FROM Pas_DNI_vinculado
SELECT * FROM RUMANIA_ABRIL_AGOSTO


SELECT * FROM Rim_Extraccion_2022
SELECT * FROM RrhhFormatoPermisos
UPDATE RrhhFormatoPermisos SET bAtendido = 0

-- DEPURACION
SELECT * FROM SidUsuario
UPDATE SidUsuario
	SET sGrupo = 'DEPURACION'
WHERE uIdUsuario = 'A12E06BB-4BC7-4E92-A4B5-79F0967B1A58'

UPDATE RimTablaDinamica
	SET uIdUsrCreador = '662F5C2F-3B01-46E6-A771-8CA4A611F86D'
FROM RimTablaDinamica td
JOIN SidUsuario uc ON td.uIdUsrCreador = uc.uIdUsuario
WHERE
	uc.sLogin = 'rguevarav'

SELECT * FROM RimTablaDinamica td
JOIN SidUsuario uc ON td.uIdUsrCreador = uc.uIdUsuario
WHERE
	uc.sLogin = 'rguevarav_c'
	
EXEC [dbo].[usp_Rim_Rpt_Produccion_Diaria] '2023-03-17', '2023-03-17'

USE SIRIM
GO

SELECT * FROM SidUsuario 
WHERE 
	-- sLogin = 'rguevarav_c'
	sGrupo = 'DEPURACION'


UPDATE SidUsuario
	SET sGrupo = 'DEPURACION'
WHERE sLogin = 'ASALDARRIAGAA'


-- $2a$10$QjdjjZ3Z1gB3mEuO1Wft3O43hX8xJTLarNC5Ah3RyO20YXejTFpi2
-- $2a$10$SmgP1tGoOkTJdRfuo71ew.sUO4oCIA1h2Vtji1kJJhiPSYXgyrEZO
UPDATE SidUsuario
	-- SET sGrupo = 'DEPURACION'
	-- SET sGrupo = 'ANALISIS'
	 SET xPassword = '$2a$10$SmgP1tGoOkTJdRfuo71ew.sUO4oCIA1h2Vtji1kJJhiPSYXgyrEZO'
WHERE 
	sLogin = 'NPASTOR'
	-- sLogin = 'ASALDARRIAGAA'

SELECT TOP 10 * FROM RimProduccionAnalisis


