/*
========================================================================================================================================================================
	Title: Hours by Phase - Technology Solutions
	Purpose: Create a crystal report that references this view.  Shows projected hours, Estimated, hours, JTD, and Percent complete for selected parameter for time frame.     
	Author: Gabe Green
	Created: 3/20/25
	Last Edited: 3/20/25
	Change Log: 
========================================================================================================================================================================
*/


WITH CTE AS (
--Use a sub query to aggregate inner queries before adding aggregations dependendant on inner queries 
	SELECT 
		 phases.Job_Number
		,jobs.Job_Description
		,phases.Phase_Code
		,phases.Description
		,phases.Cost_Type
		,ISNULL(SUM(pchist.Projected_Hours),0) Projected_Hours
		,chng.Est_Hours
		,ISNULL(SUM(trans.JTD_Hours),0) JTD_Hours
		,trans.Tran_Date
		

		

	
	FROM
		JC_PHASE_MASTER_MC phases WITH (NOLOCK)
		--Use left joins to phase master table to show all phases for a project regardless of transaction history 	
	
		
		LEFT OUTER JOIN (
		--Add subqueires for transaction tables and change order tables to avoid nested joins
				SELECT 
					job_number
					,phase_code
					,SUM(total_hours) JTD_Hours 
					,CAST(Tran_Date_Text AS DATE) Tran_Date 
				FROM 
					JC_TRANSACTION_HISTORY_MC WITH (NOLOCK)
				GROUP BY 
					Job_Number
					,Phase_Code
					,Tran_Date_Text
				) trans 
			ON phases.job_number = trans.job_number 
			AND phases.Phase_Code = trans.Phase_Code
			
	
		

		LEFT OUTER JOIN (
				SELECT 
					Company_Code
					,Job
					,Phase
					,Cost_Type
					,sum(Projected_Hours) Projected_Hours
				FROM 
					JC_PROJ_COST_HISTORY_MC WITH (NOLOCK)
				GROUP BY 
					Company_Code
					,Job
					,Phase
					,Cost_Type
					
		) pchist 
		ON phases.Job_Number = pchist.Job 
		AND pchist.Phase = phases.Phase_Code
		AND pchist.Cost_Type = phases.Cost_Type
		AND pchist.Company_Code = phases.Company_Code
	
		--Projected cost tables contain projection data 
		
	
	
	LEFT OUTER JOIN (
		
			SELECT 
				p.Job_Number
				,p.Phase_Code
				,p.Cost_Type, 
				 p.Original_Est_Hours + ISNULL(e.Est_Hours,0) + ISNULL(v2.Est_Hours,0) as Est_Hours
			FROM JC_PHASE_MASTER_MC p WITH (NOLOCK)

			LEFT OUTER JOIN JC_PHASE_ESTIMATES_MC e WITH (NOLOCK)
				ON e.Company_Code = p.Company_Code
				AND e.Job_Number = p.Job_Number
				AND e.Phase_Code = p.Phase_Code
				AND e.Cost_Type = p.Cost_Type 


			LEFT OUTER JOIN (
				SELECT v.Company_Code, v.Job_Number, v.Phase_Code, v.Cost_Type,
					   SUM(Est_Quantity) as Est_Quantity, 
					   SUM(Est_Hours) as Est_Hours,
					   SUM(Est_Cost) as Est_Cost
				FROM(
					SELECT a.Company_Code,
						   a.Job_Number,
						   a.Phase_Code,
						   a.Cost_Type, 
						   a.Change_Request_Quantity as Est_Quantity,
						   a.Change_Request_Hours as Est_Hours,
						   a.Change_Request_Amount as Est_Cost
					FROM CR_CHNG_REQ_CON_DET_MC a WITH (NOLOCK)

					LEFT OUTER JOIN CR_CHNG_REQ_HDR_MC b WITH (NOLOCK)
					ON b.Customer_Code = a.Customer_Code
					AND b.Company_Code = a.Company_Code
					AND b.Job_Number = a.Job_Number
					AND b.Change_Request_Number = a.Change_Request_Number

					LEFT OUTER JOIN CR_CHNG_REQ_STATUS_MC c WITH (NOLOCK)
					ON c.Company_Code = a.Company_Code
					AND c.Status_Code = ISNULL(b.Status,' ')
					AND b.Change_Order_Number = ''

					WHERE b.Change_Order_Number <> ''
					   OR ISNULL(c.CR_Type,' ') = '1' 
					   OR ISNULL(c.CR_Type,' ') = '2' 
					   OR ISNULL(c.CR_Type,' ') = '5'          
          
					 ) v 
				GROUP BY v.Company_Code, v.Job_Number, v.Phase_Code, v.Cost_Type
			 ) v2
			 ON v2.Company_Code = p.Company_Code
			 AND v2.Job_Number = p.Job_Number
			 AND v2.Phase_Code = p.Phase_Code
			 AND v2.Cost_Type = p.Cost_Type   
			WHERE
				p.Company_Code = 'EEI'
				--and ltrim(p.Job_Number) = '25602'
				--and p.Cost_Type = 'V'


		) chng
			ON chng.Job_Number = phases.Job_Number
			AND chng.Phase_Code = phases.Phase_Code
			AND chng.Cost_Type = phases.Cost_Type
			--Change order subqueries add estimated hours for approved and executed change orders

	LEFT OUTER JOIN JC_JOB_MASTER_MC jobs WITH (NOLOCK)
			on jobs.Job_Number = phases.Job_Number
	
		
	WHERE 
		phases.Company_Code = 'EEI'
		--and LTRIM(phases.Job_Number) like '25607'
	GROUP BY
		phases.job_number
		,jobs.Job_Description
		,phases.Phase_Code
		,phases.Description
		,phases.Cost_Type
		,chng.Est_Hours
		,trans.Tran_Date

)
SELECT 
    *
	,Projected_Hours - JTD_Hours AS Projected_Hours_Remaining
	,CASE
		WHEN Projected_Hours = 0
		THEN 0
		ELSE (JTD_Hours/Projected_Hours) * 100
	END Phase_Percent_Complete_Projected 
	,Est_Hours - JTD_Hours Remaining_Hours_Estimated
	,ISNULL(JTD_Hours/NULLIF(Est_Hours,0),0) * 100 Estimated_Percent_Complete

FROM CTE
--WHERE
	--LTRIM(Job_Number) like '25607'

ORDER BY 
	Phase_Code