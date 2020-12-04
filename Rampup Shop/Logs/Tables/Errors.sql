CREATE TABLE [Logs].[Errors]
(
	[ErrorId] INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_Logs_Errors_ErrorId PRIMARY KEY,
	[OperationRunId] INT NULL CONSTRAINT FK_Errors_OperationRuns_OperationRunId FOREIGN KEY REFERENCES [Logs].[OperationRuns](OperationRunId), 
    [Number] INT NULL, 
    [Severity] INT NULL, 
    [State] INT NULL, 
    [CallingProc] VARCHAR(255) NULL, 
    [Line] INT NULL, 
    [Message] NVARCHAR(MAX) NULL, 
    [DateTime] DATETIME NOT NULL,
)
