/*
	Title: Labor Hours by Phase Technology Solutions
	Purpose: Create a crystal report that references this view.  Shows projected hours, Estimated, hours, WTD, JTD, and Percent complete for previouse month.   
	Author: Gabe Green
	Created: 3/20/25
	Last Edited: 3/20/25
	Change Log: 
*/


SELECT 
	jcthist.Job_Number
	,jobs.Job_Description
	,Phase_Code
	,Cost_Type
	,SUM(Total_Hours) Hours
	,CAST(Tran_Date_Text AS DATE) Tran_Date 
	--,CAST(GETDATE() as Date) Today
	,DATEDIFF(DAY, CAST(Tran_Date_Text AS DATE), CAST(GETDATE() as Date)) Date_Diff
	--TOP 1000 * 
FROM 
	JC_TRANSACTION_HISTORY_MC jcthist
	LEFT OUTER JOIN JC_JOB_MASTER_MC jobs on jcthist.Job_Number = jobs.Job_Number
	
WHERE 
	ltrim(jcthist.Job_Number) like '25607'
	and jcthist.Cost_Center in (/*'130','140',*/'150')
	and Cost_Type in ('L','V','C')
	and DATEDIFF(DAY, CAST(Tran_Date_Text AS DATE), CAST(GETDATE() as Date)) < 30
	and Cost_Type = 'L'
GROUP BY 
	jcthist.Job_Number
	,jobs.Job_Description
	,Phase_Code
	,Cost_Type
	,Tran_Date_Text
ORDER BY 
	Tran_Date_Text;
	