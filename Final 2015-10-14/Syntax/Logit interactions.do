/***********************************************************************
* Author: Scott Latham
* Purpose: This file constructs tables for the paper "Is kindergarten
* 			the new first grade?
* Created:		 8/25/2014
* Last modified: 9/14/2015
************************************************************************/
	set more off
	pause on
	use "C:\Users\sal3ff\Scott\K is the New 1st Grade\Generated Datasets\ECLS-K waves appended.dta", clear 	
	
	foreach x in PrepAlpha_HI PrepRead_HI PrepFormal_HI ClassSciArea ClassDramaArea ClassWaterArea ClassArtArea	{

		reg `x' dataset HiPctFRL_K INT_FRL_K
		reg `x' dataset HiPctMin_K INT_Min_K
	}
	
	foreach x in A2TOSTND_HI ELA2_Basal_daily MTH2_MathTextbk_daily WholeClass_3om ChildSelect_mt1 A2OFTSCI_weekly FreqArt FreqMusic {
	
		reg `x' dataset HiPctFRL_K INT_FRL_K
		reg `x' dataset HiPctMin_K INT_Min_K
	}
	
	*************************************************
	* Table 6. Predicting changes in teacher beliefs
	*************************************************
		
		//Macros for outcome variables
			# delimit ;
				
				gl T1 "PrepRead PrepAlpha PrepFormal PrepPreSch PrepHmwk
							RdyAlpha RdyColor RdyCnt20 RdyFllwDir RdySitSti RdyFinTsk
							RdyNotDisr RdyShare RdySensit RdyPrbSlv RdyPencil RdyComm RdyEng " ;
							
				gl T2a "A2OFTRDL A2OFTMTH A2OFTSOC A2OFTSCI A2OFTMUS A2OFTART A2OFTDAN A2OFTHTR A2OFTFOR" ;
				
				gl T2b "A4OFTRDL A4OFTMTH A4OFTSOC A4OFTSCI A4OFTMUS A4OFTART A4OFTDAN A4OFTFLN" ;
				
				gl T3a "ClassListCenter ClassWriteCenter ClassMathArea ClassPlayArea
						ClassWaterArea ClassCompArea ClassSciArea ClassDramaArea ClassArtArea" ;
						//ClassReadArea - Not identified in logit models;
						
				gl T3b "A4ARTMAT A4COSTUM A4COOK A4EQUIPM" ; //Doesn't include outcomes that have unidentified logits
					//A4MUSIC;
					
				gl T4 "ChildSelect_mt1 WholeClass_3om ELA2_Wrkbk_daily ELA2_Basal_daily MTH2_MathSheet_daily MTH2_MathTextbk_daily 
						PEDaily RecDaily" ;
				
				gl T5a	"A2TOCLAS_HI A2TOSTND_HI A2IMPRVM_HI A2EFFO_HI A2BEHAVR_HI A2COPRTV_HI A2FLLWDR_HI" ;

				gl T5b	"A4TOCLSS_HI A4TOSTDR_HI A4IMPPRG_HI A4EFFRT_HI A4CLSBHV_HI A4COOPRT_HI A4FLLDIR_HI " ;	
				
				gl T6_fall  "PrepAlpha_HI PrepRead_HI PrepFormal_HI ClassSciArea ClassDramaArea ClassWaterArea ClassArtArea" ;
				gl T6_spring "A2TOSTND_HI ELA2_Basal_daily MTH2_MathTextbk_daily WholeClass_3om ChildSelect_mt1 A2OFTSCI_weekly FreqArt FreqMusic " ;

			# delimit cr

	
		capture program drop logtabs
		program define logtabs
			args dv suffix grade weight title
		
			//Initializations
				cap gen baseline = 1

				matrix FRL = J(9,1,.) //Initialize FRL panel (9 rows incl blanks)
				matrix Min = J(9,1,.) //Initialize Min panel (9 rows incl blanks)
				
				loc controls ""
				
				# delimit ;
				
					loc K_vars "SmClassSize Sch_Large Sch_Small Midwest South West City Rural
								NewTeacher TeachElemCt TeachErlyCt TeachMale TeachHisp TeachBlack TeachOther 
								FullDay Sch_PreK " ;
		
					loc F_vars "SmClassSize Sch_Large Sch_Small Midwest South West City Rural
									NewTeacher TeachElemCt TeachErlyCt TeachMale TeachHisp TeachBlack TeachOther " ;
								
				# delimit cr
					
				foreach x in ``grade'_vars'	{			
					loc controls "`controls' `x'_`grade'"
				}		
			
			
			foreach x in `dv'	{
			
				foreach type in FRL Min	{
				
					loc var "`type'_`grade'"  //Just so I don't have to have this typed out everywhere
					
					logit `x'`suffix' dataset HiPct`var' INT_`var' baseline `controls' if PublicSchool == 1 [pw = `weight'], cl(S_ID) or noconstant
					
					//Calculate marginal odds ratios and test differences
						margins, over(dataset HiPct`var') expression(exp(xb())) at((mean) `controls') post
						
							matrix b = e(b) //Save matrix of odds ratios
							matrix odds98 = (round(b[1,1], .01) \ round(b[1,2], .01)) , (. \ .) //To be used later when constructing table
							matrix odds10 = (round(b[1,3], .01) \ round(b[1,4], .01)) , (. \ .)
							
							matrix col = . \ . //Initialize column matrix

						//Testing linear combinations
						
							//List linear combinations to test
								loc comb1 "0.dataset#1.HiPct`var' - 0.dataset#0.HiPct`var'" //Difference in 1998
								loc comb2 "1.dataset#1.HiPct`var' - 1.dataset#0.HiPct`var'" //Difference in 2010
								loc comb3 "(1.dataset#1.HiPct`var' - 1.dataset#0.HiPct`var') - (0.dataset#1.HiPct`var' - 0.dataset#0.HiPct`var')" //Diff in diff
							
								loc z "r(estimate) / r(se)" //For saving z scores

								foreach comb in comb1 comb2 comb3	{
								
									lincom ``comb'' 							
										
										loc b = round(r(estimate), .01)												
						
											if abs(`z') < 1.96		loc sig = 0
											if abs(`z') >= 1.96 	loc sig = 1
											if abs(`z') >= 2.58 	loc sig = 2
											if abs(`z') >= 3.29		loc sig = 3
										
										matrix `comb' =  `b' , `sig'

								}
								
						//Assemble column, add to table - This is totally hardcoded, but don't see an easy way around it
							matrix col = odds98 \ comb1 \ (. , .) \ odds10 \ comb2 \ (. , .) \ comb3						
							matrix `type' = `type' , col
							
					} // close type loop
					
			} // close x loop
			
			matrix table = FRL \ Min  //Assemble the full table		
			putexcel A1 = matrix(table) using "C:\Users\sal3ff\Scott\K is the new 1st Grade\Tables/`title'", replace

		end //ends program logtabs

		logtabs "${T6_fall}" 	"" 	K  "fweight" "Table 6 - fall"
		logtabs "${T6_spring}"  "" 	K  "sweight" "Table 6 - spring"
										 
		logtabs "$T1"  "_HI" 	 K "fweight" "Table C1"
				
		logtabs "$T2a" "_daily"  K "sweight" "Table C2a"	
		logtabs "$T2b" "_daily"  F "oweight" "Table C2b"	
		
		logtabs "$T3a" ""  		 K "fweight" "Table C3a"				
		logtabs "$T3b" "_daily"  F "oweight" "Table C3b"	

		logtabs "$T4"  ""  		 K "sweight" "Table C4"
			
		logtabs "$T5a" ""  		 K "sweight" "Table C5a"		
		logtabs "$T5b" ""  		 F "oweight" "Table C5b"
