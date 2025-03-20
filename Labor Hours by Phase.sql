SELECT 
	Job_Number
	,Phase_Code
	,SUM(Total_Hours) Hours
	,CAST(Tran_Date_Text AS DATE) Tran_Date 
	--,CAST(GETDATE() as Date) Today
	,DATEDIFF(DAY, CAST(Tran_Date_Text AS DATE), CAST(GETDATE() as Date)) Date_Diff
	--TOP 1000 * 
FROM JC_TRANSACTION_HISTORY_MC
WHERE 
	ltrim(Job_Number) like '25607'
	and Cost_Center in (/*'130','140',*/'150')
	and Cost_Type in ('L','V','C')
	--and DATEDIFF(DAY, CAST(Tran_Date_Text AS DATE), CAST(GETDATE() as Date)) < 30	
GROUP BY 
	Job_Number
	,Phase_Code
	,Tran_Date_Text
ORDER BY Tran_Date_Text
	