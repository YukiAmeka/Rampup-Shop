CREATE TABLE [Master].[Employees] (
    [EmployeeId] INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_Master_Employees_EmployeeId PRIMARY KEY,
    [FirstName] VARCHAR (50) NOT NULL,
    [LastName] VARCHAR (50) NOT NULL,
    [Email] VARCHAR (100) NOT NULL,
    [PasswordHash] VARCHAR (50)  NULL,
    [EmployeePositionId] INT NOT NULL CONSTRAINT FK_Employees_EmployeePositions_EmployeePositionId FOREIGN KEY REFERENCES [Master].[EmployeePositions] ([EmployeePositionId]),
    [DateHired] DATE NOT NULL,
    [DateFired] DATE NOT NULL DEFAULT ('2999-12-31')
);

