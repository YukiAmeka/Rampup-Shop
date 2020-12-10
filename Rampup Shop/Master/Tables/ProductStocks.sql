CREATE TABLE [Master].[ProductStocks]
(
	[ProductStockId] INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_Master_ProductStocks_ProductStockId PRIMARY KEY,
	[ProductDetailId] INT NOT NULL CONSTRAINT FK_ProductStocks_ProductDetails_ProductDetailId FOREIGN KEY REFERENCES [Master].[ProductDetails] ([ProductDetailId]), 
    [Price] MONEY NOT NULL, 
    [StartVersion] INT NOT NULL CONSTRAINT FK_ProductStocks_Versions_StartVersionId FOREIGN KEY REFERENCES [Master].[Versions] ([VersionId]), 
    [EndVersion] INT NULL CONSTRAINT FK_ProductStocks_Versions_EndVersionId FOREIGN KEY REFERENCES [Master].[Versions] ([VersionId])
)
