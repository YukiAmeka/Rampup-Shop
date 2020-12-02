CREATE TABLE [Master].[Customers]
(
	[CustomerId] INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_Master_Customers_CustomerId PRIMARY KEY, 
    [FirstName] VARCHAR(50) NOT NULL, 
    [LastName] VARCHAR(50) NOT NULL, 
    [Email] VARCHAR(100) NOT NULL, 
    [Phone] VARCHAR(20) NULL
)
