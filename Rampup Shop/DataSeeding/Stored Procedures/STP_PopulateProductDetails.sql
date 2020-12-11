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

		-- Record a temporary list of product details (used here & in populating product stocks)
		DROP TABLE IF EXISTS ##ProductDetails;
		CREATE TABLE ##ProductDetails (
			[ProductDetailId] INT NOT NULL IDENTITY(1,1),
			[Name] VARCHAR(50) NOT NULL,
			[ProductTypeId] INT NOT NULL,
			[Description] VARCHAR(255) NULL,
			[Price] MONEY NOT NULL,
			[SoldPerWeek] INT NOT NULL
		);
		INSERT INTO ##ProductDetails (Name, ProductTypeId, Description, Price, SoldPerWeek)
			VALUES ('Molokiya Milk', 1, '1L carton package of natural cow milk', 36.25, 150),
				('Ferma Milk', 1, '1L plastic package of natural cow milk', 32.80, 150),
				('Bila Liniya Milk', 1, '0.5L plastic package of natural cow milk', 20.50, 75),
				('Prostokvashyno Milk', 1, '0.5L carton package of natural cow milk', 22.10, 75),
				('Karpatskyi Bread', 2, 'A loaf of fresh bread made from wholegrain', 15.15, 300),
				('Zavarnyi Bread', 2, 'A loaf of fresh fluffy sweet bread', 18.70, 300),
				('Baguette', 2, 'A loaf of fresh baguette', 11.05, 300),
				('Chicken Breasts', 3, '1kg of chicken breasts', 73.40, 50),
				('Chicken Wings', 3, '1kg of chicken wings', 69.95, 50),
				('Chicken Legs', 3, '1kg of chicken legs', 89.75, 50),
				('Potatoes', 4, '1kg of potatoes', 19.00, 150),
				('Carrots', 4, '1kg of carrots', 17.35, 150),
				('Onions', 4, '1kg of white onions', 12.20, 150),
				('Tomatoes', 4, '1kg of red tomatoes', 15.80, 150),
				('Broccoli', 4, '1kg of broccoli', 22.50, 150),
				('Mayo', 5, '100g of mayonnaise', 13.70, 300),
				('Cheddar Cheese', 6, '100g of packaged cheddar cheese', 73.90, 450),
				('Parmesan Cheese', 6, '100g of packaged parmesan cheese', 99.90, 150),
				('Selyanske Butter', 7, '200g of fresh butter', 25.15, 150),
				('Sambirske Butter', 7, '200g of fresh butter', 28.30, 150),
				('Prostokvashyno Butter', 7, '200g of fresh butter', 23.85, 150),
				('Apples', 8, '1kg of yellow apples', 10.45, 150),
				('Plumes', 8, '1kg of plumes', 17.20, 150),
				('Grapes', 8, '1kg of green grapes', 28.00, 150),
				('Pears', 8, '1kg of yellow pears', 34.65, 150),
				('Oranges', 8, '1kg of oranges', 20.90, 150);

		-- Populate only an empty table:
		IF NOT EXISTS (SELECT TOP 1 * FROM [Master].[ProductDetails])
		BEGIN
			INSERT INTO [Master].[ProductDetails] (Name, ProductTypeId, Description)
			SELECT Name, ProductTypeId, Description 
			FROM ##ProductDetails;
			
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