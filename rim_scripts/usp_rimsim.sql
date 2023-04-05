USE RIMSIM
GO

/*► dbo.usp_Rim_Procedimiento_DynamicJoinStatement ...*/
/*-----------------------------------------------------------------------------------------------------------------------*/
ALTER PROCEDURE dbo.usp_Rim_Procedimiento_DynamicJoinStatement
(
	@mod VARCHAR(55),
	@fields NVARCHAR(MAX),
	@where NVARCHAR(MAX)
)
AS
BEGIN

	DECLARE @select NVARCHAR(MAX)

	SET @select = CASE
						WHEN @mod = 'Control Migratorio' THEN
							N'SELECT ' + @fields + ' FROM SimMovMigra ' + '
								LEFT OUTER JOIN SimPersona ON SimMovMigra.uIdPersona = SimPersona.uIdPersona
								LEFT OUTER JOIN SimPais ON SimMovMigra.sIdPaisNacionalidad = SimPais.sIdPais
								LEFT OUTER JOIN SimUsuario ON SimMovMigra.nIdOperadorDigita = SimUsuario.nIdOperador
								LEFT OUTER JOIN SimPersonaNoAutorizada ON SimPersona.sNombre = SimPersonaNoAutorizada.sNombre AND SimPersona.sPaterno = SimPersonaNoAutorizada.sPaterno AND SimPersona.sMaterno = SimPersonaNoAutorizada.sMaterno
								LEFT OUTER JOIN SimProfesion ON SimPersona.sIdProfesion = SimProfesion.sIdProfesion
								LEFT OUTER JOIN SimDocInvalidacion ON SimPersonaNoAutorizada.nIdDocInvalidacion = SimDocInvalidacion.nIdDocInvalidacion
								LEFT OUTER JOIN SimCancelacionMov ON SimMovMigra.sIdMovMigratorio = SimCancelacionMov.sIdMovMigratorio
								LEFT OUTER JOIN SimCalidadMigratoria ON SimMovMigra.nIdCalidad = SimCalidadMigratoria.nIdCalidad
								LEFT OUTER JOIN SimCarnetExtranjeria ON SimPersona.uIdPersona = SimCarnetExtranjeria.uIdPersona
								LEFT OUTER JOIN SimAlojamiento ON SimMovMigra.nIdTipoAlojamiento = SimAlojamiento.nIdTipoAlojamiento
								LEFT OUTER JOIN SimEmpTransporte ON SimMovMigra.nIdTransportista = SimEmpTransporte.nIdTransportista
								LEFT OUTER JOIN SimDependencia ON SimMovMigra.sIdDependencia = SimDependencia.sIdDependencia
								LEFT OUTER JOIN SimTramiteInm ON SimMovMigra.sIdMovMigratorio = SimTramiteInm.sIdMovMigratorio
								LEFT OUTER JOIN SimTramite ON SimTramiteInm.sNumeroTramite =  SimTramite.sNumeroTramite
								LEFT OUTER JOIN SimMotivoTramite ON SimTramite.nIdMotivoTramite = SimMotivoTramite.nIdMotivoTramite
								LEFT OUTER JOIN SimExtranjero ON SimPersona.uIdPersona = SimExtranjero.uIdPersona
								LEFT OUTER JOIN SimUbigeo ON SimExtranjero.sIdUbigeoDomicilio = SimUbigeo.sIdUbigeo
								LEFT OUTER JOIN SimOrganizacion ON SimExtranjero.nIdOrganizacion = SimOrganizacion.nIdOrganizacion
								LEFT OUTER JOIN SimMotivoViaje ON SimMovMigra.nIdMotivoViaje = SimMotivoViaje.nIdMotivoViaje
								LEFT OUTER JOIN SimEscalaMovMigra ON SimMovMigra.sIdMovMigratorio = SimEscalaMovMigra.sIdMovMigratorio
								LEFT OUTER JOIN SimOrdenPago ON SimMovMigra.sIdMovMigratorio = SimOrdenPago.sIdMovMigratorio
								LEFT OUTER JOIN SimSalidaAutorizada ON SimMovMigra.sIdMovMigratorio = SimSalidaAutorizada.sIdMovMigratorio
								WHERE
									SimMovMigra.bAnulado = 0
									AND SimCarnetExtranjeria.bAnulado = 0 ' + @where
						WHEN @mod = 'DNV' THEN
							N'SELECT (smm.sIdDocumento)Documento,
								(smm.sNumeroDoc)Numero_Documento,
								(sp.sNombre)Nombre,
								(sp.sPaterno)Ape_Pat,
								(sp.sMaterno)Ape_Mat,
								(sp.sSexo)Sexo,
								(sp.dFechaNacimiento)Fecha_Nacimiento,
								(spnacimiento.sNombre)Pais_Nacimiento,
								(spnacionalidad.sNombre)Pais_Nacionalidad,
								(smm.sTipo)Tipo_Movimiento,
								(smm.dFechaControl)Fecha_Control,
								sope.sLogin Login_Operador_Digita,
								sope.sNombre Operador_Digita,
								(spaismov.sNombre)Procedencia_Destino,
								(sd.sNombre)Dependencia,
								(setran.sNombreRazon)Empresa_Transporte,
								(scm.sDescripcion)Calidad_Migratoria,
								Tipo_Residencia = CASE 
													WHEN scm.sDescripcion LIKE ''%TRAB%'' THEN ''RESIDENTE''
													WHEN scm.sDescripcion LIKE ''%PERMA%'' THEN ''RESIDENTE''
													WHEN scm.sDescripcion IN (''FAMILIAR RESIDENTE'', ''FAMILIAR DE RESIDENTE'') THEN ''RESIDENTE''
													WHEN scm.sDescripcion LIKE ''%INMIGRANTE%'' THEN ''INMIGRANTE''
													ELSE ''TEMPORAL''
												END,
								(sce.sNumeroCarnet)Numero_Carnet,
								(sce.dFechaCaducidad)Fecha_Caducidad,
								(sprof.sDescripcion)Ocupacion,
								(sorg.sNombre)Razon_Social_Empresa,
								(sorg.sNumeroDoc)Ruc_Empresa,
								(sp.sIdEstadoCivil)Estado_Civil,

								su.sIdUbigeo Id_Ubigeo,
								(
									(SELECT sNombre FROM SimUbigeo WHERE sCodAnterior = LEFT(su.sIdUbigeo, 2)) + '' - '' + 
									(SELECT sNombre FROM SimUbigeo WHERE sCodAnterior = LEFT(su.sIdUbigeo, 4)) + '' - '' +
									(su.sNombre)
								)Ubigeo,
								se.sDomicilio Domicilio,
								(smm.sObservaciones)Observaciones_SIM_RCM,
								(sdi.sIdDocInvalida)Doc_Invalida,
								(sdi.sNumDocInvalida)Numero_Doc_Invalida,
								(sdi.nTipoAlerta)Tipo_Alerta,
								(spna.sDescripcion)Descripcion,
								(spna.sObservaciones)Observaciones,

								smv.sDescripcion Motivo_Viaje,
								smm.sObservaciones Observaciones_MovMigra,
								ssa.sNumeroDoc Documento_Autoridad_Viaje,
								ssa.dFechaEmision Fec_Emision_SalidaAutorizada,
								ssa.sObservaciones Obervaciones_SalidaAutorizada,
								ssa.sNombreAutoridad NombreAutoridad_SalidaAutorizada,
								sta.sDescripcion Tipo_Autoridad
							FROM SimMovMigra smm 
							JOIN SimPersona sp ON sp.uIdPersona = smm.uIdPersona
							LEFT JOIN SimUsuario sope ON smm.nIdOperadorDigita = sope.nIdOperador
							LEFT JOIN SimPersonaNoAutorizada spna ON sp.sNombre = spna.sNombre AND sp.sPaterno = spna.sPaterno AND sp.sMaterno = spna.sMaterno
							LEFT JOIN SimProfesion sprof ON sp.sIdProfesion = sprof.sIdProfesion
							LEFT JOIN SimDocInvalidacion sdi ON spna.nIdDocInvalidacion = sdi.nIdDocInvalidacion
							LEFT JOIN SimDependencia sd ON smm.sIdDependencia = sd.sIdDependencia
							LEFT JOIN SimCarnetExtranjeria sce ON sp.uIdPersona = sce.uIdPersona
							LEFT JOIN SimExtranjero se ON sp.uIdPersona = se.uIdPersona
							LEFT JOIN SimUbigeo su ON se.sIdUbigeoDomicilio = su.sIdUbigeo
							LEFT JOIN SimOrganizacion sorg ON se.nIdOrganizacion = sorg.nIdOrganizacion
							LEFT JOIN SimEmpTransporte setran ON smm.nIdTransportista = setran.nIdTransportista
							LEFT JOIN SimCalidadMigratoria scm ON smm.nIdCalidad = scm.nIdCalidad
							LEFT JOIN SimPais spnacimiento ON sp.sIdPaisNacimiento = spnacimiento.sIdPais
							LEFT JOIN SimPais spnacionalidad ON sp.sIdPaisNacionalidad = spnacionalidad.sIdPais
							LEFT JOIN SimPais spaismov ON smm.sIdPaisMov = spaismov.sIdPais
							LEFT JOIN SimMotivoViaje smv ON smm.nIdMotivoViaje = smv.nIdMotivoViaje
							LEFT JOIN SimSalidaAutorizada ssa ON smm.sIdMovMigratorio = ssa.sIdMovMigratorio
							LEFT JOIN SimTipoAutoridad sta ON ssa.nIdTipoAutoridad = sta.nIdTipoAutoridad
							WHERE
								smm.bAnulado = 0
								AND sce.bAnulado = 0 ' + @where

					END
	
	EXEC SP_EXECUTESQL @select
	
