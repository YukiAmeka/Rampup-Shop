CREATE TABLE [Master].[Orders]
(
	[OrderId] INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_Master_Orders_OrderId PRIMARY KEY, 
    [OrderDate] DATE NOT NULL, 
    [ShipDate] DATE NULL, 
    [CustomerId] INT NOT NULL CONSTRAINT FK_Orders_Customers_CustomerId FOREIGN KEY REFERENCES [Master].[Customers] ([CustomerId]), 
    [AddressId] INT NULL CONSTRAINT FK_Orders_Addresses_AddressId FOREIGN KEY REFERENCES [Master].[Addresses] ([AddressId]),
    [OrderStatusId] INT NOT NULL CONSTRAINT FK_Orders_OrderStatuses_OrderStatusId FOREIGN KEY REFERENCES [Master].[OrderStatuses] ([OrderStatusId]), 
    [ShipMethodId] INT NOT NULL CONSTRAINT FK_Orders_ShipMethods_ShipMethodId FOREIGN KEY REFERENCES [Master].[ShipMethods] ([ShipMethodId]), 
    [EmployeeId] INT NULL CONSTRAINT FK_Orders_Employees_EmployeeId FOREIGN KEY REFERENCES [Master].[Employees] ([EmployeeId])
)
