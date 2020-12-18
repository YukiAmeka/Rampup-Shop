CREATE TABLE [Master].[Versions]
(
	[VersionId] INT NOT NULL IDENTITY(10000,10000) CONSTRAINT PK_Master_Versions_VersionId PRIMARY KEY,
	[OperationRunId] INT NOT NULL CONSTRAINT FK_Versions_OperationRuns_OperationRunId FOREIGN KEY REFERENCES [Logs].[OperationRuns](OperationRunId), 
    [VersionDate] DATE NOT NULL, 
    [VersionDetails] VARCHAR(MAX) NULL
)