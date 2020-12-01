CREATE TABLE [Logs].[Errors]
(
	[ErrorId] INT NOT NULL IDENTITY CONSTRAINT PK_Logs_ErrorId PRIMARY KEY,
	[OperationRunId] INT NOT NULL CONSTRAINT FK_Errors_OperationRuns_OperationRunId FOREIGN KEY REFERENCES [Logs].[OperationRuns](OperationRunId), 
    [Number] INT NULL, 
    [Severity] TINYINT NOT NULL, 
    [State] TINYINT NOT NULL, 
    [CallingProc] VARCHAR(MAX) NULL, 
    [Line] INT NOT NULL, 
    [Message] VARCHAR(MAX) NOT NULL, 
    [DateTime] DATETIME NOT NULL,
)
