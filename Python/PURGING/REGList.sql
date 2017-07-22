
SELECT [refid], [PATH], [issueddate], [ExpireDate] FROM FLRS.dbo.EXPLICDATA 
    WHERE [TYPE] = 'CLS'
    AND [PATH] is NOT NULL
    ORDER BY [ExpireDate], [refid]