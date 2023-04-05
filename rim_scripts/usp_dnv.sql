USE [BDSidtefim-Test]
GO

-- ===========================================================================================================================================================
-- dbo.usp_Rim_Utilitario_Dnv
-- ===========================================================================================================================================================
CREATE OR ALTER PROCEDURE dbo.usp_Rim_Utilitario_Dnv
(
	@nacionalidad VARCHAR(3), --PER
	@dependencia VARCHAR(3), --25 | %
	@tipoMov VARCHAR(1), -- E | S | %
	@fecIniMovMig DATETIME, -- 2022-01-01
	@fecFinMovMig DATETIME -- 2022-01-01
)
AS
BEGIN
	/*► Dep's */
	/*DECLARE @dtFecIniMovMig DATETIME = CONCAT(@fecIniMovMig, ' 00:00:00'),
			@dtFecFinMovMig DATETIME = CONCAT(@fecFinMovMig, ' 23:59:59')*/

	/*► Repo: ... */
	/*======================================================*/
	DROP TABLE IF EXISTS #estadia_migratoria
	CREATE TABLE #estadia_migratoria
	(
		[uIdPersona] UNIQUEIDENTIFIER,
		[Tipo_Calidad_Migratoria] VARCHAR(55) NULL,
		[Calidad_Migratoria] VARCHAR(55) NULL,
		[Fecha_Inicio_Calidad_Migratoria] DATE NULL,
		[Fecha_Vencimiento_Calidad_Migratoria] DATE NULL
	)
	/*======================================================*/


	/*► STEP-01: Guardar `MovMig` en tabla temporal ... */
	DROP TABLE IF EXISTS #mm_dnv
	SELECT
		-- Group-01
		Nro = ROW_NUMBER() OVER (ORDER BY smm.dFechaControl, smm.uIdPersona),
		(smm.sIdDocumento)Documento,
		[Num_Doc_Viaje] = CONCAT('''', smm.sNumeroDoc),
		(sp.sNombre)Nombre,
		(sp.sPaterno)Ape_Paterno,
		(sp.sMaterno)Ape_Materno,
		(sp.sSexo)Sexo,
		[Fec_Nacimiento] = CONVERT(VARCHAR, sp.dFechaNacimiento, 20),
		(sp.sIdEstadoCivil)Estado_Civil,
		(spnacimiento.sNombre)Pais_Nacionalidad,
		(spnacionalidad.sNombre)Pais_Nacimiento,
		(smm.sTipo)Tipo_Mov,
		[Fec_Control] = CONVERT(VARCHAR, smm.dFechaControl, 20),
		sope.sLogin L_Ope_Digita,
		sope.sNombre Operador_Digita,
		(spaismov.sNombre)Proc_Des,
		(sd.sNombre)Dep_Digita,
		(setran.sNombreRazon)Empresa_Transporte,
		(scm.sDescripcion)MovMig_Calidad_Migratoria,
		smm.bAnulado [MM_Anulado],

		-- Group-02
		--(sce.sNumeroCarnet)Numero_Carnet,
		--(sce.dFechaCaducidad)Fecha_Caducidad,
		(sprof.sDescripcion)Ocupacion,
		(sorg.sNombre)Razon_Social_Empresa,
		(sorg.sNumeroDoc)Ruc_Empresa,

		su.sIdUbigeo Id_Ubigeo,
		(
			(SELECT sNombre FROM SimUbigeo WHERE sCodAnterior = LEFT(su.sIdUbigeo, 2)) + ' - ' +
			(SELECT sNombre FROM SimUbigeo WHERE sCodAnterior = LEFT(su.sIdUbigeo, 4)) + ' - ' +
			(su.sNombre)
		) Direccion_Ubigeo,
		se.sDomicilio Direccion_Domicilio,
	
		-- Group-03
		(smm.sObservaciones)Observaciones_SIM_RCM,
		(sdi.sIdDocInvalida)Doc_Invalida,
		(sdi.sNumDocInvalida)Num_Doc_Inva,
		(sdi.nTipoAlerta)Tipo_Alerta,
		(spna.sDescripcion)Des_Persona_No_Auto,
		(spna.sObservaciones)Observaciones_Persona_No_Auto,

		smv.sDescripcion Motivo_Viaje,
		smm.sObservaciones Observaciones_MovMigra,
		ssa.sNumeroDoc Doc_Autoridad_Viaje,
		ssa.dFechaEmision Fec_Emi_SalidaAutorizada,
		ssa.sObservaciones Obs_SalidaAutorizada,
		ssa.sNombreAutoridad Autoridad_SalidaAutorizada,
		sta.sDescripcion Tipo_Autoridad
		--INTO #mm_dnv
	FROM SimMovMigra smm 
	LEFT OUTER JOIN SimPersona sp ON sp.uIdPersona = smm.uIdPersona
	LEFT OUTER JOIN SimUsuario sope ON smm.nIdOperadorDigita = sope.nIdOperador
	LEFT OUTER JOIN SimPersonaNoAutorizada spna ON smm.sNumeroDoc = spna.sNumDocIdentidad
	LEFT OUTER JOIN SimProfesion sprof ON sp.sIdProfesion = sprof.sIdProfesion
	LEFT OUTER JOIN SimDocInvalidacion sdi ON spna.nIdDocInvalidacion = sdi.nIdDocInvalidacion
	LEFT OUTER JOIN SimDependencia sd ON smm.sIdDependencia = sd.sIdDependencia
	--LEFT OUTER JOIN SimCarnetExtranjeria sce ON sp.uIdPersona = sce.uIdPersona
	LEFT OUTER JOIN SimExtranjero se ON sp.uIdPersona = se.uIdPersona
	LEFT OUTER JOIN SimUbigeo su ON se.sIdUbigeoDomicilio = su.sIdUbigeo
	LEFT OUTER JOIN SimOrganizacion sorg ON se.nIdOrganizacion = sorg.nIdOrganizacion
	LEFT OUTER JOIN SimEmpTransporte setran ON smm.nIdTransportista = setran.nIdTransportista
	LEFT OUTER JOIN SimCalidadMigratoria scm ON smm.nIdCalidad = scm.nIdCalidad
	LEFT OUTER JOIN SimPais spnacimiento ON sp.sIdPaisNacimiento = spnacimiento.sIdPais
	LEFT OUTER JOIN SimPais spnacionalidad ON sp.sIdPaisNacionalidad = spnacionalidad.sIdPais
	LEFT OUTER JOIN SimPais spaismov ON smm.sIdPaisMov = spaismov.sIdPais
	LEFT OUTER JOIN SimMotivoViaje smv ON smm.nIdMotivoViaje = smv.nIdMotivoViaje
	LEFT OUTER JOIN SimSalidaAutorizada ssa ON smm.sIdMovMigratorio = ssa.sIdMovMigratorio
	LEFT OUTER JOIN SimTipoAutoridad sta ON ssa.nIdTipoAutoridad = sta.nIdTipoAutoridad
	WHERE
		smm.bAnulado = 0
		--AND sce.bAnulado = 0
		AND smm.sTipo LIKE @tipoMov
		AND smm.dFechaControl BETWEEN @fecIniMovMig AND @fecFinMovMig
		AND smm.sIdDependencia LIKE @dependencia
		AND smm.sIdPaisNacionalidad LIKE @nacionalidad
		
	/*► CREATE NONCLUSTERED INDEX ix_mm_dnv_uIdPersona
	ON #mm_dnv(uIdPersona)

	/*► STEP-02: Guardar `Ciudadanos` en tabla temporal ... */
	SELECT DISTINCT mm.uIdPersona INTO #dnv_ciudadanos FROM #mm_dnv mm

	CREATE NONCLUSTERED INDEX ix_dnv_ciudadanos
	ON #dnv_ciudadanos(uIdPersona)

	/*► STEP-03:  ... */
	WHILE (SELECT COUNT(1) FROM #dnv_ciudadanos) > 0
	BEGIN
		DECLARE @uId UNIQUEIDENTIFIER = (SELECT TOP 1 uIdPersona FROM #dnv_ciudadanos ORDER BY uIdPersona)

		INSERT INTO #estadia_migratoria
			EXEC usp_Rim_Utilitario_Estadia_Migratoria @uId

		/► Eliminar ciudadano .../
		DELETE FROM #dnv_ciudadanos WHERE uIdPersona = @uId
	END

	CREATE NONCLUSTERED INDEX ix_estadia_migratoria_uIdPersona
	ON #estadia_migratoria(uIdPersona)


	/*► STEP-04: Join #mm_dnv y #estadia_migratoria */
	SELECT 
		es.Tipo_Calidad_Migratoria,
		es.Calidad_Migratoria,
		es.Fecha_Inicio_Calidad_Migratoria,
		es.Fecha_Vencimiento_Calidad_Migratoria,
		mm.* 
	FROM #mm_dnv mm
	LEFT OUTER JOIN #estadia_migratoria es ON mm.uIdPersona = es.uIdPersona*/

	/*► Clean-up ...*/
	DROP TABLE IF EXISTS #mm_dnv
	DROP TABLE IF EXISTS #dnv_ciudadanos
	DROP TABLE IF EXISTS #estadia_migratoria

END

/*► Test ... */
EXEC dbo.usp_Rim_Utilitario_Dnv 'CUB', '%', '%', '2022-02-01T00:00:00', '2022-03-01T23:59:59'
EXEC dbo.usp_Rim_Utilitario_Dnv 'MAR', '%', '%', '2022-05-01T00:00:00.000', '2022-05-31T23:59:59.999'
-- =============================================================================================================================================================


/*================================================================================================*/
/*► STEP-00: Si ultimo movmigra es `E` y realizó CCM(Estado: P | Posterior al movmigra) ... */
/*================================================================================================*/
CREATE OR ALTER PROCEDURE usp_Rim_Utilitario_Estadia_Migratoria(@uIdPersona UNIQUEIDENTIFIER)
AS
BEGIN

	/*► Repo to query result ... */
	/*======================================================*/
	DROP TABLE IF EXISTS tmp_estadia_migratoria
	CREATE TABLE tmp_estadia_migratoria
	(
		[uIdPersona] UNIQUEIDENTIFIER,
		[Tipo_Calidad_Migratoria] VARCHAR(55) NULL,
		[Calidad_Migratoria] VARCHAR(55) NULL,
		[Fecha_Inicio_Calidad_Migratoria] DATE NULL,
		[Fecha_Vencimiento_Calidad_Migratoria] DATE NULL
	)
	/*======================================================*/

	/*================================================================================================*/
	/*► STEP-01: Obtener el ultimo movimiento  migratorio de extranjeros ... */
	/*================================================================================================*/
	DROP TABLE IF EXISTS #tmp_extranj_ulti_movmigra
	SELECT * INTO #tmp_extranj_ulti_movmigra FROM (
		SELECT 
			*,
			ROW_NUMBER() OVER (PARTITION BY smm.uIdPersona ORDER BY smm.dFechaControl DESC) nRow_mm
		FROM SimMovMigra smm
		WHERE
			smm.bAnulado = 0
			AND smm.uIdPersona = @uIdPersona
			AND smm.sTipo IN ('E', 'S')
			AND smm.sIdPaisNacionalidad != 'PER'
	) tmp_smm
	WHERE 
		tmp_smm.nRow_mm <= 2
	/*================================================================================================*/

	/*================================================================================================*/
	/*► STEP-02: Obtener el ultimo trámite de CCM y ... */
	/*================================================================================================*/
	DROP TABLE IF EXISTS #tmp_extranj_ulti_ccm
	SELECT * INTO #tmp_extranj_ulti_ccm FROM(
		SELECT 
			*,
			ROW_NUMBER() OVER (PARTITION BY uIdPersona ORDER BY dFechaAud DESC) nRow_tram
		FROM (
			SELECT * FROM (
				SELECT 
					st.uIdPersona,
					st.nIdTipoTramite,
					sti.sEstadoActual,
					[nIdCalSolicitada] = '',
					st.dFechaHoraReg [dFechaAud],
					[dFechaVencimiento] = '',
					ROW_NUMBER() OVER (PARTITION BY st.uIdPersona ORDER BY st.dFechaHoraReg DESC) nRow
				FROM SimTramite st
				JOIN SimTramiteInm sti ON st.sNumeroTramite = sti.sNumeroTramite
				WHERE
					sti.sEstadoActual IN ('P', 'E')
					AND (st.nIdTipoTramite = 58) -- CCM
					AND st.uIdPersona = @uIdPersona
			) tmp_tram
			WHERE
				tmp_tram.nRow = 1

			UNION ALL

			SELECT * FROM ( -- Ultimo Permiso de Viaje ...
				SELECT 
					st.uIdPersona,
					st.nIdTipoTramite,
					sti.sEstadoActual,
					[nIdCalSolicitada] = '',
					sti.dFechaFin [dFechaAud],
					[dFechaVencimiento] = '',
					ROW_NUMBER() OVER (PARTITION BY st.uIdPersona ORDER BY sti.dFechaFin DESC) nRow
				FROM SimTramite st
				JOIN SimTramiteInm sti ON st.sNumeroTramite = sti.sNumeroTramite
				WHERE
					sti.sEstadoActual = 'A'
					AND st.nIdTipoTramite = 39 -- Permiso de Viaje
					AND st.uIdPersona = @uIdPersona
			) tmp_tram
			WHERE
				tmp_tram.nRow = 1

			UNION ALL
		
			SELECT * FROM (-- Ultimo CCM Aprobado ...
				SELECT 
					st.uIdPersona,
					st.nIdTipoTramite,
					sti.sEstadoActual,
					sccm.nIdCalSolicitada,
					sccm.dFechaAprobacion [dFechaAud],
					sccm.dFechaVencimiento,
					ROW_NUMBER() OVER (PARTITION BY st.uIdPersona ORDER BY sccm.dFechaAprobacion DESC) nRow
				FROM SimTramite st
				JOIN SimTramiteInm sti ON st.sNumeroTramite = sti.sNumeroTramite
				JOIN SimCambioCalMig sccm ON st.sNumeroTramite = sccm.sNumeroTramite
				WHERE
					sti.sEstadoActual = 'A'
					AND st.nIdTipoTramite = 58 -- CCM
					AND st.uIdPersona = @uIdPersona
			) tmp_tram
			WHERE
				tmp_tram.nRow = 1

			UNION ALL

			SELECT * FROM (-- Ultima PRP Aprobada ...
				SELECT 
					st.uIdPersona,
					st.nIdTipoTramite,
					sti.sEstadoActual,
					[nIdCalSolicitada] = '',
					sti.dFechaFin [dFechaAud],
					spro.dFechaVencimiento,
					ROW_NUMBER() OVER (PARTITION BY st.uIdPersona ORDER BY sti.dFechaFin DESC) nRow
				FROM SimTramite st
				JOIN SimTramiteInm sti ON st.sNumeroTramite = sti.sNumeroTramite
				JOIN SimProrroga spro ON st.sNumeroTramite = spro.sNumeroTramite
				WHERE
					sti.sEstadoActual = 'A'
					AND st.nIdTipoTramite = 56 -- PRP
					AND st.uIdPersona = @uIdPersona
			) tmp_tram
			WHERE
				tmp_tram.nRow = 1

			UNION ALL

			SELECT * FROM (-- Ultima PRR Aprobada ...
				SELECT 
					st.uIdPersona,
					st.nIdTipoTramite,
					sti.sEstadoActual,
					[nIdCalSolicitada] = '',
					sti.dFechaFin [dFechaAud],
					spro.dFechaVencimiento,
					ROW_NUMBER() OVER (PARTITION BY st.uIdPersona ORDER BY sti.dFechaFin DESC) nRow
				FROM SimTramite st
				JOIN SimTramiteInm sti ON st.sNumeroTramite = sti.sNumeroTramite
				JOIN SimProrroga spro ON st.sNumeroTramite = spro.sNumeroTramite
				WHERE
					sti.sEstadoActual = 'A'
					AND st.nIdTipoTramite = 57 -- PRR
					AND st.uIdPersona = @uIdPersona
			) tmp_tram
			WHERE
				tmp_tram.nRow = 1
		) tmp_1
	) tmp_2
	WHERE tmp_2.nRow_tram <= 3


	/*→ ...*/
	DECLARE @ult_mm CHAR(1) = (SELECT sTipo FROM #tmp_extranj_ulti_movmigra WHERE uIdPersona = @uIdPersona AND nRow_mm = 1),
			@penult_mm CHAR(1) = ISNULL((SELECT sTipo FROM #tmp_extranj_ulti_movmigra WHERE uIdPersona = @uIdPersona AND nRow_mm = 2), ''),

			@ult_tram INT = ISNULL((SELECT nIdTipoTramite FROM #tmp_extranj_ulti_ccm WHERE uIdPersona = @uIdPersona AND nRow_tram = 1), 0),
			@penult_tram INT = ISNULL((SELECT nIdTipoTramite FROM #tmp_extranj_ulti_ccm WHERE uIdPersona = @uIdPersona AND nRow_tram = 2), 0),
			@apenult_tram INT = ISNULL((SELECT nIdTipoTramite FROM #tmp_extranj_ulti_ccm WHERE uIdPersona = @uIdPersona AND nRow_tram = 3), 0),

			@e_ult_tram CHAR(1) = ISNULL((SELECT sEstadoActual FROM #tmp_extranj_ulti_ccm WHERE uIdPersona = @uIdPersona AND nRow_tram = 1), ''),
			@e_penult_tram CHAR(1) = ISNULL((SELECT sEstadoActual FROM #tmp_extranj_ulti_ccm WHERE uIdPersona = @uIdPersona AND nRow_tram = 2), ''),
			@e_apenult_tram CHAR(1) = ISNULL((SELECT sEstadoActual FROM #tmp_extranj_ulti_ccm WHERE uIdPersona = @uIdPersona AND nRow_tram = 3), ''),

			@cal_ult_mm VARCHAR(55) = (SELECT scm.sDescripcion FROM #tmp_extranj_ulti_movmigra smm 
									    JOIN SimCalidadMigratoria scm ON  smm.nIdCalidad = scm.nIdCalidad
									    WHERE smm.uIdPersona = @uIdPersona AND smm.nRow_mm = 1),
			@cal_ult_e VARCHAR(55) = (SELECT LTRIM(RTRIM(scm.sDescripcion)) FROM #tmp_extranj_ulti_movmigra smm 
									    JOIN SimCalidadMigratoria scm ON  smm.nIdCalidad = scm.nIdCalidad
									    WHERE smm.uIdPersona = @uIdPersona AND smm.sTipo = 'E'),
			@cal_ccm_a VARCHAR(55) = (SELECT scm.sDescripcion FROM #tmp_extranj_ulti_ccm st
									    JOIN SimCalidadMigratoria scm ON  st.nIdCalSolicitada = scm.nIdCalidad
									    WHERE st.uIdPersona = @uIdPersona AND st.nIdTipoTramite = 58 AND st.sEstadoActual = 'A'),
			@tipocal_ccm_a VARCHAR(15) = CASE (SELECT scm.sTipo FROM #tmp_extranj_ulti_ccm st 
											   JOIN SimCalidadMigratoria scm ON st.nIdCalSolicitada = scm.nIdCalidad 
											   WHERE st.uIdPersona = @uIdPersona AND st.nIdTipoTramite = 58 AND st.sEstadoActual = 'A')
											WHEN 'T' THEN 'TEMPORAL'
											WHEN 'R' THEN 'RESIDENTE'
											WHEN 'I' THEN 'INMIGRANTE'
										END,
			@tipocal_ult_mm VARCHAR(15) = CASE (SELECT scm.sTipo FROM #tmp_extranj_ulti_movmigra mm 
											   JOIN SimCalidadMigratoria scm ON mm.nIdCalidad = scm.nIdCalidad 
											   WHERE mm.uIdPersona = @uIdPersona AND mm.nRow_mm = 1)
											WHEN 'T' THEN 'TEMPORAL'
											WHEN 'R' THEN 'RESIDENTE'
											WHEN 'I' THEN 'INMIGRANTE'
										 END,
			@tipocal_ult_e VARCHAR(15) = CASE (SELECT scm.sTipo FROM #tmp_extranj_ulti_movmigra mm 
											   JOIN SimCalidadMigratoria scm ON mm.nIdCalidad = scm.nIdCalidad 
											   WHERE mm.uIdPersona = @uIdPersona AND mm.sTipo = 'E')
											WHEN 'T' THEN 'TEMPORAL'
											WHEN 'R' THEN 'RESIDENTE'
											WHEN 'I' THEN 'INMIGRANTE'
										 END,

			@fec_aud_ccm_a DATETIME = ISNULL((SELECT dFechaAud FROM #tmp_extranj_ulti_ccm 
											    WHERE uIdPersona = @uIdPersona AND nIdTipoTramite = 58 AND sEstadoActual = 'A'), ''),
			@fec_aud_prr_a DATETIME = ISNULL((SELECT dFechaAud FROM #tmp_extranj_ulti_ccm
											    WHERE uIdPersona = @uIdPersona AND nIdTipoTramite = 57 AND sEstadoActual = 'A'), ''),
			@fec_aud_prp_a DATETIME = ISNULL((SELECT dFechaAud FROM #tmp_extranj_ulti_ccm 
											    WHERE uIdPersona = @uIdPersona AND nIdTipoTramite = 56 AND sEstadoActual = 'A'), ''),

			@fec_venc_ccm_a DATETIME = ISNULL((SELECT [dFechaVencimiento] FROM #tmp_extranj_ulti_ccm 
											    WHERE uIdPersona = @uIdPersona AND nIdTipoTramite = 58 AND sEstadoActual = 'A'), ''),
			@fec_venc_prp_a DATETIME = ISNULL((SELECT [dFechaVencimiento] FROM #tmp_extranj_ulti_ccm 
											    WHERE uIdPersona = @uIdPersona AND nIdTipoTramite = 56 AND sEstadoActual = 'A'), ''),
			@fec_venc_prr_a DATETIME = ISNULL((SELECT [dFechaVencimiento] FROM #tmp_extranj_ulti_ccm 
											    WHERE uIdPersona = @uIdPersona AND nIdTipoTramite = 57 AND sEstadoActual = 'A'), ''),

			@fec_aud_ult_tram DATETIME = ISNULL((SELECT dFechaAud FROM #tmp_extranj_ulti_ccm WHERE uIdPersona = @uIdPersona AND nRow_tram = 1), ''),
			@fec_aud_penult_tram DATETIME = ISNULL((SELECT dFechaAud FROM #tmp_extranj_ulti_ccm WHERE uIdPersona = @uIdPersona AND nRow_tram = 2), ''),

			@fec_ult_mm DATETIME = ISNULL((SELECT dFechaControl FROM #tmp_extranj_ulti_movmigra smm WHERE smm.uIdPersona = @uIdPersona AND smm.nRow_mm = 1), ''),
			@fec_ult_e DATETIME = ISNULL((SELECT dFechaControl FROM #tmp_extranj_ulti_movmigra WHERE uIdPersona = @uIdPersona AND sTipo = 'E'), ''),
			@fec_ult_s DATETIME = ISNULL((SELECT dFechaControl FROM #tmp_extranj_ulti_movmigra WHERE uIdPersona = @uIdPersona AND sTipo = 'S'), ''),

			@dias_perm_ult_e INT = (SELECT nPermanencia FROM #tmp_extranj_ulti_movmigra WHERE uIdPersona = @uIdPersona AND sTipo = 'E')
				
	/*► Si ultimo movmig es `E` o Si ultimo movmig es `S` y no registra trámites de CCM ... */
	IF (@ult_tram = 0 AND (@ult_mm = 'E' OR @ult_mm = 'S'))
		INSERT INTO tmp_estadia_migratoria
			SELECT 
				@uIdPersona,
				[Tipo Calidad Migratoria] = @tipocal_ult_e,
				@cal_ult_e,
				@fec_ult_e,
				DATEADD(DD, @dias_perm_ult_e, @fec_ult_e)

	ELSE IF(/*► Si tiene `E` y realizó el trámite de CCM(Estado: P) y solicitó Permiso de Viaje ...*/
				@ult_mm = 'S'
				AND @ult_tram = 39 
				AND @e_ult_tram = 'A'
				AND @penult_tram = 58
				AND @e_penult_tram != 'A'
			)
		INSERT INTO tmp_estadia_migratoria
				SELECT 
					@uIdPersona,
					[Tipo Calidad Migratoria] = @tipocal_ult_e,
					@cal_ult_e,
					@fec_ult_e,
					DATEADD(DD, @dias_perm_ult_e, @fec_ult_e)
		
	ELSE IF(/*► CCM `A` ...*/
				(@ult_mm = 'E' OR @penult_mm = 'E')
				AND (@e_ult_tram = 'A' OR @e_penult_tram = 'A')
				AND (@ult_tram = 58 OR @penult_tram = 58)
				AND @fec_ult_e < @fec_aud_ccm_a --Si valor es: 1900-01-01 00:00:00.000, trámite no `A`
			)
		INSERT INTO tmp_estadia_migratoria
				SELECT 
					@uIdPersona,
					[Tipo Calidad Migratoria] = @tipocal_ccm_a,
					@cal_ccm_a,
					@fec_aud_ccm_a,
					@fec_venc_ccm_a

	ELSE IF(/*► PRP `A` ...*/
				(@ult_mm = 'E' OR @penult_mm = 'E')
				AND (@e_ult_tram = 'A' OR @e_penult_tram = 'A')
				AND (@ult_tram = 56 OR @penult_tram = 56)-- PRP
				AND @fec_ult_e < @fec_aud_prp_a --Si valor es: 1900-01-01 00:00:00.000, trámite no `A`
			)
		INSERT INTO tmp_estadia_migratoria
				SELECT 
					@uIdPersona,
					[Tipo Calidad Migratoria] = @tipocal_ult_e,
					@cal_ult_e,
					@fec_ult_e,
					@fec_venc_prp_a

	ELSE IF(/*► ...*/
				@tipocal_ult_mm = 'TEMPORAL'
				AND @ult_mm = 'E'
				AND (@ult_tram = 58 OR @penult_tram = 58)-- CCM
				AND (@e_ult_tram = 'A' OR @e_penult_tram = 'A')
				AND @fec_ult_mm < @fec_aud_ccm_a --Si valor es: 1900-01-01 00:00:00.000, trámite no `A`
			)
		INSERT INTO tmp_estadia_migratoria
				SELECT 
					@uIdPersona,
					[Tipo Calidad Migratoria] = @tipocal_ccm_a,
					@cal_ccm_a,
					@fec_aud_ccm_a,
					@fec_venc_ccm_a

	ELSE IF(/*► ...*/
				@tipocal_ult_e = 'RESIDENTE'
				AND (@ult_mm = 'E' OR @penult_mm = 'E')
				AND (@ult_tram = 58 OR @penult_tram = 58)-- CCM
				AND (@e_ult_tram = 'A' OR @e_penult_tram = 'A')
				AND @fec_aud_ccm_a < @fec_ult_e --Si valor es: 1900-01-01 00:00:00.000, trámite no `A`
			)
		INSERT INTO tmp_estadia_migratoria
				SELECT 
					@uIdPersona,
					[Tipo Calidad Migratoria] = @tipocal_ccm_a,
					@cal_ccm_a,
					@fec_aud_ccm_a,
					@fec_venc_ccm_a
	ELSE IF(/*► Permiso Viaje(A) & PRR(A) & CCM(A) ... */
				@ult_tram = 39 AND @penult_tram = 57 AND @apenult_tram = 58
			)
		INSERT INTO tmp_estadia_migratoria
				SELECT 
					@uIdPersona,
					[Tipo Calidad Migratoria] = @tipocal_ccm_a,
					@cal_ccm_a,
					@fec_aud_ccm_a,
					@fec_venc_prr_a

	ELSE IF(/*► Calidad ultima `E`: INMIGRANTE, tiene trámite de CCM en estado `A` ... */
				@tipocal_ult_e = 'INMIGRANTE'
				AND (@ult_tram = 58 OR @penult_tram = 58 OR @apenult_tram = 58)
				AND @fec_aud_ccm_a < @fec_ult_e
			)
		INSERT INTO tmp_estadia_migratoria
				SELECT 
					@uIdPersona,
					[Tipo Calidad Migratoria] = 'RESIDENTE',
					@cal_ult_e,
					@fec_ult_e,
					@fec_ult_e

	ELSE IF(/*► Calidad ultima `E`: HUMANITARIA || REFUGIADO ... */
				@cal_ult_e = 'HUMANITARIA' 
				OR @cal_ult_e = 'REFUGIADO'
			)
		INSERT INTO tmp_estadia_migratoria
				SELECT 
					@uIdPersona,
					[Tipo Calidad Migratoria] = 'RESIDENTE',
					@cal_ult_e,
					@fec_ult_e,
					(SELECT TOP 1 dFechaVencRes FROM SimTramite st
					JOIN SimTramiteInm sti ON st.sNumeroTramite = sti.sNumeroTramite
					JOIN SimCarnetExtranjeria sce ON st.sNumeroTramite = sce.sNumeroTramite
					WHERE
						sti.sEstadoActual = 'A'
						AND st.nIdTipoTramite = 62 --INSCR.REG.CENTRAL EXTRANJERÍA
						AND st.uIdPersona = @uIdPersona
					ORDER BY sti.dFechaFin DESC)

	/*► Query-Result: */
	SELECT * FROM tmp_estadia_migratoria

	/*► Clean-Up */
	DROP TABLE IF EXISTS tmp_estadia_migratoria
	DROP TABLE IF EXISTS #tmp_extranj_ulti_movmigra
	DROP TABLE IF EXISTS #tmp_extranj_ulti_ccm

END

/*► Test ... */
/*====================================================================================================================================================================================*/
EXEC usp_Rim_Utilitario_Estadia_Migratoria '50EFC18B-ECE1-46A5-83BF-5BC429F4497E'


-- Buscar movimiento migratorio ...
SELECT * FROM SimPersona sp WHERE sp.sNombre LIKE '%maritza jose%' AND sp.sPaterno = 'GONZALEZ' AND sp.sMaterno = '' --4035C0EA-2122-496D-8F8B-93DC6E269858
SELECT * FROM SimPersona sp WHERE sp.sNombre LIKE '%JOSE%' AND sp.sPaterno LIKE 'LLIVI%' AND sp.sMaterno LIKE 'LOJA%' --065D5B9C-98AC-453B-8472-C39AB50C82A5
SELECT * FROM SimPersona sp WHERE sp.sNombre LIKE '%LUIS RAMON%' AND sp.sPaterno LIKE 'ISNARD%' AND sp.sMaterno LIKE 'JIMENEZ%' --C7A2A9F9-CB71-49F5-8E4D-5A0C9678634A
SELECT * FROM SimPersona sp WHERE sp.sNombre LIKE '%MARIN%' AND sp.sPaterno LIKE 'DRAGOMIR%' AND sp.sMaterno LIKE '%' -- DED9A9C9-87FC-4653-BE3C-E2116D6B3C94
SELECT * FROM SimPersona sp WHERE sp.sNombre LIKE '%yun%' AND sp.sPaterno LIKE 'erd%' AND sp.sMaterno LIKE '%' -- A7E4528A-AE11-4659-AA9E-983B595C838B
SELECT * FROM SimPersona sp WHERE sp.sNombre LIKE '%wig%' AND sp.sPaterno LIKE 'socorro%' AND sp.sMaterno LIKE 'matos%' -- 50EFC18B-ECE1-46A5-83BF-5BC429F4497E
SELECT * FROM SimPersona sp WHERE sp.sNombre LIKE '%vicent%' AND sp.sPaterno LIKE 'Migue%' AND sp.sMaterno LIKE 'garci%' -- 50EFC18B-ECE1-46A5-83BF-5BC429F4497E
SELECT * FROM SimPersona sp WHERE sp.sNombre LIKE '%nicolas cornelius%' AND sp.sPaterno LIKE 'kraemer%' AND sp.sMaterno LIKE '%' -- 8405F864-3E35-4E32-951B-72BC07FD2545
SELECT * FROM SimPersona sp WHERE sp.sNombre LIKE '%CARID%' AND sp.sPaterno LIKE 'HERRERA%' AND sp.sMaterno LIKE 'MARRERO%' -- 7CF7E0A5-F299-44D5-81B3-B1563142A1C4
SELECT * FROM SimPersona sp WHERE sp.sNombre LIKE '%FABIA%' AND sp.sPaterno LIKE 'GUIRIGAY%' AND sp.sMaterno LIKE 'QUICENO%' -- B9E5A2D6-BFCA-4258-9DBA-8CCC2AB17E9D

/*=================================================================================================================================================================================*/

-- ===================================================================================================================
-- dbo.usp_Rim_Rpt_Control_Migratorio_Por_Años
-- ===================================================================================================================
CREATE OR ALTER PROCEDURE usp_Rim_Rpt_Años_Control_Migratorio
AS
BEGIN

	SELECT 
		pcm.añoControl,
		[entradas] = pcm.ENTRADA,
		[salidas] = pcm.SALIDA
	FROM (

		SELECT * FROM (

			SELECT 
				[añoControl] = DATEPART(YYYY, cm.dFechaControl),
				[control] = cm.sControl,
				[totalCtrlMig] = cm.nTotalCtrlMig
			FROM SimControlMigRim cm

		) cm PIVOT (
			SUM([totalCtrlMig]) FOR [control] IN ([ENTRADA], [SALIDA])
		) pv
	
	) pcm
	ORDER BY
		pcm.añoControl

END

-- Test ...
EXEC dbo.usp_Rim_Rpt_Control_Migratorio_Por_Años @nacionalidad
-- ===================================================================================================================

-- ===================================================================================================================
-- dbo.usp_Rim_Rpt_Dependencia_Control_Migratorio
-- ===================================================================================================================
CREATE OR ALTER PROCEDURE usp_Rim_Rpt_Dependencia_Control_Migratorio
(
	@año VARCHAR(4), -- 1 ó (%)
	@nacionalidad VARCHAR(100) -- 1 ó (%)
)
AS
BEGIN
	
	SELECT 
		TOP 6
		[dependencia] = cm.sDependencia,
		[totalCtrlMig] = SUM(cm.nTotalCtrlMig)
	FROM SimControlMigRim cm
	WHERE
		YEAR(cm.dFechaControl) = @año
		AND cm.sNacionalidad LIKE IIF(@nacionalidad = '', '%', @nacionalidad)
	GROUP BY
		cm.sDependencia
	ORDER BY
		[totalCtrlMig] DESC

END

-- Test ...
EXEC dbo.usp_Rim_Rpt_Dependencia_Control_Migratorio @año = 2022, @nacionalidad = ''
-- ===================================================================================================================

-- ===================================================================================================================
-- dbo.usp_Rim_Rpt_Edades_Control_Migratorio
-- ===================================================================================================================
CREATE OR ALTER PROCEDURE usp_Rim_Rpt_Edades_Control_Migratorio
(
	@año VARCHAR(4), -- 1 ó (%)
	@nacionalidad VARCHAR(100) -- 1 ó (%)
)
AS
BEGIN

	SELECT 
		[rangoEdad] = cm.sRangoEdad,
		[totalCtrlMig] = SUM(cm.nTotalCtrlMig)
	FROM SimControlMigRim cm
	WHERE
		YEAR(cm.dFechaControl) = @año
		AND cm.sNacionalidad LIKE IIF(@nacionalidad = '', '%', @nacionalidad)
	GROUP BY
		cm.sRangoEdad
	ORDER BY
		[rangoEdad]

END

-- Test ...
EXEC dbo.usp_Rim_Rpt_Edades_Control_Migratorio @año = 2022, @nacionalidad = ''
-- ===================================================================================================================

-- ===================================================================================================================
-- dbo.usp_Rim_Rpt_Nacionalidad_Control_Migratorio
-- ===================================================================================================================
CREATE OR ALTER PROCEDURE usp_Rim_Rpt_Nacionalidad_Control_Migratorio
(
	@año VARCHAR(4) -- 1 ó (%)
)
AS
BEGIN

	SELECT 
		[nacionalidad] = cm.sNacionalidad,
		[totalCtrlMig] = SUM(cm.nTotalCtrlMig)
	FROM SimControlMigRim cm
	WHERE
		YEAR(cm.dFechaControl) = @año
	GROUP BY
		cm.sNacionalidad
	ORDER BY
		[totalCtrlMig] DESC

END

-- Test ...
EXEC dbo.usp_Rim_Rpt_Nacionalidad_Control_Migratorio @año = 2022
-- ===================================================================================================================

-- ===================================================================================================================
-- dbo.usp_Rim_Rpt_Control_Migratorio
-- ===================================================================================================================
CREATE OR ALTER PROCEDURE usp_Rim_Rpt_Control_Migratorio
(
	@año VARCHAR(4), -- 1 ó (%)
	@nacionalidad VARCHAR(100) -- 1 ó (%)
)
AS
BEGIN

	WITH cte_calendario AS (

		SELECT mes = 1
		UNION ALL
		SELECT mes + 1 FROM cte_calendario c
		WHERE c.mes < 12 

	), cte_rptctrlmigra AS (
	
		SELECT 
			[año] = DATEPART(YYYY, cm.dFechaControl),
			[mes] = DATEPART(MM, cm.dFechaControl),
			[control] = cm.sControl,
			[sexo] = cm.sSexo,
			[totalCtrlMig] = cm.nTotalCtrlMig
		FROM SimControlMigRim cm
		WHERE
			DATEPART(YYYY, cm.dFechaControl) = @año
			AND cm.sNacionalidad LIKE IIF(@nacionalidad != '', @nacionalidad, '%')

	), cte_rptctrlmigra_pv_control AS (

		SELECT * FROM (
			SELECT 
				cm.año,
				cm.mes,
				cm.[control],
				cm.totalCtrlMig
			FROM cte_rptctrlmigra cm
		) cm
		PIVOT (
			SUM([totalCtrlMig]) FOR [control] IN ([ENTRADA], [SALIDA])
		) pv
		
	), cte_rptctrlmigra_pv_genero AS (

		SELECT * FROM (
			SELECT 
				cm.año,
				cm.mes,
				cm.sexo,
				cm.totalCtrlMig
			FROM cte_rptctrlmigra cm
		) cm
		PIVOT (
			SUM([totalCtrlMig]) FOR [sexo] IN ([F], [M])
		) pv
		
	), cte_rpt_join_pvs AS (
		
		SELECT 
			c.año,
			c.mes,
			c.ENTRADA,
			c.SALIDA,
			g.F,
			g.M
		FROM cte_rptctrlmigra_pv_control c
		JOIN cte_rptctrlmigra_pv_genero g ON c.año = g.año AND c.mes = g.mes
	
	), cte_calendario_join_rptctrlmigra AS (
		
		SELECT 
			[año] = COALESCE(cm.año, @año),
			[mes] = c.mes,
			[entradas] = COALESCE(cm.ENTRADA, 0),
			[salidas] = COALESCE(cm.SALIDA, 0),
			[totalFemenino] = COALESCE(cm.F, 0),
			[totalMasculino] = COALESCE(cm.M, 0)
		FROM cte_calendario c
		LEFT JOIN cte_rpt_join_pvs cm ON c.mes = cm.mes
	
	) SELECT * FROM cte_calendario_join_rptctrlmigra cm
	ORDER BY
		[año], [mes]

END

-- Test ...
USE [BDSidtefim-Test]
GO

EXEC usp_Rim_Rpt_Control_Migratorio '2022', ''
-- ==================================================================================================================



SELECT TOP 20 * FROM RimTablaDinamica
SELECT TOP 20 * FROM Rim_Test_2024