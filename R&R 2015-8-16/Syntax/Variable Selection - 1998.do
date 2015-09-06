/***********************************************************
* Author: Scott Latham
* Purpose: This file selects variables from the ECLS-K 1998
* 			for inclusion in the K is the new 1st analysis
* Created: 8/26/2014
* Last modified: 8/15/2015
***********************************************************/
set more off
pause on

	clear all
	set maxvar 10000

	global data "C:\Users\sal3ff\NCES Data\ECLS-K\Extracted Data" //Replace with data folder
	cd "C:\Users\sal3ff\Scott\K is the New 1st Grade\Generated Datasets"		
			
	***************************
	*  Kindergarten variables
	***************************
		use "$data\Base Year - Child", clear

		keep  /*

			ID variables
				*/ CHILDID S1_ID S2_ID T1_ID T2_ID /*

				
			Teacher beliefs about K readiness (Table 1)
				*/ B1ATNDPR-B1READAT B1FNSHT-B1COMM /*	
				
				
			Time use (Tables 2, A1, A2, A3)
			
				General
					*/ A2OFT* /*
					
				Reading/ELA
					*/ A2CONVNT-A2RDFLNT A2LERNLT-A2PRTUTR /*
					
				Math
					*/ A2QUANTI-A2EQTN A2OUTLOU-A2PEER	/*	
					
				Science/social studies
					*/ A2BODY-A2HYGIEN A2HISTOR-A2SOCPRO /*	
			
			
			Classroom materials (Table 3)
				*/ B1READAR-B1ARTARE /*
			
			Approaches to instruction/Phys ed/Recess (Table 4)
				*/ A2WHLCLS A2CHCLDS A2TXPE A2DYRECS /*
			
			Evaluation (Table 5)
				*/ B2TOCLAS-B2OTMT /*
				
				
			Control variables (Used in logit models)
			
				Teacher characteristics
					*/ B1AGE B1TGEND B1YRBORN B1HISP-B1RACE5 B1YRSPRE-B1YRS6PL B1ELEMCT B1ERLYCT /*

				School/classroom characteristics
					*/ S2KPUPRI CREGION KURBAN S2WHTPCT S2KFLNCH S2KRLNCH S2KMINOR S2ANUMCH S2PRKNDR /*
					*/ A1HRSDA A1DYSWK A1TOTAG /*

			Sample weights (One each for fall and spring of K)
				*/ C1CPTW0 C2CPTW0		

			save "Kindergarten - 1998", replace

	***************************
	*	First grade variables
	***************************
		use "$data/1st Grade", clear
		
			keep /*

			ID variables
				*/ CHILDID S4_ID T4_ID  /*


			General time use (Table 2)
				*/ A4OFT* A4WHLCLS A4CHCLDS /*
				
			Classroom materials (Table 3)
				*/ A4ARTMAT-A4COOK A4EQUIPM	/*
			
			Evaluation (Table 5)
				*/ A4TOCLAS-A4FLLWDR A4STNDRD /*
			
			
			Control variables
			
				Teacher characteristics
					*/ B4TGEND B4HISP-B4RACE5 B4YRSPR-B4YRS6P B4ELEMCT B4ERLYCT  /*
			
				School/class characteristics
					*/ S4PUPRI R4REGION R4URBAN S4WHTPCT S4FLNCH S4RLNCH S4ANUMCH S4PRKNDR   /*
					*/ A4TOTAG /*
					
			Sample weight (Spring of 1st)
				*/ C4CPTW0			
		
		save "First grade - 1998", replace


	//Merge across grades and save
		use "Kindergarten - 1998", clear

		merge 1:1 CHILDID using "First grade - 1998"
		drop _merge

		order *_ID

		save "K is the new 1st - 1998 Raw", replace

		erase "Kindergarten - 1998.dta"
		erase "First grade - 1998.dta"


			



