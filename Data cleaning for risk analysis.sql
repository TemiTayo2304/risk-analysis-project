

-- Risk Analysis Project
-- Data Cleaning
USE Risk_analysis_project

SELECT * FROM loan_data

-- Change the table name
EXEC sp_rename '[dbo].[3.1 loan_data_2007-2014]', 'loan_data'

-- Delete unwanted colunm
ALTER TABLE loan_data
DROP COLUMN column1;

-- 19,326 records
SELECT * FROM loan_data
WHERE [desc] IS NULL AND emp_title IS NULL

--8,262 records
SELECT emp_title, [desc], purpose FROM loan_data
WHERE emp_title IS NULL AND [desc] IS NOT NULL 

-- 743 records
SELECT emp_title, [desc], purpose FROM loan_data
WHERE emp_title IS NULL AND [desc] IS NOT NULL AND [desc] LIKE '%business%' 

--110 records
SELECT emp_title, [desc], purpose FROM loan_data
WHERE emp_title IS NULL AND [desc] IS NOT NULL AND [desc] LIKE '%student%'

-- Find postion of student and business in the desc column
SELECT PATINDEX('%student%',[desc])
FROM loan_data
WHERE [desc] IS NOT NULL AND emp_title IS NULL AND [desc] LIKE '%student%'

SELECT [desc], PATINDEX('%business%',[desc])
FROM loan_data
WHERE [desc] IS NOT NULL AND emp_title IS NULL AND [desc] LIKE '%business%'

-- Extracting business & student from the desc column
SELECT [desc], SUBSTRING([desc], PATINDEX('%business%',[desc]),LEN('business'))
FROM loan_data
WHERE [desc] IS NOT NULL AND emp_title IS NULL AND [desc] LIKE '%business%'

SELECT [desc], SUBSTRING([desc], PATINDEX('%student%',[desc]),LEN('student'))
FROM loan_data
WHERE [desc] IS NOT NULL AND emp_title IS NULL AND [desc] LIKE '%student%';

-- create a new column in the loan data for the employment status of the lenders
ALTER TABLE loan_data
ADD employment_title varchar(50)

-- made a mistake and renamed column name
sp_rename 'loan_data.employment_title', 'employment_status', 'column'

-- creating a new column to identify business owners (self-empolyed) and students
-- Populating into the newly created employment_status column
-- Update Table
begin transaction;
WITH new_title AS (
	SELECT [desc], emp_title,
		   CASE WHEN [Desc] like '%business%' then 'self_employed' 
			    WHEN [Desc] like '%student%' then 'student' 
			    END AS [employment_status]
	FROM loan_data
	WHERE [desc] IS NOT NULL AND emp_title IS NULL 
			AND ([desc] LIKE '%business%' OR [desc] LIKE '%student%')
)
UPDATE loan_data
SET loan_data.employment_status = new_title.[employment_status]
FROM new_title
WHERE loan_data.[desc] = new_title.[desc]

-- updating employment_status column
begin transaction;
UPDATE loan_data
SET employment_status = 'employed'
WHERE employment_status IS NULL AND emp_title IS NOT NULL;

SELECT [desc],emp_title,employment_status
FROM loan_data
WHERE employment_status IS NULL
