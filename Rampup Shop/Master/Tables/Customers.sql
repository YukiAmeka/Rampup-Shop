CREATE TABLE [Master].[Customers]
(
	[CustomerId] INT IDENTITY NOT NULL PRIMARY KEY, 
    [FirstName] VARCHAR(50) NOT NULL, 
    [LastName] VARCHAR(50) NOT NULL, 
    [Email] VARCHAR(100) NOT NULL, 
    [Phone] VARCHAR(20) NULL
)