END

/*► Test ...*/
--SimMovMigra
EXEC dbo.usp_Rim_Procedimiento_DynamicJoinStatement 'DNV', '', 'AND smm.sIdDependencia LIKE ''%'''
/*---------------------------------------------------------------------------------------------------------------------------------------------------------*/

CREATE CLUSTERED INDEX ix_SimMovMigra_sIdMovMigratorio
	ON SimMovMigra(sIdMovMigratorio)

CREATE NONCLUSTERED INDEX ix_SimMovMigra_uIdPersona
	ON SimMovMigra(uIdPersona)

CREATE NONCLUSTERED INDEX ix_SimMovMigra_nIdCalidad
	ON SimMovMigra(nIdCalidad)

CREATE NONCLUSTERED INDEX ix_SimMovMigra_nIdTipoAlojamiento
	ON SimMovMigra(nIdTipoAlojamiento)

CREATE NONCLUSTERED INDEX ix_SimMovMigra_nIdTransportista
	ON SimMovMigra(nIdTransportista)

CREATE NONCLUSTERED INDEX ix_SimMovMigra_sIdDependencia
	ON SimMovMigra(sIdDependencia)

CREATE NONCLUSTERED INDEX ix_SimMovMigra_nIdMotivoViaje
	ON SimMovMigra(nIdMotivoViaje)

