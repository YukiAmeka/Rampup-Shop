CREATE TABLE [Logs].[Errors]
(
	[ErrorId] INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_Logs_Errors_ErrorId PRIMARY KEY,
	[OperationRunId] INT NOT NULL CONSTRAINT FK_Errors_OperationRuns_OperationRunId FOREIGN KEY REFERENCES [Logs].[OperationRuns](OperationRunId), 
    [Number] INT NULL, 
    [Severity] TINYINT NOT NULL, 
    [State] TINYINT NOT NULL, 
    [CallingProc] VARCHAR(100) NULL, 
    [Line] INT NOT NULL, 
    [Message] VARCHAR(MAX) NOT NULL, 
    [DateTime] DATETIME NOT NULL,
)
