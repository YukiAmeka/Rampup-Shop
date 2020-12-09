CREATE TABLE [Master].[EmployeePositions] (
    [EmployeePositionId] INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_Master_EmployeePositions_EmployeePositionId PRIMARY KEY,
    [Title] VARCHAR (50)  NOT NULL,
    [Description] VARCHAR (255) NULL
);

