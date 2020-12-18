-- ===================================================================================================================================================
/*
	Table's data:		[Master].[ProductTypes]
	Short description:	Post-deployment data seeding into the table
	Created on:			2020-12-09
	Modified on:		2020-12-10
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [DataSeeding].[STP_PopulateProductTypes]
	@OperationRunId INT = NULL,
	@AffectedRows INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SuccessStatus INT,
		@TargetTable VARCHAR(100) = '[Master].[ProductTypes]';

	BEGIN TRY
		-- Log the event
		DECLARE @Message VARCHAR(MAX) = 'Populating data into ' + @TargetTable;
		EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
			@CallingProc = @@PROCID,
			@Message = @Message;
		
		IF @SuccessStatus = 1
			RAISERROR('Event logging has failed. Table %s has not been populated', 12, 25, @TargetTable);

		-- Check if table exists
		IF OBJECT_ID(@TargetTable) IS NULL
			RAISERROR('Table %s cannot be populated, as it does not exist in this DB', 16, 25, @TargetTable);

		-- Populate only an empty table:
		IF NOT EXISTS (SELECT TOP 1 * FROM [Master].[ProductTypes])
		BEGIN
			INSERT INTO [Master].[ProductTypes] (Name, Description)
			VALUES ('Milk', 'Natural cow milk'),
				('Bread', 'Fresh bread'),
				('Chicken', 'Pieces of chicken carcass'),
				('Vegetables', 'An assortment of vegetables incl. potatoes, carrots, etc'),
				('Mayonnaise', ''),
				('Cheese', 'Packaged cheese made from natural cow milk'),
				('Butter', 'Butter made from natural cow milk'),
				('Fruit', 'An assortment of fruits incl. apples, plumes, grapes, etc');
			
			-- Output the number of affected rows
			SET @AffectedRows = @@ROWCOUNT;
		END
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
		RETURN 1
	END CATCH
END;