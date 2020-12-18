CREATE TABLE [Logs].[OperationRuns]
(
	[OperationRunId] INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_Logs_OperationRuns_OperationRunId PRIMARY KEY, 
    [OperationId] INT NULL CONSTRAINT FK_OperationRuns_Operations_OperationId FOREIGN KEY REFERENCES [Logs].[Operations](OperationId), 
    [CallingUser] VARCHAR(255) NULL, 
    [CallingProc] VARCHAR(255) NULL, 
    [StartTime] DATETIME NOT NULL, 
    [EndTime] DATETIME NULL , 
    [Status] VARCHAR(10) NOT NULL, 
    [AffectedRows] INT NULL, 
    [Message] VARCHAR(MAX) NULL
)
