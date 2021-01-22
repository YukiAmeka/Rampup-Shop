CREATE TABLE [Config].[UploadParameters]
(
	[UploadParameterId] INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_Config_UploadParameters_UploadParameterId PRIMARY KEY,
	[TargetTable] VARCHAR(255) NOT NULL, 
    [FileNameBeginning] VARCHAR(255) NOT NULL, 
    [SourceFilePath] VARCHAR(255) NOT NULL, 
    [ArchiveFilePath] VARCHAR(255) NOT NULL, 
    [FormatFilePath] VARCHAR(255) NOT NULL, 
    [FieldTerminator] VARCHAR(5) NOT NULL, 
    [RowTerminator] VARCHAR(5) NOT NULL
)
