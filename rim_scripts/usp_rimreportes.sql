USE [BDSidtefim-Test]
GO

-- ====================================================================================================================================
-- » Tiempo promedio de Analisis por Servidor ...
-- ====================================================================================================================================
CREATE OR ALTER usp_Rim_rpt_Indicadores_Pasaportes
AS
BEGIN

	SELECT TOP 10 * FROM RimPasaporte rp
	ORDER BY rp.dFechaEntrega DESC

END



-- ► Test ...
EXEC usp_rpt_Tiempo_Promedio_Analisis '2022-09-09', '2022-09-09'
-- ====================================================================================================================================

-- ====================================================================================================================================
-- » Progreso respecto a la proyección de registros analizados...
-- ====================================================================================================================================
CREATE OR ALTER PROCEDURE usp_Rim_rpt_ProyeccionAnalisisMensual
(
	@año INT
)
AS
BEGIN

	;WITH cte_produccion_mensual AS (

		SELECT
			[grupo] = uc.sGrupo,
			[año] = DATEPART(YYYY, p.dFechaFin),
			[mes] = DATEPART(MM, p.dFechaFin),
			[totalAnalizados] = COUNT(1)
		FROM RimTablaDinamica t
		JOIN SidUsuario uc ON t.uIdUsrCreador = uc.uIdUsuario
		JOIN RimGrupoCamposAnalisis g ON t.nIdTabla = g.nIdTabla
		JOIN RimAsigGrupoCamposAnalisis a ON g.nIdGrupo = a.nIdGrupo
		JOIN SidUsuario ua ON a.uIdUsrAnalista = ua.uIdUsuario
		JOIN RimProduccionAnalisis p ON a.nIdAsigGrupo = p.nIdAsigGrupo
		WHERE
			DATEPART(YYYY, p.dFechaFin) = @año
			AND uc.sLogin != 'rguevarav'
		GROUP BY
			uc.sGrupo,
			DATEPART(YYYY, p.dFechaFin),
			DATEPART(MM, p.dFechaFin)
	
	) SELECT 
		[grupo] = pa.sGrupo,
		[año] = pa.nAño,
		[mes] = pa.nMes,
		[analizados] = COALESCE(pm.totalAnalizados, 0),
		[proyeccion] = pa.nTotal
	FROM RimProyeccionAnalisis pa
	LEFT JOIN cte_produccion_mensual pm ON pa.sGrupo = pm.grupo 
										AND pa.nAño = pm.año
										AND pa.nMes = pm.mes
	WHERE
		pa.nAño = @año
	ORDER BY
		[grupo],
		[mes]

END

-- ► Test ...
EXEC usp_Rim_rpt_ProyeccionAnalisisMensual 2023
-- ====================================================================================================================================




-- ====================================================================================================================================
-- » ...
-- ====================================================================================================================================


DECLARE @metaFieldIdErrorCsv VARCHAR(MAX),
		@uc VARCHAR(8000)

SELECT 
	[usrAnalista] = ua.sNombres,
	metaFieldIdErrorCsv = STRING_AGG(p.sMetaFieldIdErrorCsv, ',')
FROM RimProduccionAnalisis p
JOIN RimAsigGrupoCamposAnalisis a ON p.nIdAsigGrupo = a.nIdAsigGrupo
JOIN SidUsuario ua ON a.uIdUsrAnalista = ua.uIdUsuario
WHERE
	p.sMetaFieldIdErrorCsv IS NOT NULL
	AND LEN(p.sMetaFieldIdErrorCsv) > 0
GROUP BY
	ua.sNombres

SELECT 
	err.*,
	[nTotalPorcentaje] = ROUND((CONVERT(FLOAT, err.nTotal) / SUM(err.nTotal) OVER()) * 100, 2)
FROM (

	SELECT 
		[sMetaFieldIdErrorCsv] = LTRIM(RTRIM(err.[value])),
		[nTotal] = COUNT(1)
	FROM STRING_SPLIT(@metaFieldIdErrorCsv, ',') err
	GROUP BY
		LTRIM(RTRIM(err.[value]))

) err
ORDER BY
	err.[nTotal] DESC



SELECT CONVERT(FLOAT, 122) / 1200


SELECT * FROM SidUsuario





SELECT TOP 10 * FROM RimCtrlCalCamposAnalisis

-- ► Test ...
EXEC usp_Rim_rpt_ProyeccionAnalisisMensual 2023
-- ====================================================================================================================================