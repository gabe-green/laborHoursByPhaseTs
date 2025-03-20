/*
	Title: Labor Hours by Phase Technology Solutions
	Purpose: Create a crystal report that references this view.  Shows projected hours, Estimated, hours, WTD, JTD, and Percent complete for previouse month.   
	Author: Gabe Green
	Created: 3/20/25
	Last Edited: 3/20/25
	Change Log: 
*/


SELECT 
	phases.Job_Number
	--,jobs.Job_Description
	,phases.Phase_Code
	,jcthist.Cost_Type
	,SUM(jcthist.Total_Hours) Hours
	--,CAST(Tran_Date_Text AS DATE) Tran_Date 
	--,CAST(GETDATE() as Date) Today
	--,DATEDIFF(DAY, CAST(Tran_Date_Text AS DATE), CAST(GETDATE() as Date)) Date_Diff
	--TOP 1000 * 
FROM 
	
	
	JC_PHASE_MASTER_MC phases 
	FULL OUTER JOIN JC_TRANSACTION_HISTORY_MC jcthist ON phases.Job_Number = jcthist.Job_Number and phases.Phase_Code = jcthist.Phase_Code
--	LEFT OUTER JOIN JC_JOB_MASTER_MC jobs ON jcthist.Job_Number = jobs.Job_Number
	
	



WHERE 
	ltrim(jcthist.Job_Number) like '25%'
	and jcthist.Cost_Center in ('130','140','150')
	and jcthist.Cost_Type in ('L','V','C')
	--and DATEDIFF(DAY, CAST(Tran_Date_Text AS DATE), CAST(GETDATE() as Date)) < 30
	--and SUM(Total_Hours) = 0
GROUP BY 
	phases.Job_Number
	--,jobs.Job_Description
	,phases.Phase_Code
	,jcthist.Cost_Type
	--,Tran_Date_Text
ORDER BY 
	Job_Number,Phase_Code;
	