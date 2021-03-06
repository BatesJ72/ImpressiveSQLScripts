--HB Report

--1a. Update JB_HBReport_AddLienData to have appropriate CaseId (2505)
--1b. Download an extended claim search extract from COL 
--1c. Modify and import the most recent CSR 
--1d. Update a new JB_JGHB_Research if needed


--2. Import data into SQL: 
drop table JB_JGHB_Case_Current
drop table JB_JGHB_Obligation_Current
drop table JB_JGHB_Case_Prev

drop table JB_JGHB_COLData

drop table JB_JGHB_CSR



select count(*) from JB_JGHB_Case_Current
select count(*) from JB_JGHB_Obligation_Current
select count(*) from JB_JGHB_Case_Prev

select count(*) from JB_JGHB_COLData
select count(*) from JB_JGHB_CSR



select * from JB_JGHB_Case_Current



--3. Run query to combine [dbo].[JB_GHB_Case_Current] and [dbo].[JB_GHB_Case_Prev]. Also renames these two tables and G column headers. 

	--Source tables
		select * from JB_GHB_Case_Current
		select * from JB_GHB_Case_Prev


	--Query to analyze G's data
			
			drop table #Case_Updated

			

			
		Select	sub.*, 
				Case
					When [G Overall Lien Status ok?] like 'Issue%' then 'Issue - notify G and do not process'
					When [G Overall Lien HB ok?] like 'Issue%' then 'Issue - notify G and do not process'
					When [G Overall Lien Status ok?] like 'G Internal Issue (system hold)%' then 'G Internal Issue - do not process'
					When [G Overall Lien Status ok?] = 'Look Into' then 'Fix before moving on'
					When [G Overall Lien HB ok?] = 'Look Into' then 'Fix before moving on'
					Else 'Move along - nothing to see here, son'
					End as 'QA on G Data'
		Into #Case_Updated
		From	(
				SELECT	Case_Current.[Client Name], Case_Current.[Settlement Name], Case_Current.[Case ID], Case_Current.[GID], Case_Current.[Last Name] as 'G Last Name', Case_Current.[First Name] as 'G First Name', 
						Case_Current.SSN as 'G SSN', Case_Current.[Final Award] 'G Allocation', Case_Current.[Overall Lien Status] as 'G Current Overall Status', Case_Prev.[Overall Lien Status] as 'G Prev Overall Status',
						Case
							When Case_Current.[Overall Lien Status] = Case_Prev.[Overall Lien Status] then 'Good - no change'
							When Case_Current.[Overall Lien Status] = 'Complete' and  Case_Prev.[Overall Lien Status] = 'Pending' then 'Good - newly final'
							When Case_Current.[Overall Lien Status] = 'Satisfied' and  Case_Prev.[Overall Lien Status] = 'Pending' then 'Good - newly final'
							When Case_Current.[Overall Lien Status] = 'Pending' and  Case_Prev.[Overall Lien Status] <> 'Pending' then 'Issue - was final, now pending'
							When Case_Current.[Overall Lien Status] = 'System Hold' and Case_Prev.[Overall Lien Status] = 'Pending' then 'G Internal Issue (system hold) - do not process'
							When Case_Current.[Overall Lien Status] = 'System Hold' and Case_Prev.[Overall Lien Status] <> 'Pending' then 'Issue - G Internal Issue (system hold) - but was previously final'
							When Case_Prev.[Overall Lien Status] is null then 'Good - not on previous report'
							When Case_Current.[Overall Lien Status] = 'Complete' and  Case_Prev.[Overall Lien Status] = 'Satisfied' then 'Good - no change'
							When Case_Current.[Overall Lien Status] = 'Satisfied' and  Case_Prev.[Overall Lien Status] = 'Complete' then 'Good - no change'
							Else 'Look Into'
							End as 'G Overall Lien Status ok?',
						Case_Current.[Overall Lien Holdback] as 'G Current Overall Holdback', Case_Prev.[Overall Lien Holdback] as 'G Prev Overall Holdback',
						Case
							When Case_Current.[Overall Lien Holdback] = Case_Prev.[Overall Lien Holdback] then 'Good - no change'
							When Case_Current.[Overall Lien Status] = 'Pending' then 'Good - pending claimant'
							When Case_Current.[Overall Lien Status] = 'Satisfied' and  Case_Prev.[Overall Lien Status] = 'Pending' then 'Good - newly final'
							When Case_Current.[Overall Lien Status] = 'Complete' and  Case_Prev.[Overall Lien Status] = 'Pending' then 'Good - newly final'
							When Case_Current.[Overall Lien Holdback] <> Case_Prev.[Overall Lien Holdback] then 'Issue - HB amount changed for final claimant'
							When Case_Prev.[Overall Lien Holdback] is null then 'Good - not on previous report'
							Else 'Look Into'
							End as 'G Overall Lien HB ok?',
						Case_Prev.[Fee Holdback]

				FROM	JB_JGHB_Case_Current as Case_Current 
							LEFT OUTER JOIN JB_JGHB_Case_Prev as Case_Prev ON Case_Current.GID = Case_Prev.GID
				) as sub



		--Check data
			Select * From #Case_Updated

			Select * From #Case_Updated where [QA on G Data] not like 'move along%'




