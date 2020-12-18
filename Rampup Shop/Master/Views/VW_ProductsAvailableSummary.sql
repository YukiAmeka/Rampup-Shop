-- ===================================================================================================================================================
/*
	Table's data:		[Master].[VW_ProductsAvailableInStocks]
	Short description:	View that shows the summarized quantities of the product items that have not been sold yet
	Created on:			2020-12-16
	Modified on:		2020-12-17
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE VIEW [Master].[VW_ProductsAvailableSummary]
AS 
	SELECT [Price]
      ,[ProductName]
	  ,COUNT(ProductStockId) AS AvailableCount
      ,[ProductDescription]
      ,[ProductType]
      ,[TypeDescription]
  FROM [Master].[VW_ProductsAvailableInStocks]
  GROUP BY ProductDetailId, ProductName, Price, ProductDescription, ProductType, TypeDescription
