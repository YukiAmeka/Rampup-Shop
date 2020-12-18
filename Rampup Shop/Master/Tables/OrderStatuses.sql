CREATE TABLE [Master].[OrderStatuses]
(
	[OrderStatusId] INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_Master_OrderStatuses_OrderStatusId PRIMARY KEY, 
    [Name] VARCHAR(50) NOT NULL, 
    [Description] VARCHAR(255) NULL
)
