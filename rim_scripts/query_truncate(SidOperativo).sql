SELECT * FROM SidPais
SELECT * FROM SidDistrito
SELECT * FROM SidEmpresa
SELECT * FROM SidOperativo
SELECT * FROM SidDetOperativo

--DELETE FROM SidDistrito
--DBCC CHECKIDENT ('dbo.SidDistrito', RESEED, 0)

--DELETE FROM SidEmpresa
--DBCC CHECKIDENT ('dbo.SidEmpresa', RESEED, 0)

--DBCC CHECKIDENT ('dbo.SidOperativo', RESEED, 0)
--DELETE FROM SidOperativo

--TRUNCATE TABLE SidDetOperativo

SET IDENTITY_INSERT SidOperativo ON



SET IDENTITY_INSERT SidOperativo OFF