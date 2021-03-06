﻿
-- =============================================
-- Author:		<Author: Ken Hill>
-- Create date: <Create Date: 4/29/2015>
-- Description:	<Description: Builds completed counts>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Get_CMPMetrics_CompletedCount]
	-- Add the parameters for the stored procedure here
    @BeginDate date,
	@EndDate date
AS
BEGIN
SELECT DISTINCT(OTD) AS 'C-OTD', Count(OTD) AS 'C-Count' FROM 
(SELECT f.id, RequestName, VMType, SLA, targetvmname, submitted, laststatusupdate, buildhours, builddays, statuscode,
CASE 
   When Resubmits > 0 THEN Resubmits
   ELSE 0
END AS Resubmits,
OTD,
CASE
   When ManuallyRemediated IS NULL Then 'N'
   ELSE 'Y'
END AS ManuallyRemediated
FROM
(SELECT id, RequestName, VMType, SLA, targetvmname, submitted, laststatusupdate, buildhours, builddays, statuscode, e.Resubmits,
   CASE
      WHEN builddays <= SLA THEN 'Y'
	  ELSE 'N'
   END AS 'OTD'
   FROM
(SELECT id, RequestName, VMType,
   CASE 
      WHEN VMType = 'FS' THEN 2
	  WHEN VMType = 'IIS' THEN 5
	  WHEN VMType = 'SQL' THEN 5
   END AS 'SLA',
   targetvmname,
   submitted,
   whenrequested,
   laststatusupdate,
   buildhours,
   builddays,
   statuscode
FROM
(SELECT a.id, a.RequestName, 
   CASE 
      WHEN PATINDEX('%<RoleCode>SROFS%',a.tagdata)>0 THEN 'FS'
	  WHEN PATINDEX('%<RoleCode>SROIIS%',a.tagdata)>0 THEN 'IIS'
	  WHEN PATINDEX('%<IISBuildOut>true%',a.tagdata)>0 THEN 'IIS'
      WHEN PATINDEX('%<RoleCode>SROSQL%',a.tagdata)>0 THEN 'SQL'
	  WHEN PATINDEX('%<SQLBuildOut>true%',a.tagdata)>0 THEN 'SQL'
   END AS 'VMType',
   a.targetvmname, 
   a.tagdata, 
   b.[When] as submitted, 
   a.whenrequested, 
   a.laststatusupdate,
   DATEDIFF(hour, b.[When], a.laststatusupdate) as buildhours, 
   DATEDIFF(day, b.[When], a.laststatusupdate) as builddays,
   a.statuscode FROM
(Select id,requestname,targetvmname,tagdata,whenrequested,laststatusupdate,exceptionmessage, statuscode,statusmessage,warnings
from [dbo].[VmDeploymentRequests] 
Where statuscode = 'complete' 
and CONVERT(date,LastStatusUpdate) >= @BeginDate 
and CONVERT(date,LastStatusUpdate) <= @EndDate 
and requesttype = 'NewVM') a
JOIN 
(Select * 
from [dbo].[ChangeLog] 
Where StatusCode = 'Submitted'
AND [Message] IS NULL) b ON a.id = b.RequestID) c) d
LEFT OUTER JOIN
(SELECT DISTINCT[RequestID], 
Count(RequestID) AS Resubmits
FROM [dbo].[ChangeLog] 
Where 
StatusCode = 'Submitted' 
AND [Message] LIKE 'Manual%' 
Group by RequestID) e ON d.id = e.RequestID) f
LEFT OUTER JOIN
(SELECT Distinct(Id), 
   CASE
      WHEN Count(Id)>0 THEN 'Y'
	  ELSE 'N'
   END AS 'ManuallyRemediated'
 FROM [dbo].[VmDeploymentRequests]
WHERE StatusCode = 'Complete' 
AND RequestType = 'NewVM'
AND StatusMessage like '%Manual send to status%'
Group By Id) g ON g.ID = f.id) h
--WHERE 
--ManuallyRemediated = 'N'
--AND Resubmits = 0
Group By OTD WITH ROLLUP
Order By OTD DESC
END