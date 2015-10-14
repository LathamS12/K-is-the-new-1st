/***********************************************************************
* Author: Scott Latham
* Purpose: This file constructs tables for the paper "Is kindergarten
* 			the new first grade?
* Created:		 7/27/2015
* Last modified: 8/16/2015
************************************************************************/
	set more off
	pause on
	use "C:\Users\sal3ff\Scott\K is the New 1st Grade\Generated Datasets\ECLS-K waves appended.dta", clear 
	
	
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
						
				gl T3b "A4ARTMAT A4MUSIC A4COSTUM A4COOK A4EQUIPM" ; //Doesn't include outcomes that have unidentified logits
			
				gl T4 "ChildSelect_mt1 WholeClass_3om ELA2_Wrkbk_daily ELA2_Basal_daily MTH2_MathSheet_daily MTH2_MathTextbk_daily 
						PEDaily RecDaily" ;
				
				gl T5a	"A2TOCLAS_HI A2TOSTND_HI A2IMPRVM_HI A2EFFO_HI A2BEHAVR_HI A2COPRTV_HI A2FLLWDR_HI" ;

				gl T5b	"A4TOCLSS_HI A4TOSTDR_HI A4IMPPRG_HI A4EFFRT_HI A4CLSBHV_HI A4COOPRT_HI A4FLLDIR_HI " ;	
				


				gl A1a " ELA1_Comp ELA1_Spell ELA1_Story ELA1_Main ELA1_Text ELA1_Rhyme ELA1_Pred ELA1_Oral    
							ELA1_Direct ELA1_Prep ELA1_Match ELA1_Recog ELA1_WrNam ELA1_Conv" ;	

				gl A1b " ELA2_Basal ELA2_WrtWrd ELA2_WrtStory ELA2_Wrkbk ELA2_RdSilent ELA2_InventSpell 
							ELA2_Retell ELA2_ReadLd ELA2_NoPrint ELA2_Journal ELA2_MxdGrp ELA2_ChooseBk ELA2_PeerTutor 
							ELA2_Phonic ELA2_NewVoc ELA2_SeePrint ELA2_BookProj ELA2_PracLt ELA2_Skits ELA2_Dictat ";
					
				gl A2a " MTH1_WordPbs MTH1_Data MTH1_Place MTH1_Count2_5_10 MTH1_Sub MTH1_Money MTH1_Add 
							MTH1_Prob MTH1_Write1_100 MTH1_Graphs  MTH1_ReadTwo MTH1_ReadThree MTH1_CountMore100 MTH1_Meas 
							MTH1_OrdNum MTH1_Write1_10 MTH1_RelQuant MTH1_SortSub MTH1_Patterns MTH1_Est MTH1_Time 
							MTH1_Fractions MTH1_NumQuant MTH1_OrderObj MTH1_Shapes " ;

				gl A2b " MTH2_MathTextbk MTH2_Chalkboard MTH2_MathSheet MTH2_ExpMath MTH2_MthPartners
							MTH2_MusicMath MTH2_CreatMath MTH2_MthRealLife MTH2_PeerTutor MTH2_Calendar MTH2_Calculator 
							MTH2_MxdGrp MTH2_CntOutLd MTH2_MathGames MTH2_CntManip MTH2_GeoManip MTH2_Rulers  ";  

			# delimit cr


		// Non dichotomized outcome tables
		**************************************
		
			capture program drop nondich
			program define nondich
				args title cats weight outcomes 
			
				preserve

					//Initialize table
						matrix table = .
						
						forvalues i = 1 / `cats'	{
							matrix table = table , . , .  
						}
					
					foreach y in `outcomes' {
			
						matrix row = . //Initialize row matrix
			
						forvalues n = 1 / `cats' {
						
							gen `y'var_`n' = `y' == `n' //This is basically a manual "tab, gen()" that allows for no obs for a given value
							replace `y'var_`n' = . if `y' >=.
						
						
							sum `y'var_`n' if dataset == 0 & PublicSchool == 1 [aw=`weight']			
							loc m_98 = round((r(mean)*100), 1)	

							sum `y'var_`n' if dataset == 1 & PublicSchool == 1 [aw=`weight']			
							loc m_10 = round((r(mean)*100), 1)
							
							
							matrix A = (`m_98', `m_10')
							matrix row = row, A //Builds each row 2 numbers at a time
							
						} // closes n loop
							
						matrix table = table \ row //Adds the finished row to the matrix								   
						  
					} //closes y loop
					
					putexcel A1 = matrix(table) using "C:\Users\sal3ff\Scott\K is the new 1st Grade\Tables/`title' - Non dich", replace

				restore
				
			end //ends program nondich		

			nondich "Table 1" 	"5" "fweight" "${T1}"
			
			nondich "Table 2a" 	"5" "sweight" "${T2a}"
			nondich "Table 2b" 	"5" "oweight" "${T2b}"
		
			nondich "Table 3b"	"7" "oweight" "${T3b}"
		
			nondich "Table 4"	"5" "sweight" "TeachChildSelect TeachDirectWhole A2TXPE A2DYRECS"
			
			nondich "Table 5a"	"4"	"sweight" "A2TOCLAS A2TOSTND A2IMPRVM A2EFFO A2BEHAVR A2COPRTV A2FLLWDR"
			nondich "Table 5b"	"4" "oweight" "A4TOCLSS A4TOSTDR A4IMPPRG A4EFFRT A4CLSBHV A4COOPRT A4FLLDIR"	
			
			nondich "Table A1a"	"6" "sweight" "${A1a}"
			nondich "Table A1b"	"6" "sweight" "${A1b}"
			
			nondich "Table A2a"	"6" "sweight" "${A2a}"
			nondich "Table A2b"	"6" "sweight" "${A2b}"
			
		

		// Logit estimations with interactions for minority and FRPL
		**************************************************************

			capture program drop regtabs
			program define regtabs
				args dv suffix var1 var2 grade weight title
				
				set matsize 1000
				
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
				
				capture estimates clear
				foreach x in `dv'	{
					logit `x'`suffix' dataset `var1' `controls' if PublicSchool == 1 [pw = `weight'], cl(S_ID) or
					estimates store `x'1

					logit `x'`suffix' dataset `var2' `controls' if PublicSchool == 1 [pw = `weight'], cl(S_ID) or
					estimates store `x'2	
				}

				estout *1 *2 using "C:\Users\sal3ff\Scott\K is the New 1st Grade\Tables/`title' - Logits",  ///
						eform cells(b(star fmt(2))  se(par(`"="("' `")""') fmt(2))) stats(r2 N) ///
						starlevels(* .05 ** .01 *** .001) replace ///
						keep(dataset HiPctFRL_? INT_FRL_? HiPctMin_? INT_Min_?)
				
			end //ends program regtabs

		// Running with interactions for high % min & high %frpl and a set of controls
			regtabs "$T1"  "_HI" 	"HiPctFRL_K INT_FRL_K" "HiPctMin_K INT_Min_K" K "fweight" "Table 1"
					
			regtabs "$T2a" "_daily" "HiPctFRL_K INT_FRL_K" "HiPctMin_K INT_Min_K" K "sweight" "Table 2a"	
			regtabs "$T2b" "_daily" "HiPctFRL_F INT_FRL_F" "HiPctMin_F INT_Min_F" F "oweight" "Table 2b"	
			
			regtabs "$T3a" ""  		"HiPctFRL_K INT_FRL_K" "HiPctMin_K INT_Min_K" K "fweight" "Table 3a"				
			regtabs "$T3b" "_daily" "HiPctFRL_F INT_FRL_F" "HiPctMin_F INT_Min_F" F "oweight" "Table 3b"	

			regtabs "$T4"  ""  		"HiPctFRL_K INT_FRL_K" "HiPctMin_K INT_Min_K" K "sweight" "Table 4"
				
			regtabs "$T5a" ""  		"HiPctFRL_K INT_FRL_K" "HiPctMin_K INT_Min_K" K "sweight" "Table 5a"		
			regtabs "$T5b" ""  		"HiPctFRL_F INT_FRL_F" "HiPctMin_F INT_Min_F" F "oweight" "Table 5b"

			
	
		//Including low-income & high minority interactions together, along with 3 way interactions
		**********************************************************************************************
			capture program drop fullint
			program define fullint
				args dv suffix grade weight title
				
				loc controls ""
				
				if "`grade'" == "K"  	{

					# delimit ;
						loc vars "SmClassSize Sch_Large Sch_Small Midwest South West City Rural
									NewTeacher TeachElemCt TeachErlyCt 
									TeachMale TeachHisp TeachBlack TeachOther 
									FullDay Sch_PreK " ;	
									
						loc ints "PCTFRLK_HI INT_FRLK PCTMINK_HI INT_MINK INT_MINK_FRLK " ;
					# delimit cr
					
					foreach x in `vars'	{
						loc controls "`controls' `x'_K"
					}
				}
				
				if "`grade'" == "F"		{

					# delimit ;
						loc vars "SmClassSize Sch_Large Sch_Small Midwest South West City Rural
									NewTeacher TeachElemCt TeachErlyCt 
									TeachMale TeachHisp TeachBlack TeachOther " ;	
										
						loc ints "PCTFRL1_HI INT_FRL1 PCTMIN1_HI INT_MIN1 INT_MIN1_FRL1 " ;
						
					# delimit cr
					
					foreach x in `vars'	{
						loc controls "`controls' `x'_F"
					}
				}
				
				capture estimates clear
				foreach x in `dv'	{

					logit `x'`suffix' dataset `ints' `controls' if PublicSchool == 1 [pw = `weight'], cl(S_ID) or
					estimates store `x'1			
					
				}

				estout *1 using "C:\Users\sal3ff\Scott\K is the New 1st Grade\Tables/`title' - Race & SES 3 way int",  ///
						eform cells(b(star fmt(2))  se(par(`"="("' `")""') fmt(2))) stats(r2 N) ///
						starlevels(* .05 ** .01 *** .001) replace ///
						keep(dataset `ints')

				
			end //ends program fullint

			// 			dv		suffix 		grade	weight		title
			fullint 	"$T1"  	"_3"  		"K" 	"fweight" 	"Table 1"

			fullint 	"$T2a"  "_daily"  	"K" 	"sweight" 	"Table 2a"
			fullint 	"$T2b"  "_daily"  	"F" 	"oweight" 	"Table 2b"

			fullint 	"$T3a"  ""  		"K" 	"fweight" 	"Table 3a"
			fullint 	"$T3b"  "_daily"  	"F" 	"oweight" 	"Table 3b"
			
			fullint 	"$T4" 	""  		"K" 	"sweight" 	"Table 4"

			fullint 	"$T5a" 	""  		"K" 	"sweight" 	"Table 5a"
			fullint 	"$T5b" 	""  		"F" 	"oweight" 	"Table 5b"

			
	//Comparisons of means (Bottom half of appendix table is pulled from Kids Today analysis)

		#delimit ;
			loc vars "FullDay SmClassSize Sch_PreK Sch_Large Sch_Small Northeast Midwest South West 
				NewTeacher TeachMale TeachWhite TeachHisp TeachBlack TeachOther TeachElemCt TeachErlyCt " ;
		#delimit cr
	
		loc outcomes ""	
		
		foreach x in `vars'	{
			loc outcomes "`outcomes' `x'_K"
		}
			
	   matrix A = 0, 1
	   
		foreach y in `outcomes' {
			
			sum `y' if dataset == 0 & PublicSchool == 1 [aw=fweight]			
			loc x_0 = round(r(mean), .01)	
	
			sum `y' if dataset == 1 & PublicSchool == 1 [aw=fweight]			
			loc x_1 = round(r(mean), .01)	
				
			
			matrix B = `x_0' , `x_1'
			matrix A = A \ B
		
		
		} //closes y loop

		putexcel A1 = matrix(A) using "C:\Users\sal3ff\Scott\K is the new 1st Grade\Tables\Mean comparisons", replace


