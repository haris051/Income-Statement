drop procedure if Exists PROC_INCOME_STATEMENT;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROC_INCOME_STATEMENT`( P_ENTRY_DATE_FROM TEXT,
										 P_ENTRY_DATE_TO TEXT,
										 P_YEAR TEXT,
										 P_COMPANY_ID INT )
BEGIN

	SELECT 
		   IF(C.AMOUNT < 0 AND C.ACCOUNT_ID = 1, IFNULL(MIN(IF(C.ACCOUNT_ID = 1, C.AMOUNT, 0)), 0), IFNULL(MAX(IF(C.ACCOUNT_ID = 1, C.AMOUNT, 0)), 0)) INCOME,
		   IF(C.AMOUNT < 0 AND C.ACCOUNT_ID = 2, IFNULL(MIN(IF(C.ACCOUNT_ID = 2, C.AMOUNT, 0)), 0), IFNULL(MAX(IF(C.ACCOUNT_ID = 2, C.AMOUNT, 0)), 0)) COST,
		   IF(C.AMOUNT < 0 AND C.ACCOUNT_ID = 5, IFNULL(MIN(IF(C.ACCOUNT_ID = 5, C.AMOUNT, 0)), 0), IFNULL(MAX(IF(C.ACCOUNT_ID = 5, C.AMOUNT, 0)), 0)) EXPENSE
		   INTO @INCOMEAMOUNT, @COSTAMOUNT, @EXPENSEAMOUNT
		FROM ( 
					select
								SUM(A.BALANCE) AS Amount,
								C.ACCOUNT_ID 
					from 		
								daily_account_balance A 
					inner join	
								accounts_id B 
					ON			
								A.AccountId = B.id 
					inner join 	
								account_type C
					ON 			
								C.id = B.ACCOUNT_TYPE_ID 
					where
								case 
									when 
										P_ENTRY_DATE_FROM <> "" then A.EntryDate   >  P_ENTRY_DATE_FROM
									ELSE 
									TRUE
								END
							 
					and 
								case 
									when 
										P_ENTRY_DATE_TO <> "" then A.EntryDate    <  P_ENTRY_DATE_TO
									ELSE 
									TRUE
								END		
					and 
								case 
									when 
										P_COMPANY_ID <> "" then B.COMPANY_ID = P_COMPANY_ID
									ELSE 
									TRUE
								END
					group by 
								C.ACCOUNT_ID
			 )C;

	-- ===================== TOTAL GROSS =====================

	SELECT IFNULL(@INCOMEAMOUNT, 0) - IFNULL(@COSTAMOUNT, 0) INTO @GROSSPROFIT;

	-- ===================== TOTAL GROSS ===================== 
	
	
	-- ===================== NET OPERATING INCOME =====================

	SELECT IFNULL(@GROSSPROFIT, 0) - IFNULL(@EXPENSEAMOUNT, 0) INTO @NETOPERATING;

	-- ===================== NET OPERATING INCOME ===================== 
  

	SELECT 
		   IF(C.AMOUNT < 0 AND C.ACCOUNT_ID = 1, IFNULL(MIN(IF(C.ACCOUNT_ID = 1, C.AMOUNT, 0)), 0), IFNULL(MAX(IF(C.ACCOUNT_ID = 1, C.AMOUNT, 0)), 0)) INCOMEYEARLY,
		   IF(C.AMOUNT < 0 AND C.ACCOUNT_ID = 2, IFNULL(MIN(IF(C.ACCOUNT_ID = 2, C.AMOUNT, 0)), 0), IFNULL(MAX(IF(C.ACCOUNT_ID = 2, C.AMOUNT, 0)), 0)) COSTYEARLY
		   INTO @INCOMEAMOUNTYEARLY, @COSTAMOUNTYEARLY
      FROM (
                select 
							SUM(A.BALANCE) AS Amount,
							C.ACCOUNT_ID 
				from 
							daily_account_balance A 
				inner join 
							accounts_id B 
				ON
							A.AccountId = B.id 
				inner join 
							account_type C
				ON 
							C.id = B.ACCOUNT_TYPE_ID 
				where
							case 
								when 
									P_YEAR <> "" then A.EntryDate   >  CONCAT(P_YEAR, '-01-01')
								ELSE 
								TRUE
							END 
				and 
							case 
								when 
									P_ENTRY_DATE_TO <> "" then A.EntryDate    <  P_ENTRY_DATE_TO
								ELSE 
								TRUE
							END
						     
				and 
							case 
								when 
									P_COMPANY_ID <> "" then B.COMPANY_ID = P_COMPANY_ID
								ELSE 
								TRUE
							END
				group by 
							C.ACCOUNT_ID
			)C;
           
	-- ========================================================================================================

			SELECT 
						*, COUNT(*) OVER() AS TOTAL_ROWS
			from (
						select    
								C.ACCOUNT_ID as 'id',
								B.ACC_ID as 'ACC_ID',
								B.DESCRIPTION as 'DESCRIPTION',
								IFNULL(SUM(A.Amount),0) as 'MONTH_AMT',
								IFNULL(SUM(A.Amount)/IFNULL(@INCOMEAMOUNT,0) * 100,0) as 'PERCENTAGE',
								IFNULL(SUM(B.Amount),0) as 'YEAR_AMT',
								IFNULL(SUM(B.Amount)/IFNULL(@INCOMEAMOUNTYEARLY,0) * 100,0) as 'YEARLY_PERCENTAGE',
								B.id as 'ACCOUNT_ID',
								C.ACCOUNT_TYPE_NAME
						from (			
								select 	
										IFNULL(A.BALANCE,0) AS Amount,
										B.id,
										B.Description,
										B.ACC_ID,
										B.ACCOUNT_TYPE_ID 
								from (
										select 
												   SUM(A.Balance) as Balance,B.id 
										from  
												   Daily_Account_Balance A 
										Right Join 
												   Accounts_Id B 
										on 
												   A.AccountId = B.id 
										where 
												   case 
														when 
															 P_ENTRY_DATE_TO <> "" then A.ENTRYDATE < P_ENTRY_DATE_TO 
														else true
												   end
										AND
												   case 
														when P_ENTRY_DATE_FROM <> "" then A.ENTRYDATE > P_ENTRY_DATE_FROM 
														else true 
												   end
										and 
												   case 
														when P_COMPANY_ID <> "" then B.COMPANY_ID = P_COMPANY_ID 
														else true 
												   end
										group by 
												   B.id
									)A 
								Right Join 
											Accounts_ID B 
								on 
											A.id = B.id 
								where 
											case 
												when P_COMPANY_ID <> "" then B.COMPANY_ID = P_COMPANY_ID 
												else true 
											end
							)A 
						INNER join 
									(
										select 	
													IFNULL(A.BALANCE,0) AS Amount,
													B.id,
													B.Description,
													B.ACC_ID,
													B.ACCOUNT_TYPE_ID 
										from (
													select 
																SUM(A.Balance) as Balance,
																B.id 
													from  
																Daily_Account_Balance A 
													Right Join 
																Accounts_Id B 
													on 
																A.AccountId = B.id 
													where 
																case 
																	when P_ENTRY_DATE_TO <> "" then  A.ENTRYDATE < P_ENTRY_DATE_TO 
																	else true 
																end 
													and  
																case 
																	when P_ENTRY_DATE_FROM <> "" then A.EntryDate >P_ENTRY_DATE_FROM 
																	else true 
																end 
													and 
																case 
																	when P_COMPANY_ID <> 1 then B.COMPANY_ID = P_COMPANY_ID 
																	else true 
																end
													group by 
																B.id
											 )A 
										Right Join 
													Accounts_ID B 
										on 
													A.id = B.id 
										where 
													case 
														when P_COMPANY_ID <> 1 then B.COMPANY_ID = P_COMPANY_ID 
														else true 
													end
									)B 
				        ON A.id = B.id
						INNER join 
									account_type C 
						ON 
									C.id = B.ACCOUNT_TYPE_ID
						where  C.Account_Id = 1 OR C.ACCOUNT_ID = 2 OR C.ACCOUNT_ID = 5
                        group by 
								  C.ACCOUNT_ID,
								  B.id,
								  B.DESCRIPTION,
								  B.ACC_ID,
                                  C.ACCOUNT_TYPE_NAME
						with ROLLUP
                        having (
									B.id is not null and 
                                    B.DESCRIPTION is not null and 
                                    B.ACC_ID is not null and 
                                    C.Account_Id is not null and
                                    C.ACCOUNT_TYPE_NAME is not null
								) OR 
                                (
									B.id is null and 
                                    B.DESCRIPTION is null and 
                                    B.ACC_ID is null and 
                                    C.ACCOUNT_TYPE_NAME is null and
                                    C.Account_Id is not null
								)
                                UNION ALL
						   
						SELECT 
									'' AS ID,
									'' AS ACC_ID,
									CONCAT('GROSS PROFIT  :  ', IFNULL(@GROSSPROFIT, 0)) AS DESCRIPTION,
									'' AS MONTH_AMT,
									'' AS PERCENTAGE,
									'' AS YEAR_AMT,
                                    '' AS YEARLY_PERCENTAGE,
                                    '' AS ACCOUNT_ID,
									'' AS ACCOUNT_TYPE_NAME
                                       
							    UNION ALL
						   
						SELECT 
									'' AS ID,
									'' AS ACC_ID,
									CONCAT('NET OPERATING INCOME  :  ', (IFNULL(@GROSSPROFIT, 0) - IFNULL(@EXPENSEAMOUNT, 0))) AS DESCRIPTION,
									'' AS MONTH_AMT ,
									'' AS PERCENTAGE,
									'' AS YEAR_AMT,
                                    '' AS YEARLY_PERCENTAGE,
									'' AS ACCOUNT_ID,
                                    '' AS ACCOUNT_TYPE_NAME)V;
   
END $$
DELIMITER ;
