CREATE TABLE [Master].[EmployeePositions] (
    [EmployeePositionId] INT           IDENTITY (1, 1) NOT NULL,
    [Title]              VARCHAR (50)  NOT NULL,
    [Description]        VARCHAR (200) NULL,
    PRIMARY KEY CLUSTERED ([EmployeePositionId] ASC)
);

