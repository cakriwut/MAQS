USE [MAQSPerform]
GO

/****** Object:  Table [dbo].[Configuration]    Script Date: 1/27/2017 8:36:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Configuration](
	[Configuration_ID] [uniqueidentifier] NOT NULL,
	[App_Instance] [nvarchar](max) NULL,
	[DB_Instance] [nvarchar](max) NULL,
	[App_Version] [nvarchar](50) NULL,
	[Browser] [nchar](50) NULL,
	[Browser_OS] [nchar](50) NULL,
 CONSTRAINT [PK_Configuration] PRIMARY KEY CLUSTERED 
(
	[Configuration_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO


