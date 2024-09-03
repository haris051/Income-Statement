drop procedure if Exists PROC_INCOME_STATEMENT;
DELIMITER $$
CREATE PROCEDURE `PROC_INCOME_STATEMENT`( P_ENTRY_DATE_FROM TEXT,
										 P_ENTRY_DATE_TO TEXT,
										 P_YEAR TEXT,
										 P_COMPANY_ID INT )
BEGIN

Declare INCOMEAMOUNT Decimal(22,2) default 0;
Declare COSTAMOUNT Decimal(22,2) default 0;
Declare EXPENSEAMOUNT Decimal(22,2) default 0;
Declare GROSSPROFITMONTHLY Decimal(22,2) default 0;
Declare GROSSPROFITMONTHLYPERCENTAGE Decimal(22,2) default 0;
Declare NETOPERATINGMONTHLY DECIMAL(22,2) default 0;
Declare NETOPERATINGMONTHLYPERCENTAGE DECIMAL(22,2) default 0;

Declare INCOMEAMOUNTYEARLY Decimal(22,2) default 0;
Declare COSTAMOUNTYEARLY DECIMAL(22,2) default 0;
Declare EXPENSEAMOUNTYEARLY DECIMAL(22,2) default 0;
Declare GROSSPROFITYEARLY DECIMAL(22,2) default 0;
Declare GROSSPROFITPERCENTAGEYEARLY DECIMAL(22,2) default 0;
Declare NETOPERATINGYEARLY DECIMAL(22,2) default 0;
Declare NETOPERATINGPERCENTAGEYEARLY DECIMAL(22,2) default 0;

select SUM(INCOME) as INCOME,SUM(COST) as COST,SUM(EXPENSE) as EXPENSE INTO INCOMEAMOUNT, COSTAMOUNT, EXPENSEAMOUNT
from(

	SELECT 
			IF(C.ACCOUNT_ID = 1,C.Amount,NULL) INCOME,
			IF(C.ACCOUNT_ID = 2,C.AMOUNT,NULL) COST,
			IF(C.ACCOUNT_ID = 5,C.AMOUNT,NULL) EXPENSE,
			IF(C.ACCOUNT_ID = '1' OR C.ACCOUNT_ID = '2' OR C.ACCOUNT_ID = '5','Balance',null)as Balance
		   
		FROM ( 
        
              select C.Amount,C.ACCOUNT_ID from(
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
										P_ENTRY_DATE_FROM <> "" then A.EntryDate   >=  P_ENTRY_DATE_FROM
									ELSE 
									TRUE
								END
							 
					and 
								case 
									when 
										P_ENTRY_DATE_TO <> "" then A.EntryDate    <=  P_ENTRY_DATE_TO
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
					)C where C.ACCOUNT_ID = 1 OR C.ACCOUNT_ID = '2' OR C.ACCOUNT_ID = '5'
			 )C
    )C group by C.Balance;

	-- ===================== TOTAL GROSS Monthly=====================
	
	SELECT IFNULL(INCOMEAMOUNT, 0) - IFNULL(COSTAMOUNT, 0) INTO GROSSPROFITMONTHLY;

	-- ===================== TOTAL GROSS Monthly===================== 
	
	
	
	-- ===================== TOTAL GROSS PERCENTAGE Monthly=====================
	
	SELECT  case when IFNULL(COSTAMOUNT,0) <> 0 then IFNULL(GROSSPROFITMONTHLY,0)/IFNULL(COSTAMOUNT,0) * 100 else 0 end into GROSSPROFITMONTHLYPERCENTAGE;

	-- ===================== TOTAL GROSS PERCENTAGE Monthly ===================== 
	
    	
	-- ===================== NET OPERATING INCOME Monthly =====================

	SELECT IFNULL(GROSSPROFITMONTHLY, 0) - IFNULL(EXPENSEAMOUNT, 0) INTO NETOPERATINGMONTHLY;

	-- ===================== NET OPERATING INCOME Monthly===================== 
  
  
	-- ===================== NET OPERATING INCOME PERCENTAGE Monthly =====================

	SELECT case when IFNULL(COSTAMOUNT,0) <> 0 then IFNULL(NETOPERATINGMONTHLY,0)/IFNULL(COSTAMOUNT,0) * 100 else 0 end INTO NETOPERATINGMONTHLYPERCENTAGE;

	-- ===================== NET OPERATING INCOME PERCENTAGE Monthly ===================== 
  
  
  

