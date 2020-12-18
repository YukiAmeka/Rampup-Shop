CREATE TABLE [Master].[ProductDetails]
(
	[ProductDetailId] INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_Master_ProductDetails_ProductDetailId PRIMARY KEY,
	[Name] VARCHAR(50) NOT NULL,
	[ProductTypeId] INT NOT NULL CONSTRAINT FK_ProductDetails_ProductTypes_ProductTypeId FOREIGN KEY REFERENCES [Master].[ProductTypes] ([ProductTypeId]),
    [Description] VARCHAR(255) NULL
)
