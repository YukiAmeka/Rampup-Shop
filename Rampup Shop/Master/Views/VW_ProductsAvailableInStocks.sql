-- ===================================================================================================================================================
/*
	Table's data:		[Master].[ProductStocks], [Master].[ProductDetails], [Master].[ProductTypes]
	Short description:	View that shows the details of all the product items that have not been sold yet
	Created on:			2020-12-10
	Modified on:		2020-12-17
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE VIEW [Master].[VW_ProductsAvailableInStocks]
AS 
	SELECT ProductStockId,
		Price,
		StartVersion,
		EndVersion,
		PD.ProductDetailId,
		PD.Name AS ProductName,
		PD.Description AS ProductDescription,
		PT.Name AS ProductType,
		PT.Description AS TypeDescription
	FROM [Master].[ProductStocks] AS PS
	JOIN [Master].[ProductDetails] AS PD ON PS.ProductDetailId = PD.ProductDetailId
	JOIN [Master].[ProductTypes] AS PT ON PD.ProductTypeId = PT.ProductTypeId
	WHERE EndVersion = 999999999
