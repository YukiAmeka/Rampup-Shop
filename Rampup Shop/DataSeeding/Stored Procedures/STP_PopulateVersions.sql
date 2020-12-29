-- ===================================================================================================================================================
/*
	Table's data:		[Master].[Versions]
	Short description:	Post-deployment data seeding into the table
	Created on:			2020-12-10
	Modified on:		2020-12-24
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [DataSeeding].[STP_PopulateVersions]
	@OperationRunId INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SuccessStatus INT,
		@AffectedRows INT = 0,
		@TargetTable VARCHAR(100) = '[Master].[Versions]';

	BEGIN TRY
		-- Check if table exists
		IF OBJECT_ID(@TargetTable) IS NULL
			RAISERROR('Table %s cannot be populated, as it does not exist in this DB', 16, 25, @TargetTable);

		-- Populate only an empty table:
		IF NOT EXISTS (SELECT TOP 1 * FROM [Master].[Versions])
		BEGIN
			DECLARE @StartDate DATE = '2020-01-05', 
				@EndDate DATE = DATEADD(d, -1, CAST(CURRENT_TIMESTAMP AS DATE));

			-- Generate all dates between @StartDate and today
			WITH Calendar 
			AS (
				SELECT DATEADD(d, n-1, @StartDate) AS VersionDate
				FROM (
					SELECT TOP (DATEDIFF(d, @StartDate, @EndDate) + 1)
						ROW_NUMBER() OVER (ORDER BY [object_id]) AS n
					FROM sys.all_objects) AS Numbers
			)
			-- Create versions for all orders (150 per workday; details updated later) and 1 resupply on Sunday
			INSERT INTO [Master].[Versions] (OperationRunId, VersionDate, VersionDetails)
			SELECT @OperationRunId, VersionDate, 'Products weekly resupply'
			FROM Calendar
			WHERE DATENAME(dw, VersionDate) = 'Sunday'
				UNION ALL
			SELECT @OperationRunId, VersionDate, ''
			FROM Calendar
			CROSS JOIN (SELECT TOP (150) 
				ROW_NUMBER() OVER (ORDER BY [object_id]) AS n
				FROM sys.all_objects
			) AS Numbers
			WHERE DATENAME(dw, VersionDate) <> 'Sunday'
			ORDER BY VersionDate;
									
			-- Output the number of affected rows
			SET @AffectedRows = @@ROWCOUNT;
		END

		-- Log the event
		DECLARE @Message VARCHAR(MAX) = '11) Populating data into ' + @TargetTable;
		EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
			@CallingProc = @@PROCID,
			@AffectedRows = @AffectedRows,
			@Message = @Message;
		
		IF @SuccessStatus = 1
			RAISERROR('Event logging has failed. Table %s has not been populated', 12, 25, @TargetTable);
		RETURN 0
	END TRY
	BEGIN CATCH
		DECLARE @ErrorNumber INT = ERROR_NUMBER(), 
			@ErrorSeverity INT = ERROR_SEVERITY(), 
			@ErrorState INT = ERROR_STATE(), 
			@ErrorProcedure VARCHAR(255) = ERROR_PROCEDURE(), 
			@ErrorLine INT = ERROR_LINE(), 
			@ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
		
		-- Log the error
		EXEC [Logs].[STP_SetError] @OperationRunId, @ErrorNumber, @ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine, @ErrorMessage;
		
		-- Raiserror to the application
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
		
		RETURN 1
	END CATCH
END;
