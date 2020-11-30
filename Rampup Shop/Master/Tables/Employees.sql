CREATE TABLE [Master].[Employees] (
    [EmployeeId]   INT          IDENTITY (1, 1) NOT NULL,
    [FirstName]    VARCHAR (50) NOT NULL,
    [LastName]     VARCHAR (50) NOT NULL,
    [Email]        VARCHAR (50) NOT NULL,
    [PasswordHash] VARCHAR (50) DEFAULT (NULL) NULL,
    [EmployeePositionId]   INT          NOT NULL,
    [DateHired]    DATE         NOT NULL,
    [DateFired]    DATE         NOT NULL,
    PRIMARY KEY CLUSTERED ([EmployeeId] ASC),
    FOREIGN KEY ([EmployeePositionId]) REFERENCES [Master].[EmployeePositions] ([EmployeePositionId])
);

