--1. Update JB_HBReport_AddClientData and JB_HBReport_AddLienData to have appropriate CaseId


--2. Import data into SQL: 
drop table JB_GHB_Case_Current
drop table JB_GHB_Obligation_Current
drop table JB_GHB_Case_Prev


select count(*) from JB_GHB_Case_Current
select count(*) from JB_GHB_Obligation_Current
select count(*) from JB_GHB_Case_Prev


select * from JB_GHB_Case_Current



--3. Run query to combine [dbo].[JB_GHB_Case_Current] and [dbo].[JB_GHB_Case_Prev]. Also renames these two tables and G column headers. 

	--Source tables
		select * from JB_GHB_Case_Current
		select * from JB_GHB_Case_Prev


	--Query to analyze G's data

			drop table #Case_Updated



		Select	sub.*, 
				Case
					When [G Prev Overall Status] is null then 'Issue - claimant not on previous HB Report'
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

				FROM	JB_GHB_Case_Current as Case_Current 
							LEFT OUTER JOIN JB_GHB_Case_Prev as Case_Prev ON Case_Current.GID = Case_Prev.GID
				) as sub




		--Check data
			Select * From #Case_Updated order by [G last name]

			Select * From #Case_Updated where [QA on G Data] not like 'move along%'


			--Alter table data so it pulls as ok in subsequent queries because it's not actually an issue
				update #Case_Updated 
				set [G Overall Lien HB ok?] = 'Ok - not final in SLAM' 
				--[QA on G Data] = 'Move along - nothing to see here, son'
				where [G SSN] = '078-58-9424' 


--4. Combine and analyze G and S3 claimant data

		--Source tables
			select * from #Case_Updated
			select * from JB_HBReport_AddClientData


		--Run Query to combine the G Table (#Case_Updated) and SLAM client data
			--Note: If this has an EIF case then un-null out the join that is in the From clause about the EIFs and all the EIF statements in the query

			drop table #Updated_Claimant_Data



			Select	sub2.*, 
					Case
						When sub2.[Claimant in SLAM Case?] like 'Issue%' then 'Fix in SLAM (if possible) - Issue with identifying claimant in SLAM'

						--When sub2.[EIF Claimant?] = 'EIF' then 'No Update - EIF'

						When sub2.[SA Match?] = 'Look Into' or sub2.[G Overall Lien Status ok?] = 'Look Into' or sub2.[Overall Status Match?] = 'Look Into' or sub2.[G Overall Lien HB ok?] = 'Look Into' or sub2.[QA on G Data] = 'Look Into' then 'Look Into - Unknown Issue'

						When sub2.[SA Match?] like 'Issue%' then 'Do not process - notify CM - allocation mismatch'
						When sub2.[SSN Match?] like 'Issue%' then 'Do not process - notify CM - SSN mismatch'

						When sub2.[QA on G Data] not like 'move along%' then 'Do not process - notify G - G data is inconsistent'
						When sub2.[G Overall Lien Status ok?] like 'Issue%' then 'Do not process - notify G - G data is inconsistent'
						When sub2.[Overall Status Match?] like 'Issue%' then 'Do not process - notify G - G data is inconsistent'
						When sub2.[G Overall Lien HB ok?] like 'Issue%' then 'Do not process - notify G - G data is inconsistent'
						When sub2.[G Overall Lien Status ok?] like 'G Internal Issue (system hold) - do not process' then 'Do not process - G internal issue'

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
							sub.[G Last Name], sub.[G First Name], sub.[GID] as [G Id], 
							sub.[Client Id], sub.AttorneyReferenceId, sub.GClaimantId, 
							--sub.[SLAM EIF CaseId], sub.[SLAM EIF ClientId],
							--Case
							--	When sub.[SLAM EIF ClientId] is not null then 'EIF'
							--	Else 'Not EIF'
							--	End as 'EIF Claimant?',

							--SA
							sub.[G SA], sub.[SLAM SA],
							Case
								When sub.[G SA] = sub.[SLAM SA] then 'Good - match'
								When sub.[G SA] <> sub.[SLAM SA] then 'Issue - SA mismatch'
								Else 'Look Into'
								End As 'SA Match?',

							--SSN
							sub.[G SSN], sub.[SLAM SSN],
							Case
								When sub.[G SSN] = sub.[SLAM SSN] then 'Good - match'
								When sub.[G SSN] <> sub.[SLAM SSN] then 'Issue - SSN mismatch'
								Else 'Look Into'
								End As 'SSN Match?',

							--Checks on G Data
							sub.[G Current Overall Status], sub.[G Overall Lien Status ok?],
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
							sub.[G Current Overall Holdback], sub.[G Overall Lien HB ok?], sub.[QA on G Data]

					From	(
								SELECT	
										--Identification for Claimant
										SLAM_Clients.CaseId, SLAM_Clients.[Client Id], SLAM_Clients.AttorneyReferenceId, SLAM_Clients.GClaimantId, 
										--SLAM_ClientsEIF.CaseId as 'SLAM EIF CaseId', SLAM_ClientsEIF.[Client Id] as 'SLAM EIF ClientId',
										Case_Updated.[G Last Name], Case_Updated.[G First Name], Case_Updated.GID, 


										--SSN
										Case_Updated.[G SSN], SLAM_Clients.SSN as 'SLAM SSN',

										--SA
										Case_Updated.[G Allocation] as 'G SA', SLAM_Clients.[SettlementAmount] as 'SLAM SA', 

										--G Data
										Case_Updated.[G Current Overall Status], Case_Updated.[G Current Overall Holdback], 

										--Finalization Data
										SLAM_Clients.PreExistingInjuries, SLAM_Clients.[G Liens Final in SLAM?], 

										--Checks on G Data
										Case_Updated.[G Overall Lien HB ok?], Case_Updated.[QA on G Data], Case_Updated.[G Overall Lien Status ok?]


								FROM	#Case_Updated as Case_Updated 
											LEFT OUTER JOIN JB_HBReport_AddClientData as SLAM_Clients ON Case_Updated.[GId] = SLAM_Clients.GClaimantId
																	--ON Case_Updated.[G SSN]= SLAM_Clients.[SSN] and Case_Updated.OtherId = SLAM_Clients.AttorneyReferenceId
											--LEFT OUTER JOIN JB_HBReport_AddClientData_AEIF as SLAM_ClientsEIF on Case_Updated.[GId] = SLAM_ClientsEIF.GClaimantId


							) as sub
					) as sub2




			--Get All Results. 
				--Note: If all the SLAM data columns are NULL, then there is a problem with the GClaimantIds.

				select * from #Updated_Claimant_Data 


			--This query tells you the info for all claimants who have an issue. 
				--Copy/paste this into a new tab on your processed WIP file titled "Claimant Level Discrepancies". Make notes on the ones you look into: fix where you can, notify G when you should. 
				select * from #Updated_Claimant_Data 
				where [Good to Process?] <> 'Process as normal - no issues' 
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