--4. Combine and analyze G, COL, and S3 claimant data
		
		--Source tables
			select * from #Case_Updated
			select * from JB_HBReport_AddClientData
			select * from JB_GHB_COLData


		--Run Query to combine the G Table (#Case_Updated) and SLAM data (the view updated in step 1)
		
			drop table #Updated_Claimant_Data



			Select	distinct sub2.*, 
					Case
						When sub2.[SLAM Case Analysis] = 'Ignore - not an EIF claimant' then 'No Update - Not EIF'

						When sub2.[Claimant in SLAM Case?] like 'Issue%' then 'Fix in SLAM (if possible) - Issue with identifying claimant in SLAM'
						When sub2.[Claim Number] is null then 'Issue identifying claimant in COL'
												
						when sub2.[SLAM Case Analysis] = 'Notify G - Withdrawn in COL' then 'Notify G - Withdrawn in COL'
						when sub2.[SLAM Case Analysis] = 'Fix SLAM - In inactive case but not withdrawn in COL' then 'Fix SLAM - In inactive case but not withdrawn in COL'
																		
						When sub2.[SA Match?] = 'Look Into' or sub2.[SLAM Case Analysis] = 'Look Into' or sub2.[G Overall Lien Status ok?] = 'Look Into' or sub2.[Overall Status Match?] = 'Look Into' or sub2.[G Overall Lien HB ok?] = 'Look Into' or sub2.[QA on G Data] = 'Look Into' then 'Look Into - Unknown Issue'
						
						When sub2.[SA Match?] like 'Issue%' then 'Do not process - notify CM - allocation mismatch'
						When sub2.[SSN Match?] like 'Issue%' then 'Do not process - notify CM - SSN mismatch'
						
						When sub2.[G Overall Lien Status ok?] like 'Issue%' then 'Do not process - notify G - G data is inconsistent'
						When sub2.[Overall Status Match?] like 'Issue%' then 'Do not process - notify G - G data is inconsistent'
						When sub2.[G Overall Lien HB ok?] like 'Issue%' then 'Do not process - notify G - G data is inconsistent'
						When sub2.[QA on G Data] not like 'move along%' then 'Do not process - notify G - G data is inconsistent'
						When sub2.[G Overall Lien Status ok?] like 'G Internal Issue (system hold) - do not process' then 'Do not process - G internal issue'
						
						When sub2.[#Issue] is not null and sub2.#Issue not like '%EIF%' then 'Look Into #Problems'

						Else 'Process as normal - no issues'
						End As 'Good to Process?'


			Into	#Updated_Claimant_Data
			From	(
					Select
						--Identification for Claimant
						sub.CaseId, 
						Case
							When sub.CaseId is null then 'Issue - can not find claimant'
							Else 'Good'
							End As 'Claimant in SLAM Case?',
						sub.[G Last Name], sub.[G First Name], sub.GID, 
						sub.[EIF ClientId], sub.GClaimantId, 
						sub.[COL Status], sub.[Claim Number],
						sub.[NonEIF ClientId], 
						Case
							When sub.[EIF ClientId] is null then 'Ignore - not an EIF claimant'
							When sub.[EIF ClientId] is null and sub.[COL Status] = 'Withdrawn' then 'Notify G - Withdrawn in COL'
							When sub.[EIF ClientId] is null and sub.[COL Status] <> 'Withdrawn' then 'Fix SLAM - In inactive case but not withdrawn in COL'
							When sub.[EIF ClientId] is not null then 'Good - in active case'
							Else 'Look Into'
							End as 'SLAM Case Analysis',

						--SSN
						sub.[G SSN], sub.[SLAM SSN], sub.[COL SSN],
						Case
							When sub.[G SSN] = sub.[SLAM SSN] and sub.[G SSN] = sub.[COL SSN] then 'Good - all SSNs match'
							When sub.[G SSN] <> sub.[SLAM SSN] then 'Issue - SSN mismatch - G and SLAM'
							When sub.[G SSN] <> sub.[COL SSN] then 'Issue - SSN mismatch - G and COL'
							When sub.[SLAM SSN] <> sub.[COL SSN] then 'Issue - SSN mismatch - SLAM and COL'
							Else 'Look Into'
							End As 'SSN Match?',	

						--SA
						sub.[G SA], sub.[SLAM SA], sub.[COL SA],
						Case
							When sub.[G SA] = sub.[SLAM SA] and sub.[COL SA] = sub.[SLAM SA] then 'Good - match'
							When sub.[G SA] <> sub.[SLAM SA] then 'Issue - SA mismatch - G and SLAM'
							When sub.[G SA] <> sub.[COL SA] then 'Issue - SA mismatch - G and COL'
							When sub.[SLAM SA] <> sub.[COL SA] then 'Issue - SA mismatch - SLAM and COL'
							Else 'Look Into'
							End As 'SA Match?',

						--Escrow
						convert(int,sub.[Resolved Escrow Balance]) as 'Resolved Escrow Balance', 
						sub.[Current Escrow],
																					
						--Checks on G Data
						Sub.[G Current Overall Status], sub.[G Overall Lien Status ok?],
						sub.PreExistingInjuries, sub.[G Liens Final in SLAM?], 
						Case
							When sub.[G Current Overall Status] = 'Complete' and sub.[G Liens Final in SLAM?] like 'Final%' then 'Good - final in both'
							When sub.[G Current Overall Status] = 'Satisfied' and sub.[G Liens Final in SLAM?] like 'Final%' then 'Good - final in both'
							When sub.[G Current Overall Status] = 'Complete' and sub.[G Liens Final in SLAM?] like 'Pending%' then 'Good - newly final'
							When sub.[G Current Overall Status] = 'Satisfied' and sub.[G Liens Final in SLAM?] like 'Pending%' then 'Good - newly final'
							When sub.[G Current Overall Status] = 'Pending' and sub.[G Liens Final in SLAM?] like 'Pending%' then 'Good - pending in both'
							When sub.[G Current Overall Status] = 'Pending' and sub.[G Liens Final in SLAM?] like 'Final%' then 'Issue - pending on report but final in SLAM'
							When sub.[G Current Overall Status] = 'System Hold' and sub.[G Liens Final in SLAM?] like 'Final%' then 'Issue - G Internal Issue (system hold) - but was previously final'
							When sub.[G Current Overall Status] = 'System Hold' and sub.[G Liens Final in SLAM?] like 'Pending%' then 'Issue - G Internal Issue (system hold) - but pending so just do not process'
							Else 'Look Into'
							End As 'Overall Status Match?',
						sub.[G Current Overall Holdback], sub.[G Overall Lien HB ok?], sub.[QA on G Data], sub.[Research on G Discrepancies], sub.#Issue

					From	(

								SELECT	
										--Identification for Claimant
										SLAM_EIF.CaseId, SLAM_EIF.[Client Id] as 'EIF ClientId', SLAM_EIF.AttorneyReferenceId, SLAM_EIF.GClaimantId, 
										SLAM_NonEIF.[Client Id] as 'NonEIF ClientId', 
										Case_Updated.[G Last Name], Case_Updated.[G First Name], Case_Updated.GID, 
										COL.[Claim Status] as 'COL Status', COL.[Claim Number], COL.[Attorney Last Name] as 'COL Attorney',
										
										--SSN
										Case_Updated.[G SSN], SLAM_EIF.SSN as 'SLAM SSN', COL.SSN as 'COL SSN',
										
										--SA
										Case_Updated.[G Allocation] as 'G SA', SLAM_EIF.[SettlementAmount] as 'SLAM SA', COL.[Actual Amount] as 'COL SA',

										--Escrow
										CSR.[Resolved Escrow Balance],
										Case
											When CSR.[Resolved Escrow Balance] is null then 'Prepayment'
											Else convert(varchar, CSR.[Resolved Escrow Balance])
											End As 'Current Escrow',
										
										--#Problems
										Prob.Issue as #Issue,
																					
										--G Data
										Case_Updated.[G Current Overall Status], Case_Updated.[G Current Overall Holdback],
										
										--Finalization Data
										SLAM_EIF.PreExistingInjuries, SLAM_EIF.[G Liens Final in SLAM?], 
										
										--Checks on G Data
										Case_Updated.[G Overall Lien Status ok?], Case_Updated.[G Overall Lien HB ok?], Case_Updated.[QA on G Data], Research.Notes as 'Research on G Discrepancies'
					 

								FROM	#Case_Updated as Case_Updated
											LEFT OUTER JOIN JB_JHBReport_AddClientData_JAMSGEIF as SLAM_EIF ON Case_Updated.[G SSN]= SLAM_EIF.[SSN]
																						--ON Case_Updated.[G SSN]= SLAM_EIF.[SSN] and Case_Updated.RId = SLAM_EIF.AttorneyReferenceId
											LEFT OUTER JOIN JB_JHBReport_AddClientData as SLAM_NonEIF ON Case_Updated.[GId] = SLAM_NonEIF.GClaimantId
											LEFT OUTER JOIN JB_JGHB_COLData as COL on COL.[Claim Number] = SLAM_EIF.ThirdPartyId
											LEFT OUTER JOIN JB_JGHB_CSR as CSR on CSR.[Claim #] = SLAM_EIF.ThirdPartyId
											LEFT OUTER JOIN JB_JGHB_Research as Research on Research.GClaimantId = Case_Updated.GId
											LEFT OUTER JOIN JB_AMSProblems_Summary as Prob on Prob.[Claim #]=SLAM_EIF.ThirdPartyId

							) as sub
					) as sub2





		
					
					
		--Get All Results. 
				--Note: If all the SLAM data columns are NULL, then there is a problem with the GClaimantIds.

				select * from #Updated_Claimant_Data order by [EIF ClientId]

				select * from #Updated_Claimant_Data where [Good to Process?] = 'Process as normal - no issues'


			--This query tells you the info for all claimants who have an issue. 
				--Copy/paste this into a new tab on your processed WIP file titled "Claimant Level Discrepancies". Make notes on the ones you look into: fix where you can, notify G when you should. 
				select * from #Updated_Claimant_Data 
				where [Good to Process?] <> 'Process as normal - no issues' 
				order by [Good to Process?], [G Last Name], [G First Name]
			
				select * 
				from #Updated_Claimant_Data 
				where [Good to Process?] <> 'Process as normal - no issues' and [Good to Process?] <> 'No Update - Not EIF' and [Research on G Discrepancies] is null
				order by [Good to Process?], [G Last Name], [G First Name]
			

				
					--Check data for claimants who aren't pulling in the query. 
						--Are they in the hold case? If so, check with the CM. Ask 'Do I move it to the active case or notify G that they're inactive?'
						--Is the GClaimantId updated in SLAM? If not, check that it's the same claimant (SSN, SA, etc.) and update SLAM. 
						--Does the SSN match? If not, check with CM to determine if it should be updated in SLAM or if you should notify G. 
					select * from #Updated_Claimant_Data 
					where [Good to Process?] = 'Fix in SLAM (if possible) - Issue with identifying claimant in SLAM' 
					order by [G Last Name], [G First Name]


					--Potential issues to point out to G
					select * from #Updated_Claimant_Data 
					where [Good to Process?] = 'Do not process - notify G - G data is inconsistent' 
					order by [G Last Name], [G First Name]



					--Alter table data for claimants who don't really have an issue
						UPDATE #Updated_Claimant_Data
						SET [QA on G Data] = 'Move along - nothing to see here, son', [Good to Process?] = 'Process as normal - no issues'
						WHERE [GID] = 'TVM026681'

			
				
--5. Combine the #Updated_Claimant_Data table with the G Lien Data

		--Source Data

			select * from JB_JGHB_Obligation_Current
			select * from #Updated_Claimant_Data


		--Run Query 
			

			drop table #Liens_G_Updated



			Select	Clients_Updated.*,
					Liens_G.[Lien Type], Liens_G.[Entitlement Wave Id], Liens_G.[Lienholder Full Name], Liens_G.[Entitlement Response], 
					Liens_G.[Protocol Name], Liens_G.[Max Protocol], Liens_G.[Claim Amt], Liens_G.[Final Lien Amt], Liens_G.[Allocated Amt], 
					Liens_G.[Lien Status]
			Into	#Liens_G_Updated
			From	JB_JGHB_Obligation_Current as Liens_G 
						JOIN #Updated_Claimant_Data as Clients_Updated ON Liens_G.GID = Clients_Updated.[GId]
			Where	[SLAM Case Analysis] <> 'Ignore - not an EIF claimant'

			
			
						

		--Get Results
			select * from #Liens_G_Updated




--6. Find EWIds that need to be fixed

		--Source tables
			select * from #Liens_G_Updated
			select * from JB_HBReport_AddLienData


		--Modify G table to drop empty columns
			select * from #Liens_G_Updated


			alter table #Liens_G_Updated drop column F20
			
		





		--Run query to create temp table used to find discrepancies in the EWIds

					drop table #Fix_EWIds



			select	Liens_G.[G Last Name], Liens_G.[G First Name], Liens_G.GID, Liens_G.[G SSN], Liens_G.[G SA], Liens_G.[EIF ClientId] as 'EIF Client Id (from G table)',	Liens_G.[NonEIF ClientId] as 'NonEIF Client Id (from G table)',
					Liens_SLAM.[ClientId] as 'EIF Client Id (from SLAM table)', 
					Liens_G.[Entitlement Wave Id] as 'G EWId',	Liens_SLAM.GLienId as 'SLAM EWId', 
					Case
						When Liens_G.[Entitlement Wave Id] = Liens_SLAM.GLienId then 'Match'
						Else 'Look into - mismatch'
						End As 'EWIds Match?',
					Liens_SLAM.[S3 Product Id], Liens_G.[Lien Type] as 'G LienType', Liens_SLAM.LienType as 'SLAM LienType',  
					Case
						When Liens_G.[Lien Type] = 'MedicareGlobal' and Liens_SLAM.LienType = 'Medicare - Global' then 'Match'
						When Liens_G.[Lien Type] = 'Tricare' and Liens_SLAM.LienType = 'Military Lien - MT' then 'Match'
						When Liens_G.[Lien Type] = 'IndianHealth' and Liens_SLAM.LienType = 'IHS Lien' then 'Match'
						When Liens_G.[Lien Type] = 'Medicaid' and Liens_SLAM.LienType = 'Medicaid Lien - MT' then 'Match'
						When Liens_G.[Lien Type] = 'PLRP' and Liens_SLAM.LienType like '%PLRP%' then 'Match'
						When Liens_G.[Lien Type] = 'PrivateSELR' and Liens_SLAM.LienType = 'Private Lien - MT' then 'Match'
						When Liens_G.[Lien Type] = 'PrivateSELR' and Liens_SLAM.LienType = 'Medicare Lien - Part C' then 'Match'
						When Liens_G.[Lien Type] = 'VeteransAdministration' and Liens_SLAM.LienType = 'Military Lien - MT' then 'Match'
						Else 'Look into - mismatch'
						End As 'Lien Types Match?',
					Liens_G.[Lienholder Full Name] as 'G Lienholder', Liens_SLAM.LienHolderName as 'SLAM Lienholder',
					Liens_G.[Lien Status] as 'G Lien Status', Liens_SLAM.[AssignedUserId], Liens_SLAM.Stage, Liens_SLAM.ClosedReason, Liens_SLAM.ClientFirstName, Liens_SLAM.ClientLastName,
						[QA on G Data], [Good to Process?], [Current Escrow], [Final Lien Amt]

			into	#Fix_EWIds
			from	#Liens_G_Updated as Liens_G
						LEFT OUTER JOIN JB_JHBReport_AddLienData as Liens_SLAM on Liens_G.[GID] = Liens_SLAM.GClaimantId and Liens_G.[Entitlement Wave ID] = Liens_SLAM.GLienId
			where [SLAM Case Analysis] <> 'Ignore - not an EIF claimant'





		--Use temp table #Fix_EWIds to find liens that need fixin

			--All Data
				select	* 
				from	#Fix_EWIds

				
			--Find liens where EWId matches (does this match the total # of liens on the report? If so, you're good!)
				--Note: If the numbers don't match, filter out the liens with a status of "Matched by Rawlings Company; See PLRP Liens" on the HB Report. Do the numbers match now?
				select	* 
				from	#Fix_EWIds
				where	[G EWId] = [SLAM EWId]


			--Find liens in SLAM that are not on the report
				select	* 
				from	#Fix_EWIds 
				where	[EIF Client Id (from G table)] is null and [EIF Client Id (from SLAM table)] is not null-- and (ClosedReason <> 'Opened in Error' or ClosedReason is null)
				order by ClientLastName


				select	Liens_SLAM.ClientId, Liens_SLAM.GClaimantId, Liens_SLAM.ClientFirstName, Liens_SLAM.ClientLastName, 
						Liens_SLAM.[S3 Product Id], Liens_SLAM.GLienId,
						Liens_SLAM.LienType as SLAM_LienType, Liens_SLAM.LienholderName as SLAM_Lienholder, Liens_SLAM.LienProductStatus, Liens_SLAM.Stage
				from	JB_JHBReport_AddLienData as Liens_SLAM
							LEFT OUTER JOIN #Liens_G_Updated as Liens_G on Liens_G.[GID] = Liens_SLAM.GClaimantId
				where	Liens_SLAM.GLienId is null
						and Liens_G.[Good to Process?] = 'Process as normal - no issues'
						and (Liens_SLAM.LienType = 'Medicare - Global' or Liens_SLAM.LienType = 'Medicaid Lien - MT' or Liens_SLAM.LienType like 'Military%' or Liens_SLAM.LienType like 'ihs%')
						and Liens_SLAM.Stage <> 'Closed' and Liens_SLAM.ClosedReason not like 'Opened in Error' and Liens_SLAM.ClosedReason not like 'Per att%'
				order by 1,4


				
				
				select FullProductViews.id as LienId, FullProductViews.GLienId, FullProductViews.GClaimantId, FullProductViews.ClientId, FullProductViews.ClientFirstName, FullProductViews.ClientLastName, 
						FullProductViews.LienType, FullProductViews.LienholderName, FullProductViews.CollectorName, FullProductViews.Stage, FullProductViews.ClosedReason, FullProductViews.LienProductStatus, 
						FullProductViews.FinalizedStatusId
				from FullProductViews
						Left Join #Updated_Claimant_Data on #Updated_Claimant_Data.[EIF ClientId]=FullProductViews.ClientId
				where FullProductViews.GLienId is null and FullProductViews.GClaimantId is not null and FullProductViews.caseid = 2505
						and #Updated_Claimant_Data.[Good to Process?] = 'Process as normal - no issues' 
						and (FullProductViews.LienType = 'Medicare - Global' or FullProductViews.LienType = 'Medicaid Lien - MT' or FullProductViews.LienType like 'Military%' or FullProductViews.LienType like 'ihs%')
						and closedreason is null and stage not like 'final%'
				order by  FullProductViews.ClientFirstName, FullProductViews.ClientLastName
						

				

			--Find liens on the report that are not in SLAM
			
				select	[G Last Name], [G First Name], [GID], [G SA], [G SSN], [EIF Client Id (from G table)], [G EWId], [G LienType], [G Lienholder], [G Lien Status], [final lien amt], [QA on G Data], 
						[Good to Process?], [Current Escrow]
				from	#Fix_EWIds 
				where	[EIF Client Id (from SLAM table)] is null and [EIF Client Id (from G table)] is not null and [G Lien Status] <> 'Matched by Rawlings Company; See PLRP Liens'
				Order by [Good to Process?], [G Last Name], [G First Name]

			

				
			--Find liens on the report where the EWId is null in SLAM 
				select	*
				from	#Fix_EWIds
				where	[SLAM EWId] is null and [G Lien Status] not like 'Matched by Rawlings Company; See PLRP Liens'
				Order by [Good to Process?], [G Last Name], [G First Name]




--7. Update Liens in SLAM to match G HB Report

		--Source tables

			select * from #Liens_G_Updated
			select * from JB_JHBReport_AddLienData
			select * from JB_HBReport_AddLienData_JAMSGnonEIF

			select distinct [Entitlement Response], [Lien Status] from #Liens_G_Updated


		--Run query to combine and compare G and SLAM lien level data
		
				
		Select	
				--claimant identification
				sub.[G Last Name], sub.[G First Name], sub.[GId], 
				Sub.[Client Id (from G table)], sub.[EIF Client Id (from SLAM table)], sub.[NonEIF Client Id (from SLAM table)], 
				
				--EIF data
				sub.[SLAM Case Analysis], sub.[SLAM EIF ClientId], sub.[EIF Claimant?],
				
				--COL data
				sub.[Claim Number], sub.[COL Status], sub.[Resolved Escrow Balance], sub.[Current Escrow],
		
				--Claimant data checks
				sub.[G SSN], sub.[SSN Match?], sub.[G SA], sub.[SA Match?], 
				sub.[G Current Overall Status], sub.[G Overall Lien Status ok?], sub.[Overall Status Match?], sub.[G Overall Lien HB ok?], sub.[QA on G Data], sub.[Good to Process?], 
				sub.[Research on G Discrepancies], sub.#Issue,

				--Lien Data
				sub.[G EWId], sub.[SLAM EWId], sub.[EWId Match?], 
				sub.[G Lientype], sub.[SLAM Lientype], sub.[LienTypes Match?], 
				sub.[G Lienholder], sub.[SLAM Lienholder], sub.[Lienholder Match?], 
				sub.[G Onbenefits], sub.[SLAM OnBenefits], sub.[OnBenefits Match?], 
				sub.[Final Lien Amt], sub.[Allocated Amt], sub.[G Amounts Match?], 
				
				sub.[EIF FD], sub.[EIF Final Global], sub.[EIF Total Global], sub.[EIF True SLAM FD], 
				sub.[Non EIF FD], sub.[Non EIF Final Global], sub.[Non EIF Total Global], sub.[Non EIF True SLAM FD], 
				sum(sub.[EIF True SLAM FD]+sub.[Non EIF True SLAM FD]) as 'Combined EIF and Non EIF FD',
				'Non EIF True FD Check', 'EIF True FD Check', 'Combined Check', 'Globals Check',

				Case
					When [G Amounts Match?] <> 'Match' then 'Issue with G lien amounts'
					When [SLAM Stage] = 'Awaiting Information' and ([G Lien Status] = 'Waived' or [G Lien Status] = 'Eligible for Payment' or [G Lien Status] = 'Satisfied' or [G Lien Status] = 'Paid' or [G Lien Status] = 'Requested' or [G Lien Status] = 'Received') then 'Ok - newly final'
					When [EIF True SLAM FD]=[Allocated Amt] then 'Match'
					When [EIF True SLAM FD] is null and [Allocated Amt] = 0 then 'Match'
					When [EIF True SLAM FD] is null and [Allocated Amt] is null then 'Match'
					When [EIF True SLAM FD] = 0 and [Allocated Amt] is null then 'Match'
					When [EIF True SLAM FD]<>[Allocated Amt] then 'Mismatch'
					Else 'Look Into'
					End As 'FD Match?',
				sub.[AssignedUserId], 
				sub.[G Stage and Entitlement Match?], 
				sub.[G Lien Status], 
				sub.[SLAM LienProductStatus], sub.[SLAM Stage], sub.[SLAM ClosedReason], 
				sub.[Stage Comparison], sub.NewLienNote, sub.[S3 Product Id], 
								
				Case
				--Major issues
					When [Good to Process?] = 'Ignore - EIF claimant' then 'Ignore - EIF claimant'
					When [Good to Process?] = 'Do not process - notify G - G data is inconsistent' then 'Do not process - notify G - G data is inconsistent'
					When [Good to Process?] like '%SSN mismatch%' then 'Do not process - notify G - SSN Mismatch'
					When [Good to Process?] like '%SA mismatch%' then 'Do not process - notify G - SA Mismatch'
					When [Stage Comparison] = 'Issue - G changed final demand amount on final lien' then 'Issue - G changed final demand amount on final lien'
					When [Stage Comparison] = 'Ignore - not a valid lien and does not exist in SLAM' then 'Ignore - not a valid lien and does not exist in SLAM'
					When [Stage Comparison] = 'Ignore - not a valid lien and final/closed in SLAM' then 'Ignore - not a valid lien and final/closed in SLAM'
					When [Stage Comparison] = 'Update to FNL in SLAM - not a valid lien' then 'Update to FNL in SLAM - not a valid lien'
					When [Good to Process?] = 'Fix in SLAM (if possible) - Issue with identifying claimant in SLAM' then 'Fix in SLAM (if possible) - Issue with identifying claimant in SLAM'
					When [G Amounts Match?] = 'Look Into' then 'Issue - G lien amount does not match SLAM'
					When [G Stage and Entitlement Match?] like 'Look Into' then 'Issue - G data is inconsistent (on benefits and stage)'
					When [G Status/Amount ok?] like 'Look Into' then 'Issue - G data is inconsistent (waived/discharged)'
					When [Stage Comparison] like 'Look into - SLAM is NULL' then 'Look into - SLAM data is NULL'
					When [OnBenefits Match?] like 'Issue - lien was final and is now pending' then 'Look into - lien was unfinalized by G'
					When [Stage Comparison] = 'Look Into - probably a G claimant finalization/pending liens issue' then  'Look Into - probably a G claimant finalization/pending liens issue'

				--Minor things
					When [Client Id (from SLAM table)] is NULL then 'Fix EWId'
					When [EWId Match?] is NULL or [EWId Match?] like 'Issue%' or [EWId Match?] = 'Look Into' then 'Fix EWId'
					When [LienTypes Match?] = 'SLAM is NULL' or [LienTypes Match?] = 'Look Into' then 'Fix Lientype'
					When [OnBenefits Match?] = 'Look Into' then 'Look into on benefits'
					When [OnBenefits Match?] like 'Issue%' then 'Issue with on benefits'
					When TotalGlobalAmount is not null then 'Look Into - Total Global is not null'
					When [Stage Comparison] like 'Issue%' then 'Look into - lien level issue'
					When [Stage Comparison] like 'Look Into - Probably at Initial No Entitlement because not final on report' then 'Look Into - Probably at Initial No Entitlement because not final on report'
					When [AssignedUserId] <> 141 then 'Fix assigned user in SLAM'
					When [Stage Comparison] like 'Look into - SLAM status of hold' then 'Look into - SLAM status of hold'
					When sub.[G Lien Status] = 'Discharged' and ([SLAM OnBenefits] is null or [SLAM OnBenefits] = '') then 'Update on benefits'
					When sub.[G Lien Status] = 'Discharged' and [SLAM Stage] like 'Awaiting%' then 'Normal Update'
					When [Stage Comparison] like 'Note%' or [Stage Comparison] like 'Update%' then 'Normal Update'
					When sub.[G Lien Status] = 'Discharged' and sub.[Final Lien Amt] is null and (sub.[EIF True SLAM FD] is null or sub.[EIF True SLAM FD] = 0) and (sub.[SLAM Stage] = 'Closed' or sub.[SLAM Stage] like 'final%') then 'Note only'
					
					Else 'Look Into'
					End As 'Action Needed'




		From	(	
				select	
					--All claimant level data
						Liens_G.[G Last Name], Liens_G.[G First Name], Liens_G.[GId], Liens_G.[Client Id] as 'Client Id (from G table)', 
						Liens_SLAM.[ClientId] as 'EIF Client Id (from SLAM table)', Liens_SLAM_NonEIF.[ClientId] as 'NonEIF Client Id (from SLAM table)',
						Liens_G.[SLAM Case Analysis],	Liens_G.[SLAM EIF ClientId], Liens_G.[EIF Claimant?],
						Liens_G.[G SSN], Liens_G.[SSN Match?], Liens_G.[G SA], Liens_G.[SA Match?], 
						Liens_G.[G Current Overall Status], Liens_G.[G Overall Lien Status ok?], Liens_G.[Overall Status Match?], Liens_G.[G Overall Lien HB ok?],Liens_G.[QA on G Data],Liens_G.[Good to Process?],
						Liens_G.[Claim Number], Liens_G.[COL Status], Liens_G.[Resolved Escrow Balance], Liens_G.[Current Escrow],
						Liens_G.[Research on G Discrepancies], Liens_G.#Issue,
											
					--Lien data
						[Entitlement Wave ID] as 'G EWId', Liens_SLAM.GLienId as 'EIF SLAM EWId', Liens_SLAM_NonEIF.GLienId as 'NonEIF SLAM EWId', 
						Case
							When [Lien Status] = 'Matched by Rawlings Company; See PLRP Liens' and [Allocated Amt] is null and [Lien Type] = 'PLRP' then 'Ignore - not a valid lien'
							When [Entitlement Wave ID] = Liens_SLAM.GLienId and [Entitlement Wave ID] = Liens_SLAM_NonEIF.GLienId then 'All 3 Match'
							When Liens_SLAM.GLienId is null then 'NULL in SLAM'
							When Liens_SLAM.GLienId <> [Entitlement Wave ID] or [Entitlement Wave ID] <> Liens_SLAM_NonEIF.GLienId then 'Issue - EWId mismatch'
							Else 'Look into'
							End as 'EWId Match?',
						[Lien Type] as 'G Lientype', Liens_SLAM.LienType as 'EIF SLAM Lientype', Liens_SLAM_NonEIF.LienType as 'NonEIF SLAM Lientype',
						Case
							When [Lien Status] = 'Matched by Rawlings Company; See PLRP Liens' and [Allocated Amt] is null and [Lien Type] = 'PLRP' then 'Ignore - not a valid lien'
							When [Lien Type] = 'MedicareGlobal' and Liens_SLAM.LienType = 'Medicare - Global' then 'Match'
							When [Lien Type] = 'Medicaid' and Liens_SLAM.LienType = 'Medicaid Lien - MT' then 'Match'
							When [Lien Type] = 'PrivateSELR' and Liens_SLAM.LienType = 'Private Lien - MT' then 'Match'
							When [Lien Type] = 'PLRP' and Liens_SLAM.LienType like '%plrp%' then 'Match'
							When [Lien Type] = 'IndianHealth' and Liens_SLAM.LienType = 'IHS Lien' then 'Match'
							When [Lien Type] = 'Tricare' and Liens_SLAM.LienType = 'Military Lien - MT' then 'Match'
							When Liens_G.[Lien Type] = 'PrivateSELR' and Liens_SLAM.LienType = 'Medicare Lien - Part C' then 'Match'
							When [Lien Type] = 'VeteransAdministration' and Liens_SLAM.LienType = 'Military Lien - MT' then 'Match'
							When [Lien Type] = 'External' and Liens_SLAM.LienType = 'Military Lien - MT' then 'Match'
							When Liens_SLAM.LienType is null then 'SLAM is NULL'
							Else 'Look Into'
							End as 'EIF LienTypes Match?',
							Case
							When [Lien Status] = 'Matched by Rawlings Company; See PLRP Liens' and [Allocated Amt] is null and [Lien Type] = 'PLRP' then 'Ignore - not a valid lien'
							When [Lien Type] = 'MedicareGlobal' and Liens_SLAM_NonEIF.LienType = 'Medicare - Global' then 'Match'
							When [Lien Type] = 'Medicaid' and Liens_SLAM_NonEIF.LienType = 'Medicaid Lien - MT' then 'Match'
							When [Lien Type] = 'PrivateSELR' and Liens_SLAM_NonEIF.LienType = 'Private Lien - MT' then 'Match'
							When [Lien Type] = 'PLRP' and Liens_SLAM_NonEIF.LienType like '%plrp%' then 'Match'
							When [Lien Type] = 'IndianHealth' and Liens_SLAM_NonEIF.LienType = 'IHS Lien' then 'Match'
							When [Lien Type] = 'Tricare' and Liens_SLAM_NonEIF.LienType = 'Military Lien - MT' then 'Match'
							When Liens_G.[Lien Type] = 'PrivateSELR' and Liens_SLAM_NonEIF.Liens_SLAM.LienType = 'Medicare Lien - Part C' then 'Match'
							When [Lien Type] = 'VeteransAdministration' and Liens_SLAM_NonEIF.LienType = 'Military Lien - MT' then 'Match'
							When [Lien Type] = 'External' and Liens_SLAM_NonEIF.LienType = 'Military Lien - MT' then 'Match'
							When Liens_SLAM_NonEIF.LienType is null then 'SLAM is NULL'
							Else 'Look Into'
							End as 'NonEIF LienTypes Match?',
						[Lienholder Full Name] as 'G Lienholder', Liens_SLAM.LienHolderName as 'EIF SLAM Lienholder', Liens_SLAM_NonEIF.LienHolderName as 'Non EIF SLAM Lienholder', 
						Case
							When Liens_SLAM.LienHolderName = Liens_SLAM_NonEIF.LienHolderName then 'SLAM EIF and Non EIF Match'
							When Liens_SLAM_NonEIF.LienHolderName is null then 'NonEIF is NULL'
							When Liens_SLAM.LienHolderName is null then 'EIF is NULL'
							When Liens_SLAM.LienHolderName <> Liens_SLAM_NonEIF.LienHolderName then 'Mismatch - SLAM EIF and Non EIF'
							Else 'Look Into'
							End As 'SLAM Match?',
						[Entitlement Response] as 'G Onbenefits', Liens_SLAM.OnBenefits as 'EIF SLAM OnBenefits', Liens_SLAM_NonEIF.OnBenefits as 'SLAM OnBenefits',
						Case
							When [Lien Status] = 'Matched by Rawlings Company; See PLRP Liens' and [Allocated Amt] is null and [Lien Type] = 'PLRP' then 'Ignore - not a valid lien'
							When Liens_SLAM.OnBenefits is null or Liens_SLAM.OnBenefits = '' then 'Ok - SLAM is NULL'
							When [Entitlement Response] = 'Y' and Liens_SLAM.OnBenefits = 'Yes' then 'Match'
							When [Entitlement Response] = 'W' and Liens_SLAM.OnBenefits = 'Yes' then 'Match'
							When [Entitlement Response] = 'N' and Liens_SLAM.OnBenefits = 'No' then 'Match'
							When [Entitlement Response] = 'No Match' and Liens_SLAM.OnBenefits = 'No' then 'Match'
							When [Entitlement Response] = 'No Match' and Liens_SLAM.OnBenefits = 'Yes' then 'Issue - Mismatch'
							When [Entitlement Response] = 'Y' and Liens_SLAM.OnBenefits = 'No' then 'Issue - Mismatch'
							When [Entitlement Response] = 'Pending' and Liens_SLAM.Stage = 'Awaiting Information' then 'Ok - mismatch but pending in SLAM'
							When [Entitlement Response] = 'Pending' and Liens_SLAM.Stage like 'Final%' then 'Issue - lien was final and is now pending'
							When [Entitlement Response] = 'D' and [Lien Status] = 'Discrepancy' and Liens_SLAM.Stage = 'Awaiting Information' then 'Ok - discrepancy status but at awaiting info in SLAM'
							When [Entitlement Response] = 'D' and [Lien Status] = 'Discrepancy' and Liens_SLAM.Stage <> 'Awaiting Information' then 'Issue - discrepancy status but not at awaiting info in SLAM'
							Else 'Look Into'
							End as 'EIF OnBenefits Match?',
						Case
							When [Lien Status] = 'Matched by Rawlings Company; See PLRP Liens' and [Allocated Amt] is null and [Lien Type] = 'PLRP' then 'Ignore - not a valid lien'
							When Liens_SLAM_NonEIF.OnBenefits is null or Liens_SLAM_NonEIF.OnBenefits = '' then 'Ok - SLAM is NULL'
							When [Entitlement Response] = 'Y' and Liens_SLAM_NonEIF.OnBenefits = 'Yes' then 'Match'
							When [Entitlement Response] = 'W' and Liens_SLAM_NonEIF.OnBenefits = 'Yes' then 'Match'
							When [Entitlement Response] = 'N' and Liens_SLAM_NonEIF.OnBenefits = 'No' then 'Match'
							When [Entitlement Response] = 'No Match' and Liens_SLAM_NonEIF.OnBenefits = 'No' then 'Match'
							When [Entitlement Response] = 'No Match' and Liens_SLAM_NonEIF.OnBenefits = 'Yes' then 'Issue - Mismatch'
							When [Entitlement Response] = 'Y' and Liens_SLAM_NonEIF.OnBenefits = 'No' then 'Issue - Mismatch'
							When [Entitlement Response] = 'Pending' and Liens_SLAM_NonEIF.Stage = 'Awaiting Information' then 'Ok - mismatch but pending in SLAM'
							When [Entitlement Response] = 'Pending' and Liens_SLAM_NonEIF.Stage like 'Final%' then 'Issue - lien was final and is now pending'
							When [Entitlement Response] = 'D' and [Lien Status] = 'Discrepancy' and Liens_SLAM_NonEIF.Stage = 'Awaiting Information' then 'Ok - discrepancy status but at awaiting info in SLAM'
							When [Entitlement Response] = 'D' and [Lien Status] = 'Discrepancy' and Liens_SLAM_NonEIF.Stage <> 'Awaiting Information' then 'Issue - discrepancy status but not at awaiting info in SLAM'
							Else 'Look Into'
							End as 'NonEIF OnBenefits Match?',
						
						[Final Lien Amt], [Allocated Amt], 
						Case
							When [Final Lien Amt] = [Allocated Amt] then 'Match'
							When [Final Lien Amt] is null and [Allocated Amt] is null then 'Match'
							Else 'Look Into'
							End As 'G Amounts Match?',

						Liens_SLAM.FinalDemandAmount as 'EIF FD', Liens_SLAM.FinalGlobalAmount as 'EIF Final Global', Liens_SLAM.TotalGlobalAmount as 'EIF Total Global', 
						Case
							When Liens_SLAM.LienType = 'Medicare - Global' and Liens_SLAM.FinalGlobalAmount is not null then Liens_SLAM.FinalGlobalAmount 
							When Liens_SLAM.LienType = 'Medicare - Global' and Liens_SLAM.FinalGlobalAmount is null then 0 
							
							When Liens_SLAM.LienType <> 'Medicare - Global' and Liens_SLAM.FinalDemandAmount is not null then Liens_SLAM.FinalDemandAmount
							When Liens_SLAM.LienType <> 'Medicare - Global' and Liens_SLAM.FinalDemandAmount is null then 0
							
							Else 0
							End As 'EIF True SLAM FD',
						Liens_SLAM_nonEIF.FinalDemandAmount as 'Non EIF FD', Liens_SLAM_nonEIF.FinalGlobalAmount as 'Non EIF Final Global', Liens_SLAM_nonEIF.TotalGlobalAmount as 'Non EIF Total Global',
						Case
							When Liens_SLAM_nonEIF.LienType = 'Medicare - Global' and Liens_SLAM_nonEIF.FinalGlobalAmount is not null then Liens_SLAM_nonEIF.FinalGlobalAmount
							When Liens_SLAM_nonEIF.LienType = 'Medicare - Global' and Liens_SLAM_nonEIF.FinalGlobalAmount is null then 0
							
							When Liens_SLAM_nonEIF.LienType <> 'Medicare - Global' and Liens_SLAM_nonEIF.FinalDemandAmount is not null then Liens_SLAM_nonEIF.FinalDemandAmount
							When Liens_SLAM_nonEIF.LienType <> 'Medicare - Global' and Liens_SLAM_nonEIF.FinalDemandAmount is null then 0
							
							Else 0
							End As 'Non EIF True SLAM FD',

						Liens_SLAM.AssignedUserId as 'EIF Assigned User Id', Liens_SLAM_NonEIF.AssignedUserId as 'NonEIF Assigned User Id',
						
						Case
							When [Lien Status] = 'Matched by Rawlings Company; See PLRP Liens' and [Allocated Amt] is null and [Lien Type] = 'PLRP' then 'Ignore - not a valid lien'
							When [Lien Status] = 'Discrepancy' and Stage = 'Awaiting Information' then 'Good - discrepancy status and at awaiting in SLAM'
							When [Lien Status] = 'Discrepancy' and Stage <> 'Awaiting Information' then 'Issue - discrepancy status but not awaiting in SLAM'
							When ([Entitlement Response] = 'N' or [Entitlement Response] = 'Not Entitled' or [Entitlement Response] = 'No Match') and ([Lien Status] = 'Not Entitled' or [Lien Status] = 'No Match with No Interest - Final') then 'Good - FNE'
							When ([Entitlement Response] = 'W' or [Entitlement Response] = 'Y' or [Entitlement Response] = 'Match') and ([Lien Status] = 'Waived' or [Lien Status] = 'Eligible for Payment' or [Lien Status] = 'Satisfied' or [Lien Status] = 'Paid' or [Lien Status] = 'Requested' or [Lien Status] = 'Received') then 'Good - FD'
							When ([Entitlement Response] = 'Pending' or [Entitlement Response] = 'P' or [Entitlement Response] = 'Match' or [Entitlement Response] = 'Y') and [Lien Status] like '%Pending%' then 'Ok - pending'
							When [Lien Status] = 'Discharged' then 'Ok - discharged/opened in error'
							Else 'Look Into'
							End as 'G Stage and Entitlement Match?',
						
						Case
							When ([Lien Status] = 'Discharged' or [Lien Status] = 'Waived') and ([Allocated Amt] = 0 or [Allocated Amt] is null) then 'Good'
							When [Lien Status] <> 'Discharged' or [Lien Status] <> 'Waived' then 'Not relevant'
							Else 'Look Into'
							End as 'G Status/Amount ok?',

						[Lien Status] as 'G Lien Status', 
						Liens_SLAM.[S3 Product Id] as 'EIF LienId', Liens_SLAM.LienProductStatus as 'EIF LienProductStatus', Liens_SLAM.Stage as 'EIF Stage', Liens_SLAM.ClosedReason as 'EIF ClosedReason',
						Liens_SLAM_NonEIF.[S3 Product Id] as 'NonEIF LienId', Liens_SLAM_NonEIF.LienProductStatus as 'NonEIF LienProductStatus', Liens_SLAM_NonEIF.Stage as 'NonEIF Stage', Liens_SLAM_NonEIF.ClosedReason as 'NonEIF ClosedReason',

						Case
						--Issues
							When LienProductStatus = 'Hold' then 'Look into - SLAM status of hold'
							When ([Lien Status] = 'Waived' or [Lien Status] = 'Eligible for Payment' or [Lien Status] = 'Satisfied' or [Lien Status] = 'Paid' or [Lien Status] = 'Requested' or [Lien Status] = 'Received') 
									and Liens_SLAM.LienProductStatus = 'Open' and Liens_SLAM_NonEIF.LienProductStatus = 'Open' 
									and (Liens_SLAM.Stage = 'Final Demand Received' or Liens_SLAM.Stage = 'Final No Lien Received') 
									and Liens_SLAM.LienType = 'Medicare - Global' and Liens_SLAM_NonEIF.LienType = 'Medicare - Global'
									and Liens_SLAM.FinalGlobalAmount <> [Final Lien Amt]
									then 'Issue - G changed final demand amount on final lien'
							When ([Lien Status] = 'Waived' or [Lien Status] = 'Eligible for Payment' or [Lien Status] = 'Satisfied' or [Lien Status] = 'Paid' or [Lien Status] = 'Requested' or [Lien Status] = 'Received') 
									and Liens_SLAM.LienProductStatus = 'Open' and Liens_SLAM_NonEIF.LienProductStatus = 'Open' 
									and (Liens_SLAM.Stage = 'Final Demand Received' or Liens_SLAM.Stage = 'Final No Lien Received') 
									and Liens_SLAM.LienType <> 'Medicare - Global' and Liens_SLAM_NonEIF.LienType <> 'Medicare - Global'
									and Liens_SLAM.FinalDemandAmount <> [Final Lien Amt]
									then 'Issue - G changed final demand amount on final lien'
							When ([Lien Status] = 'Waived' or [Lien Status] = 'Eligible for Payment' or [Lien Status] = 'Satisfied' or [Lien Status] = 'Paid' or [Lien Status] = 'Requested' or [Lien Status] = 'Received') 
									and Liens_SLAM.Stage = 'Final No Entitlement' 
									then 'Issue - was FNE, now FD'
							When ([Lien Status] = 'Not Entitled' or [Lien Status] = 'No Match with No Interest - Final') 
									and Liens_SLAM.Stage = 'Final Demand Received' 
									then 'Issue - was FD, now FNE'
							When ([Lien Status] = 'Not Entitled' or [Lien Status] = 'No Match with No Interest - Final') 
									and Liens_SLAM.Stage = 'Final No Lien Received' 
									then 'Issue (minor) - was FNL, now FNE'
							When [Lien Status] like '%Pending%' and Liens_SLAM.Stage like 'Final%' then 'Issue - lien was final, now pending'
							When Liens_SLAM.[S3 Product Id] is null 
									and [Lien Status] = 'Matched by Rawlings Company; See PLRP Liens' and [Allocated Amt] is null 
									and [Lien Type] = 'PLRP' then 'Ignore - not a valid lien and does not exist in SLAM'
							When Liens_SLAM.[S3 Product Id] is not null and Liens_SLAM.Stage not like 'final%' and Liens_SLAM.stage not like 'closed' 
									and [Lien Status] = 'Matched by Rawlings Company; See PLRP Liens' and [Allocated Amt] is null 
									and [Lien Type] = 'PLRP' then 'Update to FNL in SLAM - not a valid lien'
							When Liens_SLAM.[S3 Product Id] is not null 
									and (Liens_SLAM.stage like 'final%' or Liens_SLAM.stage like 'closed') 
									and [Lien Status] = 'Matched by Rawlings Company; See PLRP Liens' and [Allocated Amt] is null 
									and [Lien Type] = 'PLRP' then 'Ignore - not a valid lien and final/closed in SLAM'
							When Liens_SLAM.Stage is null then 'Look into - SLAM is NULL'
							When Liens_SLAM.Stage like 'Under Review%' then 'SLAM stage is Under Review - look into'
							When Liens_SLAM.Stage like 'Initial%' or Liens_SLAM.Stage like 'Pending%' or Liens_SLAM.Stage like 'To Send - Final%' 
									then 'Look Into - probably a G claimant finalization/pending liens issue'
							When (Liens_SLAM.ClosedReason not like '' or Liens_SLAM.ClosedReason is not null) 
									and Liens_SLAM.Stage <> 'Closed' then 'Issue - has closed reason but stage is not closed'
							When (Liens_SLAM_NonEIF.ClosedReason not like '' or Liens_SLAM_NonEIF.ClosedReason is not null) 
									and Liens_SLAM_NonEIF.Stage <> 'Closed' then 'Issue - has closed reason but stage is not closed'

						--Liens with no changes; note only
							
							When [Lien Status] = 'Waived' 
									and Liens_SLAM.LienProductStatus = 'Open' 
									and (Liens_SLAM.Stage = 'Final Demand Received' or Liens_SLAM.Stage = 'Final No Lien Received') 
			  					and [Final Lien Amt] = sum(Liens_SLAM_NonEIF.FinalGlobalAmount, Liens_SLAM_NonEIF.FinalDemandAmount, Liens_SLAM.FinalGlobalAmount, Liens_SLAM.FinalDemandAmount)
									then 'Note only - FNL, no change'
							When [Lien Status] = 'Waived' 
									and Liens_SLAM.LienProductStatus = 'Open' 
									and Liens_SLAM.Stage = 'Closed' and Liens_SLAM.ClosedReason = 'Resolved - Final Demand' and Liens_SLAM.LienProductStatus = 'Closed' 
			  					and [Final Lien Amt] = sum(Liens_SLAM_NonEIF.FinalGlobalAmount, Liens_SLAM_NonEIF.FinalDemandAmount, Liens_SLAM.FinalGlobalAmount, Liens_SLAM.FinalDemandAmount)
									then 'Note only - FNL, no change'
							When ([Lien Status] = 'Waived' or [Lien Status] = 'Eligible for Payment' or [Lien Status] = 'Satisfied' or [Lien Status] = 'Paid' or [Lien Status] = 'Requested' or [Lien Status] = 'Received') 
									and Liens_SLAM.LienProductStatus = 'Open' 
									and (Liens_SLAM.Stage = 'Final Demand Received' or Liens_SLAM.Stage = 'Final No Lien Received') 
			  					and [Final Lien Amt] = sum(Liens_SLAM_NonEIF.FinalGlobalAmount, Liens_SLAM_NonEIF.FinalDemandAmount, Liens_SLAM.FinalGlobalAmount, Liens_SLAM.FinalDemandAmount)
									then 'Note only - FD, no change'
							When ([Lien Status] = 'Waived' or [Lien Status] = 'Eligible for Payment' or [Lien Status] = 'Satisfied' or [Lien Status] = 'Paid' or [Lien Status] = 'Requested' or [Lien Status] = 'Received') 
									and Liens_SLAM.Stage = 'Closed' and Liens_SLAM.ClosedReason = 'Resolved - Final Demand' and Liens_SLAM.LienProductStatus = 'Closed' 
			  					and [Final Lien Amt] = sum(Liens_SLAM_NonEIF.FinalGlobalAmount, Liens_SLAM_NonEIF.FinalDemandAmount, Liens_SLAM.FinalGlobalAmount, Liens_SLAM.FinalDemandAmount)
									then 'Note only - FD, no change'
							When ([Lien Status] = 'Not Entitled' or [Lien Status] = 'No Match with No Interest - Final') and Liens_SLAM.LienProductStatus = 'Open' and Liens_SLAM.Stage = 'Final No Entitlement' then 'Note only - FNE, no change'
							When ([Lien Status] = 'Not Entitled' or [Lien Status] = 'No Match with No Interest - Final') 
									and Liens_SLAM.LienProductStatus = 'Closed' and Liens_SLAM.Stage = 'Closed' and Liens_SLAM.ClosedReason like 'Resolved - No Entitlement' 
									then 'Note only - Closed/FNE, no change'
							When [Lien Status] = 'Matched by Rawlings Company; See PLRP Liens' and [Allocated Amt] is null and [Lien Type] = 'PLRP' then 'Ignore - not a valid lien'
							When [Lien Status] = 'Discharged' and Liens_SLAM.Stage = 'Final No Lien Received' and sum(Liens_SLAM_NonEIF.FinalGlobalAmount, Liens_SLAM_NonEIF.FinalDemandAmount, Liens_SLAM.FinalGlobalAmount, Liens_SLAM.FinalDemandAmount) = 0 then 'Note only - Discharged, no change'
							When [Lien Status] = 'Discharged' 
									and Liens_SLAM.Stage = 'Closed' and Liens_SLAM.ClosedReason = 'Opened in Error' 
									and Liens_SLAM.Stage_NonEIF = 'Closed' and Liens_SLAM_NonEIF.ClosedReason = 'Opened in Error' 
									then 'Note only - Discharged, no change'
							When ([Lien Status] like '%Pending%' or [Lien Status] = 'Discrepancy') 
									and Liens_SLAM.Stage = 'Awaiting Information' then 'Note only - pending'

						--Update to Final
							When [Lien Status] = 'Waived' and Liens_SLAM.LienProductStatus = 'Open' and Liens_SLAM.Stage = 'Awaiting Information' then 'Update to FNL'
							When ([Lien Status] = 'Eligible for Payment' or [Lien Status] = 'Satisfied' or [Lien Status] = 'Paid' or [Lien Status] = 'Requested' or [Lien Status] = 'Received') 
									and Liens_SLAM.LienProductStatus = 'Open' 
									and Liens_SLAM.Stage = 'Awaiting Information' 
									then 'Update to FD'
							When ([Lien Status] = 'Not Entitled' or [Lien Status] = 'No Match with No Interest - Final') 
									and Liens_SLAM.LienProductStatus = 'Open' 
									and Liens_SLAM.Stage = 'Awaiting Information' then 'Update to FNE'
							When [Lien Status] = 'Discharged' and Liens_SLAM.Stage = 'Awaiting Information' then 'Update to FNL'
							Else 'Look Into'
							End as 'Stage Comparison',
						
						--NewLienNote
						Case
							When Liens_SLAM.LienProductStatus = 'Hold' then 'Look into - SLAM status of hold'
							When [Entitlement Response] = 'D' and [Lien Status] = 'Discrepancy' then 'G Tracking - HB Report [date] with a lien status of discrepancy'
							When [Entitlement Response] = 'N' and [Lien Status] = 'Not Entitled' then 'G Tracking - HB Report [date] as not entitled and final'
							When [Entitlement Response] = 'No Match' and [Lien Status] = 'No Match with No Interest - Final' then 'G Tracking - HB Report [date] as not entitled and final'
							When ([Entitlement Response] like '%Pending%' or [Entitlement Response] like 'P') and [Lien Status] = 'Pending' then 'G Tracking - HB Report [date] as pending'
							When [Entitlement Response] = 'W' and [Lien Status] = 'Waived' then 'G Tracking - HB Report [date] as yes/waived entitlement and final'
							When [Entitlement Response] = 'Y' 
									and ([Lien Status] = 'Paid' or [Lien Status] = 'Eligible for Payment' or [Lien Status] = 'Received' or [Lien Status] = 'Discharged' or [Lien Status] = 'Requested' or [Lien Status] = 'Satisfied' or [Lien Status] = 'Waived') 
									then 'G Tracking - HB Report [date] as yes entitlement and final'
							When Liens_SLAM.[S3 Product Id] is null and [Lien Status] = 'Matched by Rawlings Company; See PLRP Liens' and [Allocated Amt] is null and [Lien Type] = 'PLRP' then 'Ignore - not a valid lien and does not exist in SLAM'
							When Liens_SLAM.[S3 Product Id] is not null and Liens_SLAM.Stage not like 'final%' and Liens_SLAM.stage not like 'closed' 
									and [Lien Status] = 'Matched by Rawlings Company; See PLRP Liens' and [Allocated Amt] is null and [Lien Type] = 'PLRP' 
									then 'G Tracking - HB Report [date] as final (placeholder PLRP lien)'
							When Liens_SLAM.[S3 Product Id] is not null 
									and (Liens_SLAM.stage like 'final%' or Liens_SLAM.stage like 'closed') 
									and [Lien Status] = 'Matched by Rawlings Company; See PLRP Liens' and [Allocated Amt] is null 
									and [Lien Type] = 'PLRP' 
									then 'G Tracking - HB Report [date] as final (placeholder PLRP lien)'
							When [Lien Status] = 'Discharged' and Liens_SLAM.Stage = 'Closed' and Liens_SLAM.ClosedReason = 'Opened in Error' then 'G Tracking [date] - HB Report as discharged/opened in error/FNL'
							When [Lien Status] = 'Discharged' and Liens_SLAM.Stage = 'Final No Lien Received'  then 'G Tracking [date] - HB Report as discharged/opened in error/FNL'
							Else 'Look Into'
							End As 'NewLienNote'
			
				from	#Liens_G_Updated as Liens_G 
							LEFT OUTER JOIN JB_JHBReport_AddLienData as Liens_SLAM on Liens_G.[Entitlement Wave ID] = Liens_SLAM.GLienId and Liens_G.[GId] = Liens_SLAM.GClaimantId
							LEFT OUTER JOIN JB_HBReport_AddLienData_JAMSGnonEIF as Liens_SLAM_NonEIF on Liens_G.[Entitlement Wave ID] = Liens_SLAM_NonEIF.GLienId and Liens_G.[GId] = Liens_SLAM_NonEIF.GClaimantId
				where	[SLAM Case Analysis] <> 'Ignore - not an EIF claimant'
				
						
			) as sub

	

	




			
	--QA

		select 
				--Claimant Identification
				HB.[GId], HB.[G First Name], HB.[G Last Name], HB.[Client Id], F.ClientId, F.GClaimantId,F.FinalizedStatusId,
				HB.[EIF Claimant?],
				
				--Checks on claimant level data
				HB.[SA Match?], HB.[SSN Match?], HB.[G Overall Lien Status ok?], HB.[G Overall Lien HB ok?], HB.[QA on G Data], HB.[Good to Process?],
				
				--Lien Level Data: G
				HB.[G Current Overall Status], HB.[Entitlement Wave Id], HB.[Lien Type], HB.[Entitlement Response], HB.[Final Lien Amt], HB.[Lien Status],
				
				--Lien Level Data: SLAM
				F.Id as 'SLAM Lien Id', F.GLienId, F.LienType, F.OnBenefits, F.OnBenefitsVerified, 
					Liens_SLAM.FinalDemandAmount as 'EIF FD', Liens_SLAM.FinalGlobalAmount as 'EIF Final Global', Liens_SLAM.TotalGlobalAmount as 'EIF Total Global', 
						Case
							When Liens_SLAM.LienType = 'Medicare - Global' and Liens_SLAM.FinalGlobalAmount is not null then Liens_SLAM.FinalGlobalAmount 
							When Liens_SLAM.LienType = 'Medicare - Global' and Liens_SLAM.FinalGlobalAmount is null then 0 
							
							When Liens_SLAM.LienType <> 'Medicare - Global' and Liens_SLAM.FinalDemandAmount is not null then Liens_SLAM.FinalDemandAmount
							When Liens_SLAM.LienType <> 'Medicare - Global' and Liens_SLAM.FinalDemandAmount is null then 0
							
							Else 0
							End As 'EIF True SLAM FD',
						Liens_SLAM_nonEIF.FinalDemandAmount as 'Non EIF FD', Liens_SLAM_nonEIF.FinalGlobalAmount as 'Non EIF Final Global', Liens_SLAM_nonEIF.TotalGlobalAmount as 'Non EIF Total Global',
						Case
							When Liens_SLAM_nonEIF.LienType = 'Medicare - Global' and Liens_SLAM_nonEIF.FinalGlobalAmount is not null then Liens_SLAM_nonEIF.FinalGlobalAmount
							When Liens_SLAM_nonEIF.LienType = 'Medicare - Global' and Liens_SLAM_nonEIF.FinalGlobalAmount is null then 0
							
							When Liens_SLAM_nonEIF.LienType <> 'Medicare - Global' and Liens_SLAM_nonEIF.FinalDemandAmount is not null then Liens_SLAM_nonEIF.FinalDemandAmount
							When Liens_SLAM_nonEIF.LienType <> 'Medicare - Global' and Liens_SLAM_nonEIF.FinalDemandAmount is null then 0
							
							Else 0
							End As 'Non EIF True SLAM FD',
					F.LienProductStatus, F.Stage, F.ClosedReason,
					F.FinalizedStatusId,
				
				--Lien Level Data Match?
				Case
					When HB.[Lien Status] = 'Matched by Rawlings Company; See PLRP Liens' and HB.[Final Lien Amt] is null and HB.[Lien Type] = 'PLRP' then 'Not a valid lien'
					When HB.[Lien Type] = 'MedicareGlobal' and F.LienType = 'Medicare - Global' then 'Match'
					When HB.[Lien Type] = 'Medicaid' and F.LienType = 'Medicaid Lien - MT' then 'Match'
					When HB.[Lien Type] = 'PrivateSELR' and F.LienType = 'Private Lien - MT' then 'Match'
					When HB.[Lien Type] = 'PLRP' and F.LienType like '%plrp%' then 'Match'
					When HB.[Lien Type] = 'IndianHealth' and F.LienType = 'IHS Lien' then 'Match'
					When HB.[Lien Type] = 'Tricare' and F.LienType = 'Military Lien - MT' then 'Match'
					When HB.[Lien Type] = 'VeteransAdministration' and F.LienType = 'Military Lien - MT' then 'Match'
					When HB.[Lien Type] = 'External' and F.LienType = 'Military Lien - MT' then 'Match'
					When HB.[Lien Type] = 'PrivateSELR' and F.LienType = 'Medicare Lien - Part C' then 'Match'
					When F.LienType is null then 'SLAM is NULL'
					Else 'Look Into'
					End as 'LienTypes Match?',
				'' as 'OnBenefits ok?', '' as 'Amounts ok?', '' as 'Stage ok?', '' as 'Claimant Updated Correctly?'
		from #Liens_G_Updated as HB
				LEFT OUTER JOIN FullProductViews as F on HB.[GID]=F.GClaimantId and HB.[Entitlement Wave Id]=F.GLienId
				LEFT OUTER JOIN JB_HBReport_AddLienData as Liens_SLAM on HB.[Entitlement Wave ID] = Liens_SLAM.GLienId and HB.[GId] = Liens_SLAM.GClaimantId
				LEFT OUTER JOIN JB_HBReport_AddLienData_JAMSGnonEIF as Liens_SLAM_nonEIF on HB.[Entitlement Wave ID] = Liens_SLAM_nonEIF.GLienId and HB.[GId] = Liens_SLAM.GClaimantId
		where f.caseid = 2505
		Order By [Client Id], LienType
		
		


		

	--Finalization Check
		select Gclaimantid, id, PreExistingInjuries, FinalizedStatusId, ClientHoldbackAmount
		from clients
		where caseid = 2505 and Gclaimantid in (
