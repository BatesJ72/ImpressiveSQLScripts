--1. Import questionnaire data

		--1a. Drop current table
			drop table Questionnaire_BSC_prelim


		--1b. Import new data. Check data for errors. 
			
			select * from Questionnaire_BSC_prelim


			select count(*) from Questionnaire_BSC_prelim


		--1c. Add CaseId to the questionnaire table and create the new base table, Questionnaire_BSC
		
						drop table Questionnaire_BSC

				select distinct F.Casename, Q.* 
				into Questionnaire_BSC
				from Questionnaire_BSC_prelim as Q
						Left Outer Join FullProductViews as F on Q.[S3 Id] = F.ClientId

						
						select * from Questionnaire_BSC
						
						
						select count(*) from Questionnaire_BSC



--2. Analyze Claimant Data and check for major discrepancies
		
			--2a. Create table combining SLAM and questionnaire data

						drop table #ClientCheck1_BSC


					Select	Q.[S3 ID] as 'Q Client Id', C.Id as 'SLAM Client Id', Q.[Claimant First Name], Q.[Claimant Last Name] as Quest_LastName, Q.[Cl SSN] as Quest_SSN, Q.[Archer ID], 
							C.LastName as SLAM_LastName, C.SSN as SLAM_SSN, C.ThirdPartyId,
							Case
								When C.ThirdPartyId is null and C.FirstName is null and C.LastName is null then 'Issue - Claimant not in SLAM'
								Else 'Claimant is in SLAM'
								End As 'Claimant in SLAM?',
							Case	
								When Q.[Cl SSN] <> C.SSN and (Q.[Cl SSN] is not null or Q.[Cl SSN] <> '' or Q.[Cl SSN] <> 'NULL') then 'Issue - SSN mismatch'
								When Q.[Cl SSN] = C.SSN and (Q.[Cl SSN] is not null or Q.[Cl SSN] <> '' or Q.[Cl SSN] <> 'NULL') then 'Good - SSN match'
								When (Q.[Cl SSN] is null or Q.[Cl SSN] = '' or Q.[Cl SSN] = 'NULL') and Q.[Archer ID] = C.ThirdPartyid then 'Good - Third Party Id Match, No SSN'
								When (Q.[Cl SSN] is null or Q.[Cl SSN] = '' or Q.[Cl SSN] = 'NULL') and Q.[Archer ID] <> C.ThirdPartyid then 'Issue - Third Party Id Mismatch, No SSN'
								Else 'Issue - Look Into'
								End As 'SSN or ThirdPartyId Match?',
							Case
								When Q.[Claimant Last Name] = C.LastName then 'Match'
								When SOUNDEX(Q.[Claimant Last Name]) = soundex(c.lastname) then 'Check, but probably ok'
								Else 'Issue - Lastname mismatch'
								End As 'Last Name Match?'
					Into	#ClientCheck1_BSC
					From	Questionnaire_BSC as Q  
								LEFT JOIN Clients as C on Q.[S3 ID] = C.Id


								select * from #ClientCheck1_BSC

								select * from #ClientCheck1_BSC where [SSN or ThirdPartyId Match?] like 'Issue%' or [Last Name Match?] like 'Check%' or [Last Name Match?] like 'Issue%' or [Claimant in SLAM?] like 'Issue%'

								select count(*) from #ClientCheck1_BSC
								


						--Review Last Name "Checks" and Mismatches!!
								select * from #ClientCheck1_BSC where [Last Name Match?] like 'Check%'
								

									select * from Questionnaire_BSC where [S3 ID] = 226938

									update Questionnaire_BSC 
									set [Claimant Last Name] = 'Christiansen (Sheets)'
									where [S3 ID] = 225293
							


			--2b. Identify Claimants who have a SSN or last name mismatch or is not in SLAM

							drop table #Discrepancy1_BSC


					Select	*, 
							case
								when [SSN or ThirdPartyId Match?] like 'Issue%' or [Last Name Match?] like 'Check%' or [Last Name Match?] like 'Issue%' or [Claimant in SLAM?] like 'Issue%' then 'Issue - Data on spreadsheet does not match claimant data in SLAM' 
								when [SSN or ThirdPartyId Match?] like 'Good%' or [Last Name Match?] = 'Match' and [Claimant in SLAM?] = 'Claimant is in SLAM' then 'No Issue' 
								else 'Look Into'
								End as 'Issue Detail: Claimant data does not match SLAM'
					Into	#Discrepancy1_BSC
					From	#ClientCheck1_BSC
				


					select * from  #Discrepancy1_BSC where [Issue Detail: Claimant data does not match SLAM] <> 'No Issue'


			--2b1. Leave note CSV for client level discrepancy in 2b
					
				Select	[SLAM Client Id] as Id, 
						Case
							When [Issue Detail: Claimant data does not match SLAM] like 'Issue%' then 'Questionnaire processing issue: Data on spreadsheet does not match claimant data in SLAM' 
							Else 'Look Into'
							End As 'NewClientNote'
				From	#Discrepancy1_BSC
				Where	[Issue Detail: Claimant data does not match SLAM] <> 'No Issue'




			--2c. Create temp table to check that each Client Id shows up only once
			
							drop table #ClientCheck2_BSC


					Select	sub.*,
							Case
								When sub.[Count of Client Id] = 1 then 'Good'
								Else 'Issue'
								End As 'Client Id Count Good?'
					Into #ClientCheck2_BSC
					From 
							(
							Select	[S3 ID], Count([S3 ID]) as 'Count of Client Id'
							From	Questionnaire_BSC 
							Group by [S3 ID]
							) as sub



							select * from #ClientCheck2_BSC where [Client Id Count Good?] <> 'Good'




			--2d. Identify claimants whose ClientId appears more than once

							drop table #Discrepancy2_BSC


					Select	*, 
							case 
								when [Client Id Count Good?] <> 'Good'  then 'Claimant is on spreadsheet more than once'
								when [Client Id Count Good?] = 'Good'  then 'No Issue'
								Else 'Look Into'
								End As 'Issue Detail: Duplicate Records'
					Into	#Discrepancy2_BSC
					From	#ClientCheck2_BSC
				
			

						select * from #Discrepancy2_BSC where [Issue Detail: Duplicate Records] <> 'No Issue'


			--2e. Leave note CSV for client level discrepancy in 2d
								
					Select	[S3 ID] as Id, 'Questionnaire processing issue: Claimant is on spreadsheet more than once' as 'NewClientNote'
					From	#ClientCheck2_BSC
					Where	[Client Id Count Good?] = 'Issue'




			--2f. Find claimants with Misc. Discrepancies from instructions 
					

								drop table #Discrepancy3_BSC


					Select	[S3 ID], [Claimant Last Name], [Claimant First Name], [Scribbles?], 
							Case
								When [Scribbles?] is not null  then 'Issue - Has scribbles'
								When [Scribbles?] is null then 'No Issue'
								Else 'Look Into'
								End As 'Issue Detail: Scribbles?'
					Into	#Discrepancy3_BSC
					From	Questionnaire_BSC




						select	* 
						from	#Discrepancy3_BSC 
						where	[Issue Detail: Scribbles?] not like 'No Issue'
								

						 
								
					

			--2g. Leave note CSV for client level discrepancy in 2f
			
				Select	[S3 ID] as Id, 
						'Questionnaire processing issue: According to instructions was not able to process questionnaire data for claimant (scribbles)' As 'NewClientNote'
				From	#Discrepancy3_BSC
				Where	[Issue Detail: Scribbles?] not like 'No Issue'

				



			--2h. Find any claimants who currently have questionnaire rec'd marked as true in SLAM

							drop table #Discrepancy4_BSC


					select	Q.[S3 ID] as 'ClientId', C.QuestionnaireReceived, 
							case
								when C.QuestionnaireReceived = 1 then 'Claimant already has questionnaire received marked as true in SLAM' 
								when C.QuestionnaireReceived <> 1 or C.QuestionnaireReceived is null then 'No Issue'
								Else 'Look Into'
								End as 'Issue Detail: Quest Recd already true in SLAM'
					into	#Discrepancy4_BSC
					from	Clients as C
								INNER JOIN Questionnaire_BSC as Q on C.Id = Q.[S3 ID]
	
				

					select * from #Discrepancy4_BSC where [Issue Detail: Quest Recd already true in SLAM] <> 'No Issue'


			--2i. Leave note CSV for client level discrepancy in 2h

					select	Q.[S3 ID] as 'Id', 'Questionnaire processing issue: Claimant already has questionnaire received marked as true in SLAM. Per AK, will not process second questionnaire.' as 'NewClientNote'
					from	Clients as C
								INNER JOIN Questionnaire_BSC as Q on C.Id = Q.[S3 ID]
					where	C.QuestionnaireReceived = 1



			--2j. Compile a discrepancy report


						drop table #AllTheDiscrepancies_BSC


					select	distinct Q.CaseName, Q.[S3 ID] as 'Client Id', Q.[Claimant Last Name], Q.[Claimant First Name],-- Q.[Which Report?],
							D1.Quest_SSN, D1.SLAM_SSN, D1.[Archer ID], D1.ThirdPartyId,
							D1.[Issue Detail: Claimant data does not match SLAM],
							D1.[Claimant in SLAM?], D1.[SSN or ThirdPartyId Match?], D1.[Last Name Match?],
							D2.[Issue Detail: Duplicate Records], 
							D3.[Scribbles?], 
							D3.[Issue Detail: Scribbles?], 
							D4.[Issue Detail: Quest Recd already true in SLAM]
					into	#AllTheDiscrepancies_BSC
					from	Questionnaire_BSC as Q
								LEFT OUTER JOIN #Discrepancy1_BSC as D1 on D1.[Q Client Id] = Q.[S3 ID]
								LEFT OUTER JOIN #Discrepancy2_BSC as D2 on D2.[S3 ID] = Q.[S3 ID]
								LEFT OUTER JOIN #Discrepancy3_BSC as D3 on D3.[S3 ID] = Q.[S3 ID]
								LEFT OUTER JOIN #Discrepancy4_BSC as D4 on D4.[ClientId] = Q.[S3 ID]
					where	D1.[Issue Detail: Claimant data does not match SLAM] <> 'No Issue' or 
							D2.[Issue Detail: Duplicate Records] <> 'No Issue' or 
							D3.[Issue Detail: Scribbles?] <> 'No Issue' or 
							D4.[Issue Detail: Quest Recd already true in SLAM] <> 'No Issue'


							select * from #AllTheDiscrepancies_BSC

							select count(*) from #AllTheDiscrepancies_BSC
							

							--2j1: Discrepancy report for CM to review
						
						select	*
						from	#AllTheDiscrepancies_BSC 
						where	[Issue Detail: Quest Recd already true in SLAM] = 'no issue'



						--2j1: Discrepancy report to notify CM that the claimant already had questionnaire rec'd as true
						
						select	*
						from	#AllTheDiscrepancies_BSC 
						where	[Issue Detail: Quest Recd already true in SLAM] <> 'no issue'





							--Clear out discrepancy table when processing questionnaire discrepancy report

								delete from #AllTheDiscrepancies_BSC where [Issue Detail: Quest Recd already true in SLAM] = 'No Issue' and [Issue Detail: Scribbles?] = 'Issue - Has scribbles'


								select * from #AllTheDiscrepancies_BSC




	--3. Analyze Military Data

			--3a. Analyze military data on spreadsheet with instructions

							drop table #MilitaryAnalysis_BSC


					select	CaseName, [S3 ID], [Claimant Last Name], [Claimant First Name], [Eligible Tricare, VA, HIS?], [Branch of Military], [Type military Ins], [DOD ID #], [City/State Treated], [Referring Facilities], [Tribal Details], [Spons Name], [Spons Relation], [Spons Last 4 SSN], [Spons DOB], [Spons DOD ID #],
							Case
								When [Eligible Tricare, VA, HIS?] = 'Truthy' and ([Branch of Military] is not null or [Type military Ins] is not null or [DOD ID #] is not null or [City/State Treated] is not null or [Referring Facilities] is not null or [Tribal Details] is not null or [Spons Name] is not null or [Spons Relation] is not null or [Spons Last 4 SSN] is not null or [Spons DOB] is not null or [Spons DOD ID #] is not null) then 'M1'
								When [Eligible Tricare, VA, HIS?] = 'Truthy' and [Branch of Military] is null and [Type military Ins] is null and [DOD ID #] is null and [City/State Treated] is null and [Referring Facilities] is null and [Tribal Details] is null and [Spons Name] is null and [Spons Relation] is null and [Spons Last 4 SSN] is null and [Spons DOB] is null and [Spons DOD ID #] is null then 'M2' 
								When [Eligible Tricare, VA, HIS?] = 'Falsey' and ([Branch of Military] is not null or [Type military Ins] is not null or [DOD ID #] is not null or [City/State Treated] is not null or [Referring Facilities] is not null or [Tribal Details] is not null or [Spons Name] is not null or [Spons Relation] is not null or [Spons Last 4 SSN] is not null or [Spons DOB] is not null or [Spons DOD ID #] is not null) then 'M3'
								When [Eligible Tricare, VA, HIS?] = 'Falsey' and [Branch of Military] is null and [Type military Ins] is null and [DOD ID #] is null and [City/State Treated] is null and [Referring Facilities] is null and [Tribal Details] is null and [Spons Name] is null and [Spons Relation] is null and [Spons Last 4 SSN] is null and [Spons DOB] is null and [Spons DOD ID #] is null then 'M4'
								When [Eligible Tricare, VA, HIS?] = 'Blanky' and ([Branch of Military] is not null or [Type military Ins] is not null or [DOD ID #] is not null or [City/State Treated] is not null or [Referring Facilities] is not null or [Tribal Details] is not null or [Spons Name] is not null or [Spons Relation] is not null or [Spons Last 4 SSN] is not null or [Spons DOB] is not null or [Spons DOD ID #] is not null) then 'M5'
								When [Eligible Tricare, VA, HIS?] = 'Blanky' and [Branch of Military] is null and [Type military Ins] is null and [DOD ID #] is null and [City/State Treated] is null and [Referring Facilities] is null and [Tribal Details] is null and [Spons Name] is null and [Spons Relation] is null and [Spons Last 4 SSN] is null and [Spons DOB] is null and [Spons DOD ID #] is null then 'M6'							Else 'Look Into'
								End as 'Military Analysis'
					Into	#MilitaryAnalysis_BSC
					from	Questionnaire_BSC



						select * from  #MilitaryAnalysis_BSC

						select * from  #MilitaryAnalysis_BSC where [Eligible Tricare, VA, HIS?] is null

						select distinct [Eligible Tricare, VA, HIS?] from  #MilitaryAnalysis_BSC 

						select distinct [Military Analysis] from  #MilitaryAnalysis_BSC 


			--3b. QA Summary

					--Summary: All
					select	M.CaseName, [S3 ID], [Military Analysis],
							D.[Issue Detail: Claimant data does not match SLAM],
							D.[Issue Detail: Duplicate Records],
							D.[Issue Detail: Scribbles?],
							D.[Issue Detail: Quest Recd already true in SLAM]
					from	#MilitaryAnalysis_BSC as M
								LEFT OUTER JOIN #AllTheDiscrepancies_BSC as D on D.[Client Id]=M.[S3 ID]
						
						
					--Summary: Liens that need to be created
						--# of Military liens to create
						select	M.CaseName, [S3 ID], [Military Analysis],
								D.[Issue Detail: Claimant data does not match SLAM],
								D.[Issue Detail: Duplicate Records],
								D.[Issue Detail: Scribbles?],
								D.[Issue Detail: Quest Recd already true in SLAM]
						from #MilitaryAnalysis_BSC as M
								LEFT OUTER JOIN #AllTheDiscrepancies_BSC as D on D.[Client Id]=M.[S3 ID]
						Where (M.[Military Analysis] = 'M1' or M.[Military Analysis] = 'M2' or M.[Military Analysis] = 'M3' or M.[Military Analysis] = 'M5') 
								and D.[Client Id] is null
						


			--3c. Find claimants who already have a Military or IHS lien in SLAM. 

					Select	F.ClientId, F.Id as 'SLAM Lien Id', F.LienType, F.Stage, M.*
					From	#MilitaryAnalysis_BSC as M 
								LEFT OUTER JOIN FullProductViews as F on M.[S3 ID]=F.ClientId
								LEFT OUTER JOIN #AllTheDiscrepancies_BSC as D on M.[S3 ID]=D.[Client Id]
					Where	(F.Lientype like 'Military%' or F.LienType like 'ihs%')
							and (M.[Military Analysis] = 'M1' or M.[Military Analysis] = 'M2' or M.[Military Analysis] = 'M3' or M.[Military Analysis] = 'M5')
							and D.[Client Id] is null

							

			--3d. Create liens CSV for M1, M3, and M5
					select	[S3 ID] as ClientId, 'Military Lien - MT' as 'LienType', '1599' as 'LienholderId', '1214' as 'CollectorId', 
							Case
								When M.Casename = 'BSC' then 89
								When M.Casename = 'BSC - GRG' then 141 
								Else 'Look Into'
								End as 'AssignedUserId', 
							'To Send - EV' as 'Stage', 'Open' as 'LienProductStatus', 'Yes' as 'OnBenefits', cast(getdate() as date) as 'OnBenefitsVerified'
					From	#MilitaryAnalysis_BSC as M
								LEFT OUTER JOIN #AllTheDiscrepancies_BSC as D on M.[S3 ID]=D.[Client Id]
					Where	(M.[Military Analysis] = 'M1' or M.[Military Analysis] = 'M3' or M.[Military Analysis] = 'M5')
							and D.[Client Id] is null



			--3e. NewLienNote CSV for M1, M3, and M5: Get newly created Ids and leave note

					select	F.Id, Concat('Created lien based on claimant questionnaire. Other information given was- Branch of Military: ',[Branch of Military], '; Type military Ins:', [Type military Ins], '; DOD ID #: ',[DOD ID #], '; City/State Treated: ', [City/State Treated], '; Referring Facilities: ',[Referring Facilities], '; Tribal Details: ', [Tribal Details], '; Spons Name: ',[Spons Name], '; Spons Relation: ',[Spons Relation], '; Spons Last 4 SSN: ', [Spons Last 4 SSN],'; Spons DOB: ', [Spons DOB], '; Spons DOD ID #: ', [Spons DOD ID #], '.') as 'NewLienNote'
					from	Fullproductviews as F 
								LEFT OUTER JOIN #MilitaryAnalysis_BSC as M on M.[S3 ID]=F.ClientId
					where	(M.[Military Analysis] = 'M1' or M.[Military Analysis] = 'M3' or M.[Military Analysis] = 'M5')
							and F.createdon = cast(getdate() as date) and (F.lientype like 'military%' or f.lientype like 'ihs%')
			



										
			--3f. Create liens CSV for M2
					select	[S3 ID] as ClientId, 'Military Lien - MT' as 'LienType', '1599' as 'LienholderId', '1214' as 'CollectorId',
							 Case
								When M.Casename = 'BSC' then 89
								When M.Casename = 'BSC - GRG' then 141 
								Else 'Look Into'
								End as 'AssignedUserId', 
							'Awaiting Sponsor/Facility Information' as 'Stage', 'Open' as 'LienProductStatus', 'Yes' as 'OnBenefits', cast(getdate() as date) as 'OnBenefitsVerified'
					From	#MilitaryAnalysis_BSC as M
								LEFT OUTER JOIN #AllTheDiscrepancies_BSC as D on D.[Client Id]=M.[S3 ID]
					Where	M.[Military Analysis] = 'M2'
							and D.[Client Id] is null



			--3g. NewLienNote CSV for M2

					select	F.Id, 'Created lien based on claimant questionnaire. No military info input on questionnaire but claimant indicated they are on benefits.' as 'NewLienNote'
					from	Fullproductviews as F 
								LEFT OUTER JOIN #MilitaryAnalysis_BSC as M on M.[S3 ID]=F.ClientId
					where	M.[Military Analysis] = 'M2' 
							and F.CreatedOn = cast(getdate() as date) and F.LienType like 'military%'
						





	--4. Private Lien Analysis
			
			--4a. Analyze private lien data on spreadsheet with instructions


							drop table #PrivateAnalysis_BSC

							
					select	distinct CaseName, [S3 ID], [Claimant Last Name], [Claimant First Name], [Which Questionnaire?],
							[Plan on notice?], 
							[Inco 1 Name], [Inco 1 Address], [Inco 1 Phone], [Inco 1 Gr #], [Inco 1 ID #], 
							[Inco 2 Name], [Inco 2 Address], [Inco 2 Phone], [Inco 2 Gr #], [Inco 2 ID #], 
							[Inco 3 Name], [Inco 3 Address], [Inco 3 Phone], [Inco 3 Gr #], [Inco 3 ID #], 
							Case
								When [Plan on notice?] = 'Truthy' and ([Inco 1 Name] is not null or [Inco 1 Address] is not null or [Inco 1 Phone] is not null or [Inco 1 Gr #] is not null or [Inco 1 ID #] is not null or [Inco 2 Name] is not null or [Inco 2 Address] is not null or [Inco 2 Phone] is not null or [Inco 2 Gr #] is not null or [Inco 2 ID #] is not null or [Inco 3 Name] is not null or [Inco 3 Address] is not null or [Inco 3 Phone] is not null or [Inco 3 Gr #] is not null or [Inco 3 ID #] is not null) then 'Private 1'
								When [Plan on notice?] = 'Truthy' and [Inco 1 Name] is null and [Inco 1 Address] is null and [Inco 1 Phone] is null and [Inco 1 Gr #] is null and [Inco 1 ID #] is null and [Inco 2 Name] is null and [Inco 2 Address] is null and [Inco 2 Phone] is null and [Inco 2 Gr #] is null and [Inco 2 ID #] is null and [Inco 3 Name] is null and [Inco 3 Address] is null and [Inco 3 Phone] is null and [Inco 3 Gr #] is null and [Inco 3 ID #] is null then 'Private 2'
								When [Plan on notice?] = 'Falsey' and ([Inco 1 Name] is not null or [Inco 1 Address] is not null or [Inco 1 Phone] is not null or [Inco 1 Gr #] is not null or [Inco 1 ID #] is not null or [Inco 2 Name] is not null or [Inco 2 Address] is not null or [Inco 2 Phone] is not null or [Inco 2 Gr #] is not null or [Inco 2 ID #] is not null or [Inco 3 Name] is not null or [Inco 3 Address] is not null or [Inco 3 Phone] is not null or [Inco 3 Gr #] is not null or [Inco 3 ID #] is not null) then 'Private 3'
								When [Plan on notice?] = 'Falsey' and [Inco 1 Name] is null and [Inco 1 Address] is null and [Inco 1 Phone] is null and [Inco 1 Gr #] is null and [Inco 1 ID #] is null and [Inco 2 Name] is null and [Inco 2 Address] is null and [Inco 2 Phone] is null and [Inco 2 Gr #] is null and [Inco 2 ID #] is null and [Inco 3 Name] is null and [Inco 3 Address] is null and [Inco 3 Phone] is null and [Inco 3 Gr #] is null and [Inco 3 ID #] is null then 'Private 4'
								When [Plan on notice?] = 'Blanky' and ([Inco 1 Name] is not null or [Inco 1 Address] is not null or [Inco 1 Phone] is not null or [Inco 1 Gr #] is not null or [Inco 1 ID #] is not null or [Inco 2 Name] is not null or [Inco 2 Address] is not null or [Inco 2 Phone] is not null or [Inco 2 Gr #] is not null or [Inco 2 ID #] is not null or [Inco 3 Name] is not null or [Inco 3 Address] is not null or [Inco 3 Phone] is not null or [Inco 3 Gr #] is not null or [Inco 3 ID #] is not null) then 'Private 5'
								When [Plan on notice?] = 'Blanky' and [Inco 1 Name] is null and [Inco 1 Address] is null and [Inco 1 Phone] is null and [Inco 1 Gr #] is null and [Inco 1 ID #] is null and [Inco 2 Name] is null and [Inco 2 Address] is null and [Inco 2 Phone] is null and [Inco 2 Gr #] is null and [Inco 2 ID #] is null and [Inco 3 Name] is null and [Inco 3 Address] is null and [Inco 3 Phone] is null and [Inco 3 Gr #] is null and [Inco 3 ID #] is null then 'Private 6'
								Else 'Look Into'
								End as 'Private Lien Analysis'
						Into	#PrivateAnalysis_BSC
						from	Questionnaire_BSC
						

						SELECT * FROM #PrivateAnalysis_BSC

						select [Private Lien Analysis], count([s3 id]) 
						from #PrivateAnalysis_BSC
						Group by [Private Lien Analysis]


						select * from #PrivateAnalysis_BSC where [Private Lien Analysis] = 'look into'


			--4b. QA: How many private liens should be created?

				--Summary: All
				select	P.[S3 ID], P.[Private Lien Analysis], 
						D.[Issue Detail: Claimant data does not match SLAM],
						D.[Issue Detail: Duplicate Records],
						D.[Issue Detail: Scribbles?],
						D.[Issue Detail: Quest Recd already true in SLAM]
				from	#PrivateAnalysis_BSC as P
							LEFT OUTER JOIN #AllTheDiscrepancies_BSC as D on D.[Client Id]=P.[S3 ID]


				--Summary: Liens that need to be created
				select	P.[S3 ID], P.[Private Lien Analysis], 
						D.[Issue Detail: Claimant data does not match SLAM],
						D.[Issue Detail: Duplicate Records],
						D.[Issue Detail: Scribbles?],
						D.[Issue Detail: Quest Recd already true in SLAM]
				from	#PrivateAnalysis_BSC as P
								LEFT OUTER JOIN #AllTheDiscrepancies_BSC as D on D.[Client Id]=P.[S3 ID]
				where	(P.[Private Lien Analysis] = 'Private 1' or P.[Private Lien Analysis] = 'Private 2')
						and D.[Client Id] is null


		--4c. Create file to send to RA for private lien analysis for Private 1

				--Query to get all current SLAM data for non-governmental liens (creates temp table)
					

					drop table #PrivateSLAM_BSC


				SELECT		F.ClientId as 'S3 Client Id', F.ClientFirstName, F.ClientLastName, F.Id as 'S3 Product Id', F.LienType, 
							F.LienholderName, F.LienholderId, F.CollectorName, F.CollectorId, F.LienProductStatus, F.Stage, 
							F.ClosedReason, F.FinalDemandAmount, F.CaseName, F.AssignedUserId, 
							D.[Issue Detail: Claimant data does not match SLAM],
							D.[Issue Detail: Duplicate Records],
							D.[Issue Detail: Scribbles?],
							D.[Issue Detail: Quest Recd already true in SLAM]
				INTO		#PrivateSLAM_BSC
				FROM		FullProductViews as F 
								INNER JOIN #PrivateAnalysis_BSC as P on P.[S3 ID]=F.[ClientId]
								LEFT OUTER JOIN #AllTheDiscrepancies_BSC as D on D.[Client Id]=P.[S3 ID]
				WHERE		Lientype not like 'Medicare - Global' and lientype not like 'Medicaid Lien - MT' and lientype not like 'military%' and lientype not like 'ihs%'
							and P.[Private Lien Analysis] = 'Private 1' 
							and D.[Client Id] is null
				GROUP BY	ClientId, ClientFirstName, ClientLastName, Id, LienType, LienholderName, LienholderId, CollectorName, CollectorId, LienProductStatus, Stage, 
							ClosedReason, FinalDemandAmount, F.CaseName, AssignedUserId, D.[Issue Detail: Claimant data does not match SLAM],
							D.[Issue Detail: Duplicate Records],
							D.[Issue Detail: Scribbles?],
							D.[Issue Detail: Quest Recd already true in SLAM]
				ORDER BY	3



						select * from #PrivateSLAM_BSC



				--Creates spreadsheet to send to RA
					
				SELECT		P.[S3 ID], P.[Claimant Last Name], P.[Claimant First Name], count(S.[S3 Client Id]) as 'Current SLAM non-govntl lien count', 
							P.[Plan on notice?], 
							P.[Inco 1 Name], P.[Inco 1 Address], P.[Inco 1 Phone], P.[Inco 1 Gr #], P.[Inco 1 ID #], '' as 'Create Lien 1', '' as 'RA Notes 1','' as 'LienHolderId 1', '' as 'CollectorId 1', '' as 'AssignedUserId 1',
							P.[Inco 2 Name], P.[Inco 2 Address], P.[Inco 2 Phone], P.[Inco 2 Gr #], P.[Inco 2 ID #], '' as 'Create Lien 2', '' as 'RA Notes 2','' as 'LienHolderId 2', '' as 'CollectorId 2', '' as 'AssignedUserId 2',
							P.[Inco 3 Name], P.[Inco 3 Address], P.[Inco 3 Phone], P.[Inco 3 Gr #], P.[Inco 3 ID #], '' as 'Create Lien 3', '' as 'RA Notes 3','' as 'LienHolderId 3', '' as 'CollectorId 3', '' as 'AssignedUserId 3',
							D.[Issue Detail: Claimant data does not match SLAM],
							D.[Issue Detail: Duplicate Records],
							D.[Issue Detail: Scribbles?],
							D.[Issue Detail: Quest Recd already true in SLAM]
				FROM 		#PrivateAnalysis_BSC as P 
								LEFT OUTER JOIN #PrivateSLAM_BSC as S on P.[S3 ID]=S.[S3 Client Id]
								LEFT OUTER JOIN #AllTheDiscrepancies_BSC as D on D.[Client Id]=P.[S3 ID]
				WHERE		P.[Private Lien Analysis] = 'Private 1' 
							and D.[Client Id] is null
				GROUP BY	P.[S3 ID], P.[Claimant Last Name], P.[Claimant First Name], P.[Plan on notice?], 
							P.[Inco 1 Name], P.[Inco 1 Address], P.[Inco 1 Phone], P.[Inco 1 Gr #], P.[Inco 1 ID #], 
							P.[Inco 2 Name], P.[Inco 2 Address], P.[Inco 2 Phone], P.[Inco 2 Gr #], P.[Inco 2 ID #], 
							P.[Inco 3 Name], P.[Inco 3 Address], P.[Inco 3 Phone], P.[Inco 3 Gr #], P.[Inco 3 ID #], 
							D.[Issue Detail: Claimant data does not match SLAM],
							D.[Issue Detail: Duplicate Records],
							D.[Issue Detail: Scribbles?],
							D.[Issue Detail: Quest Recd already true in SLAM]
					


				--Other tab for RA with current lien data in SLAM

				select	[S3 Client Id],ClientFirstName, ClientLastName, [S3 Product Id], LienType, LienHolderName, LienholderId, CollectorName, CollectorId, LienProductStatus, Stage, ClosedReason, FinalDemandAmount, P.CaseName, AssignedUserId
				from	#PrivateSLAM_BSC as P
							LEFT OUTER JOIN #AllTheDiscrepancies_BSC as D on D.[Client Id]=P.[S3 Client Id]
				where	D.[Client Id] is null




				--NewClientNote for claimants who had data sent to RA

				SELECT	P.[S3 ID] as Id, CONCAT('Questionnaire Processed ',cast(getdate() as date),'. Claimant opted in to private lien resolution. Provided insurance info sent to RA for review ',cast(getdate() as date),'.') as NewClientNote
				FROM 	#PrivateAnalysis_BSC as P 
							LEFT OUTER JOIN #AllTheDiscrepancies_BSC as D on D.[Client Id]=P.[S3 ID]
				WHERE	P.[Private Lien Analysis] = 'Private 1' 
						and D.[Client Id] is null



		--4d. Create opt-in/out CSV
		

				select	C.Id, C.AdditionalInformation as 'Current AdditionalInfo',
						Case
							When P.[Private Lien Analysis] = 'Private 4' or P.[Private Lien Analysis] = 'Private 6' or P.[Private Lien Analysis] = 'Private 3' or P.[Private Lien Analysis] = 'Private 5' then 'Opt-Out'
							When P.[Private Lien Analysis] = 'Private 1' or P.[Private Lien Analysis] = 'Private 2' then 'Opt-In'
							Else 'Look Into'
							End As 'Opt In/Out',
						Case
							When (C.AdditionalInformation = '' or C.AdditionalInformation is null or C.AdditionalInformation = 'NULL') and (P.[Private Lien Analysis] = 'Private 3' or P.[Private Lien Analysis] = 'Private 4' or P.[Private Lien Analysis] = 'Private 5' or P.[Private Lien Analysis] = 'Private 6') then 'Opt-Out'
							When (C.AdditionalInformation = '' or C.AdditionalInformation is null or C.AdditionalInformation = 'NULL') and (P.[Private Lien Analysis] = 'Private 1' or P.[Private Lien Analysis] = 'Private 2') then 'Opt-In'
							When C.AdditionalInformation is not null or C.AdditionalInformation <> '' then 'Check'
							Else 'Look Into'
							End As 'Updated AdditionalInformation',
						Case
							When P.[Private Lien Analysis] = 'Private 4' or P.[Private Lien Analysis] = 'Private 6' or P.[Private Lien Analysis] = 'Private 3' or P.[Private Lien Analysis] = 'Private 5' then concat('Questionnaire Processed ',cast(getdate() as date),'. Claimant opted out of Private and Part C lien resolution per questionnaire.')
							when P.[Private Lien Analysis] = 'Private 1'  then concat('Questionnaire Processed ',cast(getdate() as date),'. Claimant opted in for Private Lien Resolution.') 
							when P.[Private Lien Analysis] = 'Private 2' then concat('Questionnaire Processed ',cast(getdate() as date),'. Claimant opted in and didn’t provide ins info. Per AWKO, claimant should be submitted to Rawlings PLRP.') 
							Else 'Look Into'
							End as 'NewClientNote'
				from	clients as C 
							INNER JOIN #PrivateAnalysis_BSC as P on P.[S3 ID]=C.Id
							LEFT OUTER JOIN #AllTheDiscrepancies_BSC as D on D.[Client Id]=P.[S3 ID]
				where	D.[Client Id] is null



		--4e. Create placeholder Private Lien - PLRP for P2


				--4e pt 1: Check for any current Private or Part C liens
						
						--Create temp table
									
									drop table #BSC_P2
							
							select	
									--Claimant Questionnaire Data
									P.[S3 ID], P.[Claimant Last Name], P.[Claimant First Name], 
									--Liens currently in SLAM
									FPV.Id as LienId, FPV.LienType,
									Case
										When lientype like '%plrp%' then 'PLRP'
										Else 'Not PLRP'
										End As 'LienType_Updated'
							into	#BSC_P2		
							from	#PrivateAnalysis_BSC as P
										LEFT OUTER JOIN #AllTheDiscrepancies_BSC as D on D.[Client Id]=P.[S3 ID]
										LEFT OUTER JOIN FullProductViews as FPV on FPV.ClientId=P.[S3 ID]
							where 	[Private Lien Analysis] = 'Private 2'
									and D.[Client Id] is null


									select * from #BSC_P2
									

						--Pivot data
								
								drop table #BSC_P2Pivot
							

							select sub.[S3 ID], sub.[Claimant Last Name], sub.[Claimant First Name], sum(sub.[PLRP]) as PLRP_Total, sum(sub.[Not_PLRP]) as NotPLRP_Total
							into #BSC_P2Pivot
							from (
									select *
									from #BSC_P2
											PIVOT (
													count(LienId) 
													for LienType_Updated 
													in ([Not_PLRP], [PLRP])
													) as LienCount
									) as sub
							group by sub.[S3 ID], sub.[Claimant Last Name], sub.[Claimant First Name]



										select * from #BSC_P2Pivot



					--4e pt 2: Use the pivoted data to determine who needs liens created and make a PLRP lien for them

							select	P.[S3 ID] as ClientId, 'Private Lien - PLRP' as 'LienType', '214' as 'LienholderId', '227' as 'CollectorId', '269' as 'AssignedUserId', 'To Send - EV' as 'Stage', 'Open' as 'LienProductStatus'
							From	#PrivateAnalysis_BSC as P
										LEFT OUTER JOIN #AllTheDiscrepancies_BSC as D on D.[Client Id]=P.[S3 ID]
										LEFT OUTER JOIN #BSC_P2Pivot as Piv on Piv.[S3 ID]=P.[S3 ID]
							Where	[Private Lien Analysis] = 'Private 2'
									and D.[Client Id] is null
									and Piv.PLRP_Total = 0



		--4f. NewLienNote CSV for P2: Get newly created Ids and leave note (from 4e)

				select	F.Id, concat('Created lien based on claimant questionnaire. Questionnaire Processed ',cast(getdate() as date),'. Claimant opted in and didn’t provide ins info. Sent report to Settlement Manager.') as 'NewLienNote'
				from	Fullproductviews as F 
							LEFT OUTER JOIN #PrivateAnalysis_BSC as P on P.[S3 ID]=F.ClientId
							LEFT OUTER JOIN #AllTheDiscrepancies_BSC as D on D.[Client Id]=P.[S3 ID]
				Where	[Private Lien Analysis] = 'Private 2'
						and F.CreatedOn = cast(getdate() as date) and F.LienType like 'Private Lien - PLRP'
						and D.[Client Id] is null




		--4g. NewLienNote CSV for P2 where claimant already had a Private/PLRP lien (from 4e)

				select	F.Id, concat('Created lien based on claimant questionnaire. Questionnaire Processed ',cast(getdate() as date),'. Claimant opted in and didn’t provide ins info. Per AWKO, claimant should be submitted to Rawlings PLRP. Claimant previously submitted to PLRP.') as 'NewLienNote'
				from	Fullproductviews as F 
							LEFT OUTER JOIN #PrivateAnalysis_BSC as P on P.[S3 ID]=F.ClientId
							LEFT OUTER JOIN #AllTheDiscrepancies_BSC as D on D.[Client Id]=F.ClientId
							LEFT OUTER JOIN #BSC_P2Pivot as Piv on Piv.[S3 ID]=F.ClientId
				Where	[Private Lien Analysis] = 'Private 2'
						and D.[Client Id] is null
						and Piv.PLRP_Total > 0
						and F.LienType like '%PLRP%'




		--4g. Gather Part C data to send to Cathy for review

					drop table #PartCEntitlement_BSC


				--Check: Does anyone in the batch have a Part C lien?

					select ClientId, Id, LienType
					from FullProductViews as F
							join Questionnaire_BSC as Q on Q.[S3 ID]=F.ClientId
					where lientype like '%part c%'



			--Main Query
				
				select	ClientId, 
						Case
							When Lientype = 'Medicare - Global' and PartCEntitlementStart is null and OnBenefits = 'Yes' then 'Not entitled for Part C'
							When Lientype = 'Medicare - Global' and PartCEntitlementStart is not null and OnBenefits = 'Yes' then 'Entitled for Part C'
							When Lientype = 'Medicare - Global' and OnBenefits = 'No' then 'FNE for Medicare'
							When Lientype = 'Medicare - Global' and OnBenefits is null then 'No response from Medicare yet'
							Else 'Look Into'
							End As 'Detail for CE - Part C Entitlement'
				Into	#PartCEntitlement_BSC
				From	FullProductViews
				Where	Lientype = 'Medicare - Global' and CaseId in (2770,2741)



				select	sub.*, 
						Case
							When sub.[Opt In/Out based on Questionnaire] = 'Opt-In' and sub.[Detail for CE - Part C Entitlement] = 'Not entitled for Part C' then 'No action - there should not be Part C liens if the claimant has no Part C Entitlement Dates'
							When sub.[Opt In/Out based on Questionnaire] = 'Opt-In' and sub.[Detail for CE - Part C Entitlement] = 'Entitled for Part C' then 'Open any Part C liens in SLAM'
							When sub.[Opt In/Out based on Questionnaire] = 'Opt-In' and sub.[Detail for CE - Part C Entitlement] = 'FNE for Medicare' then 'No action - there should not be Part C liens if the claimant is FNE for Mcare'
							When sub.[Opt In/Out based on Questionnaire] = 'Opt-In' and sub.[Detail for CE - Part C Entitlement] = 'No response from Medicare yet' then 'No action - keep any Part C liens at hold'
							When sub.[Opt In/Out based on Questionnaire] = 'Opt-Out' and sub.[Detail for CE - Part C Entitlement] = 'Not entitled for Part C' then 'No action - there should not be Part C liens if the claimant has no Part C Entitlement Dates'
							When sub.[Opt In/Out based on Questionnaire] = 'Opt-Out' and sub.[Detail for CE - Part C Entitlement] = 'Entitled for Part C' then 'Close any Part C liens in SLAM'
							When sub.[Opt In/Out based on Questionnaire] = 'Opt-Out' and sub.[Detail for CE - Part C Entitlement] = 'FNE for Medicare' then 'No action - there should not be Part C liens if the claimant is FNE for Mcare'
							When sub.[Opt In/Out based on Questionnaire] = 'Opt-Out' and sub.[Detail for CE - Part C Entitlement] = 'No response from Medicare yet' then 'No action - keep any Part C liens at hold'
							Else 'Look Into'
							End as 'Things for CE to do'					
				from	(
								select	P.[S3 ID],F.Id as 'Lien Id', F.LienProductStatus, F.LienType, P.[Claimant Last Name], P.[Claimant First Name], P.[Private Lien Analysis], F.AdditionalInformation,
										Case
											When P.[Private Lien Analysis] = 'Private 3' or P.[Private Lien Analysis] = 'Private 5' then 'Discrepancy'
											When P.[Private Lien Analysis] = 'Private 4' or P.[Private Lien Analysis] = 'Private 6' then 'Opt-Out'
											When P.[Private Lien Analysis] = 'Private 1' or P.[Private Lien Analysis] = 'Private 2' then 'Opt-In'
											Else 'Look Into'
											End As 'Opt In/Out based on Questionnaire',
										C.[Detail for CE - Part C Entitlement]
								from	#PrivateAnalysis_BSC as P 
											LEFT OUTER JOIN FullProductViews as F on F.[ClientId]=P.[S3 ID]
											LEFT OUTER JOIN #PartCEntitlement_BSC as C on C.[ClientId]=P.[S3 ID]
											LEFT OUTER JOIN #AllTheDiscrepancies_BSC as D on D.[Client Id]=P.[S3 ID]
								where	D.[Client Id] is null
										and F.LienType like '%Part C%'
					
							) as sub





							




	--5. CSV to update Questionnaire Rec'd to be True

			SELECT	Q.[S3 ID] as Id, C.QuestionnaireReceived as 'Current QuestionnaireReceived', 
					Case
						When C.QuestionnaireReceived = '' or C.QuestionnaireReceived is null then 'True'
						Else 'Look Into'
						End As 'Updated QuestionnaireReceived', 
					'Updated Questionnaire Receieved to be true' as 'NewClientNote'

			FROM	Questionnaire_BSC as Q 
						LEFT OUTER JOIN Clients as C on Q.[S3 ID]=C.Id 
						LEFT OUTER JOIN #AllTheDiscrepancies_BSC as D on D.[Client Id]=Q.[S3 ID]
						LEFT OUTER JOIN #PrivateAnalysis_BSC as P on Q.[S3 ID]=P.[S3 Id]
			WHERE	D.[Client Id] is null
					--Data sent to RA
					and P.[Private Lien Analysis] <> 'Private 1'
