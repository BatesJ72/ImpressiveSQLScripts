--Double Nos

-- Double No Claimants 

				  -- Run A: Create Table 1: Cases with Double No Scope
					  select distinct Name 
					  into ##casedoubleno
					  from cases
					  where ScopeDoubleNo = 1

									
				  -- Run B: Create Table 2 for Clients Associated with Double No Cases (to figure out the true # of claimants who should have PLRP liens).
				  				
								drop table ##detail

							SELECT  [##casedoubleno].name AS 'Case Name', f.ClientId, f.finalizedstatusid, f.stage, f.closedreason, 
									f.Id AS LienID, f.LienType, f.OnBenefits, 
							
									CASE 
							 			WHEN f.lientype = 'medicaid lien - mt' AND f.onbenefits = 'no' and
										stage = 'final no entitlement'
										THEN 'McaidNo' 

										WHEN f.lientype = 'medicaid lien - mt' AND (f.ClosedReason = 'Opened in Error' or f.ClosedReason = 'Per Attorney Request' or f.ClosedReason = 'Per Atty Request')
										THEN 'McaidNo' 
							
										WHEN f.lientype = 'medicaid lien - mt' AND f.onbenefits = 'no' and
										stage ='closed' and closedreason = 'resolved - no entitlement'
										THEN 'McaidNo' 

										WHEN f.lientype = 'medicare - global' AND (f.ClosedReason = 'Opened in Error' or f.ClosedReason = 'Per Attorney Request' or f.ClosedReason = 'Per Atty Request')
										THEN 'McareNo' 

										WHEN lientype = 'medicare - global' AND f.OnBenefits = 'no' and stage = 'final no entitlement'
										THEN 'McareNo'
							
										WHEN f.lientype = 'medicare lien - mt' AND f.OnBenefits = 'no' and stage = 'final no entitlement'
										THEN 'McaidNo'
								
										WHEN (f.lientype = 'medicare lien - mt' OR lientype = 'medicare - global') AND f.OnBenefits = 'no' and 
										stage = 'closed' and closedreason = 'resolved - no entitlement' 
										THEN 'McareNo'

										WHEN (f.lientype = 'medicare lien - mt' Or lientype = 'medicare - global') AND f.onbenefits = 'yes' 
										THEN 'McareYes'
								
										WHEN f.lientype = 'medicaid lien - mt' AND f.OnBenefits = 'yes' 
										THEN 'McaidYes'

										when f.lientype like '%plrp%' and (closedreason <> 'opened in error' or closedreason is null or closedreason = '' 
										or closedreason = 'null') 
										then 'PLRP Legit' 

										when f.lientype like '%plrp%' and closedreason = 'opened in error'
										then 'PLRP Suspect'
																					
										WHEN (f.lientype in('medicaid lien - mt','medicare lien - mt','medicare - global') or f.lientype like '%plrp%')
										and f.stage <> 'final no entitlement'
										then 'Pending' 
								 
										WHEN (f.lientype in('medicaid lien - mt','medicare lien - mt','medicare - global') or f.lientype like '%plrp%')
										and f.closedreason <> 'resolved - no entitlement' 
										THEN 'Pending' 
																													
										WHEN (f.lientype in('medicaid lien - mt','medicare lien - mt','medicare - global') or f.lientype like '%plrp%')
										and (onbenefits IS NULL OR onbenefits = '' OR onbenefits = 'null')
										THEN 'Pending' 
																
										ELSE 'Issue' END AS 'Category'
												
							INTO     [##detail]
							FROM     FullProductViews AS f RIGHT OUTER JOIN
										 [##casedoubleno] ON f.CaseName = [##casedoubleno].Name
							WHERE    (f.LienType = 'medicare - global') OR
									 (f.LienType = 'medicare lien - mt') OR
									 (f.LienType = 'medicaid lien - mt') or
									 (f.lientype like '%plrp%')



						--Run C: Create Table 3
							select sub.*
							into ##summarydoubleno
							from (select [Case Name], clientid, category, count(lienid) as Liens
							from ##detail
							group by clientid, Category, [Case Name]) sub

									


						-- Run D: Create table for Regular -- Only Find Clients with Mcaid Yes + Mcare Yes + PLRP Legit  + Pending = 0
							 drop table ##FinalRegularDoubleNo
							 
							 select sub.*
							 Into ##FinalRegularDoubleNo
							 from (select *
							 from ##summarydoubleno
											 pivot (count(liens) for category  in ([plrp suspect],[plrp legit],[mcaidyes],[mcaidno],[mcareyes],[mcareno],[pending],[issue])) as Total_Amount) sub
							 where (sub.mcaidyes + sub.mcareyes + sub.pending  + sub.[plrp legit] = 0 and sub.[plrp suspect] = 0)
									and ClientId not in (135434, 135675, 156134, 208096, 136233)
							 Order by [Case Name]
						



						--Run E (To copy into excel): Good
								Select sub.*
								From (
										SELECT distinct R.ClientId, F.CaseName, F.ClientState, F.CaseUserDisplayName, F.ClientSettlementAmount, f.ClientDescriptionOfInjury, f.FinalizedStatusId, f.ClientSSN, f.ThirdPartyId,
												CASE
													WHEN f.FinalizedStatusId>1 then 'Issue - Claimant Already Final'
													WHEN f.CaseName like '%Blizzard%' then 'Ask Lauren'
													WHEN f.ClientSettlementAmount <= '43000' and f.ClientDescriptionOfInjury like 'Mesh Implant with%' then 'FNE'
													ELSE 'To Send - EV'
													END AS 'Stage for PLRP Lien'  ,
												Case
												When f.CaseName like 'Sburnett%' then concat(f.thirdpartyid,',')
												Else ''
												End as 'COL/SLAM SSN Match?' 
										FROM FullProductViews as f INNER JOIN
										 ##FinalRegularDoubleNo as R ON F.ClientId = R.ClientId
										WHERE f.IsMt = 1 and f.ScopeDoubleNo <> 0 and f.CaseUserDisplayName not like '%Global%' and f.CaseUserDisplayName not like '%Complete%' 
									) as sub
								Where [Stage for PLRP Lien] <> 'Issue - Claimant Already Final'
								Order by CaseName, CaseUserDisplayName


						--Run F (To copy into excel): Bad
								Select sub.*
								From (
										SELECT distinct R.ClientId, F.CaseName, F.ClientState, F.CaseUserDisplayName, F.ClientSettlementAmount, f.ClientDescriptionOfInjury, f.FinalizedStatusId,
												CASE
													WHEN f.FinalizedStatusId>1 then 'Issue - Claimant Already Final'
													WHEN f.ClientSettlementAmount <= '43000' and f.ClientDescriptionOfInjury like 'Mesh Implant with%' then 'FNE'
													ELSE 'To Send - EV'
													END AS 'Stage for PLRP Lien'    
										FROM FullProductViews as f INNER JOIN
										 ##FinalRegularDoubleNo as R ON F.ClientId = R.ClientId
										WHERE f.IsMt = 1 and f.ScopeDoubleNo <> 0 and f.CaseUserDisplayName not like '%Global%' and f.CaseUserDisplayName not like '%Complete%' 
									) as sub
								Where [Stage for PLRP Lien] = 'Issue - Claimant Already Final'
										


						 -- Run G: Create table for Suspect -- Only Find Clients with Mcaid Yes + Mcare Yes + Pending  = 0 and PLRP Suspect > 0
														
									drop table ##FinalSuspectDoubleNo

								 select sub.*
								 Into ##FinalSuspectDoubleNo
								 from (select *
								 from ##summarydoubleno
												 pivot (count(liens) for category  in ([plrp suspect],[plrp legit],[mcaidyes],[mcaidno],[mcareyes],[mcareno],[pending],[issue])) as Total_Amount) sub
								 where sub.mcaidyes + sub.mcareyes + sub.pending  + sub.[plrp legit] = 0 and sub.[plrp suspect] > 0
										
								

							--Run H (to copy into excel): Suspect 
							
								SELECT distinct R.ClientId, F.CaseName, F.ClientState, F.CaseUserDisplayName, F.ClientSettlementAmount, f.ClientDescriptionOfInjury, f.FinalizedStatusId,
										CASE
											WHEN f.FinalizedStatusId>1 then 'Issue - Claimant Already Final'
											WHEN f.ClientSettlementAmount <= '43000' and f.ClientDescriptionOfInjury like 'Mesh Implant with%' then 'FNE'
											ELSE 'To Send - EV'
											END AS 'Stage for PLRP Lien'    
								FROM FullProductViews as f INNER JOIN
								 ##FinalSuspectDoubleNo as R ON F.ClientId = R.ClientId
								WHERE f.IsMt = 1 and f.ScopeDoubleNo <> 0 and f.CaseUserDisplayName not like '%Global%' and f.CaseUserDisplayName not like '%Complete%' 
											
