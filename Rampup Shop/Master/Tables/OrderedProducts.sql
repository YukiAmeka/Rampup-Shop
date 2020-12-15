CREATE TABLE [Master].[OrderedProducts]
(
	[OrderedProductId] INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_Master_OrderedProducts_OrderedProductId PRIMARY KEY, 
    [OrderId] INT NOT NULL CONSTRAINT FK_OrderedProducts_Orders_OrderId FOREIGN KEY REFERENCES [Master].[Orders] ([OrderId]), 
    [ProductStockId] INT NOT NULL CONSTRAINT FK_OrderedProducts_ProductStocks_ProductStockId FOREIGN KEY REFERENCES [Master].[ProductStocks] ([ProductStockId])
)
