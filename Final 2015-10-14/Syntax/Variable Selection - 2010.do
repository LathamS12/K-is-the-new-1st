/***********************************************************
* Author: Scott Latham
* Purpose: This file selects variables from the ECLS-K 2010
* 			for inclusion in the K is the new 1st analysis
* Created: 3/20/2014
* Last modified: 8/15/2015
***********************************************************/
set more off
pause on

	clear all
	set maxvar 10000
	
	global data "C:\Users\sal3ff\NCES Data\ECLS-K\Extracted Data"
	cd "C:\Users\sal3ff\Scott\K is the New 1st Grade\Generated Datasets"	
				
				
	use "$data\ECLS-K 2010 K-1", clear  //Kindergarten and 1st grade variables are merged in 2010
		
	keep  /*
	
		***************************************
		*  Kindergarten variables
		***************************************
		
			ID variables
				*/ CHILDID S1_ID S2_ID T1_ID T2_ID /*

				
			Teacher beliefs about K readiness (Table 1)
				*/  A1ATNDPR-A1READAT A1FNSHT-A1COMM /*	
				
				
			Time use (Tables 2, A1, A2, A3)
			
				General
					*/ A2OFT* /*
					
				Reading/ELA
					*/ A2CONVNT-A2RDFLNT A2PRACLT-A2PATTXT /*
					
				Math
					*/ A2QUANTI-A2EQTN A2OUTLOU-A2NUMBLN /*	
					
				Science/social studies
					*/ A2BODY-A2HYGIEN A2HISTOR-A2SOCPRO /*	
			
			
			Classroom materials (Table 3)
				*/ A1READAR-A1ARTARE /*
			
			Approaches to instruction/Recess (Table 4 - Note: Phys ed is grouped w/general time use in 2010)
				*/ A2WHLCLS A2CHCLDS A2DYRECS /*
			
			Evaluation (Table 5)
				*/ A2TOCLAS-A2FLLWDR A2STNDRD /*
				
				
			Control variables (Used in logit models)
			
				Teacher characteristics
					*/ A1TGEND A1HISP-A1WHITE A1YRSPRE-A1YRS6PL A1ELEMCT A1ERLYCT /*

				School/classroom characteristics
					*/ X2PUBPRI X1REGION X1LOCALE S2WHITPT X2FLCH2_I X2RLCH2_I S2ANUMCH S2PRKNDR /*
					*/ A1AHRSDA A1PHRSDA A1DHRSDA A1*TOTAG /*

			Sample weights (One each for fall and spring of K)
				*/ W1A0 W12AC0 /*		


		*******************
		* First grade variables
		*******************
				
			ID variables
				*/ S4_ID T4_ID /*


			General time use (Table 2)
				*/ A4OFT* /*
				
			Classroom materials (Table 3)
				*/ A4ARTMAT-A4COOK A4EQUIPM	/*
			
			Evaluation (Table 5)
				*/ A4TOCLSS-A4FLLDIR A4STNTST /*
			
			
			Control variables
			
				Teacher characteristics
					*/ A4TGEND A4HISP-A4WHITE A4YRSPRE-A4YRS6PL A4ELEMCT A4ERLYCT /*
			
				School/class characteristics
					*/ X4PUBPRI X4REGION X4LOCALE S4WHITPT X4FMEAL_I X4RMEAL_I S4ANUMCH S4PRKNDR /*
					*/ A4TOTAG /*
					
			Sample weight (Spring of 1st)
				*/ W4CS4P_2T0 		
		
		
		 save "K is the new 1st - 2010 Raw", replace