select SUM(INCOME) as INCOME,SUM(COST) as COST,SUM(EXPENSE) as EXPENSE INTO INCOMEAMOUNTYEARLY,COSTAMOUNTYEARLY,EXPENSEAMOUNTYEARLY
from(

	SELECT 
			IF(C.ACCOUNT_ID = 1,C.Amount,NULL) INCOME,
			IF(C.ACCOUNT_ID = 2,C.AMOUNT,NULL) COST,
			IF(C.ACCOUNT_ID = 5,C.AMOUNT,NULL) EXPENSE,
			IF(C.ACCOUNT_ID = 1 OR C.ACCOUNT_ID = '2' OR C.ACCOUNT_ID = '5','Balance',null)as Balance
		   
		FROM ( 
        
              select C.Amount,C.ACCOUNT_ID from(
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
										P_YEAR <> "" then A.EntryDate   >=  CONCAT(P_YEAR, '-01-01')
									ELSE 
									TRUE
								END
							 
					and 
								case 
									when 
										P_ENTRY_DATE_TO <> "" then A.EntryDate    <=  P_ENTRY_DATE_TO
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
					)C where C.ACCOUNT_ID = 1 OR C.ACCOUNT_ID = '2' OR C.ACCOUNT_ID = '5'
			)C
    )C group by C.Balance;

	-- ===================== TOTAL GROSS YEARLY =====================
	
	SELECT IFNULL(INCOMEAMOUNTYEARLY, 0) - IFNULL(COSTAMOUNTYEARLY, 0) INTO GROSSPROFITYEARLY;

	-- ===================== TOTAL GROSS YEARLY ===================== 
	
	
	-- ===================== TOTAL GROSS YEARLY =====================

	SELECT case when IFNULL(COSTAMOUNTYEARLY,0) <> 0 then IFNULL(GROSSPROFITYEARLY, 0) / IFNULL(COSTAMOUNTYEARLY, 0) * 100 else 0 end INTO GROSSPROFITPERCENTAGEYEARLY;

	-- ===================== TOTAL GROSS YEARLY ===================== 
	
	
	
	
	-- ===================== NET OPERATING INCOME YEARLY =====================

	SELECT IFNULL(GROSSPROFITYEARLY, 0) - IFNULL(EXPENSEAMOUNTYEARLY, 0) INTO NETOPERATINGYEARLY;

	-- ===================== NET OPERATING INCOME YEARLY =====================
	
	
	-- ===================== NET OPERATING INCOME YEARLY =====================

	SELECT  case when IFNULL(COSTAMOUNTYEARLY,0) <> 0 then  IFNULL(NETOPERATINGYEARLY, 0) / IFNULL(COSTAMOUNTYEARLY, 0)  * 100 else 0 end INTO NETOPERATINGPERCENTAGEYEARLY;

	-- ===================== NET OPERATING INCOME YEARLY =====================



           
	-- ========================================================================================================
		select * 
		  from (
					SELECT 
								id,
								ACC_ID,
								DESCRIPTION,
								MONTH_AMT,
								PERCENTAGE,
								YEAR_AMT,
								YEARLY_PERCENTAGE,
								ACCOUNT_ID,
								ACCOUNT_TYPE_NAME,
										case 
											 when V.id = "1"  and V.ACC_ID is not null then "aa"
											 when V.id = "1"  and V.ACC_ID is null then "ab"
											 when V.id = "2"  and V.ACC_ID is not null then "ba"
											 when V.id = "2"  and V.ACC_ID is null then "bb"
											 when V.id = "5" and V.ACC_ID is not null then "da"
											 when V.id = "5" and V.ACC_ID is null then "db"
											 when V.id = "ca" then "ca"
											 when V.id = "ea" then "ea"
										END as SortingOrder, COUNT(*) OVER() AS TOTAL_ROWS
					from (
								select    
										C.ACCOUNT_ID as 'id',
										B.ACC_ID as 'ACC_ID',
										B.DESCRIPTION as 'DESCRIPTION',
										Round(IFNULL(cast((SUM(A.Amount)) as Decimal(22,2)),0),2) as 'MONTH_AMT',
										case when IFNULL(INCOMEAMOUNT,0) <> 0 then Round(IFNULL(cast((SUM(A.Amount)/IFNULL(INCOMEAMOUNT,0) *100) as Decimal(22,2)),0),2) else 0 end as 'PERCENTAGE',
										Round(IFNULL(cast((SUM(B.Amount)) as Decimal(22,2)),0),2) as 'YEAR_AMT',
										case when IFNULL(INCOMEAMOUNTYEARLY,0) <> 0 then Round(IFNULL(cast((SUM(B.Amount)/IFNULL(INCOMEAMOUNTYEARLY,0) * 100) as Decimal(22,2)),0),2) else 0 end as 'YEARLY_PERCENTAGE',
										B.id as 'ACCOUNT_ID',
										C.ACCOUNT_TYPE_NAME
										
								from (			
										select 	
												IFNULL(A.Balance,0) AS Amount,
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
																when 
																	 P_ENTRY_DATE_TO <> "" then A.ENTRYDATE <= P_ENTRY_DATE_TO 
																else true
														   end
												AND
														   case 
																when P_ENTRY_DATE_FROM <> "" then A.ENTRYDATE >= P_ENTRY_DATE_FROM 
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
										INNER Join 
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
																			when P_ENTRY_DATE_TO <> "" then  A.ENTRYDATE <= P_ENTRY_DATE_TO 
																			else true 
																		end 
															and  
																		case 
																			when P_ENTRY_DATE_FROM <> "" then A.EntryDate >= CONCAT(P_YEAR, '-01-01') 
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
												INNER Join 
															Accounts_ID B 
												on 
															A.id = B.id 
												where 
															case 
																when P_COMPANY_ID <> "" then B.COMPANY_ID = P_COMPANY_ID 
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
											'ca' AS ID,
											'' AS ACC_ID,
											'GROSS PROFIT' AS DESCRIPTION,
											Round(cast(GROSSPROFITMONTHLY AS decimal(22,2)),2) AS MONTH_AMT,
											Round(CAST(GROSSPROFITMONTHLYPERCENTAGE as decimal(22,2)),2) AS PERCENTAGE,
											Round(cast(GROSSPROFITYEARLY as decimal(22,2)),2) AS YEAR_AMT,
											Round(cast(GROSSPROFITPERCENTAGEYEARLY as decimal(22,2)),2) AS YEARLY_PERCENTAGE,
											'' AS ACCOUNT_ID,
											'' AS ACCOUNT_TYPE_NAME
											
											   
										UNION ALL
								   
								SELECT 
											'ea' AS ID,
											'' AS ACC_ID,
											'NET OPERATING INCOME' AS DESCRIPTION,
											Round(cast(NETOPERATINGMONTHLY as decimal(22,2)),2) AS MONTH_AMT ,
											Round(cast(NETOPERATINGMONTHLYPERCENTAGE as decimal(22,2)),2) AS PERCENTAGE,
											Round(cast(NETOPERATINGYEARLY as decimal(22,2)),2) AS YEAR_AMT,
											Round(cast(NETOPERATINGPERCENTAGEYEARLY as decimal(22,2)),2) AS YEARLY_PERCENTAGE,
											'' AS ACCOUNT_ID,
											'' AS ACCOUNT_TYPE_NAME
											
									)V
									
				)V order by V.SortingOrder;
   
END $$
DELIMITER ;
