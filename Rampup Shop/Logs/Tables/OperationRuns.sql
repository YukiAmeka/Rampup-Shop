CREATE TABLE [Logs].[OperationRuns]
(
	[OperationRunId] INT NOT NULL IDENTITY CONSTRAINT PK_Logs_OperationRunId PRIMARY KEY, 
    [OperationId] INT NULL CONSTRAINT FK_OperationRuns_Operations_OperationId FOREIGN KEY REFERENCES [Logs].[Operations](OperationId), 
    [CallingUser] VARCHAR(50) NULL, 
    [CallingProc] VARCHAR(50) NULL, 
    [StartTime] DATETIME NOT NULL, 
    [EndTime] DATETIME NULL , 
    [Status] VARCHAR(10) NOT NULL, 
    [AffectedRows] INT NULL, 
    [Message] VARCHAR(MAX) NULL
)
