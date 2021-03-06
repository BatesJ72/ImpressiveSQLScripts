--subquery with complex case statments


select	sub.*, (MostRecent_LienAmount-MostRecent_AuditedAmount) as LienAmount_AuditedAmount_Delta,
		Case
                    When stage like 'final%' or stage like 'closed' then 'Lien is final'
                    When MostRecent_AuditedAmount is null or MostRecent_LienAmount is null then 'NULL data'
                    When MostRecent_AuditedAmount=MostRecent_LienAmount then 'Amounts match'
                    When (MostRecent_LienAmount-MostRecent_AuditedAmount) > 2 then 'Continue fighting lien'
                    When (MostRecent_LienAmount-MostRecent_AuditedAmount) <= 2 then 'Accept all charges'
                    Else 'Look Into'
                    End As 'Accept Charges?'
from (
		select	CaseName, CaseId, FirmName, FirmId,
				ClientId, ClientSSN, ClientDOB, ClientSettlementAmount, FinalizedStatusId,
				FPV.CreatedOn, FPV.Id as LienId, FPV.LienType, LienProductStatus, FPV.Stage, 
				Case
					When FPV.Stage in ('To Send - Contested Response', 'Pending Internal Finalization', 'Related Claims Received/Pending Resolution of Other Liens', 'Researching Collector', 'To Send - Attorney Verification', 'To Send - Claims Request', 'To Send - Dispute', 'To Send - EV', 'To Send - Final Demand', 'Audited Claims Received/Pending QA', 'Claims Received', 'Claims Received/Pending Audit', 'Contested Claims Received', 'Initial No Entitlement', 'No Lien/Pending Settlement', 'To Send – Claims Request', 'To Send – Contested Response', 'To Send – Dispute ', 'To Send – EV ', 'To Send – Final Demand', 'To Send – Claims Request with Updated Injury Information', 'Under Review/Updated Information Received')
							then 'Ar Court'
					When FPV.Stage in ('Awaiting Sponsor/Facility Information', 'To Send - EV/Pending Injury Details', 'To Send - Final Settlement Details', 'Hold', 'Awaiting Information', 'Awaiting Consents', 'Awaiting Medical Records', 'Awaiting Documentation', 'Awaiting Consents', 'Awaiting Documents', 'Awaiting Information', 'Awaiting Medical Records', 'Claims Received/Pending Injury Details', 'Claims Received/Pending Settlement', 'To Send – Claims Request/Pending Settlement', 'To Send – Claims Request/Pending Surgeries', 'To Send – Dispute/Pending Settlement', 'To Send – EV/Pending Injury Details', 'To Send – EV/Pending Settlement')
							then 'Attorney/Firm Court'
					When FPV.Stage in ('Negotiating Reduction', 'Pending Contested Response', 'Pending Final Demand', 'Pending Final No Lien', 'Agreed Lien Received/Pending Timeframe Expiration', 'Claims Received/Pending Timeframe Expiration', 'Disputing Unrelateds', 'Entitlement Verification', 'Entitlement Verification/Pending Submission Confirmation', 'Pending Claims')
							then 'PLRP Agency Court'
					Else 'Other'
					End as 'Whose Court?',
				ClosedReason, UserName, OnBenefits, OnBenefitsVerified,
				LienholderName, LienholderId, CollectorName, CollectorId, SubmittedToPLRPDate, PLRPTimeframeExpirationDate, 
				Case
					When CollectorId = 227 then 'Ra'
					When CollectorId = 1867 or CollectorName like 'Hi' then 'Hi'
					When CollectorId = 1866 then 'Eq'
					When CollectorId = 117 then 'Hu'
					When CollectorId = 1868 then 'Be'
					When CollectorId = 1625 then 'MS'
					When CollectorId = 1988 then 'HH'
					Else 'Look Into'
					End as Collector_Agency,
				coalesce(AuditedAmount4, AuditedAmount3, AuditedAmount2, AuditedAmount1) as MostRecent_AuditedAmount,
				coalesce(LienAmount4, LienAmount3, LienAmount2, LienAmount1) as MostRecent_LienAmount,
				Case 
					When FPV.stage in ('Agreed Lien Received/Pending Timeframe Expiration', 'Audited Claims Received/Pending QA', 'Awaiting Consents', 'Awaiting Documents', 'Awaiting Information', 'Awaiting Medical Records', 'Claims Received', 'Claims Received/Pending Audit', 'Claims Received/Pending Injury Details', 'Claims Received/Pending Settlement', 'Claims Received/Pending Timeframe Expiration', 'Contested Claims Received', 'Disputing Unrelateds', 'Entitlement Verification', 'Entitlement Verification/Pending Submission Confirmation', 'Initial No Entitlement', 'No Lien/Pending Settlement', 'Pending Claims', 'To Send – Claims Request', 'To Send – Claims Request with Updated Injury Information', 'To Send – Claims Request/Pending Settlement', 'To Send – Claims Request/Pending Surgeries', 'To Send – Contested Response', 'To Send – Dispute', 'To Send – Dispute/Pending Settlement', 'To Send – EV', 'To Send – EV/Pending Injury Details', 'To Send – EV/Pending Settlement', 'To Send – Final Demand', 'To Send – Final Settlement Details', 'Under Review/Updated Information Received')
							Then 'Concerning Stage'
					Else 'Not Concerning Stage'
					End as 'Concerning Stage?',
				LST.ChangeDate as StageChangeDate, datediff(DAY, LST.ChangeDate, GetDate()) as DaysInStage,
				P.Phase, P.Phase_Sequence
		from	FullProductViews as FPV
					LEFT OUTER JOIN LienStageTracker as LST on LST.LienId = FPV.Id
					LEFT OUTER JOIN input_phase_stage_sequence as P on P.Stage = FPV.Stage
		where	casename like '%pic%' and FPV.lientype like '%plrp%'
	) as sub
