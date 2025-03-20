SELECT 
	 phases.Job_Number
	--,jobs.Job_Description
	,phases.Phase_Code
	,phases.Cost_Type
	,ISNULL(SUM(trans.JTD_Hours),0) JTD_Hours
	,ISNULL(SUM(pchist.Projected_Hours),0) Projected_Hours
	
FROM
	JC_PHASE_MASTER_MC phases WITH (NOLOCK)
	
	
	LEFT JOIN (
			SELECT 
				job_number
				,phase_code
				,SUM(total_hours) JTD_Hours 
			FROM JC_TRANSACTION_HISTORY_MC WITH (NOLOCK)
			GROUP BY Job_Number, Phase_Code
			) trans 
		ON phases.job_number = trans.job_number 
		AND phases.Phase_Code = trans.Phase_Code
	
	
	LEFT JOIN (
			SELECT DISTINCT 
				Job
				,Phase
				,sum(Projected_Hours) Projected_Hours
			FROM JC_PROJ_COST_HISTORY_MC
			GROUP BY 
				Job
				,Phase
	) pchist 
	ON phases.Job_Number = pchist.Job 
	AND pchist.Phase = phases.Phase_Code
	
	/*LEFT OUTER JOIN JC_JOB_MASTER_MC jobs WITH (NOLOCK)
		on jobs.Job_Number = phases.Job_Number
	
		*/
WHERE 
	phases.Company_Code = 'EEI'
	and LTRIM(phases.Job_Number) like '25602'
GROUP BY
	phases.job_number
	--,jobs.Job_Description
	,phases.Phase_Code
	,phases.Cost_Type
ORDER BY 
	phases.Phase_Code
	