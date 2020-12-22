-- ===================================================================================================================================================
/*
	Table's data:		[Master].[OrderedProducts], [Master].[ProductStocks], [Master].[ProductDetails], [Master].[Orders]
	Short description:	Function that shows data about an individual customer
	Created on:			2020-12-20
	Modified on:		2020-12-21
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE FUNCTION [Master].[FN_OrderInfo]
(
	@OrderId int
)
RETURNS @OrderInfo TABLE
(
	OrderId INT, 
	OrderDate DATE, 
	ShipDate DATE, 
	CustomerId INT, 
	AddressId INT, 
	OrderStatusId INT, 
	ShipMethodId INT, 
	EmployeeId INT, 
	ProductStockId INT, 
	ProductDetailId INT, 
	Name VARCHAR(50), 
	ProductTypeId INT, 
	Description VARCHAR(255), 
	Price MONEY, 
	StartVersion INT, 
	EndVersion INT
)
AS
BEGIN
	INSERT INTO @OrderInfo
	SELECT O.OrderId, 
		OrderDate, 
		ShipDate, 
		CustomerId, 
		AddressId, 
		OrderStatusId, 
		ShipMethodId, 
		EmployeeId, 
		PS.ProductStockId, 
		PD.ProductDetailId, 
		Name, 
		ProductTypeId, 
		Description, 
		Price, 
		StartVersion, 
		EndVersion
	FROM [Master].[Orders] AS O
	JOIN [Master].[OrderedProducts] AS OP ON O.OrderId = OP.OrderId
	JOIN [Master].[ProductStocks] AS PS ON OP.ProductStockId = PS.ProductStockId
	JOIN [Master].[ProductDetails] AS PD ON PS.ProductDetailId = PD.ProductDetailId
	WHERE O.OrderId = @OrderId
	RETURN
END