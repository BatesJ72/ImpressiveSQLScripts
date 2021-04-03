--Freshdesk

USE [S3Reporting]
GO
/****** Object:  StoredProcedure [dbo].[JB_FreshDesk]    Script Date: 8/21/2019 9:43:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







ALTER procedure [dbo].[JB_FreshDesk]
AS

set nocount on


-- Create temp table to get data from freshdesk with true due date
select	freshdesk.*, 
		case 
			when [due date] is not null 
			then [due date] 
			else [Due By] 
			end as 'True Due Date',
		ROW_NUMBER ( )   OVER (partition by [ticket number] order by [ticket number], [updated on] asc) as Row#
Into	#JB_FD
from	freshdesk





--Create temp table to get max udpated on date
select		distinct [Ticket Number], max([Updated On]) as MaxDate
into		#JB_FD_MaxUpdated
from		freshdesk
group by	[Ticket Number], [Assigned To], [Created On], [Status], [Priority], [Due By], [Due Date], [Resolved Time], [Requester Team], [Requester], [Plaintiff Lawfirm],
			[Defendant], [Agency/Collector], [Category], [Detail], [Subject], [Type], [Completion Time Frame], [Processing Time], [Updated On], [Group]



--Create temp table to get max row #

select	[Ticket Number], max(Row#) as 'MaxRow'
into	#JB_FD_MaxRow2
from	#JB_FD
group by [ticket number]




--Join of all tables

select	distinct #JB_FD.[Ticket Number], #JB_FD.[Assigned To], #JB_FD.[Created On], #JB_FD.[Status], #JB_FD.[Priority], #JB_FD.[True Due Date], #JB_FD.[Resolved Time], #JB_FD.[Requester Team], #JB_FD.[Requester], #JB_FD.[Plaintiff Lawfirm],
		#JB_FD.[Defendant], #JB_FD.[Agency/Collector], #JB_FD.[Category], #JB_FD.[Detail], #JB_FD.[Subject], #JB_FD.[Type], #JB_FD.[Completion Time Frame], #JB_FD.[Processing Time], 
		Case
			When #JB_FD.[Processing Time] = 'Less than 1 hour' then 0.5
			When #JB_FD.[Processing Time] = '1-4 hours' then 2.5
			When #JB_FD.[Processing Time] = '4-8 hours' then 6
			When #JB_FD.[Processing Time] = 'More than 8 hours' then 10
			Else 0
			End as 'Avg Processing Time Required',
		#JB_FD.[Updated On], #JB_FD.[Group]

from	#JB_FD 
		Join #JB_FD_MaxUpdated on #JB_FD_MaxUpdated.[Ticket Number]=#JB_FD.[Ticket Number]
		Join #JB_FD_MaxRow2 on #JB_FD_MaxRow2.[Ticket Number]=#JB_FD.[Ticket Number] and #JB_FD_MaxRow2.MaxRow=#JB_FD.Row#
Order by #JB_FD.[Ticket Number] desc


