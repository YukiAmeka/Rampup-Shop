-- ===================================================================================================================================================
/*
	Table's data:		[Master].[ProductDetails]
	Short description:	Post-deployment data seeding into the table
	Created on:			2020-12-09
	Modified on:		2020-12-10
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [DataSeeding].[STP_PopulateProductDetails]
	@OperationRunId INT = NULL,
	@AffectedRows INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SuccessStatus INT,
		@TargetTable VARCHAR(100) = '[Master].[ProductDetails]';

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
		IF NOT EXISTS (SELECT TOP 1 * FROM [Master].[ProductDetails])
		BEGIN
			INSERT INTO [Master].[ProductDetails] (Name, ProductTypeId, Description)
			VALUES ('Molokiya Milk', 1, '1L carton package of natural cow milk'),
				('Ferma Milk', 1, '1L plastic package of natural cow milk'),
				('Bila Liniya Milk', 1, '0.5L plastic package of natural cow milk'),
				('Prostokvashyno Milk', 1, '0.5L carton package of natural cow milk'),
				('Karpatskyi Bread', 2, 'A loaf of fresh bread made from wholegrain'),
				('Zavarnyi Bread', 2, 'A loaf of fresh fluffy sweet bread'),
				('Baguette', 2, 'A loaf of fresh baguette'),
				('Chicken Breasts', 3, '1kg of chicken breasts'),
				('Chicken Wings', 3, '1kg of chicken wings'),
				('Chicken Legs', 3, '1kg of chicken legs'),
				('Potatoes', 4, '1kg of potatoes'),
				('Carrots', 4, '1kg of carrots'),
				('Onions', 4, '1kg of white onions'),
				('Tomatoes', 4, '1kg of red tomatoes'),
				('Broccoli', 4, '1kg of broccoli'),
				('Mayo', 5, '100g of mayonnaise'),
				('Cheddar Cheese', 6, '100g of packaged cheddar cheese'),
				('Parmesan Cheese', 6, '100g of packaged parmesan cheese'),
				('Selyanske Butter', 7, '200g of fresh butter'),
				('Sambirske Butter', 7, '200g of fresh butter'),
				('Prostokvashyno Butter', 7, '200g of fresh butter'),
				('Apples', 8, '1kg of yellow apples'),
				('Plumes', 8, '1kg of plumes'),
				('Grapes', 8, '1kg of green grapes'),
				('Pears', 8, '1kg of yellow pears'),
				('Oranges', 8, '1kg of oranges');
			
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