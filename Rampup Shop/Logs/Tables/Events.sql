CREATE TABLE [Logs].[Events]
(
	[EventId] INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_Logs_Events_EventId PRIMARY KEY,
	[OperationRunId] INT NOT NULL CONSTRAINT FK_Events_OperationRuns_OperationRunId FOREIGN KEY REFERENCES [Logs].[OperationRuns](OperationRunId), 
    [CallingProc] VARCHAR(100) NULL,
    [Message] VARCHAR(MAX) NULL, 
    [DateTime] DATETIME NOT NULL,
)
