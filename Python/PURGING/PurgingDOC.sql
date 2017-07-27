USE [FLRS]
GO

/****** Object:  StoredProcedure [dbo].[PurgingDOC]    Script Date: 27-07-2017 12:37:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Prashaath R
-- Create date: 27-07-2017
-- Description:	Document Purging
-- =============================================
ALTER PROCEDURE [dbo].[PurgingDOC] 
	-- Add the parameters for the stored procedure here
	@do			varchar(10) 	= 'getCount', 
	@rmDate		date 			= '2016-12-31',
	@tillDate 	date 			= '2017-06-30'			--convert(date,GETDATE())
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if (@do = 'getCount')
	BEGIN 
	-- This Query will give total Licenses issued till @tillDate and Licenses Expired before @rmDate
	select 'CLS' as LicType,
		(select distinct count(licenseno) from CL_FBO_License where IssuedDate  <= @tillDate	) as Total,
		(select distinct count(licenseno) from CL_FBO_License where [Expiredate]<= @rmDate		) as Expired,
		'F:\FSSAI-DOCS1\FLRS\CLS\' as BasePath,
		'https://foodlicensing.fssai.gov.in/CLSDOCS/CLS/' as URL
	union
	select 'SLS' as LicType,
		(select distinct count(licenseno) from SL_FBO_License where IssuedDate  <= @tillDate	) as Total,
		(select distinct count(licenseno) from SL_FBO_License where [Expiredate]<= @rmDate		) as Expired,
		'E:\FSSAI-DOCS\FLRS\SLS\' as BasePath,
		'https://foodlicensing.fssai.gov.in/FLRSDOCS/SLS/'	as URL
	union
	select 'REG' as LicType,
		(select distinct count(licenseno) from RG_License     where IssuedDate  <= @tillDate	) as Total,
		(select distinct count(licenseno) from RG_License     where [Expiredate]<= @rmDate		) as Expired,
		'F:\FSSAI-DOCS1\FLRS\REG\' as BasePath,
		'https://foodlicensing.fssai.gov.in/REGDOCS/REG/' as URL
	END
    -- Insert statements for procedure here
	if (@do = 'getCLS')
	BEGIN
	select 'CLS', A.REFID, L.IssuedDate, L.ExpireDate, A.DOCLocation, A.TableName FROM (
	      select REFID, DOCLocation, 'LM_CL_FBO_Documents'			as TableName from LM_CL_FBO_Documents
	union select REFID, DOCLocation, 'LM_CL_FBO_Documents_Log'		as TableName from LM_CL_FBO_Documents_Log
	union select REFID, DOCLocation, 'CL_FBO_Documents'				as TableName from CL_FBO_Documents
	union select REFID, DOCLocation, 'CL_FBO_DocumentChange_log'	as TableName from CL_FBO_DocumentChange_log
	union select REFID, DOCLocation, 'CL_FBO_PADocument'			as TableName from CL_FBO_PADocument
	union select REFID, DOCLocation, 'CL_FBO_PADocumentChange_LOG'	as TableName from CL_FBO_PADocumentChange_LOG
	) AS A 
	left join CL_FBO_License as L on A.REFID = L.REFID

	where	A.DocLocation is not null 
		and convert(date,L.ExpireDate) < @rmDate
	order by L.ExpireDate
	END
		
END
GO


