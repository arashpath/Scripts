USE [FLRS]
GO
/****** Object:  StoredProcedure [dbo].[PurgingDOC]    Script Date: 04-08-2017 11:57:04 ******/
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
		(SELECT COUNT (L.LicenseNo) from 
		( select LicenseNo, MAX(CreatedOn) AS Final
												from CL_FBO_License group by LicenseNo ) as Le
										   left join CL_FBO_License as L on Le.LicenseNo = L.LicenseNo and Le.Final = L.CreatedOn WHERE L.CreatedOn     <= @tillDate ) as Total ,
		(SELECT COUNT (L.LicenseNo) from 
		( select LicenseNo, MAX(CreatedOn) AS Final 
												from CL_FBO_License group by LicenseNo ) as Le 
										   left join CL_FBO_License as L on Le.LicenseNo = L.LicenseNo and Le.Final = L.CreatedOn WHERE L.[ExpireDate]	<= @rmDate	 ) as Expired ,
		'F:\FSSAI-DOCS1\FLRS\CLS\' as BasePath, 'https://foodlicensing.fssai.gov.in/CLSDOCS/CLS/' as URL
	union
	select 'SLS' as LicType,
		(SELECT COUNT (L.LicenseNo) from 
		( select LicenseNo, MAX(CreatedOn) AS Final
												from SL_FBO_License group by LicenseNo ) as Le
										   left join SL_FBO_License as L on Le.LicenseNo = L.LicenseNo and Le.Final = L.CreatedOn WHERE L.CreatedOn     <= @tillDate ) as Total ,
		(SELECT COUNT (L.LicenseNo) from 			 
		( select LicenseNo, MAX(CreatedOn) AS Final  
												from SL_FBO_License group by LicenseNo ) as Le 
										   left join SL_FBO_License as L on Le.LicenseNo = L.LicenseNo and Le.Final = L.CreatedOn WHERE L.[ExpireDate]	<= @rmDate	 ) as Expired ,
		'E:\FSSAI-DOCS\FLRS\SLS\' as BasePath, 'https://foodlicensing.fssai.gov.in/FLRSDOCS/SLS/'	as URL
	union
	select 'REG' as LicType,
		(SELECT COUNT (L.LicenseNo) from 
		( select LicenseNo, MAX(CreatedOn) AS Final
												from RG_License group by LicenseNo ) as Le
										   left join RG_License as L on Le.LicenseNo = L.LicenseNo and Le.Final = L.CreatedOn WHERE L.CreatedOn         <= @tillDate ) as Total ,
		(SELECT COUNT (L.LicenseNo) from 			 
		( select LicenseNo, MAX(CreatedOn) AS Final  
												from RG_License group by LicenseNo ) as Le 
										   left join RG_License as L on Le.LicenseNo = L.LicenseNo and Le.Final = L.CreatedOn WHERE L.[ExpireDate]		<= @rmDate   ) as Expired ,
		'F:\FSSAI-DOCS1\FLRS\REG\' as BasePath, 'https://foodlicensing.fssai.gov.in/REGDOCS/REG/' as URL
	END
    -- Insert statements for procedure here
	if (@do = 'getCLS')
	BEGIN
	select 'CLS' as LicType, A.REFID, B.IssuedDate, B.ExpireDate, A.DOC, A.TableName FROM (
		  select REFID,  DUPLIC_DOC		 as DOC, 'CL_FBO_AppDetails'					as TableName from CL_FBO_AppDetails
	union select REFID,  TRANSFER_DOC	 as DOC, 'CL_FBO_AppDetails'					as TableName from CL_FBO_AppDetails
	union select REFID,  TRANSFER_DOCLHC as DOC, 'CL_FBO_AppDetails'					as TableName from CL_FBO_AppDetails
	union select REFID,  ModificationDoc as DOC, 'CL_FBO_AppModification'				as TableName from CL_FBO_AppModification
	union select REFID,  ModificationDoc as DOC, 'CL_FBO_AppModification_enforcement'	as TableName from CL_FBO_AppModification_enforcement
	union select REFID,  DOCLocation	 as DOC, 'CL_FBO_DocumentChange_log'			as TableName from CL_FBO_DocumentChange_log
	union select REFID,  DOCLocation	 as DOC, 'CL_FBO_Documents'						as TableName from CL_FBO_Documents
	union select REFID,  ManualInspDoc	 as DOC, 'CL_FBO_InspMaster'					as TableName from CL_FBO_InspMaster
	union select REFID,  DOCLOCATION	 as DOC, 'CL_FBO_PADocument'					as TableName from CL_FBO_PADocument
	union select REFID,  DOCLOCATION	 as DOC, 'CL_FBO_PADocumentChange_LOG'			as TableName from CL_FBO_PADocumentChange_LOG
	union select REFID,  Document		 as DOC, 'CL_FBO_SubCatFoodbusinessoperators'	as TableName from CL_FBO_SubCatFoodbusinessoperators
	union select REFID,  CancelDoc		 as DOC, 'CL_LicCancelationHistory'				as TableName from CL_LicCancelationHistory
	union select REFID,  DUPLIC_DOC		 as DOC, 'CLEXPAPPDETAILS'						as TableName from CLEXPAPPDETAILS
	union select REFID,  DOCLocation	 as DOC, 'LM_CL_FBO_Documents'					as TableName from LM_CL_FBO_Documents
	union select REFID,  DOCLocation	 as DOC, 'LM_CL_FBO_Documents_Log'				as TableName from LM_CL_FBO_Documents_Log
	) AS A 
		left join (
	SELECT L.REFID, L.IssuedDate, L.ExpireDate from ( select LicenseNo, MAX(CreatedOn) AS Final 
				     from CL_FBO_License group by LicenseNo ) as Le 
				left join CL_FBO_License as L on Le.LicenseNo = L.LicenseNo and Le.Final = L.CreatedOn ) AS B ON A.REFID = B.REFID 
	where A.REFID not in( -- Removing RFID of Applications that had been applied for Renewal
		select REFID from CL_FBO_License where ATID in (select ATID from CL_FBO_AppStatusMaster where AppType = 'R'and StatusID != 5 and PaymentFlag = 'Y' )
		) and A.DOC IS NOT NULL and CONVERT (date, B.ExpireDate) < @rmDate
	order by B.ExpireDate
	END

	if (@do = 'getSLS')
	BEGIN
	select 'SLS', A.REFID, L.IssuedDate, L.ExpireDate, A.DOCLocation, A.TableName FROM (
			select REFID, DOCLocation, 'SL_FBO_Documents'				as TableName from SL_FBO_Documents				
	union	select REFID, DOCLocation, 'SL_FBO_DocumentChange_log'		as TableName from SL_FBO_DocumentChange_log	
	union	select REFID, DOCLocation, 'LM_SL_FBO_Documents'			as TableName from LM_SL_FBO_Documents			
	union	select REFID, DOCLocation, 'LM_SL_FBO_Documents_log'		as TableName from LM_SL_FBO_Documents_log		
	union	select REFID, DOCLocation, 'SL_FBO_PADocument'				as TableName from SL_FBO_PADocument			
	union	select REFID, DOCLocation, 'SL_FBO_PADocumentChange_LOG'	as TableName from SL_FBO_PADocumentChange_LOG
	) AS A 
	left join SL_FBO_License as L on A.REFID = L.REFID
	where	A.DocLocation is not null 
		and convert(date,L.ExpireDate) < @rmDate
	order by L.ExpireDate
	END
			
END
