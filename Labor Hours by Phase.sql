SELECT
	phases.Job_Number
	,jobs.Job_Description
	,phases.Phase_Code
	,ISNULL(sum(trans.Total_Hours),0) Hours

FROM
	JC_PHASE_MASTER_MC phases
	LEFT OUTER JOIN JC_TRANSACTION_HISTORY_MC trans 
		on phases.job_number = trans.job_number 
		and phases.Phase_Code = trans.Phase_Code
	LEFT OUTER JOIN JC_JOB_MASTER_MC jobs
		on jobs.Job_Number = phases.Job_Number

WHERE 
	LTRIM(phases.Job_Number) like '25602'
GROUP BY
	phases.job_number
	,jobs.Job_Description
	,phases.Phase_Code
	--,trans.Total_Hours 
ORDER BY 
	phases.Phase_Code
