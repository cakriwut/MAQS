USE [MAQSPerform]
GO

/****** Object:  Table [dbo].[Timer]    Script Date: 1/27/2017 8:39:08 AM ******/
/******  NOTE:  This must be run LAST, as it is the center of all the normalizing tables ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Timer](
	[Timer_ID] [uniqueidentifier] NOT NULL,
	[Context_ID] [uniqueidentifier] NOT NULL,
	[Configuration_ID] [uniqueidentifier] NOT NULL,
	[Test_ID] [uniqueidentifier] NOT NULL,
	[TimerName_ID] [uniqueidentifier] NOT NULL,
	[StartTime] [datetime] NOT NULL,
	[EndTime] [datetime] NOT NULL,
	[Duration] [bigint] NULL,
 CONSTRAINT [PK_Timer] PRIMARY KEY CLUSTERED 
(
	[Timer_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Timer]  WITH CHECK ADD  CONSTRAINT [FK_Timer_Configuration] FOREIGN KEY([Configuration_ID])
REFERENCES [dbo].[Configuration] ([Configuration_ID])
GO

ALTER TABLE [dbo].[Timer] CHECK CONSTRAINT [FK_Timer_Configuration]
GO

ALTER TABLE [dbo].[Timer]  WITH CHECK ADD  CONSTRAINT [FK_Timer_Context] FOREIGN KEY([Context_ID])
REFERENCES [dbo].[Context] ([Context_ID])
GO

ALTER TABLE [dbo].[Timer] CHECK CONSTRAINT [FK_Timer_Context]
GO

ALTER TABLE [dbo].[Timer]  WITH CHECK ADD  CONSTRAINT [FK_Timer_Name] FOREIGN KEY([TimerName_ID])
REFERENCES [dbo].[TimerName] ([TimerName_ID])
GO

ALTER TABLE [dbo].[Timer] CHECK CONSTRAINT [FK_Timer_Name]
GO

ALTER TABLE [dbo].[Timer]  WITH CHECK ADD  CONSTRAINT [FK_Timer_Test] FOREIGN KEY([Test_ID])
REFERENCES [dbo].[Test] ([Test_ID])
GO

ALTER TABLE [dbo].[Timer] CHECK CONSTRAINT [FK_Timer_Test]
GO