--5. Combine the #Updated_Claimant_Data table with the G Lien Data

		--Source Data

			select * from [dbo].[JB_GHB_Obligation_Current]
			select * from #Updated_Claimant_Data


		--Run Query 


			drop table #Liens_G_Updated



			Select	Clients_Updated.*, Liens_G.[Case ID], Liens_G.[Lien Type], Liens_G.[Entitlement Wave Id], Liens_G.[Lienholder Full Name], Liens_G.[Entitlement Response], Liens_G.[Protocol Name], 
					Liens_G.[Max Protocol], Liens_G.[Claim Amt], Liens_G.[Final Lien Amt], Liens_G.[Allocated Amt], Liens_G.[Lien Status]
			Into	#Liens_G_Updated
			From	[dbo].[JB_GHB_Obligation_Current] as Liens_G LEFT OUTER JOIN
						#Updated_Claimant_Data as Clients_Updated ON Liens_G.GID = Clients_Updated.[G Id]





		--Get Results
			select * from #Liens_G_Updated




--6. Find EWIds that need to be fixed

		--Source tables
			select * from #Liens_G_Updated
			select * from JB_HBReport_AddLienData


		--Modify G table to drop empty columns
			select * from #Liens_G_Updated


			alter table #Liens_G_Updated drop column F20




		--6a. Run query to create temp table to do the ***intial*** comparison to get the EWIds to match between COL and SLAM


					drop table #Fix_EWIds_Initial


			select	Liens_G.[G Last Name], Liens_G.[G First Name], Liens_SLAM.ClientFirstName, Liens_SLAM.ClientLastName, Liens_G.[G SSN], Liens_G.[Client Id] as 'Client Id (from G table)', Liens_SLAM.[ClientId] as 'Client Id (from SLAM table)', 
					Liens_G.[Entitlement Wave Id] as 'G EWId',Liens_SLAM.IdentificationNumber as 'SLAM EWId', Liens_SLAM.GLienId as 'SLAM GLienId',
					Case
						When Liens_G.[Entitlement Wave Id] = Liens_SLAM.GLienId then 'Match'
						Else 'Look into - mismatch'
						End As 'EWIds Match?',
					Liens_G.[Lien Type] as 'G LienType', Liens_SLAM.LienType as 'SLAM LienType', 
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
					Liens_G.[Lienholder Full Name] as 'G Lienholder', Liens_SLAM.[LienholderName] as 'SLAM Lienholder', 
					Liens_G.[Lien Status] as 'G Lien Status', Liens_SLAM.[AssignedUserId], Liens_SLAM.[S3 Product Id],'' as 'Note', '' as 'Count', '' as 'Updated Needed?', '' as 'Correct EWid',
						[QA on G Data], [Good to Process?]

			into	#Fix_EWIds_Initial
			from	#Liens_G_Updated as Liens_G 
						LEFT OUTER JOIN JB_HBReport_AddLienData as Liens_SLAM on Liens_G.[G ID] = Liens_SLAM.GClaimantId --and Liens_G.[Entitlement Wave Id]=Liens_SLAM.GLienId 
										--and Liens_G.[Entitlement Wave Id]=Liens_SLAM.IdentificationNumber
			order by [G last name], [G first name], [G LienType], [G Lienholder]




					select * from  #Fix_EWIds_Initial 




					--Update GLienId field with current EWIds

					select	Liens_G.*, Liens_SLAM.IdentificationNumber, Liens_SLAM.lientype, Liens_SLAM.[s3 product id]
					from	#Liens_G_Updated as Liens_G
							JOIN #slamliens as Liens_SLAM on Liens_G.GID = Liens_SLAM.GClaimantId and Liens_G.[Entitlement Wave Id]=cast(Liens_SLAM.IdentificationNumber as int)

					select *
					into #slamliens
					from JB_HBReport_AddLienData
					where lientype = 'medicare - global' or lientype = 'medicaid lien - mt' or lientype like 'military%' or lientype like 'ihs%'





		--6b. Run query to create temp table used to find discrepancies in the EWIds

					drop table #Fix_EWIds



			select	Liens_G.[G Last Name], Liens_G.[G First Name], Liens_G.[G SSN], Liens_G.[Client Id] as 'Client Id (from G table)',	Liens_SLAM.[ClientId] as 'Client Id (from SLAM table)', 
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
						[QA on G Data], [Good to Process?]
			into	#Fix_EWIds
			from	#Liens_G_Updated as Liens_G
						LEFT OUTER JOIN JB_HBReport_AddLienData as Liens_SLAM on Liens_G.[G ID] = Liens_SLAM.GClaimantId and Liens_G.[Entitlement Wave ID] = Liens_SLAM.GLienId



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
				where	[Client Id (from G table)] is null and [Client Id (from SLAM table)] is not null-- and (ClosedReason <> 'Opened in Error' or ClosedReason is null)
				order by ClientLastName



				select	Liens_SLAM.ClientId, Liens_SLAM.GClaimantId, Liens_SLAM.ClientFirstName, Liens_SLAM.ClientLastName, 
						Liens_SLAM.[S3 Product Id], Liens_SLAM.GLienId,
						Liens_SLAM.LienType as SLAM_LienType, Liens_SLAM.LienholderName as SLAM_Lienholder, Liens_SLAM.LienProductStatus, Liens_SLAM.Stage
				from	JB_JunellHBReport_AddLienData as Liens_SLAM
							LEFT OUTER JOIN #Liens_G_Updated as Liens_G on Liens_G.[G ID] = Liens_SLAM.GClaimantId
				where	Liens_SLAM.GLienId is null
						and Liens_G.[Good to Process?] = 'Process as normal - no issues'
						--and (Liens_SLAM.LienType = 'Medicare - Global' or Liens_SLAM.LienType = 'Medicaid Lien - MT' or Liens_SLAM.LienType like 'Military%' or Liens_SLAM.LienType like 'ihs%')
						and Liens_SLAM.Stage <> 'Closed' and Liens_SLAM.ClosedReason not like 'Opened in Error' and Liens_SLAM.ClosedReason not like 'Per att%'
				order by 1,4



				--update case id
				select FullProductViews.id as LienId, FullProductViews.GLienId, FullProductViews.GClaimantId, FullProductViews.ClientId, FullProductViews.ClientFirstName, FullProductViews.ClientLastName, FullProductViews.LienType, FullProductViews.LienholderName, FullProductViews.CollectorName, FullProductViews.Stage, FullProductViews.ClosedReason, FullProductViews.LienProductStatus, FullProductViews.FinalizedStatusId
				from FullProductViews
						Left Join #Updated_Claimant_Data on #Updated_Claimant_Data.[Client Id]=FullProductViews.ClientId
				where FullProductViews.GLienId is null and FullProductViews.GClaimantId is not null and FullProductViews.caseid = 3482
						and #Updated_Claimant_Data.[Good to Process?] = 'Process as normal - no issues' 
						--and (FullProductViews.LienType = 'Medicare - Global' or FullProductViews.LienType = 'Medicaid Lien - MT' or FullProductViews.LienType like 'Military%' or FullProductViews.LienType like 'ihs%')
						and closedreason is null and stage not like 'final%'
						--Exclusion List for A E G B&C:
						--and FullProductViews.id not in (613980, 583174, 613982, 581959)
				order by  FullProductViews.ClientLastName, FullProductViews.ClientFirstName





			--Find liens on the report that are not in SLAM
				select	[G Last Name], [G First Name], [G SSN], [Client Id (from G table)], [G EWId], [G LienType], [G Lienholder]
				from	#Fix_EWIds 
				where	[Client Id (from SLAM table)] is null and [Client Id (from G table)] is not null and [G Lien Status] <> 'Matched by Rawlings Company; See PLRP Liens'
				Order by 1, 2



				select * from JB_GHB_Obligation_Current where SSN = '508-72-9076'




			--Find liens on the report where the EWId is null in SLAM 
				select	*
				from	#Fix_EWIds
				where	[SLAM EWId] is null and [G Lien Status] not like 'Matched by Rawlings Company; See PLRP Liens'





