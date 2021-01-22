CREATE TABLE [Config].[ImportFields]
(
	[ImportFieldId] INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_Config_ImportFields_ImportFieldId PRIMARY KEY, 
    [TargetTable] VARCHAR(255) NOT NULL, 
    [TargetFieldName] VARCHAR(255) NOT NULL, 
    [SourceFieldName] VARCHAR(255) NOT NULL,
)
