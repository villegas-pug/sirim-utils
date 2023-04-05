USE [BDSidtefim-Test]
GO

/*» dbo.usp_Rim_Procedimiento_ReporteMensualProduccion ... */
/*-----------------------------------------------------------------------------------------------------------------------*/
CREATE OR ALTER PROCEDURE dbo.usp_Rim_Procedimiento_ReporteMensualProduccion
(
	@idUsrAnalista UNIQUEIDENTIFIER,
	@month SMALLINT,
	@year SMALLINT
)
AS
BEGIN
	-- ► Dep's to cte `calendario` ...
	DECLARE @iniDate DATE = CONCAT(@year, '-', RIGHT(CONCAT('00', @month), 2), '-', '01')
	DECLARE @endDate DATE = DATEADD(DAY, -1, DATEADD(MM, DATEDIFF(MM, 0, @iniDate) + 1, 0))

	-- ► CTE: Calendario
	DROP TABLE IF EXISTS #calendario
	;WITH calendario AS (
		SELECT dFecha = @iniDate
		UNION ALL
		SELECT DATEADD(DD, 1, c.dFecha) FROM calendario c
		WHERE c.dFecha < @endDate
	) SELECT 
		[semana] = CONCAT('SEMANA ', DATEPART(WEEK, c.dFecha) - DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM, 0, c.dFecha), 0)) + 1),
		c.* 
		INTO #calendario 
	FROM calendario c
	WHERE 
		-- DATEPART(WEEKDAY, c.dFecha) NOT IN (6, 7)
		DATENAME(WEEKDAY, c.dFecha) NOT IN ('Saturday', 'Sunday')
	OPTION (MAXRECURSION 31)

	-- ► ...
	SELECT 
		[semanaProd] = c.semana,
		c.dFecha fechaProd,
		p.nombreBase,
		p.totalProd,
		p.observaciones
	FROM (
		SELECT 
			[fechaProd] = CONVERT(DATE, rp.dFechaFin),
			rt.sNombre nombreBase,
			[totalProd] = COUNT(1),
			[observaciones] = CONCAT('Del registro ', rag.nRegAnalisisIni, ' al ', rag.nRegAnalisisFin)
		FROM RimTablaDinamica rt
		JOIN RimGrupoCamposAnalisis rg ON rt.nIdTabla = rg.nIdTabla
		JOIN RimAsigGrupoCamposAnalisis rag ON rg.nIdGrupo = rag.nIdGrupo
		JOIN RimProduccionAnalisis rp ON rag.nIdAsigGrupo = rp.nIdAsigGrupo
		WHERE
			rag.uIdUsrAnalista = @idUsrAnalista
			AND MONTH(rp.dFechaFin) = @month
		GROUP BY
			DATEPART(WEEK, rp.dFechaFin) - DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM, 0, rp.dFechaFin), 0)),
			CONVERT(DATE, rp.dFechaFin),
			rt.sNombre,
			CONCAT('Del registro ', rag.nRegAnalisisIni, ' al ', rag.nRegAnalisisFin)
	) p
	RIGHT OUTER JOIN #calendario c ON p.fechaProd = c.dFecha

	-- ► Clean-up ...
	DROP TABLE IF EXISTS #calendario

END

/*» Test ...*/
EXEC dbo.usp_Rim_Procedimiento_ReporteMensualProduccion '513A3871-8BAD-4161-A470-119E00CD1EC5', 9, 2022
/*-----------------------------------------------------------------------------------------------------------------------*/

USE [BDSidtefim-Test]
GO

SELECT * FROM RimAsigGrupoCamposAnalisis
SELECT * FROM RimGrupoCamposAnalisis
SELECT * FROM RimProduccionAnalisis
SELECT * FROM RimCtrlCalCamposAnalisis
SELECT * FROM SidUsuario

UPDATE RimProduccionAnalisis
	SET sMetaFieldIdErrorCsv = NULL