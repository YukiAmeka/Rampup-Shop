CREATE TABLE [Logs].[Operations]
(
	[OperationId] INT NOT NULL IDENTITY CONSTRAINT PK_Logs_OperationId PRIMARY KEY, 
    [Name] VARCHAR(50) NOT NULL, 
    [Description] VARCHAR(MAX) NULL
)
