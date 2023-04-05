USE [BDSidtefim-Test]
GO

-- ==============================================================================================================================
-- » Tiempo promedio de Analisis por Servidor ...
-- ==============================================================================================================================
CREATE OR ALTER PROCEDURE usp_rpt_Tiempo_Promedio_Analisis
(
	@fecIni DATE,
	@fecFin DATE
)
AS
BEGIN
	;WITH cte_RimProdAnalisiFechas AS (-- STEP-01 ...
		SELECT
			[usrAnalista] = ru.sNombres,
			[grupo] = ru.sGrupo,
			[base] = rt.sNombre,
			ra.nRegAnalisisIni,
			ra.nRegAnalisisFin,
			[fechaHoraAnalisis] = rp.dFechaFin,
			[fechaHoraAnalisisAnt] = LAG(rp.dFechaFin) OVER (ORDER BY rp.dFechaFin)
		FROM RimProduccionAnalisis rp
		JOIN RimAsigGrupoCamposAnalisis ra ON rp.nIdAsigGrupo = ra.nIdAsigGrupo
		JOIN RimGrupoCamposAnalisis rg ON ra.nIdGrupo = rg.nIdGrupo
		JOIN RimTablaDinamica rt ON rg.nIdTabla = rt.nIdTabla
		JOIN SidUsuario ru ON ra.uIdUsrAnalista = ru.uIdUsuario
		WHERE
			rp.dFechaFin BETWEEN CONCAT(@fecIni, ' 00:00:00.000') AND CONCAT(@fecFin, ' 23:59:59.999')
			AND ru.sGrupo IN ('ANALISIS', 'DEPURACION')
	), cte_RimProdAnalisiFechasDiff AS (
		SELECT 
			rp.usrAnalista,
			rp.grupo,
			rp.base,
			rp.fechaHoraAnalisis,
			[totalAsignados] = (rp.nRegAnalisisFin - rp.nRegAnalisisIni) + 1,
			[fechaHoraAnalisisDiff] = CONVERT(FLOAT, CONVERT(DATETIME, rp.fechaHoraAnalisis)) - CONVERT(FLOAT, CONVERT(DATETIME, rp.fechaHoraAnalisisAnt))
		FROM cte_RimProdAnalisiFechas rp
	), cte_RimProdAnalisiFechasAvg AS (
		SELECT 
			rp.usrAnalista,
			rp.grupo,
			rp.base,
			rp.totalAsignados,
			[fechaAnalisis] = CONVERT(DATE, rp.fechaHoraAnalisis),
			[fechaHoraAnalisisSum] = SUM(rp.fechaHoraAnalisisDiff),
			[fechaHoraAnalisisAvg] = AVG(rp.fechaHoraAnalisisDiff),
			[totalAnalizados] = COUNT(1)
		FROM cte_RimProdAnalisiFechasDiff rp
		GROUP BY
			rp.usrAnalista,
			rp.grupo,
			rp.base,
			rp.totalAsignados,
			CONVERT(DATE, rp.fechaHoraAnalisis)
	) SELECT
		[nro] = ROW_NUMBER() OVER (ORDER BY rp.usrAnalista, rp.grupo, rp.base, rp.fechaHoraAnalisisAvg),
		rp.usrAnalista,
		rp.grupo,
		rp.base,
		rp.fechaAnalisis,
		rp.totalAsignados,
		rp.totalAnalizados,
		[fechaHoraAnalisisAvg] = CONVERT(VARCHAR, CONVERT(DATETIME, rp.fechaHoraAnalisisAvg), 24),
		[fechaHoraAnalisisSum] = CONVERT(VARCHAR, CONVERT(DATETIME, rp.fechaHoraAnalisisSum), 24)
	FROM cte_RimProdAnalisiFechasAvg rp	
END

-- ► Test ...
EXEC usp_rpt_Tiempo_Promedio_Analisis '2022-09-09', '2022-09-09'

-- ====================================================================================================================================

-- ==============================================================================================================================
-- » Tiempo promedio de Analisis por Servidor ...
-- ==============================================================================================================================
CREATE OR ALTER PROCEDURE dbo.usp_Rim_Rpt_Produccion_Diaria
(
	@fecIni DATE,
	@fecFin DATE
)
AS
BEGIN

	SELECT 
		[usrAnalista] = ua.sNombres,
		[grupo] = uc.sGrupo,
		[totalAnalizados] = COUNT(1)
	FROM RimTablaDinamica t
	JOIN SidUsuario uc ON t.uIdUsrCreador = uc.uIdUsuario
	JOIN RimGrupoCamposAnalisis g ON t.nIdTabla = g.nIdTabla
	JOIN RimAsigGrupoCamposAnalisis a ON g.nIdGrupo = a.nIdGrupo
	JOIN SidUsuario ua ON a.uIdUsrAnalista = ua.uIdUsuario
	JOIN RimProduccionAnalisis p ON a.nIdAsigGrupo = p.nIdAsigGrupo
	WHERE
		CONVERT(DATE, p.dFechaFin) BETWEEN @fecIni AND @fecFin
		AND uc.sLogin != 'rguevarav'
		AND ua.sLogin NOT IN ('NPASTOR', 'EGOLIVERA')
	GROUP BY
		ua.sNombres,
		uc.sGrupo
	HAVING 
		COUNT(1) > 0
	ORDER BY
		[totalAnalizados] DESC

END

-- Test ...
EXEC dbo.usp_Rim_Rpt_Produccion_Diaria '2022-10-26', '2022-10-26'
-- ==============================================================================================================================

SELECT * FROM SidUsuario
SELECT * FROM RimAsigGrupoCamposAnalisis




