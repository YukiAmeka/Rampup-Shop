CREATE TABLE [Logs].[Events]
(
	[EventId] INT NOT NULL IDENTITY CONSTRAINT PK_Logs_EventId PRIMARY KEY,
	[OperationRunId] INT NOT NULL CONSTRAINT FK_Events_OperationRuns_OperationRunId FOREIGN KEY REFERENCES [Logs].[OperationRuns](OperationRunId), 
    [CallingProc] VARCHAR(50) NULL,
    [Message] VARCHAR(MAX) NULL, 
    [DateTime] DATETIME NOT NULL,
)
