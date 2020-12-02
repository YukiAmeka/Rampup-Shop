CREATE TABLE [Logs].[Operations]
(
	[OperationId] INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_Logs_Operations_OperationId PRIMARY KEY, 
    [Name] VARCHAR(50) NOT NULL, 
    [Description] VARCHAR(MAX) NULL
)