--7. Update Liens in SLAM to match G HB Report

		--Source tables

			select * from #Liens_G_Updated
			select * from JB_HBReport_AddLienData

			select distinct [Entitlement Response], [Lien Status] from #Liens_G_Updated


		--Run query to combine and compare G and SLAM lien level data


		Select	
				--Claimant identification
				sub.[G Last Name], sub.[G First Name], sub.[G Id],  Sub.[Client Id (from G table)], sub.[Client Id (from SLAM table)], 

				--EIF Data
				--sub.[EIF Claimant?], 

				--Claimant data checks				
				sub.[G SSN], sub.[SSN Match?], sub.[G SA], sub.[SA Match?], 
				sub.[G Current Overall Status], sub.[G Overall Lien Status ok?], sub.[Overall Status Match?], sub.[G Overall Lien HB ok?], sub.[QA on G Data], sub.[Good to Process?], 

				--Lien Data
				sub.[G EWId], sub.[SLAM EWId], sub.[EWId Match?], 
				sub.[G Lientype], sub.[SLAM Lientype], sub.[LienTypes Match?], 
				sub.[G Lienholder], sub.[SLAM Lienholder], sub.[Lienholder Match?], 
				sub.[G Onbenefits], sub.[SLAM OnBenefits], sub.[OnBenefits Match?], 
				sub.[Final Lien Amt], sub.[Allocated Amt], sub.[G Amounts Match?], 
				sub.[FinalDemandAmount], sub.[FinalGlobalAmount], sub.[TotalGlobalAmount], sub.[True SLAM FD], 
				Case
					When [G Amounts Match?] <> 'Match' then 'Issue with G lien amounts'
					When [SLAM Stage] = 'Awaiting Information' and ([G Lien Status] = 'Waived' or [G Lien Status] = 'Eligible for Payment' or [G Lien Status] = 'Satisfied' or [G Lien Status] = 'Paid' or [G Lien Status] = 'Requested' or [G Lien Status] = 'Received') then 'Ok - newly final'
					When [True SLAM FD]=[Allocated Amt] then 'Match'
					When [True SLAM FD] is null and [Allocated Amt] = 0 then 'Match'
					When [True SLAM FD] is null and [Allocated Amt] is null then 'Match'
					When [True SLAM FD] = 0 and [Allocated Amt] is null then 'Match'
					When [True SLAM FD]<>[Allocated Amt] then 'Mismatch'
					Else 'Look Into'
					End As 'FD Match?',
				sub.[AssignedUserId], 
				sub.[G Stage and Entitlement Match?], 
				sub.[G Lien Status], 
				sub.[SLAM LienProductStatus], sub.[SLAM Stage], sub.[SLAM ClosedReason], 
				sub.[Stage Comparison], sub.NewLienNote, sub.[S3 Product Id], 

				Case
				--Major issues
					--When sub.[EIF Claimant?] = 'EIF' then 'Do not process - EIF'
					When [Good to Process?] = 'Do not process - notify G - G data is inconsistent' then 'Do not process - notify G - G data is inconsistent'
					When [Good to Process?] = 'Do not process - notify CM - SSN mismatch' or sub.[SSN Match?]  like 'Issue%' then 'Do not process - notify G - SSN Mismatch'
					When [Good to Process?] = 'Do not process - notify CM - SA mismatch' or sub.[SA Match?] = 'Issue - SA mismatch' then 'Do not process - notify G - SA Mismatch'
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
					When sub.[G Lien Status] = 'Discharged' and sub.[Final Lien Amt] is null 
							and (sub.[True SLAM FD] is null or sub.[True SLAM FD] = 0) and (sub.[SLAM Stage] = 'Closed' or sub.[SLAM Stage] like 'final%') then 'Note only'
		  		When sub.[Stage Comparison] = 'SLAM stage is Under Review - look into' then 'Look Into - SLAM stage is Under Review'

					Else 'Look Into'
					End As 'Action Needed'




		From	(	
				select	
					--All claimant level data
						Liens_G.[G Last Name], Liens_G.[G First Name], Liens_G.[G Id], Liens_G.[Client Id] as 'Client Id (from G table)', Liens_SLAM.[ClientId] as 'Client Id (from SLAM table)', 
						--Liens_G.[EIF Claimant?], 
						Liens_G.[G SSN], Liens_G.[SSN Match?], Liens_G.[G SA], Liens_G.[SA Match?], 
						Liens_G.[G Current Overall Status], Liens_G.[G Overall Lien Status ok?], Liens_G.[Overall Status Match?],
						Liens_G.[G Overall Lien HB ok?],Liens_G.[QA on G Data],Liens_G.[Good to Process?],

					--Lien data
						[Entitlement Wave ID] as 'G EWId', GLienId as 'SLAM EWId', 
						Case
							When [Lien Status] = 'Matched by Rawlings Company; See PLRP Liens' and [Allocated Amt] is null and [Lien Type] = 'PLRP' then 'Ignore - not a valid lien'
							When [Entitlement Wave ID] = GLienId then 'Match'
							When GLienId is null then 'NULL in SLAM'
							When GLienId <> [Entitlement Wave ID] then 'Issue - EWId mismatch'
							Else 'Look into'
							End as 'EWId Match?',
						[Lien Type] as 'G Lientype', LienType as 'SLAM Lientype',
						Case
							When [Lien Status] = 'Matched by Rawlings Company; See PLRP Liens' and [Allocated Amt] is null and [Lien Type] = 'PLRP' then 'Ignore - not a valid lien'
							When [Lien Type] = 'MedicareGlobal' and LienType = 'Medicare - Global' then 'Match'
							When [Lien Type] = 'Medicaid' and LienType = 'Medicaid Lien - MT' then 'Match'
							When [Lien Type] = 'PrivateSELR' and LienType = 'Private Lien - MT' then 'Match'
							When [Lien Type] = 'PLRP' and LienType like '%plrp%' then 'Match'
							When [Lien Type] = 'IndianHealth' and LienType = 'IHS Lien' then 'Match'
							When [Lien Type] = 'Tricare' and LienType = 'Military Lien - MT' then 'Match'
							When Liens_G.[Lien Type] = 'PrivateSELR' and Liens_SLAM.LienType = 'Medicare Lien - Part C' then 'Match'
							When [Lien Type] = 'VeteransAdministration' and LienType = 'Military Lien - MT' then 'Match'
							When LienType is null then 'SLAM is NULL'
							Else 'Look Into'
							End as 'LienTypes Match?',
						[Lienholder Full Name] as 'G Lienholder', LienHolderName as 'SLAM Lienholder', 
						[Entitlement Response] as 'G Onbenefits', OnBenefits as 'SLAM OnBenefits',
						Case
							When [Lien Status] = 'Matched by Rawlings Company; See PLRP Liens' and [Allocated Amt] is null and [Lien Type] = 'PLRP' then 'Ignore - not a valid lien'
							When OnBenefits is null or OnBenefits = '' then 'Ok - SLAM is NULL'
							When [Entitlement Response] = 'Y' and OnBenefits = 'Yes' then 'Match'
							When [Entitlement Response] = 'W' and OnBenefits = 'Yes' then 'Match'
							When [Entitlement Response] = 'N' and OnBenefits = 'No' then 'Match'
							When [Entitlement Response] = 'No Match' and OnBenefits = 'No' then 'Match'
							When [Entitlement Response] = 'No Match' and OnBenefits = 'Yes' then 'Issue - Mismatch'
							When [Entitlement Response] = 'Y' and OnBenefits = 'No' then 'Issue - Mismatch'
							When [Entitlement Response] = 'Pending' and Stage = 'Awaiting Information' then 'Ok - mismatch but pending in SLAM'
							When [Entitlement Response] = 'Pending' and Stage like 'Final%' then 'Issue - lien was final and is now pending'
							When [Entitlement Response] = 'D' and [Lien Status] = 'Discrepancy' and Stage = 'Awaiting Information' then 'Ok - discrepancy status but at awaiting info in SLAM'
							When [Entitlement Response] = 'D' and [Lien Status] = 'Discrepancy' and Stage <> 'Awaiting Information' then 'Issue - discrepancy status but not at awaiting info in SLAM'
							Else 'Look Into'
							End as 'OnBenefits Match?',
						[Final Lien Amt], [Allocated Amt], 
						Case
							When [Final Lien Amt] = [Allocated Amt] then 'Match'
							When [Final Lien Amt] is null and [Allocated Amt] is null then 'Match'
							Else 'Look Into'
							End As 'G Amounts Match?',
						FinalDemandAmount, FinalGlobalAmount, TotalGlobalAmount,
						Case
							When LienType = 'Medicare - Global' then FinalGlobalAmount
							Else FinalDemandAmount
							End As 'True SLAM FD',
						AssignedUserId, 
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
						[S3 Product Id], [Lien Status] as 'G Lien Status', LienProductStatus as 'SLAM LienProductStatus', Stage as 'SLAM Stage', ClosedReason as 'SLAM ClosedReason',
						Case
						--Issues
							When LienProductStatus = 'Hold' then 'Look into - SLAM status of hold'
							When ([Lien Status] = 'Waived' or [Lien Status] = 'Eligible for Payment' or [Lien Status] = 'Satisfied' or [Lien Status] = 'Paid' or [Lien Status] = 'Requested' or [Lien Status] = 'Received') 
									and LienProductStatus = 'Open' 
									and (Stage = 'Final Demand Received' or Stage = 'Final No Lien Received') 
									and LienType = 'Medicare - Global'
									and FinalGlobalAmount <> [Final Lien Amt]
									then 'Issue - G changed final demand amount on final lien'
							When ([Lien Status] = 'Waived' or [Lien Status] = 'Eligible for Payment' or [Lien Status] = 'Satisfied' or [Lien Status] = 'Paid' or [Lien Status] = 'Requested' or [Lien Status] = 'Received') 
									and LienProductStatus = 'Open' 
									and (Stage = 'Final Demand Received' or Stage = 'Final No Lien Received') 
									and LienType <> 'Medicare - Global'
									and FinalDemandAmount <> [Final Lien Amt]
									then 'Issue - G changed final demand amount on final lien'
							When ([Lien Status] = 'Waived' or [Lien Status] = 'Eligible for Payment' or [Lien Status] = 'Satisfied' or [Lien Status] = 'Paid' or [Lien Status] = 'Requested' or [Lien Status] = 'Received') 
									and Stage = 'Final No Entitlement' then 'Issue - was FNE, now FD'
							When ([Lien Status] = 'Not Entitled' or [Lien Status] = 'No Match with No Interest - Final') and Stage = 'Final Demand Received' then 'Issue - was FD, now FNE'
							When ([Lien Status] = 'Not Entitled' or [Lien Status] = 'No Match with No Interest - Final') and Stage = 'Final No Lien Received' then 'Issue (minor) - was FNL, now FNE'
							When [Lien Status] like '%Pending%' and Stage like 'Final%' then 'Issue - lien was final, now pending'
							When [S3 Product Id] is null and [Lien Status] = 'Matched by Rawlings Company; See PLRP Liens' and [Allocated Amt] is null and [Lien Type] = 'PLRP' then 'Ignore - not a valid lien and does not exist in SLAM'
							When [S3 Product Id] is not null and Stage not like 'final%' and stage not like 'closed' and [Lien Status] = 'Matched by Rawlings Company; See PLRP Liens' and [Allocated Amt] is null 
									and [Lien Type] = 'PLRP' then 'Update to FNL in SLAM - not a valid lien'
							When [S3 Product Id] is not null and (stage like 'final%' or stage like 'closed') and [Lien Status] = 'Matched by Rawlings Company; See PLRP Liens' and [Allocated Amt] is null and [Lien Type] = 'PLRP' then 'Ignore - not a valid lien and final/closed in SLAM'
							When Stage is null then 'Look into - SLAM is NULL'
							When Stage like 'Under Review%' then 'SLAM stage is Under Review - look into'
							When Stage like 'Pending%' or Stage like 'To Send - Final%' then 'Look Into - probably a G claimant finalization/pending liens issue'
							When ([Lien Status] = 'Not Entitled' or [Lien Status] = 'No Match with No Interest - Final') and LienProductStatus = 'Open' and Stage like 'Initial%' then 'Look Into - Probably at Initial No Entitlement because not final on report'
							When (ClosedReason not like '' or ClosedReason is not null) and Stage <> 'Closed' then 'Issue - has closed reason but stage is not closed'

						--Liens with no changes; note only
							When [Lien Status] = 'Waived' 
									and LienProductStatus = 'Open' 
									and (Stage = 'Final Demand Received' or Stage = 'Final No Lien Received') 
									then 'Note only - FNL, no change'
							When [Lien Status] = 'Waived' 
									and LienProductStatus = 'Open' 
									and Stage = 'Closed' and ClosedReason = 'Resolved - Final Demand' and LienProductStatus = 'Closed' 
									then 'Note only - FNL, no change'
							When ([Lien Status] = 'Waived' or [Lien Status] = 'Eligible for Payment' or [Lien Status] = 'Satisfied' or [Lien Status] = 'Paid' or [Lien Status] = 'Requested' or [Lien Status] = 'Received') 
									and LienProductStatus = 'Open' 
									and (Stage = 'Final Demand Received' or Stage = 'Final No Lien Received') 
									then 'Note only - FD, no change'
							When ([Lien Status] = 'Waived' or [Lien Status] = 'Eligible for Payment' or [Lien Status] = 'Satisfied' or [Lien Status] = 'Paid' or [Lien Status] = 'Requested' or [Lien Status] = 'Received') 
									and LienProductStatus = 'Closed' and Stage = 'Closed' and ClosedReason like 'Resolved - Final Demand' 
									then 'Note only - Closed/FD, no change'
							When ([Lien Status] = 'Not Entitled' or [Lien Status] = 'No Match with No Interest - Final') and LienProductStatus = 'Open' and Stage = 'Final No Entitlement' then 'Note only - FNE, no change'
							When ([Lien Status] = 'Not Entitled' or [Lien Status] = 'No Match with No Interest - Final') 
									and LienProductStatus = 'Closed' and Stage = 'Closed' and ClosedReason like 'Resolved - No Entitlement' 
									then 'Note only - Closed/FNE, no change'
							When [Lien Status] = 'Matched by Rawlings Company; See PLRP Liens' and [Allocated Amt] is null and [Lien Type] = 'PLRP' then 'Ignore - not a valid lien'
							When [Lien Status] = 'Discharged' and Stage = 'Final No Lien Received' and FinalDemandAmount = 0 then 'Note only - Discharged, no change'
							When [Lien Status] = 'Discharged' and Stage = 'Closed' and ClosedReason = 'Opened in Error' then 'Note only - Discharged, no change'
							When ([Lien Status] like '%Pending%' or [Lien Status] = 'Discrepancy') and Stage = 'Awaiting Information' then 'Note only - pending'

						--Compare Stage Data
							When [Lien Status] = 'Waived' and LienProductStatus = 'Open' and Stage = 'Awaiting Information' then 'Update to FNL'
							When ([Lien Status] = 'Eligible for Payment' or [Lien Status] = 'Satisfied' or [Lien Status] = 'Paid' or [Lien Status] = 'Requested' or [Lien Status] = 'Received') 
									and LienProductStatus = 'Open' 
									and Stage = 'Awaiting Information' 
									then 'Update to FD'
							When ([Lien Status] = 'Not Entitled' or [Lien Status] = 'No Match with No Interest - Final') 
									and LienProductStatus = 'Open' 
									and Stage = 'Awaiting Information' then 'Update to FNE'
							When [Lien Status] = 'Discharged' and Stage = 'Awaiting Information' then 'Update to FNL/Opened in error'
							Else 'Look Into'
							End as 'Stage Comparison',

						--NewLienNote
						Case
							When LienProductStatus = 'Hold' then 'Look into - SLAM status of hold'
							When [Entitlement Response] = 'D' and [Lien Status] = 'Discrepancy' then 'G Tracking - HB Report [date] with a lien status of discrepancy'
							When [Entitlement Response] = 'N' and [Lien Status] = 'Not Entitled' then 'G Tracking - HB Report [date] as not entitled and final'
							When [Entitlement Response] = 'No Match' and [Lien Status] = 'No Match with No Interest - Final' then 'G Tracking - HB Report [date] as not entitled and final'
							When [Lien Status] = 'Pending' then 'G Tracking - HB Report [date] as pending'
							When [Entitlement Response] = 'W' and [Lien Status] = 'Waived' then 'G Tracking - HB Report [date] as yes/waived entitlement and final'
							When [Entitlement Response] = 'Y' 
									and ([Lien Status] = 'Paid' or [Lien Status] = 'Eligible for Payment' or [Lien Status] = 'Received' or [Lien Status] = 'Discharged' or [Lien Status] = 'Requested' or [Lien Status] = 'Satisfied' or [Lien Status] = 'Waived') 
									then 'G Tracking - HB Report [date] as yes entitlement and final'
							When [S3 Product Id] is null and [Lien Status] = 'Matched by Rawlings Company; See PLRP Liens' and [Allocated Amt] is null and [Lien Type] = 'PLRP' then 'Ignore - not a valid lien and does not exist in SLAM'
							When [S3 Product Id] is not null and Stage not like 'final%' and stage not like 'closed' 
									and [Lien Status] = 'Matched by Rawlings Company; See PLRP Liens' and [Allocated Amt] is null and [Lien Type] = 'PLRP' 
									then 'G Tracking - HB Report [date] as final (placeholder PLRP lien)'
							When [S3 Product Id] is not null and (stage like 'final%' or stage like 'closed') and [Lien Status] = 'Matched by Rawlings Company; See PLRP Liens' and [Allocated Amt] is null and [Lien Type] = 'PLRP' 
									then 'G Tracking - HB Report [date] as final (placeholder PLRP lien)'
							When [Lien Status] = 'Discharged' and Stage = 'Closed' and ClosedReason = 'Opened in Error' then 'G Tracking [date] - HB Report as discharged/opened in error/FNL'
							When [Lien Status] = 'Discharged' and Stage = 'Final No Lien Received'  then 'G Tracking [date] - HB Report as discharged/opened in error/FNL'

							Else 'Look Into'
							End As 'NewLienNote'

				from	#Liens_G_Updated as Liens_G LEFT OUTER JOIN
							JB_HBReport_AddLienData as Liens_SLAM on Liens_G.[Entitlement Wave ID] = Liens_SLAM.GLienId
																and Liens_G.[G Id] = Liens_SLAM.GClaimantId

			) as sub








	--QA

		select 
				--Claimant Identification
				HB.[G Id], HB.[G First Name], HB.[G Last Name], HB.[Client Id], F.ClientId, F.GClaimantId,F.FinalizedStatusId, F.ClientPreExistingInjuries,
				--HB.[EIF Claimant?], 

				--Checks on claimant level data
				HB.[SA Match?], HB.[SSN Match?], HB.[G Overall Lien Status ok?], HB.[G Overall Lien HB ok?], HB.[QA on G Data], HB.[Good to Process?],

				--Lien Level Data: G
				HB.[G Current Overall Status], HB.[Entitlement Wave Id], HB.[Lien Type], HB.[Entitlement Response], HB.[Final Lien Amt], HB.[Lien Status],

				--Lien Level Data: SLAM
				F.Id as 'SLAM Lien Id', F.GLienId, F.LienType, F.OnBenefits, F.OnBenefitsVerified, F.FinalDemandAmount, F.FinalGlobalAmount,
				Case
					When F.LienType = 'Medicare - Global' then F.FinalGlobalAmount
					Else F.FinalDemandAmount
					End As 'True FD', 
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
					When HB.[Lien Type] = 'PrivateSELR' and F.LienType = 'Medicare Lien - Part C' then 'Match'
					When F.LienType is null then 'SLAM is NULL'
					Else 'Look Into'
					End as 'LienTypes Match?',
          '' as 'OnBenefits ok?', '' as 'Amounts ok?', '' as 'Stage ok?', '' as 'Issues?', '' as 'Claimant Updated Correctly?'
		from #Liens_G_Updated as HB
				LEFT OUTER JOIN FullProductViews as F on HB.[G ID]=F.GClaimantId and HB.[Entitlement Wave Id]=F.GLienId
		where f.caseid = 3482
		Order By [Client Id], LienType




		--Finalization Check (update case id)
		select Gclaimantid, id, PreExistingInjuries, FinalizedStatusId, ClientHoldbackAmount
		from clients
		where caseid = 3482 and Gclaimantid in (
