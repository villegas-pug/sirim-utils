USE SIRIM
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


-- ====================================================================================================================================
-- » usp_rpt_Produccion_Horas_Laborales_Por_Analista
-- ====================================================================================================================================
CREATE OR ALTER PROCEDURE usp_rpt_Produccion_Horas_Laborales_Por_Analista
(
	@fechaAnalisis DATE,
	@grupo VARCHAR(55)
)
AS
BEGIN

	;WITH cte_working_hours AS (
		SELECT [hora] = 8
		UNION ALL
		SELECT [hora] = wh.hora + 1 FROM cte_working_hours wh
		WHERE wh.hora < 18
	), cte_working_hours_crossjoin_users AS (
		SELECT * FROM cte_working_hours w
		CROSS JOIN SidUsuario u
		WHERE 
			u.sGrupo LIKE @grupo
	), cte_prod AS (
		SELECT
			[usrAnalista] = ru.sNombres,
			[grupo] = ru.sGrupo,
			[base] = rt.sNombre,
			[horaAnalisis] = CONVERT(CHAR(2), CONVERT(VARCHAR, rp.dFechaFin, 108)),
			[totalAnalizados] = COUNT(1)
		FROM RimProduccionAnalisis rp
		JOIN RimAsigGrupoCamposAnalisis ra ON rp.nIdAsigGrupo = ra.nIdAsigGrupo
		JOIN RimGrupoCamposAnalisis rg ON ra.nIdGrupo = rg.nIdGrupo
		JOIN RimTablaDinamica rt ON rg.nIdTabla = rt.nIdTabla
		JOIN SidUsuario ru ON ra.uIdUsrAnalista = ru.uIdUsuario
		WHERE
			rp.dFechaFin BETWEEN CONCAT(@fechaAnalisis, ' 00:00:00.000') AND CONCAT(@fechaAnalisis, ' 23:59:59.999')
			AND ru.sGrupo LIKE @grupo
		GROUP BY
			ru.sNombres,
			ru.sGrupo,
			rt.sNombre,
			CONVERT(CHAR(2), CONVERT(VARCHAR, rp.dFechaFin, 108))
	), cte_working_hours_join_prod AS (
		SELECT 
			*,
			[fechaAnalisis] = @fechaAnalisis,
			[eventos] = (
							SELECT STRING_AGG(re.sTitle, '|') FROM RimEvento re 
							WHERE 
								wh.uIdUsuario = re.uIdUsuario
								AND CONCAT(@fechaAnalisis, ' ', wh.hora, ':00') BETWEEN re.dStart AND re.dEnd
						)
		FROM cte_working_hours_crossjoin_users wh
		LEFT JOIN cte_prod p ON wh.sNombres = p.usrAnalista AND wh.hora = p.horaAnalisis
	) SELECT
		p.fechaAnalisis,
		[horaAnalisis] = p.hora,
		[idUsuario] = p.uIdUsuario,
		[nombres] = p.sNombres,
		[grupo] = p.sGrupo,
		p.base,
		p.eventos,
		[totalAnalizados] = COALESCE(p.totalAnalizados, 0)
	FROM cte_working_hours_join_prod p
	ORDER BY 
		p.hora

END

/* ► Test ... */
EXEC usp_rpt_Produccion_Horas_Laborales_Por_Analista '2022-09-12', '%'
SELECT * FROM RimProduccionAnalisis
SELECT * FROM SidUsuario
SELECT * FROM RimEvento
-- ====================================================================================================================================

DECLARE @fechaAnalisis DATE = '2022-09-08'

SELECT
	[usrAnalista] = ru.sNombres,
	[grupo] = ru.sGrupo,
	[base] = rt.sNombre,
	[horaAnalisis] = CONVERT(CHAR(2), CONVERT(VARCHAR, rp.dFechaFin, 108)),
	[totalAnalizados] = COUNT(1)
FROM RimProduccionAnalisis rp
JOIN RimAsigGrupoCamposAnalisis ra ON rp.nIdAsigGrupo = ra.nIdAsigGrupo
JOIN RimGrupoCamposAnalisis rg ON ra.nIdGrupo = rg.nIdGrupo
JOIN RimTablaDinamica rt ON rg.nIdTabla = rt.nIdTabla
JOIN SidUsuario ru ON ra.uIdUsrAnalista = ru.uIdUsuario
WHERE
	rp.dFechaFin BETWEEN CONCAT(@fechaAnalisis, ' 00:00:00.000') AND CONCAT(@fechaAnalisis, ' 23:59:59.999')
GROUP BY
	ru.sNombres,
	ru.sGrupo,
	rt.sNombre,
	CONVERT(CHAR(2), CONVERT(VARCHAR, rp.dFechaFin, 108))

SELECT STRING_AGG(re.sTitle, '|') FROM RimEvento re 