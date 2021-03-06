--Part C

--Drop existing tables and import new data into SQL
	
		--drop table CE_PartC_Data  --[dbo].[CE_PartC_Data] --VOE results
		--drop table CE_Submission_Data --[dbo].[CE_Submission_Data] --Post 15th submission file that has a record of who was submitted that month
		--drop table CE_AssignedUserTable -- A table CE imported into SLAM that has info on who should be assigned the different liens 
		--drop table JB_PartC_HMOCodes --[dbo].[JB_PartC_HMOCodes] -- Master HMO Code spreadsheet


		Select * from CE_Submission_Data
		select * from CE_PartC_Data
		select * from CE_AssignedUserTable
		select * from JB_PartC_HMOCodes




--Notes/Background info. Change for each VOE. This is just to keep from having to look at SLAM.

	--active caseid = [caseid] -3681
	--closed caseid =  [caseid] 
	


	--Prework: If the VOE has an "A" or a "1A" in the Match Indicator column, write over that with a "1" so it's all numeric for future queries

		--P1: Check for any non-numeric values
			
			select * from CE_PartC_Data where ISNUMERIC([Match Indicator]) = 0


		--P2: Write over the non-numeric values (unless it's something weird)

			update CE_PartC_Data
			set [Match Indicator] = 72
			from CE_PartC_Data
			where ISNUMERIC([Match Indicator]) = 0 and [Match Indicator] = '1A'


		--P3: Validate results worked out the way you wanted
			
			select * from CE_PartC_Data where ISNUMERIC([Match Indicator]) = 0
				
			select * from CE_PartC_Data 



--1. Get only pertinent data from VOE

		drop table #PartC_1

	select	[First Name] as FirstName, [Last Name] as LastName, [SSN Sent] as SSN, [Match Indicator] as MatchInd, 
			[HMO Start], [HMO End], [HMO Contractor], 
			[HMO Start (2)], [HMO End (2)], [HMO Contractor (2)], 
			[HMO Start (3)], [HMO End (3)], [HMO Contractor (3)], 
			[HMO Start (4)], [HMO End (4)], [HMO Contractor (4)], 
			[HMO Start (5)], [HMO End (5)], [HMO Contractor (5)],
			[HMO Start (6)], [HMO End (6)], [HMO Contractor (6)],
			[HMO Start (7)], [HMO End (7)], [HMO Contractor (7)],
			[HMO Start (8)], [HMO End (8)], [HMO Contractor (8)],
			[HMO Start (9)], [HMO End (9)], [HMO Contractor (9)],
			[HMO Start (10)], [HMO End (10)], [HMO Contractor (10)],
			[HMO Start (11)], [HMO End (11)], [HMO Contractor (11)],
			[HMO Start (12)], [HMO End (12)], [HMO Contractor (12)],
			[HMO Start (13)], [HMO End (13)], [HMO Contractor (13)],
			[HMO Start (14)], [HMO End (14)], [HMO Contractor (14)],
			[HMO Start (15)], [HMO End (15)], [HMO Contractor (15)],
			[HMO Start (16)], [HMO End (16)], [HMO Contractor (16)],
			[HMO Start (17)], [HMO End (17)], [HMO Contractor (17)],
			[HMO Start (18)], [HMO End (18)], [HMO Contractor (18)],
			[HMO Start (19)], [HMO End (19)], [HMO Contractor (19)],
			[HMO Start (20)], [HMO End (20)], [HMO Contractor (20)],
			[HMO Start (21)], [HMO End (21)], [HMO Contractor (21)],
			[HMO Start (22)], [HMO End (22)], [HMO Contractor (22)],
			[HMO Start (23)], [HMO End (23)], [HMO Contractor (23)],
			[HMO Start (24)], [HMO End (24)], [HMO Contractor (24)],
			[HMO Start (25)], [HMO End (25)], [HMO Contractor (25)],
			[HMO Start (26)], [HMO End (26)], [HMO Contractor (26)],
			[HMO Start (27)], [HMO End (27)], [HMO Contractor (27)],
			[HMO Start (28)], [HMO End (28)], [HMO Contractor (28)],
			[HMO Start (29)], [HMO End (29)], [HMO Contractor (29)],
			[HMO Start (30)], [HMO End (30)], [HMO Contractor (30)],
			[HMO Start (31)], [HMO End (31)], [HMO Contractor (31)],
			[HMO Start (32)], [HMO End (32)], [HMO Contractor (32)],
			[HMO Start (33)], [HMO End (33)], [HMO Contractor (33)],
			[HMO Start (34)], [HMO End (34)], [HMO Contractor (34)],
			[HMO Start (35)], [HMO End (35)], [HMO Contractor (35)],
			[HMO Start (36)], [HMO End (36)], [HMO Contractor (36)],
			[HMO Start (37)], [HMO End (37)], [HMO Contractor (37)],
			[HMO Start (38)], [HMO End (38)], [HMO Contractor (38)],
			[HMO Start (39)], [HMO End (39)], [HMO Contractor (39)],
			[HMO Start (40)], [HMO End (40)], [HMO Contractor (40)],
			[HMO Start (41)], [HMO End (41)], [HMO Contractor (41)],
			[HMO Start (42)], [HMO End (42)], [HMO Contractor (42)],
			[HMO Start (43)], [HMO End (43)], [HMO Contractor (43)],
			[HMO Start (44)], [HMO End (44)], [HMO Contractor (44)],
			[HMO Start (45)], [HMO End (45)], [HMO Contractor (45)],
			[HMO Start (46)], [HMO End (46)], [HMO Contractor (46)],
			[HMO Start (47)], [HMO End (47)], [HMO Contractor (47)],
			[HMO Start (48)], [HMO End (48)], [HMO Contractor (48)],
			[HMO Start (49)], [HMO End (49)], [HMO Contractor (49)],
			[HMO Start (50)], [HMO End (50)], [HMO Contractor (50)]

	into	#PartC_1
	from	CE_PartC_Data
	where	([Match Indicator] = 8 or [Match Indicator] = 1) and [HMO Contractor] is not null


		select * from #PartC_1


--2. Create temp table from SLAM Data to get Client Ids for this case
	--If you're processing a reverification VOE, use the submission table
	--If you're processing an initial case VOE, then only use that Case Id in the WHERE clause
	
	
	
	--2a_i. If a claimant is on the Reverification VOE, this will get their ClientId that is in LPM
			--Note: The purpose of this section is to bring information into the VOE file from FPV (Ids, AdditionalInformation, etc.)
	
						drop table #PartC_SLAM
		

			select	distinct b.Personid, b.ClientSSN, b.ClientId,b.CaseId, b.CaseName, b.ClientAdditionalInformation, a.[Medicare Product Id] as 'Id'
			into	#PartC_SLAM
			from	CE_Submission_Data a
						left join FullProductViews b on a.[Medicare Product Id] = b.Id
	
	
					select * from CE_Submission_Data 

					select * from CE_Submission_Data order by id




	--2a_ii. If a claimant is on the Initial Case VOE, this will get their ClientId that is in LPM

				drop table #PartC_SLAM

			select distinct ClientSSN, PrevSSN, ClientId, FullProductViews.CaseId, FullProductViews.CaseName, FullProductViews.ClientAdditionalInformation
			into #PartC_SLAM
			from FullProductViews
			where CaseId in (3681)

				select * from #PartC_SLAM




	--2b. SSN check: make sure all SSNs on the VOE are in the active SLAM case. 
		--If they are in the inactive case, include that CaseId in the analysis and create the Part C liens. 

		--If the claimants SSN has changed but you still need to create the Part C for some reason, then modify the table to have the old SSN or something so the Client Id pulls. 
		


			--2b_i. Check: Are all SSNs on the VOE in the active SLAM case? And are all SSNs on the VOE submission?
					--If a SSN missing, then email the CM and ask them what to do about it. 

						drop table #Missing_SSN


					select * 
					into #Missing_SSN
					from #PartC_1
					where #PartC_1.SSN not in (select distinct #PartC_SLAM.ClientSSN from #PartC_SLAM) 
			
			
						select * from #Missing_SSN


			
			--2b_ii. If a claimant's SSN on the VOE does not show up in the active SLAM case (2b_i), what case are they in?
					--If claimant is in the correct case according to this query, then they were probably not on the submission. 
					drop table #Missing_SSN_Cases

					select	distinct f.clientid, f.ClientSSN, f.CaseId, f.stage,f.id, f.casename, m.* 
					into #Missing_SSN_Cases
					from	#Missing_SSN m
								left join FullProductViews as f on f.clientssn = m.ssn
					where	f.lientype like 'medicare - global'




	--2c. Get all casenames for claimants who are not in the active case

				
			--2c_i. Get pertinent casenames


							drop table #PartC_ClosedCases


				select	distinct a.casename as 'Active Cases', b.CaseName 'Inactive CaseNames', b.CaseId as 'Inactive CaseId'
				into	#PartC_ClosedCases
				from	#PartC_SLAM a
							left join FullProductViews b on left(b.CaseName, LEN(a.casename)) =  a.casename
				where	(b.casename like '%hold%' or b.CaseName like '%closed%')
				order by 1
		

							select * from #PartC_ClosedCases



			--2c_ii. Get all the client info from these inactive cases (2c_i)

						drop table #PartC_SLAM_Closed

				
					select distinct ClientSSN, ClientId, CaseId
					into #PartC_SLAM_Closed
					from FullProductViews FPV
					where CaseId in (select distinct #PartC_ClosedCases.[Inactive CaseId] from #PartC_ClosedCases)

		
						select distinct caseid from #PartC_SLAM_Closed




--3. Join VOE Data (#PartC_1) and SLAM Data (#PartC_SLAM) to get ClientId in with the VOE data


		--3a. Add data together if the claimant is in the active case

					drop table #PartC_2


			select	SLAM.ClientId, VOE.FirstName, VOE.LastName, VOE.SSN, VOE.MatchInd, VOE.[HMO Start], isnull(VOE.[HMO End], '01/01/1900') as 'HMO End', VOE.[HMO Contractor], 
					isnull(VOE.[HMO Start (2)], '01/01/1900') as 'HMO Start (2)', isnull(VOE.[HMO End (2)], '01/01/1900') as 'HMO End (2)', VOE.[HMO Contractor (2)], 
					isnull(VOE.[HMO Start (3)], '01/01/1900') as 'HMO Start (3)', isnull(VOE.[HMO End (3)], '01/01/1900') as 'HMO End (3)', VOE.[HMO Contractor (3)], 
					isnull(VOE.[HMO Start (4)], '01/01/1900') as 'HMO Start (4)', isnull(VOE.[HMO End (4)], '01/01/1900') as 'HMO End (4)', VOE.[HMO Contractor (4)], 
					isnull(VOE.[HMO Start (5)], '01/01/1900') as 'HMO Start (5)', isnull(VOE.[HMO End (5)], '01/01/1900') as 'HMO End (5)', VOE.[HMO Contractor (5)], 
					isnull(VOE.[HMO Start (6)], '01/01/1900') as 'HMO Start (6)', isnull(VOE.[HMO End (6)], '01/01/1900') as 'HMO End (6)', VOE.[HMO Contractor (6)],
					isnull(VOE.[HMO Start (7)], '01/01/1900') as 'HMO Start (7)', isnull(VOE.[HMO End (7)], '01/01/1900') as 'HMO End (7)', VOE.[HMO Contractor (7)],
					isnull(VOE.[HMO Start (8)], '01/01/1900') as 'HMO Start (8)', isnull(VOE.[HMO End (8)], '01/01/1900') as 'HMO End (8)', VOE.[HMO Contractor (8)],
					isnull(VOE.[HMO Start (9)], '01/01/1900') as 'HMO Start (9)', isnull(VOE.[HMO End (9)], '01/01/1900') as 'HMO End (9)', VOE.[HMO Contractor (9)],
					isnull(VOE.[HMO Start (10)], '01/01/1900') as 'HMO Start (10)', isnull(VOE.[HMO End (10)], '01/01/1900') as 'HMO End (10)', VOE.[HMO Contractor (10)],
					isnull(VOE.[HMO Start (11)], '01/01/1900') as 'HMO Start (11)', isnull(VOE.[HMO End (11)], '01/01/1900') as 'HMO End (11)', VOE.[HMO Contractor (11)],
					isnull(VOE.[HMO Start (12)], '01/01/1900') as 'HMO Start (12)', isnull(VOE.[HMO End (12)], '01/01/1900') as 'HMO End (12)', VOE.[HMO Contractor (12)],
					isnull(VOE.[HMO Start (13)], '01/01/1900') as 'HMO Start (13)', isnull(VOE.[HMO End (13)], '01/01/1900') as 'HMO End (13)', VOE.[HMO Contractor (13)],
					isnull(VOE.[HMO Start (14)], '01/01/1900') as 'HMO Start (14)', isnull(VOE.[HMO End (14)], '01/01/1900') as 'HMO End (14)', VOE.[HMO Contractor (14)],
					isnull(VOE.[HMO Start (15)], '01/01/1900') as 'HMO Start (15)', isnull(VOE.[HMO End (15)], '01/01/1900') as 'HMO End (15)', VOE.[HMO Contractor (15)],
					isnull(VOE.[HMO Start (16)], '01/01/1900') as 'HMO Start (16)', isnull(VOE.[HMO End (16)], '01/01/1900') as 'HMO End (16)', VOE.[HMO Contractor (16)],
					isnull(VOE.[HMO Start (17)], '01/01/1900') as 'HMO Start (17)', isnull(VOE.[HMO End (17)], '01/01/1900') as 'HMO End (17)', VOE.[HMO Contractor (17)],
					isnull(VOE.[HMO Start (18)], '01/01/1900') as 'HMO Start (18)', isnull(VOE.[HMO End (18)], '01/01/1900') as 'HMO End (18)', VOE.[HMO Contractor (18)],
					isnull(VOE.[HMO Start (19)], '01/01/1900') as 'HMO Start (19)', isnull(VOE.[HMO End (19)], '01/01/1900') as 'HMO End (19)', VOE.[HMO Contractor (19)],
					isnull(VOE.[HMO Start (20)], '01/01/1900') as 'HMO Start (20)', isnull(VOE.[HMO End (20)], '01/01/1900') as 'HMO End (20)', VOE.[HMO Contractor (20)],
					isnull(VOE.[HMO Start (21)], '01/01/1900') as 'HMO Start (21)', isnull(VOE.[HMO End (21)], '01/01/1900') as 'HMO End (21)', VOE.[HMO Contractor (21)],
					isnull(VOE.[HMO Start (22)], '01/01/1900') as 'HMO Start (22)', isnull(VOE.[HMO End (22)], '01/01/1900') as 'HMO End (22)', VOE.[HMO Contractor (22)],
					isnull(VOE.[HMO Start (23)], '01/01/1900') as 'HMO Start (23)', isnull(VOE.[HMO End (23)], '01/01/1900') as 'HMO End (23)', VOE.[HMO Contractor (23)],
					isnull(VOE.[HMO Start (24)], '01/01/1900') as 'HMO Start (24)', isnull(VOE.[HMO End (24)], '01/01/1900') as 'HMO End (24)', VOE.[HMO Contractor (24)],
					isnull(VOE.[HMO Start (25)], '01/01/1900') as 'HMO Start (25)', isnull(VOE.[HMO End (25)], '01/01/1900') as 'HMO End (25)', VOE.[HMO Contractor (25)],
					isnull(VOE.[HMO Start (26)], '01/01/1900') as 'HMO Start (26)', isnull(VOE.[HMO End (26)], '01/01/1900') as 'HMO End (26)', VOE.[HMO Contractor (26)],
					isnull(VOE.[HMO Start (27)], '01/01/1900') as 'HMO Start (27)', isnull(VOE.[HMO End (27)], '01/01/1900') as 'HMO End (27)', VOE.[HMO Contractor (27)],
					isnull(VOE.[HMO Start (28)], '01/01/1900') as 'HMO Start (28)', isnull(VOE.[HMO End (28)], '01/01/1900') as 'HMO End (28)', VOE.[HMO Contractor (28)],
					isnull(VOE.[HMO Start (29)], '01/01/1900') as 'HMO Start (29)', isnull(VOE.[HMO End (29)], '01/01/1900') as 'HMO End (29)', VOE.[HMO Contractor (29)],
					isnull(VOE.[HMO Start (30)], '01/01/1900') as 'HMO Start (30)', isnull(VOE.[HMO End (30)], '01/01/1900') as 'HMO End (30)', VOE.[HMO Contractor (30)],
					isnull(VOE.[HMO Start (31)], '01/01/1900') as 'HMO Start (31)', isnull(VOE.[HMO End (31)], '01/01/1900') as 'HMO End (31)', VOE.[HMO Contractor (31)],
					isnull(VOE.[HMO Start (32)], '01/01/1900') as 'HMO Start (32)', isnull(VOE.[HMO End (32)], '01/01/1900') as 'HMO End (32)', VOE.[HMO Contractor (32)],
					isnull(VOE.[HMO Start (33)], '01/01/1900') as 'HMO Start (33)', isnull(VOE.[HMO End (33)], '01/01/1900') as 'HMO End (33)', VOE.[HMO Contractor (33)],
					isnull(VOE.[HMO Start (34)], '01/01/1900') as 'HMO Start (34)', isnull(VOE.[HMO End (34)], '01/01/1900') as 'HMO End (34)', VOE.[HMO Contractor (34)],
					isnull(VOE.[HMO Start (35)], '01/01/1900') as 'HMO Start (35)', isnull(VOE.[HMO End (35)], '01/01/1900') as 'HMO End (35)', VOE.[HMO Contractor (35)],
					isnull(VOE.[HMO Start (36)], '01/01/1900') as 'HMO Start (36)', isnull(VOE.[HMO End (36)], '01/01/1900') as 'HMO End (36)', VOE.[HMO Contractor (36)],
					isnull(VOE.[HMO Start (37)], '01/01/1900') as 'HMO Start (37)', isnull(VOE.[HMO End (37)], '01/01/1900') as 'HMO End (37)', VOE.[HMO Contractor (37)],
					isnull(VOE.[HMO Start (38)], '01/01/1900') as 'HMO Start (38)', isnull(VOE.[HMO End (38)], '01/01/1900') as 'HMO End (38)', VOE.[HMO Contractor (38)],
					isnull(VOE.[HMO Start (39)], '01/01/1900') as 'HMO Start (39)', isnull(VOE.[HMO End (39)], '01/01/1900') as 'HMO End (39)', VOE.[HMO Contractor (39)],
					isnull(VOE.[HMO Start (40)], '01/01/1900') as 'HMO Start (40)', isnull(VOE.[HMO End (40)], '01/01/1900') as 'HMO End (40)', VOE.[HMO Contractor (40)],
					isnull(VOE.[HMO Start (41)], '01/01/1900') as 'HMO Start (41)', isnull(VOE.[HMO End (41)], '01/01/1900') as 'HMO End (41)', VOE.[HMO Contractor (41)],
					isnull(VOE.[HMO Start (42)], '01/01/1900') as 'HMO Start (42)', isnull(VOE.[HMO End (42)], '01/01/1900') as 'HMO End (42)', VOE.[HMO Contractor (42)],
					isnull(VOE.[HMO Start (43)], '01/01/1900') as 'HMO Start (43)', isnull(VOE.[HMO End (43)], '01/01/1900') as 'HMO End (43)', VOE.[HMO Contractor (43)],
					isnull(VOE.[HMO Start (44)], '01/01/1900') as 'HMO Start (44)', isnull(VOE.[HMO End (44)], '01/01/1900') as 'HMO End (44)', VOE.[HMO Contractor (44)],
					isnull(VOE.[HMO Start (45)], '01/01/1900') as 'HMO Start (45)', isnull(VOE.[HMO End (45)], '01/01/1900') as 'HMO End (45)', VOE.[HMO Contractor (45)],
					isnull(VOE.[HMO Start (46)], '01/01/1900') as 'HMO Start (46)', isnull(VOE.[HMO End (46)], '01/01/1900') as 'HMO End (46)', VOE.[HMO Contractor (46)],
					isnull(VOE.[HMO Start (47)], '01/01/1900') as 'HMO Start (47)', isnull(VOE.[HMO End (47)], '01/01/1900') as 'HMO End (47)', VOE.[HMO Contractor (47)],
					isnull(VOE.[HMO Start (48)], '01/01/1900') as 'HMO Start (48)', isnull(VOE.[HMO End (48)], '01/01/1900') as 'HMO End (48)', VOE.[HMO Contractor (48)],
					isnull(VOE.[HMO Start (49)], '01/01/1900') as 'HMO Start (49)', isnull(VOE.[HMO End (49)], '01/01/1900') as 'HMO End (49)', VOE.[HMO Contractor (49)],
					isnull(VOE.[HMO Start (50)], '01/01/1900') as 'HMO Start (50)', isnull(VOE.[HMO End (50)], '01/01/1900') as 'HMO End (50)', VOE.[HMO Contractor (50)],
					SLAM.ClientAdditionalInformation
			into	#PartC_2
			from	#PartC_1 as VOE
						LEFT OUTER JOIN #PartC_SLAM as SLAM on SLAM.ClientSSN=VOE.[SSN]

					select * from #PartC_2


	--3b. Add ClientId to #PartC_2 (table from 3a) if the claimant is in the closed case
		
			update #PartC_2
			set	#PartC_2.[ClientId]  = SLAM_Closed.[ClientId]
			from #PartC_2 INNER JOIN
			#PartC_SLAM_Closed as SLAM_Closed on SLAM_Closed.ClientSSN=#PartC_2.[SSN]
			where #PartC_2.[ClientId] is null


					--QA on 3b: Check Closed Case Clients
						select b.ClientId
						from #PartC_2 a
						left join #PartC_SLAM_Closed b on a.ClientId = b.ClientId
						where b.clientid is not null



	--3c. Create file to send CM NULL Clients (aka claimants who are neither in the active or inactive case)
		
		select b.ClientId, b.CaseName, b.LastName, b.FirstName, a.SSN, 'Claimant on VOE response and is Part C entitled, but was not the original submission. Did not process VOE data due to this discrepancy; sent data to Case Manager.' as CM_Discrepancy_Note
		from  #PartC_2 a
		left join #Missing_SSN_Cases b on a.SSN = b.SSN 
		where a.ClientId is null
		
		select * from #Missing_SSN_Cases

	--3d. Drop note on client page 
		
		select clientId as 'Id', 'Claimant on VOE response and is Part C entitled, but was not the original submission. Waiting on CM response to continue processing' as NewClientNote
		from #Missing_SSN_Cases



--4. QA check on #PartC_s. Should give you NO values. Checks if there is more than 1 ClientId on the #PartC_2 file. 

	select clientid, count(clientid) as count
	from #PartC_2
	group by clientid
	having count(clientid) >1
	order by 2




--5. Unpivot the VOE data to get one row per HMO Code


	--5a. Renames column headers
		
			EXEC tempdb.sys.sp_rename '#PartC_2.[HMO Contractor]','HMO Contractor (1)', 'COLUMN'
			EXEC tempdb.sys.sp_rename '#PartC_2.[HMO Start]','HMO Start (1)', 'COLUMN'
			EXEC tempdb.sys.sp_rename '#PartC_2.[HMO End]','HMO End (1)', 'COLUMN'
		


	--5b. Unpivot HMO Code data from VOE (#PartC_2)
		
				select * from #PartC_2
	
				drop table #PartC_Pivot


		select	ClientId, LastName, FirstName, SSN, HMO_Code, HMO_Start, HMO_End
		into	#PartC_Pivot
		from 
				(
					select * 
					from #PartC_2 
				) as pc2 
				UNPIVOT
					(HMO_Code FOR Detail IN
						([HMO Contractor (1)], [HMO Contractor (2)], [HMO Contractor (3)], [HMO Contractor (4)], [HMO Contractor (5)])
					) as unpvt_code
				UNPIVOT
					(HMO_Start FOR Detail2 IN
						([HMO Start (1)], [HMO Start (2)], [HMO Start (3)], [HMO Start (4)], [HMO Start (5)])
					) as unpvt_start
				UNPIVOT
					(HMO_End FOR Detail3 IN
						([HMO End (1)], [HMO End (2)], [HMO End (3)], [HMO End (4)], [HMO End (5)])
	
					) as unpvt_end
			where RIGHT(Detail,3) = RIGHT(Detail2, 3) and RIGHT(Detail2,3) = RIGHT(Detail3, 3) 

	
	
				 select * from #PartC_Pivot



--6. Remove Duplicate HMO Codes to get actual pivot with max dates

				drop table #PartC_Pivot_Complete

		select a.ClientId, a.LastName, a.FirstName, a.SSN, b.HMO_Code,  b.HMO_Start, b.HMO_End
		into #PartC_Pivot_Complete
		from #PartC_Pivot a
				inner join
				(
					select distinct SSN, HMO_Code, cast(HMO_Start as date) as 'HMO_Start', cast(HMO_End as date) as 'HMO_End',
					row_number() over
						(
							partition by SSN, HMO_code
							order by ssn desc
						) as order_date
					from #PartC_Pivot
				) b
		on b.SSN = a.SSN and b.HMO_Start = a.HMO_Start
		where b.order_date like'%1%'
		Order by ClientId

				
				select * from #PartC_Pivot_Complete



		
--7. Analyze the HMO codes that result in "skipped". This check makes sure all the HMO Codes that are on the VOE are on the HMO Code Spreadsheet for every tort/PLRP. 
		--This needs to be sent to RA for analysis. Include Part C Start and End Date for that HMO Code for that claimant. 
		--Have RA determine what the HMO Code translates to for each tort/PLRP combo. 
		

		--7a. Check to see if the HMO code is on the spreadsheet
				--Update Tort in subquery as needed

						drop table #Missing_HMOCodes

						
				select	distinct #PartC_Pivot_Complete.* , FPV.ClientAdditionalInformation
				into	#Missing_HMOCodes
				from	#PartC_Pivot_Complete
							left join FullProductViews as FPV on FPV.ClientId = #PartC_Pivot_Complete.ClientId
				where	#PartC_Pivot_Complete.HMO_Code not in (select distinct JB_PartC_HMOCodes.PlanCode from JB_PartC_HMOCodes where JB_PartC_HMOCodes.Tort like '%Pinnacle%')
			
					
						select * from #Missing_HMOCodes

			
		--7b. Check SLAM: Does the claimant have a placeholder Medicare Lien - Part C? If so, update this one instead of creating a new one. 

						drop table #ExistingPlaceholders

				select	#Missing_HMOCodes.ClientId, FullProductViews.Id, FullProductViews.LienHolderId, FullProductViews.CollectorId, FullProductViews.LienType, 
						FullProductViews.AdditionalInformation
				into	#ExistingPlaceholders
				from	#Missing_HMOCodes
							left join FullProductViews on FullProductViews.ClientId = #Missing_HMOCodes.ClientId
				where	FullProductviews.lienholderid = 696 and FullProductviews.CollectorId = 736 and FullProductviews.LienType like '%medicare lien - part c%'


						select * from #ExistingPlaceholders
	

		--7c. Create CSV that makes placeholder liens for any claimant who has a "skipped" HMO code -- Placeholder

				select	a.ClientId, Cast(696 as int) as LienHolderId, Cast(736 as int) as CollectorId, Cast(46 as int) as AssignedUserId, 'Open' as LienProductStatus,'Medicare Lien - Part C' as LienType, 'Researching Collector' as Stage, 
						Cast('Yes' as nvarchar(50)) as OnBenefits, '[date VOE was recd]' as OnBenefitsVerified
				from	#Missing_HMOCodes a 
				left join Fullproductviews b on a.clientid = b.clientid 
				where a.ClientId not in (Select ClientId from #ExistingPlaceholders) and a.ClientAdditionalInformation <> '%opt%out%' and b.caseid not in (2919)

			

		--7d. Create lien note for placeholder liens created in 7c
					
					drop table #PlaceholderNote

			
			select	distinct M.ClientId, F.Id, 'Created placeholder lien based on Sept 2019 TVM Reverification CMS VOE results.' as 'NewLienNote'
			into	#PlaceholderNote
			from	Fullproductviews as F 
				JOIN #Missing_HMOCodes as M on M.[ClientId]=F.ClientId
			where	F.CreatedOn = cast(getdate() as date) and F.LienType like '%Medicare Lien - Part C%' and F.Stage like '%Researching Collector%'

			
					select * from #PlaceholderNote



		--7e. Create spreadsheet to send to Ryan Abbott for research. This will have two tabs on it. -- (HMOCodeResearch - Send to RA.xlsx)
			
			--Name of the first tab: WIP 
			--This has the client data, Placeholder Lien Ids and the HMO Code and HMO dates

					select	distinct P.Id, M.*
					from	#Missing_HMOCodes as M
								Right join #PlaceholderNote as P on M.ClientId = P.ClientId
					order by 3,6

		
			--Name of the second tab: HMO 
				--Note: need to UPDATE THE TORT as needed BEFORE running it and sending it to RA
				--This has the data needed to update the HMO Code spreadsheet

					select	distinct HMO_Code as 'PlanCode', Cast('' as nvarchar) as LienholderId,  Cast('' as nvarchar) as CollectorId, Cast('TVM' as nvarchar) as Tort, 
							Cast('' as nvarchar) as 'PLRP?'
					from	#Missing_HMOCodes
					order by HMO_Code





--8. Join the HMO Code WS with the Pivoted VOE data
		
		drop table #PartC_3a
		drop table #PartC_3
		drop table #AssignedUserTable 



		
		--8a. Create a table with distinct Assigned User Ids for this VOE's tort
				--Import the "Collector Combo Table - Use for creating liens" excel file. You will use this to add the correct assigned user Ids to the CSV spreadsheets.
				--Imported file name: CE_AssignedUserTable
				--Run this query to get only the relevant data from the "Collector Combo Table - Use for creating liens" excel file.
		
					select	* 
					into	#AssignedUserTable 
					from	CE_AssignedUserTable 
					where	(CE_AssignedUserTable.[Tort] like 'TVM%'  or CE_AssignedUserTable.[Tort] like 'Pinnacle Hip%' or CE_AssignedUserTable.[Tort] like '%Hip%') 
							and CE_AssignedUserTable.[Assigned User Id] is not null
					--from	CE_AssignedUserTable 
					--where	(CE_AssignedUserTable.[Tort] like 'TVM%') and CE_AssignedUserTable.[Assigned User Id] is not null


					--Delete the additional placeholders

					Delete 
					from	#AssignedUserTable 
					where	LienholderId = 696 and LienType in 
																(select distinct #AssignedUserTable.LienType 
																 from #AssignedUserTable 
																 where LienHolderId = 696 and lientype <> 'Medicare Lien - Part C') 



					select * from #AssignedUserTable
		
		
		
					 
		--8b. Convert [PLRP Yes or PLRP No] to appropriate lien type (either "Part C - PLRP" or "Medicare Lien - Part C"); then add this to the #PartC_Pivot_Complete table. 

						drop table #PartC_3a
						
						select * from #PartC_Pivot_Complete
						select * from JB_PartC_HMOCodes

								
				select	VOE.*, HMOData.LienholderId, HMOData.CollectorId, HMOData.Tort, HMOData.[PLRP?],
						case 
							when HMOData.[PLRP?] = 'Yes' then 'Part C - PLRP'
							else 'Medicare Lien - Part C'
							end as LienType
				into	#PartC_3a
				from	#PartC_Pivot_Complete as VOE
							LEFT OUTER JOIN JB_PartC_HMOCodes as HMOData on HMOData.PlanCode = VOE.HMO_Code 
				--where	HMOData.Tort = 'TVM'
				--where	HMOData.Tort = 'Stryker Hip Implant'
				where	HMOData.Tort = 'Pinnacle Hip Implant' 
				order by 1


						select * from #PartC_3a
						
		

		--8c. Tweak data on #AssignedUserTable to account for PLRPs
	

					drop table #PartC_3b

	
			select distinct #PartC_3a.*,
				case 
					when  #PartC_3a.Tort like 'TVM' and #PartC_3a.LienType like '%Part C - PLRP%' and #PartC_3a.[CollectorId]  = 227 then '269'
					when  (#PartC_3a.Tort like 'Pinnacle Hip Implant' or #PartC_3a.Tort like 'Stryker Hip Implant') and #PartC_3a.LienType like '%Part C - PLRP%' and #PartC_3a.[CollectorId]  = 227 then '269'
					when  (#PartC_3a.Tort like 'Pinnacle Hip Implant' or #PartC_3a.Tort like 'Stryker Hip Implant')and #PartC_3a.LienType like '%Part C - PLRP%' and #PartC_3a.[CollectorId]  = 1866 then '295'
					when  (#PartC_3a.Tort like 'Pinnacle Hip Implant' or #PartC_3a.Tort like 'Stryker Hip Implant') and #PartC_3a.LienType like '%Part C - PLRP%' and #PartC_3a.[CollectorId]  = 1867 then '295'
					when  (#PartC_3a.Tort like 'Pinnacle Hip Implant' or #PartC_3a.Tort like 'Stryker Hip Implant') and #PartC_3a.LienType like '%Part C - PLRP%' and #PartC_3a.[CollectorId]  = 117 then '46'
					when  (#PartC_3a.Tort like 'Pinnacle Hip Implant' or #PartC_3a.Tort like 'Stryker Hip Implant') and #PartC_3a.LienType like '%Part C - PLRP%' and #PartC_3a.[CollectorId]  = 1625 then '46'
					when  (#PartC_3a.Tort like 'Pinnacle Hip Implant' or #PartC_3a.Tort like 'Stryker Hip Implant') and #PartC_3a.LienType like '%Part C - PLRP%' and #PartC_3a.[CollectorId]  = 531 then '105'
					when  #PartC_3a.[LienType] like '%Medicare Lien - Part C%' and #PartC_3a.[LienholderId] = #AssignedUserTable.LienholderId and #PartC_3a.CollectorId = #AssignedUserTable.CollectorId then #AssignedUserTable.[Assigned User Id]
					else '46'
				end as 'AssignedUserId'
			into #PartC_3b
			from #PartC_3a 
					left outer join #AssignedUserTable on #AssignedUserTable.[LienHolderId] = #PartC_3a.[LienholderId] and #PartC_3a.CollectorId = #AssignedUserTable.CollectorId 
			order by #PartC_3a.ClientId



					select * from #PartC_3b




--9. Drop Duplicate liens

					drop table #PartC_3
		

		select distinct a.ClientId, a.LastName, a.FirstName, a.SSN, b.HMO_Start, b.HMO_End, a.LienholderId, a.CollectorId,a.AssigneduserId ,a.LienType, a.Tort, a.[PLRP?] 
		into #PartC_3
		from #PartC_3b a
				inner join
				(
					select distinct SSN, LienholderId, CollectorId,cast(HMO_Start as date) as 'HMO_Start', cast(HMO_End as date) as 'HMO_End',
					row_number() over
						(
							partition by SSN, LienholderId, CollectorId
							order by ssn, HMO_Start desc
						) as order_date
					from #PartC_3b
				) b
		on b.SSN = a.SSN and b.HMO_Start = a.HMO_Start
		where b.order_date like '%1%'
		Order by ClientId



				select * from #PartC_3
				select * from #PartC_3b




--10. Take the #PartC_3 data (table created in previous step) and join it back to the original VOE data to get the max HMO End Date to do the ingestiondate/entitlement date analysis
		
		--10a. Analyze if the lien should be processed normally or set to Closed Opened in Error because ingestion date is after HMO end date.
	

						drop table #PartC_4a

				select	sub.*, 
					case
						when [Ingestion Date/Entitlement Analysis] like 'Normal process%' then 'Create - Normal'
						when [Ingestion Date/Entitlement Analysis] like 'Set to Closed Opened in Error%' then 'Create - Closed Opened in Error'
						when [Ingestion Date/Entitlement Analysis] like 'Set to Closed Per Attorney Request%' then 'Create - Closed Per Attorney Request'
						Else 'Look Into'
						End as 'Stage_Notes'
				into #PartC_4a
				from	
						(
							select	distinct ModPartC.ClientId, ModPartC.LastName, ModPartC.FirstName, ModPartC.SSN, ModPartC.[LienholderId], ModPartC.[CollectorId], ModPartC.AssignedUserId,ModPartC.[LienType], ModPartC.[Tort], 
									ModPartC.[HMO_End] as 'Most Recent HMO End Date', SLAMClients.IngestionDate, SLAMClients.DescriptionOfInjury, SLAMClients.SettlementAmount, SLAMClients.AdditionalInformation,
										case
											when SLAMClients.AdditionalInformation like '%opt%out%' then 'Set to Closed Per Attorney Request - claimant is opt out'
											when ModPartC.[HMO_End] = '1/1/1900' then 'Normal process - no HMO end date'
											when SLAMClients.IngestionDate <= [HMO_End] then 'Normal process - Ingestion date is before HMO end date'
											when SLAMClients.IngestionDate > ModPartC.[HMO_End]then 'Set to Closed Opened in Error - ingestion date is after HMO end date'
											when SLAMClients.SettlementDate < ModPartC.[HMO_Start]then 'Set to Closed Opened in Error - settlement date is before HMO start date'
											when SLAMClients.IngestionDate is null or SLAMClients.IngestionDate = '' then 'Normal process - NULL Ingestion date'
											else 'Look Into'
										end as 'Ingestion Date/Entitlement Analysis'
							from	#PartC_3 as ModPartC 
											LEFT OUTER JOIN Clients as SLAMClients on SLAMClients.Id = ModPartC.ClientId		
						) as sub
				order by lastname

				select * from #PartC_4a




	--10b. Add Updated Stage for liens that should be set to Closed Opened in Error because ingestion date is after HMO end date, ones that should be FNL, FNE, etc. .
		
					drop table #PartC_4

			
			select *,
					case 
						when Stage_Notes like 'Create - Normal' and LienType like 'Medicare Lien - Part C' and (DescriptionOfInjury is null or DescriptionOfInjury = '' or DescriptionOfInjury like '%faulty%') then 'To Send - Claims Request/Pending Surgeries'
						when Stage_Notes like 'Create - Normal' and LienType like 'Medicare Lien - Part C' and (DescriptionOfInjury is not null and DescriptionOfInjury not like '%faulty%') then 'To Send - Claims Request'
						when Stage_Notes like 'Create - Normal' and LienType like 'Medicare Lien - Part C' and (SettlementAmount is null or SettlementAmount = '' ) then 'To Send - Claims Request/Pending Surgeries'
						when Stage_Notes like 'Create - Normal' and LienType like 'Part C - PLRP' then 'To Send - EV'
						when Stage_Notes like 'Create - Closed Opened in Error' then 'Closed Opened in Error'
						when Stage_Notes like 'Create - Closed Per Attorney Request' then 'Closed - Per Attorney Request'
						else 'Look Into'
						end as 'Updated_Stage'
			into #PartC_4
			from #PartC_4a

					select * from #PartC_4



	--10c. For OptIn/OptOut Cases ONLY - Set stage to hold when a claimant is in an Opt In/Out case but doesn't have Opt In/Out Info.
			--Skip Pinnacle Hip Tort. Liens found on a VOE should be cretaed regardless of if they're opt out

			update	#PartC_4
			set		[Updated_Stage]  = 'Hold'
			from	#PartC_4
			left join FullProductViews on #PartC_4.ClientId = FullProductViews.ClientId
			where	#PartC_4.AdditionalInformation not like '%opt%out%' and #PartC_4.AdditionalInformation not like '%opt%in%'
					and caseid in (2872, 2741) and caseid not in (2919)




--11. Compare VOE data (#PartC_4) against current SLAM data. Desired Result: Case statement saying Upload or Update in a new column.

		--11a. Get a table of current SLAM liens

				drop table #CurrentFPV


			select	distinct FPV.ClientId, FPV.ClientSSN, FPV.ClientLastName, FPV.ClientFirstName, FPV.Id as 'LienId', FPV.LienType, FPV.LienholderId, FPV.CollectorId, FPV.LienProductStatus, FPV.Stage, FPV.ClosedReason, FPV.ClientAdditionalInformation
			into	#CurrentFPV
			from	fullproductviews as FPV
						JOIN #PartC_4 on #PartC_4.SSN = FPV.ClientSSN
			where	#PartC_4.ClientId is not null 



				select * from #CurrentFPV			


		--11b. This will set the stage to be FNL for PLRP liens that need to be created if the claimant already has a PLRP lien at Final.

						update	#PartC_4
						set		Updated_Stage = 'Final No Lien Received'
						where	lientype like '%plrp' and Updated_Stage like '%To Send - EV%' and LienType like '%Part C - PLRP%' 
								and clientid in 
												(select clientid 
												from #CurrentFPV 
												where lientype like '%PLRP%' and Stage like 'Final%')
												
												
								select * from #PartC_4



						


--QA 1: make sure all HMO Codes are accounted for for each person; An empty table is the desired outcome, else look into
				drop table #QA1_3b
				drop table #QA1_4

			--Make temp tables
				select	ClientId, Concat(ClientId,'-',LienholderId,'-', CollectorId) as Unique_3b
				Into	#QA1_3b
				from	#PartC_3b 


				select	ClientId, Concat(ClientId,'-',LienholderId,'-', CollectorId) as Unique_4
				into	#QA1_4
				from	#PartC_4

				--select * from #QA1_3b
				--select * from #QA1_4


			--Actual Checks
				select	ClientId
				from	#QA1_3b
				where	Unique_3b not in (select Unique_4 from #Qa1_4)


				select	ClientId
				from	#QA1_4
				where	Unique_4 not in (select Unique_3b from #Qa1_3b)



--QA 2: Do a count on clients to make sure everyone is accounted for from start of VOE to now

				select	ClientId
				from	#PartC_4
				where	ClientId not in (select ClientId from  #PartC_2)


				select	ClientId
				from	#PartC_2
				where	ClientId not in (select ClientId from  #PartC_4)



--QA 3: Select distinct lientype and stage to make sure they're all at appropriate stages


				select	distinct LienType, Updated_Stage, count(clientid) as 'Count'
				from	#PartC_4
				group by LienType, Updated_Stage
				order by 1,3





--QA Compare the distinct count of HMO Codes on VOE (by claimant) on #PartC_4 to what is on #PartC_3b

			select * from #PartC_3b
			select * from #PartC_4

			drop table #QA_4
			drop table #QA_3b

		--Make temp tables
				select	ClientId, Concat(ClientId,'-',LienholderId,'-', CollectorId) as Unique_QA_4
				Into	#QA_4
				from	#PartC_4
	


				select	ClientId, Concat(ClientId,'-',[LienholderId],'-', [CollectorId]) as Unique_QA_3b
				into	#QA_3b
				from	#PartC_3b
				
				

				select * from #QA_4
				select * from #QA_3b


			--Actual Checks
				select	ClientId
				from	#QA_4
				where	Unique_QA_4 not in (select Unique_QA_3b from #QA_3b)


				select	ClientId
				from	#QA_3b
				where	Unique_QA_3b not in (select Unique_QA_4 from #QA_4)



		--12. Join #CurrentFPV to #PartC_4 to determine if liens from VOE already exist in SLAM

				--drop table #PartC_Final

	
				--12a. This is the basic table. You will use the final table at the end of 12.
						--Things this table does: 
							--This joins #CurrentFPV to #PartC_4 together. 
							--It looks at current SLAM liens and determines if we can ignore the lien or not (not right lientype, etc.).
							--It determines if there is an exact match between the VOE lien and the lien in SLAM.
							--It finds placeholder liens that can be updated.

										drop table #PartC_Final_basicbiatch
	

							select  distinct VOE.ClientId, VOE.LastName, VOE.FirstName, VOE.SSN, 
									VOE.LienholderId as 'HMO LienholderId',VOE.LienType as 'HMO LienType', VOE.CollectorId as 'HMO CollectorId', VOE.AssignedUserId,VOE.Updated_Stage as 'HMO Stage', VOE.Stage_Notes as 'HMO Instructions', FPV.ClientAdditionalInformation as 'AdditionalInfo',
									FPV.Id as 'Current SLAM LienId', FPV.Lientype as 'Current SLAM LienType', FPV.LienHolderId as 'Current SLAM LienholderId', FPV.CollectorId as 'Current SLAM CollectorId', FPV.LienProductStatus as 'Current SLAM LienProductStatus', FPV.Stage as 'Current SLAM Stage', FPV.ClosedReason as 'Current SLAM ClosedReason',
									Case
										
										When VOE.LienholderId=FPV.LienholderId and VOE.CollectorId=FPV.CollectorId and VOE.LienType = FPV.LienType then 'Done - Lien Already Exists'
								
										--Translation for the below section: If there is a placeholder SLAM lien and the VOE lien is the same PLRP type (i.e. Rawlings, HHC, etc.), then update that placeholder SLAM lien.
										When FPV.LienHolderId = 214 and FPV.CollectorId = 227 and VOE.Lientype like '%PLRP%' and VOE.CollectorId = 227 then 'Update'
										When FPV.LienHolderId = 2473 and FPV.CollectorId = 1866 and VOE.Lientype like '%PLRP%' and VOE.CollectorId = 1866 then 'Update'
										When FPV.LienHolderId = 2474 and FPV.CollectorId = 1867 and VOE.Lientype like '%PLRP%' and VOE.CollectorId = 1867 then 'Update'
										When FPV.LienHolderId = 2475 and FPV.CollectorId = 1868 and VOE.Lientype like '%PLRP%' and VOE.CollectorId = 1868 then 'Update'
										When FPV.LienHolderId = 2027 and FPV.CollectorId = 117 and VOE.Lientype like '%PLRP%' and VOE.CollectorId = 117 then 'Update'
										When FPV.LienHolderId = 2651 and FPV.CollectorId = 1625 and VOE.Lientype like '%PLRP%' and VOE.CollectorId = 1625 then 'Update'
										When FPV.LienHolderId = 696 and FPV.CollectorId = 736 and VOE.Lientype like '%Medicare Lien - Part C%' then 'Update'

										--Translation for the below section: If there is a placeholder SLAM lien, but the VOE lien is not the same PLRP type (i.e. Rawlings, HHC, etc.), then do not update that SLAM lien.
										When FPV.LienHolderId = 214 and FPV.CollectorId = 227 and VOE.Lientype like '%PLRP%' and VOE.CollectorId <> 227 then 'Ignore'
										When FPV.LienHolderId = 2473 and FPV.CollectorId = 1866 and VOE.Lientype like '%PLRP%' and VOE.CollectorId <> 1866 then 'Ignore'
										When FPV.LienHolderId = 2474 and FPV.CollectorId = 1867 and VOE.Lientype like '%PLRP%' and VOE.CollectorId <> 1867 then 'Ignore'
										When FPV.LienHolderId = 2475 and FPV.CollectorId = 1868 and VOE.Lientype like '%PLRP%' and VOE.CollectorId <> 1868 then 'Ignore'
										When FPV.LienHolderId = 2027 and FPV.CollectorId = 117 and VOE.Lientype like '%PLRP%' and VOE.CollectorId <> 117 then 'Ignore'
										When FPV.LienHolderId = 2651 and FPV.CollectorId = 1625 and VOE.Lientype like '%PLRP%' and VOE.CollectorId <> 1625 then 'Ignore'
										When FPV.LienHolderId = 696 and FPV.CollectorId = 736 and VOE.Lientype not like '%Medicare Lien - Part C%' then 'Ignore'

										When VOE.LienholderId=FPV.LienholderId and VOE.CollectorId=FPV.CollectorId then 'Update'
										When FPV.lientype not like '%PLRP%' or FPV.LienType not like 'private lien - mt' then 'Ignore'
										When VOE.ClientId is null then 'Look Into - ClientId is null'
										Else 'Look Into'
										End as 'Update or Upload? prelim'
							into	#PartC_Final_basicbiatch 
							from	#PartC_4 as VOE
										LEFT OUTER JOIN Fullproductviews as FPV on VOE.ClientId=FPV.ClientId
							order by ClientId, [Current SLAM LienType], [Current SLAM CollectorId], [Update or Upload? prelim]
				

				--12ai. Create a separate table for claimants who need a lien uploaded. 
						--AKA: This lien did not show up as a match on the "Update or Upload? prelim" column - all the liens brought into the table from FPV had a result of "ignore", so they need to be uploaded.

									--data checks
											--select * from #PartC_Final_basicbiatch where clientid = 320133

											--select count(*) from #PartC_4
											--select count(*) from #PartC_Final_basicbiatch where [Update or Upload? prelim] <> 'Ignore' 

											--select * from #PartC_4 where clientid = 320513
											--select * from #PartC_Final_basicbiatch where clientid = 320133 order by [HMO LienType]
											

											drop table #PartC_4superiorbiatch

							--Creates the temp table with only the "uploads"

									select sub.* 
									into #PartC_4superiorbiatch
									from (
											select distinct ClientId, [Update or Upload? prelim], 
															LastName, FirstName, SSN, [HMO LienholderId], [HMO LienType], [HMO CollectorId], AssignedUserId, [HMO Stage], [HMO Instructions], AdditionalInfo,
															concat(clientid,'-',[HMO LienholderId], '-', [HMO CollectorId], '-', [HMO LienType]) as Unique1
											from #PartC_Final_basicbiatch
											where  [Update or Upload? prelim] like 'ignore'
										) as sub
									where unique1 not in (select concat(clientid,'-',[HMO LienholderId], '-', [HMO CollectorId], '-', [HMO LienType]) as Unique2 from #PartC_Final_basicbiatch where [Update or Upload? prelim] like 'Update')

											--Data Checks
												select * from #PartC_4superiorbiatch
												select * from #PartC_Final_basicbiatch
											



						--This query adds these "upload" liens back into the #PartC_basicbiatch table

									insert into #PartC_Final_basicbiatch
									select	Clientid, LastName, FirstName, SSN, [HMO LienholderId], [HMO LienType], [HMO CollectorId], AssignedUserId, [HMO Stage], [HMO Instructions], AdditionalInfo, 
											'' as [Current SLAM LienId], '' as [Current SLAM LienType], '' as [Current SLAM LienholderId], '' as [Current SLAM CollectorId], '' as [Current SLAM LienProductStatus], '' as [Current SLAM Stage], '' as [Current SLAM ClosedReason], 
											'Upload' as [Update or Upload? prelim]
									from #PartC_4superiorbiatch
										




				--12b. Create temp table that has a count of Lien Ids that need to be updated
				

							drop table #PartC_4_biatchcount_update


					select [Current SLAM LienId], [Update or Upload? prelim], count([Current SLAM LienId]) as LienId_Count_Update
					into #PartC_4_biatchcount_update
					from #PartC_Final_basicbiatch 
					where [Update or Upload? prelim] = 'Update'
					group by [Current SLAM LienId], [Update or Upload? prelim]


							select * from #PartC_4_biatchcount_update


				
				--12c. Join temp tables with count of lien ids back to biatch table

							drop table #PartC_Final_intermediatebiatch


					select biatch.*, biatchcount_update.LienId_Count_Update
					into #PartC_Final_intermediatebiatch
					from #PartC_Final_basicbiatch as biatch
							LEFT OUTER JOIN #PartC_4_biatchcount_update as biatchcount_update on biatchcount_update.[Current SLAM LienId] = biatch.[Current SLAM LienId]

			
							select * from #PartC_Final_intermediatebiatch
						



				--12d. Do a 'partition by' to get a count/row number for claimants by their [Update or Upload? prelim] 

							drop table #PartC_Final_advancedbiatch


					select *,
							row_number() over(partition by [Current SLAM LienId] order by LienId_count_Update, [Update or Upload? prelim] desc) as Update_Count
					into #PartC_Final_advancedbiatch
					from #PartC_Final_intermediatebiatch

			
			
							select * from #PartC_Final_advancedbiatch 



				--12e. Analyze the "count" data

							drop table #PartC_Final_reallyadvancedbiatch


					select *, CONCAT(ClientId, '-', [HMO LienHolderId], '-', [HMO CollectorId]) as UniqueId,
							case
								when LienId_Count_Update is null or LienId_Count_Update = 1 then [Update or Upload? prelim]
								when LienId_Count_Update > 1 and Update_Count = 1 then 'Update'
								when LienId_Count_Update > 1 and Update_Count <> 1 then 'Upload'
								when [Update or Upload? prelim] <> 'Update' then [Update or Upload? prelim]
								Else 'Look Into'
								End as 'Update or Upload?'
					into #PartC_Final_reallyadvancedbiatch
					from #PartC_Final_advancedbiatch

				
				
							select * from #PartC_Final_advancedbiatch --where clientid = 320461
							select * from #PartC_Final_reallyadvancedbiatch --where clientid = 320461

		
		

----QA 4: Compare the sum of 'Update + Upload' = the distinct count of HMO Codes on VOE (by claimant)


select * from #PartC_4
select * from #PartC_Final_reallyadvancedbiatch

		--Make temp tables
						drop table #QA4_4
			
				select	ClientId, Concat(ClientId,'-',LienholderId,'-', CollectorId) as Unique_QA4_4
				Into	#QA4_4
				from	#PartC_4
	

						drop table #QA4_RAB

				select	ClientId, Concat(ClientId,'-',[HMO LienholderId],'-', [HMO CollectorId]) as Unique_QA4_RAB
				into	#QA4_RAB
				from	#PartC_Final_reallyadvancedbiatch
				where	[Update or Upload?] <> 'Ignore'



				select * from #QA4_4
				select * from #QA4_RAB


			--Actual Checks
				select	ClientId
				from	#QA4_4
				where	Unique_QA4_4 not in (select Unique_QA4_RAB from #QA4_RAB)


				select	ClientId
				from	#QA4_RAB
				where	Unique_QA4_RAB not in (select Unique_QA4_4 from #QA4_4)






				--12f. This table has the liens that need to be updated
				
							drop table #PartC_FinalUpdates
				
					select *
					into #PartC_FinalUpdates
					from #PartC_Final_reallyadvancedbiatch
					where ([Update or Upload?] = 'Update') and [Current SLAM LienProductStatus] <> 'closed'


							select * from  #PartC_FinalUpdates
					
				
				

				--12g. This table has the liens that need to be created
					
							drop table #PartC_FinalUpload


					select 
							distinct ClientId,LastName, FirstName, SSN, 
							[HMO LienholderId], [HMO LienType], [HMO CollectorId], 
							[Current SLAM LienId], [Current SLAM LienType], [Current SLAM LienholderId], [Current SLAM CollectorId], [Current SLAM Stage], [Current SLAM ClosedReason], [Current SLAM LienProductStatus],
							[AssignedUserId], [HMO Stage], [HMO Instructions], AdditionalInfo,[Update or Upload?], UniqueId
					into	#PartC_FinalUpload
					from	#PartC_Final_reallyadvancedbiatch
					where	([Update or Upload?] = 'ignore' or [Update or Upload?] = 'Upload') and [Current SLAM LienProductStatus] <> 'closed'
					
						
							select * from #PartC_FinalUpload
				
				
				

--13. Analyze the "Upload new liens" section

		--13a. Unpivot the subsidiary table
					
				--Create temp 1
					
						drop table #SubsidiaryTable1
					
					select * 
					into #SubsidiaryTable1
					from [dbo].[lienholdersplrpxref]
					where SecondaryLienHolderId1 is not null

						select * from #SubsidiaryTable1

					
				--Create temp 2 (main)
					
						drop table #SubsidiaryTable2

					select InsurerName, PrimaryLienholderId, SecondaryLienholderId
					into #SubsidiaryTable2
					from #SubsidiaryTable1
					UNPIVOT
						(SecondaryLienholderId for Detail IN
							(SecondaryLienholderId1, SecondaryLienholderId2, SecondaryLienholderId3, SecondaryLienholderId4, SecondaryLienholderId5, SecondaryLienholderId6, SecondaryLienholderId7, SecondaryLienholderId8, SecondaryLienholderId9, SecondaryLienholderId10, SecondaryLienholderId11, SecondaryLienholderId12, SecondaryLienholderId13, SecondaryLienholderId14, SecondaryLienholderId15, SecondaryLienholderId16, SecondaryLienholderId17, SecondaryLienholderId18)
							) as unpvt


							select * from #SubsidiaryTable2
						


		--13b. Join VOE data to subsidiary table
				
						drop table #uploadanalysis1


				select	sub.*,
						case
							when InsurerName is null then 'No subsidiary Lienholder Id'
							when InsurerName is not null then 'Has a subsidiary Lienholder Id'
							else 'Look Into'
							End as 'Subsidiary Analysis'
				into	#UploadAnalysis1
				from	(
						select VOE.*, SubId.*
						from	#PartC_FinalUpload as VOE
									LEFT OUTER JOIN #SubsidiaryTable2 as SubId on VOE.[HMO LienholderId]=SubId.SecondaryLienholderId
						where [Update or Upload?] <> 'Ignore'  
						) as sub
			


						select * from #UploadAnalysis1



		--13c. Determine if liens that have a subsidiary Lienholder Id need to have a lien updated or a new lien created

					drop table #UploadAnalysis2


				select	sub.*, 
						case
							when sub.SecondaryLienholderId = sub.[Current SLAM LienholderId] then 'Update existing lien'
							else 'Create new lien'
							end as 'Update/Upload with Subsidiary'
				into #UploadAnalysis2
				from	(
						select * 
						from #UploadAnalysis1
						where [Subsidiary Analysis] = 'Has a subsidiary Lienholder Id'
						) as sub



				select * from #UploadAnalysis2




--14. Create new liens 


		--14a. Create new liens for claimants who were in the "Upload" bucket and have a subsidary lienholder Id, but still need a new lien created
	
			--Data counts - These are the liens that will need to be created
					
					--Everything
						select	distinct *
						from	#UploadAnalysis2 
						where	[Update/Upload with Subsidiary] = 'Create New Lien'


					--Distinct List
						select	distinct ClientId, LastName, FirstName, SSN, [HMO LienholderId], [HMO LienType], [HMO CollectorId], [HMO Stage], [HMO Instructions], [Update or Upload?], [Subsidiary Analysis], [Update/Upload with Subsidiary]
						from	#UploadAnalysis2 
				

					--Distinct count of [Update/Upload with Subsidiary], [HMO Instructions]
						select	distinct [Update/Upload with Subsidiary], [HMO Instructions], count(clientid)
						from	#UploadAnalysis2 
						group by [Update/Upload with Subsidiary], [HMO Instructions]
	


				--14ai. CSV to create liens for normal processing : Upload-HasSubOpen
					
								drop table #CSV_Upload
							

						select	distinct ClientId, [HMO LienType] as 'LienType', [HMO CollectorId] as 'CollectorId', SecondaryLienholderId as 'LienholderId', AssignedUserId, 'Yes' as 'OnBenefits', '[date VOE was recd]' as 'OnBenefitsVerified', 'Open' as 'LienProductStatus', [HMO Stage] as 'Stage'
						into	#CSV_Upload
						from	#UploadAnalysis2
						where	[Update/Upload with Subsidiary] = 'Create New Lien' and [HMO Instructions] = 'Create - Normal'

			
				
				--14aii. CSV to create liens for Closed Opened in Error: Upload-HasSubCloseError
				
								drop table #CSV_UploadClosedError

					select	distinct ClientId, [HMO LienType] as 'LienType', [HMO CollectorId] as 'CollectorId', [HMO LienholderId] as 'LienholderId', AssignedUserId, 'Yes' as 'OnBenefits', '[date VOE was recd]' as 'OnBenefitsVerified', 
							'Closed' as 'LienProductStatus', 'Closed' as 'Stage', 'Opened in Error' as 'ClosedReason', cast(getdate() as date) as 'ClosedDate'
					into	#CSV_UploadClosedError
					from	#UploadAnalysis2
					where	[Update/Upload with Subsidiary] = 'Create New Lien' and [HMO Instructions] like 'Create - Closed Opened in Error'


				
				--14aiii. CSV to create liens for Closed Per Attorney Request: Upload-HasSubCloseAttorney
							drop table #CSV_UploadClosedAttorney

					select	distinct ClientId, [HMO LienType] as 'LienType', [HMO CollectorId] as 'CollectorId', [HMO LienholderId] as 'LienholderId', AssignedUserId, 'Yes' as 'OnBenefits', '[date VOE was recd]' as 'OnBenefitsVerified', 
							'Closed' as 'LienProductStatus', 'Closed' as 'Stage', 'Per Attorney Request' as 'ClosedReason', cast(getdate() as date) as 'ClosedDate'
					into	#CSV_UploadClosedAttorney
					from	#UploadAnalysis2
					where	[Update/Upload with Subsidiary] = 'Create New Lien' and [HMO Instructions] like 'Create - Closed Per Attorney Request'




						--Get results from CSV temp tables; DONT upload these yet!!
							 select * from #CSV_Upload
							 select * from #CSV_UploadClosedError
							 select * from #CSV_UploadClosedAttorney

								--select distinct lienholderid, lienholdername from FullProductViews where lienholderid in ( 768)


						 --QA Check: The count of 'Original' should match the sum of the three other counts

				 			select	count(sub.ClientId) as 'Original'
							from	(
										select	distinct ClientId, LastName, FirstName, SSN, [HMO LienholderId], [HMO LienType], [HMO CollectorId], [HMO Stage], [HMO Instructions], [Update or Upload?], [Subsidiary Analysis], [Update/Upload with Subsidiary]
										from	#UploadAnalysis2 
									) as sub				

									
							select count(*) from #CSV_Upload
							select count(*) from #CSV_UploadClosedError
							select count(*) from #CSV_UploadClosedAttorney





		--14b. Create new liens for claimants who were in the "Upload" bucket and do not have a subsidiary lienholder Id 
				--These queries will add liens to the CSVs created in step 14a
			
			--Data counts - These are the liens that will need to be created
					
					--Everything
						select * 
						from	#UploadAnalysis1 
						where	[Subsidiary Analysis] = 'No subsidiary Lienholder Id' and [Update or Upload?] <> 'Update'


				
				--14bi. CSV to create liens for normal processing: Upload-NoSubOpen
				
						insert	into #CSV_Upload
						select	distinct ClientId, [HMO LienType] as 'LienType', [HMO CollectorId] as 'CollectorId', [HMO LienholderId] as 'LienholderId', AssignedUserId, 'Yes' as 'OnBenefits', '[date VOE was recd]'as 'OnBenefitsVerified', 'Open' as 'LienProductStatus', [HMO Stage] as 'Stage'
						from	#UploadAnalysis1
						where	[Subsidiary Analysis] = 'No subsidiary Lienholder Id' and [Update or Upload?] like 'Upload%' and [HMO Instructions] = 'Create - Normal'


				--14bii. CSV to create liens for Closed Opened in Error: Upload-NoSubClosedError

						insert	into #CSV_UploadClosedError
						select	distinct ClientId, [HMO LienType] as 'LienType', [HMO CollectorId] as 'CollectorId', [HMO LienholderId] as 'LienholderId', AssignedUserId, 'Yes' as 'OnBenefits', '[date VOE was recd]' as 'OnBenefitsVerified', 
								'Closed' as 'LienProductStatus', 'Closed' as 'Stage', 'Opened in Error' as 'ClosedReason', cast(getdate() as date) as 'ClosedDate'
						from	#UploadAnalysis1
						where	[Subsidiary Analysis] = 'No subsidiary Lienholder Id' and [Update or Upload?] like 'Upload%' and [HMO Instructions] like 'Create - Closed Opened in Error'

			

			
				--14biii. CSV to create liens for Closed Per Attorney Request: Upload-NoSubClosedAttorney

						insert	into #CSV_UploadClosedAttorney
						select	distinct ClientId, [HMO LienType] as 'LienType', [HMO CollectorId] as 'CollectorId', [HMO LienholderId] as 'LienholderId', AssignedUserId, 'Yes' as 'OnBenefits', '[date VOE was recd]' as 'OnBenefitsVerified', 
								'Closed' as 'LienProductStatus', 'Closed' as 'Stage', 'Per Attorney Request' as 'ClosedReason', cast(getdate() as date) as 'ClosedDate'
						from	#UploadAnalysis1
						where	[Subsidiary Analysis] = 'No subsidiary Lienholder Id' and [Update or Upload?] like 'Upload%' and [HMO Instructions] like 'Create - Closed Per Attorney Request'

			



		--14c. CSVs to drop into SQL
				
			--ActiveUpload
				
				select distinct * from #CSV_Upload
				
				
			--ClosedUpload
				
				select distinct * from #CSV_UploadClosedError
				

			--ClosedUpload
				
				select distinct * from #CSV_UploadClosedAttorney




	--14d. Create CSVs for NewLienNotes for the liens that were just created
				drop table #UploadLienNote

			--Notes for liens that are still at open: UploadOpenNote
				select  distinct fpv.clientid, fpv.Id,
					case when fin.Stage like 'Final No Lien Received' then '0' else '' end as 'LienAmount1', 
					case when fin.Stage like 'Final No Lien Received' then '0' else '' end as 'AuditedAmount1', 
					case when fin.Stage like 'Final No Lien Received' then '0' else '' end as 'FinalDemandAmount', 
					case when fin.Stage like 'Final No Lien Received' then '[VOE Date]' else '' end as 'LienDate1', 
					case when fin.Stage like 'Final No Lien Received' then '[VOE Date]' else '' end as 'FinalDemandDate', 
				 'Created lien based Sept 2019 Pinnacle Reverification CMS VOE results' as NewLienNote
				into	#UploadLienNote
				from	FullProductViews fpv
							inner join #CSV_Upload fin on fin.clientid =fpv.clientid
				where	fpv.Stage not like 'closed' and fpv.createdon =  cast(getdate() as date) and fpv.Stage not like 'Researching Collector'

				select * from #UploadLienNote

			--Note for liens that were closed: UploadCloseNote
				drop table #UploadClosed_LienNote
						
				--Insert	into #UploadLienNote (clientid,	Id,	LienAmount1,	AuditedAmount1,	FinalDemandAmount,	LienDate1,	FinalDemandDate,	NewLienNote)
				select  distinct fpv.clientid, fpv.Id,'' as LienAmount1,'' as AuditedAmount1, '' as FinalDemandAmount, '' as LienDate1, '' as FinalDemandDate ,'Created lien based Sept 2019 Pinnacle Reverification CMS VOE results. Set lien to closed because HMO end date is prior to client ingestion date' as NewLienNote
				Into	#UploadClosed_LienNote
				from	FullProductViews fpv
							inner join #CSV_UploadClosedError fin on fin.clientid =fpv.clientid
				where	fpv.Stage like 'closed' and fpv.createdon =  cast(getdate() as date) and fpv.Stage not like 'Researching Collector'

					

			--MAKE ONE OF THESE	FOR THE CLOSED PER ATTORNEY REQUEST
				drop table #UploadClosedAttorney_LienNote
				
				--Insert	into #UploadLienNote (clientid,	Id,	LienAmount1,	AuditedAmount1,	FinalDemandAmount,	LienDate1,	FinalDemandDate,	NewLienNote)
				select  distinct fpv.clientid, fpv.Id,'' as LienAmount1,'' as AuditedAmount1, '' as FinalDemandAmount, '' as LienDate1, '' as FinalDemandDate ,'Created lien based Aug 2019 Pinnacle Hip Reverification CMS VOE results. Set lien to closed because HMO end date is prior to client ingestion date' as NewLienNote
				Into	#UploadClosedAttorney_LienNote
				from	FullProductViews fpv
							inner join #CSV_UploadClosedAttorney fin on fin.clientid =fpv.clientid
				where	fpv.Stage like 'closed' and fpv.createdon =  cast(getdate() as date) and fpv.Stage not like 'Researching Collector'

			-- UploadLienNote.csv
				select * from #UploadLienNote
				select * from #UploadClosed_LienNote
				select * from #UploadClosedAttorney_LienNote


				

--15. IF THERE WAS A SUBSIDIARY LIEN ID: Analyze and update anyone who needs their liens updated

		--15a. Analyze the claimants who has a subsidiary lienholder id and are now in the 'update existing liens' category
				--This query tells you what needs to be updated for each lien in the last three columns. There is not a "Create Update CSV" query. You'll need to review the info in the last three columns to determine what needs to be updated, and manually make the CSV. 
				
						drop table #UpdateAnalysis1

				select *, 
						case
							when [HMO Lientype] = [Current SLAM Lientype] then 'No Update'
							when [Current SLAM Lientype] = 'Private Lien - MT' or [Current SLAM Lientype] = 'Private Lien - PLRP' then 'Update Lientype'
							else 'Look Into'
							end as 'Lientype Update?',
						case
							when [HMO LienholderId] <> [Current SLAM LienholderId] then 'LienholderId needs update'
							else 'No Update'
							end as 'Lienholder Id Update?',
						case
							when [HMO CollectorId] <> [Current SLAM CollectorId] then 'CollectorId needs update'
							else 'No Update'
							end as 'Collector Id Update?'
				into #UpdateAnalysis1
				from #UploadAnalysis2
				where [Update/Upload with Subsidiary] = 'Update existing lien' and [Current SLAM LienProductStatus] <> 'closed'
		
		select * from #UpdateAnalysis1

		
		--15b. Review what needs to be updated

				select * from #UpdateAnalysis1

		--15c. Create the Update CSV
				
				select distinct [Current SLAM LienId] as 'Id', [HMO LienholderId] as 'LienholderId', [HMO CollectorId] as 'CollectorId', [HMO LienType] as 'LienType', AssignedUserId, 'Updated lien based on [VOE Name] CMS VOE results' as NewLienNote
				from #UpdateAnalysis1
			
	


			

--16. IF THERE WAS NOT A SUBSIDIARY LIEN ID: Analyze and update anyone who needs their liens updated

		--16a. Analyze the claimants who has a subsidiary lienholder id and are now in the 'update existing liens' category
				--This query tells you what needs to be updated for each lien in the last three columns. There is not a "Create Update CSV" query. You'll need to review the info in the last three columns to determine what needs to be updated, and manually make the CSV. 
				
						drop table #UpdateAnalysis2

				select *, 
						case
							when [HMO Lientype] = [Current SLAM Lientype] then 'No Update'
							when [Current SLAM Lientype] = 'Private Lien - MT' or [Current SLAM Lientype] = 'Private Lien - PLRP' then 'Update Lientype'
							else 'Look Into'
							end as 'Lientype Update?',
						case
							when [HMO LienholderId] <> [Current SLAM LienholderId] then 'LienholderId needs update'
							else 'No Update'
							end as 'Lienholder Id Update?',
						case
							when [HMO CollectorId] <> [Current SLAM CollectorId] then 'CollectorId needs update'
							else 'No Update'
							end as 'Collector Id Update?'
				into #UpdateAnalysis2
				from #PartC_FinalUpdates
				where [Current SLAM LienProductStatus] = 'Open'
		

		
		--16b. Review what needs to be updated

				select * from #UpdateAnalysis2

		
		--16c. Create the Update CSV
				
				--Update Liens for the Normal Process

					select distinct [Current SLAM LienId] as 'Id', [HMO LienholderId] as 'LienholderId', [HMO CollectorId] as 'CollectorId', [HMO LienType] as 'LienType', AssignedUserId, 'Updated lien based on Sept 2019 Pinnacle Reverification CMS VOE results' as NewLienNote
					from #UpdateAnalysis2
					where [HMO Instructions] <> 'Create - Closed Opened in Error'


				--Create Liens set to Opened in Error

					select	ClientId, 'Closed' as LienProductStatus, 'Closed' as Stage, 'Opened in Error' as ClosedReason, cast(getdate() as date) as 'ClosedDate',
							[HMO LienholderId] as 'LienholderId', [HMO CollectorId] as 'CollectorId', [HMO LienType] as 'LienType', AssignedUserId
					into #ClosedError_2
					from	#UpdateAnalysis2
					where	[HMO Instructions] = 'Create - Closed Opened in Error'

					select * from #ClosedError_2

				--Update liens set to Closed Opened in Error to have the lien note
					select distinct FullProductViews.Id, 'Created lien based on Sept 2019 Pinnacle Reverification CMS VOE results. Per protocol, this lien needed to be opened as Closed - Opened in Error.' as NewLienNote
					from FullProductViews
					right join #ClosedError_2 on FullProductViews.ClientId = #ClosedError_2.ClientId
					where FullProductViews.createdon = cast(getdate() as date) and FullProductViews.stage = 'closed' and FullProductViews.Id not in (Select Id from #UploadClosed_LienNote) --and FullProductViews.Id not in (Select Id from #UploadClosedAttorney_LienNote)
--QA Check
-- PartC Liens Currently in SLAM

drop table #CurrentSLAMLiens

Select a.ClientId, Concat(a.ClientId,'-',a.LienholderId, '-', a.CollectorId) as 'Unique'
into #CurrentSLAMLiens
from FullProductViews a
right join #PartC_1 b on b.SSN = a.ClientSSN
where lientype like '%part c%'

select * from #CurrentSLAMLiens

--Part C Liens that were on the VOE, that SHOULD have been created

drop table #LiensCreated

Select a.ClientId, Concat(a.ClientId,'-',a.LienholderId, '-', a.CollectorId) as 'Unique'
into #LiensCreated
from #PartC_4 a

select * from #LiensCreated

--Check for Missing Liens - There should not be anything
select * 
from #LiensCreated
where  ClientID is not null and [Unique] not in (select [Unique] from #CurrentSLAMLiens where ClientID is not null)

		--Check that lien's don't actually already exist, (so check if it was a subsidiary lien)
		select distinct lienholderid, lienholdername from FullProductViews where lienholderid in (142,768)


--17a. Analyze Part C Scope Data
		
				drop table #Scope
				drop table #voe_uploadedliencount
				drop table #scopecount
				drop table #voescope

				select distinct clientid from #PartC_2


				select #PartC_4.ClientId, count(#PartC_4.SSN) as 'Updated Scope'
				into #voescope
				from #PartC_4
				group by #PartC_4.ClientId

				select distinct fpv.ClientId, count(fpv.id) as 'Updated Scope'
				into #voe_uploadedliencount
				from FullProductViews as fpv
				where fpv.LienType like '%part C%' --and fpv.LienProductStatus not like '%closed%'
				group by fpv.ClientId


				select #PartC_4.ClientId as 'ClientId',
					case when #voe_uploadedliencount.[Updated Scope] is NULL then '0' else #voe_uploadedliencount.[Updated Scope] end as 'Updated Scope',
					case when clients.RequiredPartClienCount is NULL then '0' else clients.RequiredPartClienCount end as 'Current Scope'
				into #scopecount
				from #PartC_4
				join #voe_uploadedliencount on #voe_uploadedliencount.ClientId = #PartC_4.ClientId
				join clients on clients.id = #PartC_4.ClientId

				select * from #scopecount

				select	distinct #PartC_4.ClientId, #PartC_4.SSN, #scopecount.[Current Scope], #scopecount.[Updated Scope], 
						case 
							when (#scopecount.[Current Scope] <> #scopecount.[Updated Scope]) and (#scopecount.[Current Scope] < #scopecount.[Updated Scope]) then 'Look Into'
							when (#scopecount.[Current Scope] <> #scopecount.[Updated Scope]) and (#scopecount.[Current Scope] > #scopecount.[Updated Scope]) then 'Mismatch'
							else 'Match'
						end as 'Scope Match?'
				into	#Scope
				from	clients
						JOIN #PartC_4 on #PartC_4.ClientId = clients.Id
						JOIN #scopecount on #scopecount.ClientId = clients.id

				select * from #Scope
				
				--18 delete Opt-Out scope
				select distinct a.clientid as 'Id', 'CLEARVALUE' as RequiredPartClienCount, 'Cleared part C scope since claimant is opt-out' as NewClientNote
				into #OptOutScope
				from #PartC_2 a
				left join Fullproductviews b on a.clientid = b.clientid
				where a.clientadditionalinformation like '%opt%out%'  and b.caseid not in (2919)

				select * from #OptOutScope

				--Check Look Intos
				select distinct *
				from #Scope
				where [Scope Match?] like 'Look Into' and clientid not in (select id from #OptOutScope)

					--select distinct clientid from #PartC_2

				--Check if any lookinto's are placeholders you created
				select distinct #Scope.*, F.Id 
				from #Scope 
				left join Fullproductviews as F on #Scope.ClientId = F.ClientId
				where [Scope Match?] like 'Look Into' and F.LienType = '%Part C' and Stage = 'Researching Collector' and Createdon = cast(getdate() as date)


				--QA Liens
				select SUM([Updated Scope]) from #Scope
				select count(clientId) from #PartC_4

				select * from #PartC_4
				select distinct a.clientId, b.[Updated Scope],count(CONCAT(a.clientid, '-', a.lienholderid, '-', a.collectorid)) as partc_count 
				from #PartC_4 a
				inner join #Scope b on b.clientid = a.clientid
				group by a.clientId, b.[Updated Scope]

--17b. Create Update Scope CSV

		select ClientId as 'Id', [Updated Scope] as 'RequiredPartClienCount', Concat('Updated Scope from ', [Current Scope],' to ', [Updated Scope], ' based on Sept 2019 TVM Reverification CMS VOE results') as 'NewClientNote'
		from #Scope
		where [Scope Match?] like '%Mismatch%' --or [Scope Match?] like '%Look Into%' 
