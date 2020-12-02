CREATE TABLE [Master].[EmployeePositions] (
    [EmployeePositionId] INT NOT NULL IDENTITY CONSTRAINT PK_Master_EmployeePositionId PRIMARY KEY,
    [Title] VARCHAR (50)  NOT NULL,
    [Description] VARCHAR (200) NULL
);

