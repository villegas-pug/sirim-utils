/*► Insert: DB'S ... */
--DROP TABLE RimBaseDatos
INSERT INTO RimBaseDatos VALUES(1, 1, GETDATE(), 'SIM')

/*► Insert: MODULO'S ... */
--SELECT * FROM RimModulo
INSERT INTO RimModulo VALUES(1, 1, GETDATE(), 'Control Migratorio', 1)
INSERT INTO RimModulo VALUES(2, 1, GETDATE(), 'Trámites', 1)
INSERT INTO RimModulo VALUES(3, 1, GETDATE(), 'Nacionalización', 1)

/*► Insert: TABLE'S ... */
--DELETE FROM RimTabla
INSERT INTO RimTabla VALUES(1, 1, 'dFechaControl, sObservaciones, dFechaDigita, nPermanencia, sTipo, bAnulado, sPagoPermOk, sDireccionDestino, nIdMotivoViaje, sIdItinerario, sIdPaisNacionalidad, nGastos, sIdDependencia, dConsRq, dRptaRq, sEstadoRq, sContadorRq, nIdOperadorDigita, sIdDocControl, sNumDocControl, nIdTransportista, bExpulsion, sIdPaisResidencia, sIdEstadoCivil, sIdProfesion, sIdPaisNacimiento, sTransaccionRQ', GETDATE(), 'SimMovMigra',1)
INSERT INTO RimTabla VALUES(2, 1, 'sIdPais, sNombre, sNacionalidad, bGrupoAndino, bActivo, nIdContinente, nIdSesion, dFechaHoraAud, bVisaIngreso, bVisaSalida, sCodigoIso, sIdPaisImg, sCodigoOci, sCodigoOnu, sCodigoIata, sCodigoIsoII, bVisaTurista, bVisaNegocio, bVisaEstudiante', GETDATE(), 'SimPais',1)
INSERT INTO RimTabla VALUES(3, 1, 'nIdEscalaMovMigra, sIdMovMigratorio, sIdPaisMov', GETDATE(), 'SimEscalaMovMigra',1)
INSERT INTO RimTabla VALUES(4, 1, 'sDescripcion, sSigla, bActivo, dFechaHoraAud', GETDATE(), 'SimMotivoViaje',1)
INSERT INTO RimTabla VALUES(5, 1, 'sLogin, sNombre, sIdDependencia', GETDATE(), 'SimUsuario',1)
INSERT INTO RimTabla VALUES(6, 1, 'nIdTransportista, sNombreRazon, bActivo, sIdViaTransporte, nIdSesion, sIdDocumento, sDescripcion, nIdTipoDocumento, sCodControlRq, sIdDocumentoOcr, bUsoRegistro, bUsoMpa, bUsoViajeCmp, bUsoDocOficial, bUsoViajeDnv', GETDATE(), 'SimEmpTransporte',1)
INSERT INTO RimTabla VALUES(7, 1, 'sNumeroDoc, dFechaEmision, sObservaciones, sNombreAutoridad, nIdAutoridad', GETDATE(), 'SimSalidaAutorizada',1)
INSERT INTO RimTabla VALUES(8, 1, 'sIdDependencia, sNombre, sDireccion, sAbreviatura, sIdUbigeo, sRepresentante, sIdCiudad, consultaonpe, consultaBN', GETDATE(), 'SimDependencia',1)
INSERT INTO RimTabla VALUES(9, 1, 'nIdPago, sIdMovMigratorio, nDiasAsignados, nDiasTranscurridos, nDiasExceso, nTotal, dFecha, fExoneracion, nIdOperador, fEstado', GETDATE(), 'SimOrdenPago',1)
INSERT INTO RimTabla VALUES(10, 1, 'sPaterno, sMaterno, sNombre, sSexo, dFechaNacimiento, dFechaCancelacion, sObservaciones, bActivo, sIdMotivoInv, sIdAlertaInv, nIdMotivo, sDescripcion, dFechaInicioMedida, dFechaFinMedida', GETDATE(), 'SimPersonaNoAutorizada',1)
INSERT INTO RimTabla VALUES(11, 1, 'nIdDocInvalidacion, sIdDocInvalida, sNumDocInvalida, dFechaEmision, dFechaRecepcion, sObservaciones, sIdInstitucion, nIdSesion, sIdDocumento, nTipoAlerta', GETDATE(), 'SimDocInvalidacion',1)
INSERT INTO RimTabla VALUES(12, 1, 'sIdMovMigratorio, nIdMotivoTramite, dFechaCancela, sObservacion, sUsuarioSolicita, sDocSolicita', GETDATE(), 'SimCancelacionMov',1)
INSERT INTO RimTabla VALUES(13, 1, 'nIdTipoAlojamiento, sDescripcion', GETDATE(), 'SimAlojamiento',1)
INSERT INTO RimTabla VALUES(14, 1, 'sPaterno, sMaterno, sNombre, sSexo, dFechaNacimiento, sObservaciones, sIdPaisNacimiento, sIdPaisNacionalidad, sIdEstadoCivil, sIdProfesion, sIdDocViaje, sNumDocViaje, sIdDocIdentidad, sNumDocIdentidad, nPermanencia, dUltimoIngreso, bEnElPais, sUltimoPasaporte, bConsReniec', GETDATE(), 'SimPersona',1)
INSERT INTO RimTabla VALUES(15, 1, 'sDescripcion, sSigla, sTipo, sIdGrupoCal, nDiasPermMaximo, nDiasPermDefault, bProhTrab, bActivoTramVulner, bEmiteSoloMRE', GETDATE(), 'SimCalidadMigratoria',1)
INSERT INTO RimTabla VALUES(16, 1, 'sNroDocSalida, sEstadoActual, uIdRepresentante, uIdGarante, nIdEtapaActual, sNroDocGarante, dFechaFin, sNroDocRepresentante, sIdDocSalida, sIdDocGarante, sIdDocRepresentante', GETDATE(), 'SimTramiteInm',1)
INSERT INTO RimTabla VALUES(17, 1, 'sIdProfesion, sDescripcion, sAbreviatura, bActivo, nIdSesion, dFechaHoraAud', GETDATE(), 'SimProfesion',1)
INSERT INTO RimTabla VALUES(18, 1, 'sDescripcion, nIdTipoTramite, bRequierePago', GETDATE(), 'SimMotivoTramite',1)
INSERT INTO RimTabla VALUES(19, 1, 'dFechaInicial, dFechaEstadia, nIdOrganizacion, sIdUbigeoDomicilio, sCiudadNatal, sCarnetActual', GETDATE(), 'SimExtranjero',1)
INSERT INTO RimTabla VALUES(20, 1, 'sIdUbigeo, sNombre, sCodAnterior, bActivo', GETDATE(), 'SimUbigeo',1)
INSERT INTO RimTabla VALUES(21, 1, 'sNumeroCarnet, bAnulado, dFechaInscripcion, dFechaEmision, dFechaCaducidad, dFechaVencRes, dFechaAnulacion, bEntregado', GETDATE(), 'SimCarnetExtranjeria',1)
INSERT INTO RimTabla VALUES(22, 1, 'sNumeroDoc, sNombre, sRepresentante, sIdUbigeo, sDireccion, sObservaciones, bSunat', GETDATE(), 'SimOrganizacion',1)
INSERT INTO RimTabla VALUES(23, 1, 'sNumeroTramite, sPaterno, sMaterno, sNombre, dFechaNacimiento, sSexo, sIdPaisNacimiento, sIdPaisResidencia, sIdPaisNacionalidad, sCiudadNac, uIdPersona, nIdParentesco, nIdDetalleAdjunto', GETDATE(), 'SimAvDatoRceParentesco',2)
INSERT INTO RimTabla VALUES(24, 1, 'sNumeroTramite, sObservaciones, bCulminado, bCancelado, nIdTipoTramite, dFechaHora, bGratuito, bAutomatico, sIdDependencia, bErrado, bDigemin, bReniec, dFechaReniec', GETDATE(), 'SimTramite',2)
INSERT INTO RimTabla VALUES(25, 1, 'sNumeroTramite, sIdDependencia, sObservacion, dFechaAprobacion, sObservacionOtro, bEvaAcuerdoMercoSur', GETDATE(), 'SimEvaluarTramiteInm',2)
INSERT INTO RimTabla VALUES(26, 1, 'nIdNacTramExoneraEstadia, dFecha, sNumeroTramite, nIdEtapa', GETDATE(), 'SimNacTramExoneraEstadia',2)
INSERT INTO RimTabla VALUES(27, 1, 'nIdPermisoMas, sNumeroTramite, bActivo, dFechaHoraAud', GETDATE(), 'SimMasde183dias',2)
INSERT INTO RimTabla VALUES(28, 1, 'nIdExoPagTramVuln, sNumeroTramite, uIdPersona, dFechaHoraAud, bActivo, sObservaciones, sEstado, sComentarioEstado', GETDATE(), 'SimExoPagTramVulner',2)
INSERT INTO RimTabla VALUES(29, 1, 'sNumeroTramite, sObservaciones, bCulminado, bCancelado, nIdTipoTramite, dFechaHora, nIdMotivoTramite, nIdMotivoCancelacion, dFechaHoraReg, dFechaHoraAud, bGratuito, bAutomatico, sIdDependencia, bDigemin, bReniec, dFechaReniec', GETDATE(), 'SimTramite',3)
INSERT INTO RimTabla VALUES(30, 1, 'sNumeroTramite, sNroDocSalida, dFechaDocSalida, sEstadoActual, nIdEtapaActual, bInicioSIMNac', GETDATE(), 'SimTramiteNac',3)
INSERT INTO RimTabla VALUES(31, 1, 'uIdPersona, sPaterno, sMaterno, sNombre, sSexo, dFechaNacimiento, sObservaciones, bActivo, nIdCalidad, sIdPaisNacimiento, sIdPaisResidencia, sIdPaisNacionalidad, sCodAnterior, sIdEstadoCivil, sIdProfesion, nPermanencia, dUltimoIngreso, bConsReniec, dFechaHoraReniec', GETDATE(), 'SimPersona',3)
INSERT INTO RimTabla VALUES(32, 1, 'sIdPais, bVisaIngreso, bVisaSalida, sIdPaisImg, sCodigoOci, sCodigoOnu, sCodigoIata, sCodigoIsoII, bVisaTurista, bVisaNegocio, bVisaEstudiante', GETDATE(), 'SimPais',3)
INSERT INTO RimTabla VALUES(33, 1, 'nIdEtapaTramite, nIdEtapa, dFechaHoraInicio, dFechaHoraFin, sObservaciones, sIdDependencia, sNumeroTramite', GETDATE(), 'SimEtapaTramiteNac',3)
INSERT INTO RimTabla VALUES(34, 1, 'nIdNacionalizacion, nIdTipoNacionalizacion, sNumRegMatri, dFechaRegMatri, sIdUbigeoDirec, sDirecRegMatri, sNumeroTituloMec, sObservacion, sPaternoNac, sMaternoNac, sNombreNac, sNumDNIPerNac, sCiudadNatal, sNumInforme, sNumDictamen, sPaisNacionalidadExt, dFechaAnulacion, bDescendienteTerceraGen', GETDATE(), 'SimNacionalizacion',3)


BACKUP DATABASE [BDSidtefim-Test]
--TO DISK = 'F:\backup_sidtefim_db\SIM-2.bak'
TO DISK = N'\\192.168.18.3\backup_sidtefim_db\SIM-2.bak'
WITH INIT, COMPRESSION, NAME = N'SIM',
STATS = 1