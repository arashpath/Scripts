/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2008 R2 (10.50.2500)
    Source Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2008 R2
    Target Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [FLRS]
GO

/****** Object:  StoredProcedure [dbo].[PurgingDOC]    Script Date: 24-08-2017 14:20:02 ******/
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
	select 'CLS' as LicType,	--/*
		(SELECT COUNT (L.LicenseNo) from 
		( select LicenseNo, MAX(CreatedOn) AS Final
												from CL_FBO_License      WITH (NOLOCK) group by LicenseNo ) as Le
										   left join CL_FBO_License as L WITH (NOLOCK) on Le.LicenseNo = L.LicenseNo and Le.Final = L.CreatedOn WHERE L.CreatedOn     <= @tillDate ) as Total ,
		(SELECT COUNT (L.LicenseNo) from 
		( select LicenseNo, MAX(CreatedOn) AS Final 
												from CL_FBO_License      WITH (NOLOCK) group by LicenseNo ) as Le 
										   left join CL_FBO_License as L WITH (NOLOCK) on Le.LicenseNo = L.LicenseNo and Le.Final = L.CreatedOn WHERE L.[ExpireDate]	<= @rmDate	 ) as Expired , 
										   --*/
		'F:\FSSAI-DOCS1\FLRS\CLS\' as BasePath, 'https://foodlicensing.fssai.gov.in/CLSDOCS/CLS/' as URL
	union
	select 'SLS' as LicType,	--/*
		(SELECT COUNT (L.LicenseNo) from 
		( select LicenseNo, MAX(CreatedOn) AS Final
												from SL_FBO_License      WITH (NOLOCK) group by LicenseNo ) as Le
										   left join SL_FBO_License as L WITH (NOLOCK) on Le.LicenseNo = L.LicenseNo and Le.Final = L.CreatedOn WHERE L.CreatedOn     <= @tillDate ) as Total ,
		(SELECT COUNT (L.LicenseNo) from 			 
		( select LicenseNo, MAX(CreatedOn) AS Final  
												from SL_FBO_License      WITH (NOLOCK) group by LicenseNo ) as Le 
										   left join SL_FBO_License as L WITH (NOLOCK) on Le.LicenseNo = L.LicenseNo and Le.Final = L.CreatedOn WHERE L.[ExpireDate]	<= @rmDate	 ) as Expired , 
										   --*/
		'E:\FSSAI-DOCS\FLRS\SLS\' as BasePath, 'https://foodlicensing.fssai.gov.in/FLRSDOCS/SLS/'	as URL
	union
	select 'REG' as LicType,	--/*
		(SELECT COUNT (L.LicenseNo) from 
		( select LicenseNo, MAX(CreatedOn) AS Final
												from RG_License      WITH (NOLOCK) group by LicenseNo ) as Le
										   left join RG_License as L WITH (NOLOCK) on Le.LicenseNo = L.LicenseNo and Le.Final = L.CreatedOn WHERE L.CreatedOn         <= @tillDate ) as Total ,
		(SELECT COUNT (L.LicenseNo) from 			 				 
		( select LicenseNo, MAX(CreatedOn) AS Final  				 
												from RG_License      WITH (NOLOCK) group by LicenseNo ) as Le 
										   left join RG_License as L WITH (NOLOCK) on Le.LicenseNo = L.LicenseNo and Le.Final = L.CreatedOn WHERE L.[ExpireDate]		<= @rmDate   ) as Expired , 
										   --*/
		'F:\FSSAI-DOCS1\FLRS\REG\' as BasePath, 'https://foodlicensing.fssai.gov.in/REGDOCS/REG/' as URL
	END
 	-- Insert statements for procedure here   
	if (@do = 'getCLS')
	BEGIN
	--select * from Purging_log where LicType='Nothing'
	--/*
	select 'CLS' as LicType, REFID, IssuedDate, [ExpireDate], DOC from (
    select  B.REFID, B.IssuedDate, B.ExpireDate, A.DOC, ROW_NUMBER() OVER( Partition by A.DOC ORDER BY B.ExpireDate desc ) as rn  FROM (
		  select REFID,  DUPLIC_DOC		 as DOC from CL_FBO_AppDetails					  WITH (NOLOCK)
	union select REFID,  TRANSFER_DOC	 as DOC from CL_FBO_AppDetails					  WITH (NOLOCK)
	union select REFID,  TRANSFER_DOCLHC as DOC from CL_FBO_AppDetails					  WITH (NOLOCK)
	union select REFID,  ModificationDoc as DOC from CL_FBO_AppModification				  WITH (NOLOCK)
	union select REFID,  ModificationDoc as DOC from CL_FBO_AppModification_enforcement   WITH (NOLOCK)
	union select REFID,  DOCLocation	 as DOC from CL_FBO_DocumentChange_log			  WITH (NOLOCK)
	union select REFID,  DOCLocation	 as DOC from CL_FBO_Documents					  WITH (NOLOCK)
	union select REFID,  ManualInspDoc	 as DOC from CL_FBO_InspMaster					  WITH (NOLOCK)
	union select REFID,  DOCLOCATION	 as DOC from CL_FBO_PADocument					  WITH (NOLOCK)
	union select REFID,  DOCLOCATION	 as DOC from CL_FBO_PADocumentChange_LOG		  WITH (NOLOCK)
	union select REFID,  Document		 as DOC from CL_FBO_SubCatFoodbusinessoperators   WITH (NOLOCK)
	union select REFID,  CancelDoc		 as DOC from CL_LicCancelationHistory			  WITH (NOLOCK)
	union select REFID,  DUPLIC_DOC		 as DOC from CLEXPAPPDETAILS					  WITH (NOLOCK)
	union select REFID,  DOCLocation	 as DOC from LM_CL_FBO_Documents				  WITH (NOLOCK)
	union select REFID,  DOCLocation	 as DOC from LM_CL_FBO_Documents_Log			  WITH (NOLOCK)
	) AS A 
		left join (
	SELECT L.REFID, L.IssuedDate, L.ExpireDate from ( select LicenseNo, MAX(CreatedOn) AS Final 
				     from CL_FBO_License	  WITH (NOLOCK) group by LicenseNo ) as Le 
				left join CL_FBO_License as L WITH (NOLOCK) on Le.LicenseNo = L.LicenseNo and Le.Final = L.CreatedOn ) AS B ON A.REFID = B.REFID 
	where A.REFID not in(                -- Removing RFID of Applications that had been applied for Renewal
		select REFID from CL_FBO_License      WITH (NOLOCK) where ATID in (select ATID from CL_FBO_AppStatusMaster WITH (NOLOCK) where AppType = 'R'and StatusID != 5 and PaymentFlag = 'Y' )
		) and CONVERT (date, B.ExpireDate) < @rmDate
		and A.DOC IS NOT NULL 
		and A.DOC <> ''
		and A.DOC not in (select DOC from Purging_log where LicType = 'CLS')
	) CLSList where rn = '1'
	order by ExpireDate
	--*/
	END

	if (@do = 'getSLS')
	BEGIN
	--select * from Purging_log where LicType='Nothing'
	--/*
	select 'SLS' as LicType, REFID, IssuedDate, [ExpireDate], DOC from (
	select  B.REFID, B.IssuedDate, B.ExpireDate, A.DOC, ROW_NUMBER() OVER( Partition by A.DOC ORDER BY B.ExpireDate desc ) as rn  FROM (
		  select REFID,  DOCLocation		as DOC from LM_SL_FBO_Documents							WITH (NOLOCK)
	union select REFID,  DOCLocation		as DOC from LM_SL_FBO_Documents_log						WITH (NOLOCK)
	union select REFID,  DUPLIC_DOC			as DOC from SL_FBO_AppDetails							WITH (NOLOCK)
	union select REFID,  SCANEEDDOC			as DOC from SL_FBO_AppDetails							WITH (NOLOCK)
	union select REFID,  TRANSFER_DOC		as DOC from SL_FBO_AppDetails							WITH (NOLOCK)
	union select REFID,  TRANSFER_DOCLHC	as DOC from SL_FBO_AppDetails							WITH (NOLOCK)
	union select REFID,  DOCLocation		as DOC from SL_FBO_DocumentChange_log					WITH (NOLOCK)
	union select REFID,  DOCLocation		as DOC from SL_FBO_Documents							WITH (NOLOCK)
	union select REFID,  ManualInspDoc		as DOC from SL_FBO_InspMaster							WITH (NOLOCK)
	union select REFID,  Receipt_Doc		as DOC from SL_FBO_Payment								WITH (NOLOCK)
	union select REFID,  Treasury_DOC		as DOC from SL_FBO_PaymentDetails						WITH (NOLOCK)
	union select REFID,  Receipt_Doc		as DOC from SL_FBO_updatepaymentmodehistory_challan_log	WITH (NOLOCK)
	union select REFID,  CancelDoc			as DOC from SL_LicCancelationHistory					WITH (NOLOCK)
	) AS A 
		left join (
	SELECT L.REFID, L.IssuedDate, L.ExpireDate from ( select LicenseNo, MAX(CreatedOn) AS Final 
				     from SL_FBO_License	  WITH (NOLOCK) group by LicenseNo ) as Le 
				left join SL_FBO_License as L WITH (NOLOCK) on Le.LicenseNo = L.LicenseNo and Le.Final = L.CreatedOn ) AS B ON A.REFID = B.REFID 
	where A.REFID not in(						            -- Removing RFID of Applications that had been applied for Renewal
		select REFID from SL_FBO_AppDetails   WITH (NOLOCK) where ATID in (select ATID from CL_FBO_AppStatusMaster WITH (NOLOCK) where AppType = 'R'and StatusID != 5 and PaymentFlag = 'Y' )
		) and CONVERT (date, B.ExpireDate) < @rmDate
		and A.DOC IS NOT NULL 
		and A.DOC <> ''
		and A.DOC not in (select DOC from Purging_log where LicType = 'SLS')
	) SLSList where rn = 1
	order by [ExpireDate]
	--/*
	END
			
	if (@do = 'getREG')
	BEGIN
	--select * from Purging_log where LicType='Nothing'
	--/*
	select 'REG' as LicType, REFID, IssuedDate, [ExpireDate], DOC FROM (	
	select  B.REFID, B.IssuedDate, B.ExpireDate, A.DOC, ROW_NUMBER() OVER( Partition by A.DOC ORDER BY B.ExpireDate desc ) as rn  FROM (
		  select APPID,  photo				as DOC from RG_Registration					WITH (NOLOCK)
	union select APPID,  id					as DOC from RG_Registration					WITH (NOLOCK)
	union select APPID,  UPLOADFORMA		as DOC from RG_Registration					WITH (NOLOCK)	where UPLOADFORMA <> 'Physically'
	union select APPID,  DupAppDoc			as DOC from RG_Registration					WITH (NOLOCK)
	union select APPID,  SCANDOC			as DOC from RG_Registration					WITH (NOLOCK)
	union select APPID,  TransDeathDoc		as DOC from RG_Registration					WITH (NOLOCK)
	union select APPID,  TransferDoc		as DOC from RG_Registration					WITH (NOLOCK)
	union select APPID,  ReceiptDoc			as DOC from RG_CashPayment_Log				WITH (NOLOCK)
	union select APPID,  DocLocation		as DOC from RG_Document						WITH (NOLOCK)
	union select APPID,  DOC_UPLOADFORMA	as DOC from RG_FBO_Documentlog				WITH (NOLOCK)	where DOC_UPLOADFORMA <> 'Physically'
	union select REFID,  ManualInspDoc		as DOC from RG_FBO_InspMaster				WITH (NOLOCK)
	union select REFID,  CancelDoc			as DOC from RG_LicCancelationHistory		WITH (NOLOCK)
	union select APPID,  ReceiptDoc			as DOC from RG_Payment						WITH (NOLOCK)
	union select APPID,  ReceiptDoc			as DOC from RG_Payment_Log					WITH (NOLOCK)
	union select REFID,  DocFile			as DOC from RG_SuspendLicenseLog			WITH (NOLOCK)
	union select REFID,  UploadedID			as DOC from RG_FBO_CommercialLicenseDetails WITH (NOLOCK)

	) AS A 
		left join (
	SELECT L.REFID, L.IssuedDate, L.ExpireDate from ( select LicenseNo, MAX(CreatedOn) AS Final 
				     from RG_License	  WITH (NOLOCK) group by LicenseNo ) as Le 
				left join RG_License as L WITH (NOLOCK) on Le.LicenseNo = L.LicenseNo and Le.Final = L.CreatedOn ) AS B ON A.APPID = B.REFID 
	where B.REFID not in(                 -- Removing RFID of Applications that had been applied for Renewal
	    select APPID from RG_Registration WITH (NOLOCK) where Reg_No in  (select Reg_No from RG_Registration WITH (NOLOCK) where AppType = 'R'and StatusID != 29 and Payment_Flag = 'Y')
		) and	CONVERT (date, B.ExpireDate) < @rmDate
		and A.DOC IS NOT NULL 
		and A.DOC <> ''
		and A.DOC not in (select DOC from Purging_log where LicType = 'SLS')
	) REGList where rn = 1
	order by [ExpireDate]
	--*/
	END
END
GO