USE [BDSidtefim-Test]
GO

/*░
	dbo.usp_Rrhh_Utilitarios_ControlPermisos
--================================================================================================================================*/

CREATE OR ALTER PROCEDURE usp_Rrhh_Utilitarios_ControlPermisos
(
	@servidor VARCHAR(120)
)
AS
BEGIN
	;WITH cte_ctrlAsistencia AS (

		SELECT 
			ca.nIdUsuario,
			ca.sNombre,
			[dFechaControl] = CONVERT(DATE, ca.dFechaHoraIngreso),
			[dHoraEntrada] = SUBSTRING(STRING_AGG(CONVERT(VARCHAR(5), ca.dFechaHoraIngreso, 24), ' '), 1, 5),
			[dHoraSalida] = SUBSTRING(STRING_AGG(CONVERT(VARCHAR(5), ca.dFechaHoraIngreso, 24), ' '), 7, 5)
		FROM RrhhControlAsistencia ca
		WHERE
			ca.sNombre = @servidor
		GROUP BY
			ca.nIdUsuario,
			ca.sNombre,
			CONVERT(DATE, ca.dFechaHoraIngreso)	

	), cte_ctrlAsistencia_lj_formatoPermisos AS (
	
		SELECT 
			ca.*,
			fp.*
		FROM cte_ctrlAsistencia ca
		LEFT JOIN RrhhFormatoPermisos fp ON ca.dFechaControl = CONVERT(DATE, fp.dDesde) AND ca.sNombre = @servidor

	) SELECT 
		[idUsuario] = ca.nIdUsuario,
		[servidor] = ca.sNombre,
		[fechaControl] = CONVERT(VARCHAR, ca.[dFechaControl], 103),
		[horaEntrada] = ca.dHoraEntrada,
		[horaSalida] = ca.dHoraSalida,
		[tipoLicencia] = ca.sTipoLicencia,
		[desde] = CONVERT(VARCHAR, ca.dDesde, 103) + ' ' + CONVERT(VARCHAR, ca.dDesde, 24),
		[hasta] = CONVERT(VARCHAR, ca.dHasta, 103) + ' ' + CONVERT(VARCHAR, ca.dHasta, 24),
		[totalHoras] = ca.sTotalHoras,
		[justificacion] = ca.sJustificacion
	FROM cte_ctrlAsistencia_lj_formatoPermisos ca
	ORDER BY
		[fechaControl]

END

-- Test
EXEC usp_Rrhh_Utilitarios_ControlPermisos 'REQUENA CORNEJO GUSTAVO HUMBERTO'

-- DROP TABLE RrhhFormatoPermisos
SELECT * FROM RrhhFormatoPermisos
SELECT TOP 100 * FROM RrhhControlAsistencia

UPDATE RrhhFormatoPermisos SET bRecibido = 0



SELECT TOP 1 ca.* FROM RrhhControlAsistencia ca WHERE ca.sNombre = 'REQUENA CORNEJO GUSTAVO HUMBERTO'


--================================================================================================================================