USE BD_SIRIM
GO

-- ===========================================================================================================================================================
-- dbo.usp_Rim_Rpt_Pasaportes_Indicadores
-- ===========================================================================================================================================================
CREATE OR ALTER PROCEDURE dbo.usp_Rim_Rpt_Pasaportes_Indicadores
AS
BEGIN
	
	-- Dep's ...
	DECLARE @entregados INT,
			@vigentes INT,
			@personas INT,
			@hombres INT,
			@mujeres INT

	-- Personas: Hombres, Mujeres
	
		
	SELECT pas.sNumeroDNI, pas.sSexo INTO #tmp_persona FROM (
		SELECT 
			rp.*,
			[nRow_pas] = ROW_NUMBER() OVER (PARTITION BY rp.sNumeroDNI ORDER BY rp.sNumeroDNI)
		FROM RimPasaporte rp
	) pas
	WHERE pas.nRow_pas = 1
	
	SELECT @personas = COUNT(1) FROM #tmp_persona p
	SELECT @hombres = COUNT(1) FROM #tmp_persona p WHERE p.sSexo = 'M'
	SELECT @mujeres = COUNT(1) FROM #tmp_persona p WHERE p.sSexo = 'F'

	-- Cleanup ...
	DROP TABLE IF EXISTS #tmp_persona

	-- Entregados
	SELECT 
		@entregados = COUNT(1)
	FROM RimPasaporte rp
	WHERE 
		rp.sEstado = 'ENTREGADA'

	-- Vigentes
	SELECT 
		@vigentes = COUNT(1)
	FROM RimPasaporte rp
	WHERE
		rp.sEstado IN ('FINALIZADA', 'ENTREGADA')
		AND DATEDIFF(DD, GETDATE(), rp.dFechaCaducidad) > 0


	-- Result ...
	SELECT [entregados] = @entregados,
		   [vigentes] = @vigentes,
		   [personas] = @personas,
		   [hombres] = @hombres,
		   [mujeres] = @mujeres
		
END

-- Test ...
EXEC dbo.usp_Rim_Rpt_Indicadores_Pasaportes
-- ===========================================================================================================================================================


-- ===========================================================================================================================================================
-- dbo.usp_Rim_Rpt_Indicadores_Pasaportes
-- ===========================================================================================================================================================
CREATE OR ALTER PROCEDURE dbo.usp_Rim_Rpt_Pasaportes_Entregados_Por_Años
AS
BEGIN

	SELECT 
		[año] = COALESCE(DATEPART(YYYY, rp.dFechaEntrega), 2016),
		[entregados] = COUNT(1)
	FROM RimPasaporte rp
	WHERE 
		rp.sEstado = 'ENTREGADA'
	GROUP BY 
		COALESCE(DATEPART(YYYY, rp.dFechaEntrega), 2016)
	ORDER BY
		[año]

END

-- Test ...
EXEC dbo.usp_Rim_Rpt_Pasaportes_Entregados_Por_Años
-- ===========================================================================================================================================================

-- ===========================================================================================================================================================
-- dbo.usp_Rim_Rpt_Indicadores_Pasaportes
-- ===========================================================================================================================================================
CREATE OR ALTER PROCEDURE dbo.usp_Rim_Rpt_Pasaportes_Entregados_Por_12UltimosMeses
AS
BEGIN

	SELECT 
		[año] = DATEPART(YYYY, rp.dFechaEntrega),
		[mes] = DATEPART(MM, rp.dFechaEntrega),
		[añomes] = CONCAT(DATEPART(YYYY, rp.dFechaEntrega), '-', RIGHT(CONCAT('00', DATEPART(MM, rp.dFechaEntrega)), 2)),
		[entregados] = COUNT(1)
	FROM RimPasaporte rp
	WHERE 
		rp.sEstado = 'ENTREGADA'
		AND rp.dFechaEntrega >= DATEADD(MM, -12, GETDATE())
	GROUP BY 
		DATEPART(YYYY, rp.dFechaEntrega),
		DATEPART(MM, rp.dFechaEntrega),
		CONCAT(DATEPART(YYYY, rp.dFechaEntrega), '-', RIGHT(CONCAT('00', DATEPART(MM, rp.dFechaEntrega)), 2))
	ORDER BY
		[año],
		[mes]

END

-- Test ...
EXEC dbo.usp_Rim_Rpt_Pasaportes_Entregados_Por_12UltimosMeses

-- ===========================================================================================================================================================

-- ===========================================================================================================================================================
-- dbo.usp_Rim_Rpt_Pasaportes_Entregados_Por_30UltimosDias
-- ===========================================================================================================================================================
CREATE OR ALTER PROCEDURE dbo.usp_Rim_Rpt_Pasaportes_Entregados_Por_31UltimosDias
AS
BEGIN

	SELECT 
		[mes] = DATEPART(MM, rp.dFechaEntrega),
		[dia] = DATEPART(DD, rp.dFechaEntrega),
		[diames] = CONCAT(RIGHT(CONCAT('00', DATEPART(DD, rp.dFechaEntrega)), 2), '-', RIGHT(CONCAT('00', DATEPART(MM, rp.dFechaEntrega)), 2)),
		[entregados] = COUNT(1)
	FROM RimPasaporte rp
	WHERE 
		rp.sEstado = 'ENTREGADA'
		-- AND rp.dFechaEntrega >= DATEADD(DD, -31, GETDATE())
		AND rp.dFechaEntrega >= DATEADD(DD, -31, '2022-10-19 00:00:00.000')
	GROUP BY 
		DATEPART(MM, rp.dFechaEntrega),
		DATEPART(DD, rp.dFechaEntrega),
		CONCAT(RIGHT(CONCAT('00', DATEPART(DD, rp.dFechaEntrega)), 2), '-', RIGHT(CONCAT('00', DATEPART(MM, rp.dFechaEntrega)), 2))
	ORDER BY
		[mes],
		[dia]

END

-- Test ...
SELECT TOP 100 * FROM RimPasaporte p
ORDER BY p.dFechaEntrega DESC

SELECT * FROM SidUsuario

EXEC dbo.usp_Rim_Rpt_Pasaportes_Entregados_Por_31UltimosDias

SELECT TOP 100 * FROM RimPasaporte rp
ORDER BY
	rp.dFechaEntrega DESC

USE [BD_SIRIM]
GO

SELECT COUNT(1) FROM RimPasaporte
SELECT * FROM SidUsuario

SELECT
	t.sNombre,
	a.* 
FROM RimTablaDinamica t
JOIN [dbo].[RimGrupoCamposAnalisis] g ON t.nIdTabla = g.nIdTabla
JOIN [dbo].[RimAsigGrupoCamposAnalisis] a ON g.nIdGrupo = a.nIdGrupo
WHERE 
	a.nIdGrupo = 22
	-- AND a.nRegAnalisisIni>= 11982
	AND a.nRegAnalisisIni = 2091
	
DELETE FROM RimAsigGrupoCamposAnalisis WHERE nIdAsigGrupo = 369
DELETE FROM [dbo].[RimProduccionAnalisis] WHERE nIdAsigGrupo = 369
-- ===========================================================================================================================================================