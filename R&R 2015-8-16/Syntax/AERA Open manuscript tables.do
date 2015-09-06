/***********************************************************************
* Author: Scott Latham
* Purpose: This file constructs tables for the paper "Is kindergarten
* 			the new first grade?
* Created:		 8/25/2014
* Last modified: 8/16/2015
************************************************************************/
	set more off
	pause on
	use "C:\Users\sal3ff\Scott\K is the New 1st Grade\Generated Datasets\ECLS-K waves appended.dta", clear 

	************************************************************************
	* Table 1. Teacher's beliefs about school readiness and kindergarten learning
	***********************************************************************
		tempname memhold    //    where you temporarily hold the postings
		tempfile rdest        //    name of the temporary file that will become the new dataset
		postfile `memhold' str25(outcome) EK98 EK10 str10(diff) using `rdest' 

			#delimit ;
				loc outcomes "PrepRead PrepAlpha PrepFormal PrepPreSch PrepHmwk
							RdyAlpha RdyColor RdyCnt20 RdyFllwDir RdySitSti RdyFinTsk
							RdyNotDisr RdyShare RdySensit RdyPrbSlv RdyPencil RdyComm RdyEng " ;				
			#delimit cr

			foreach y in `outcomes' {
			
				foreach i in 0 1	{
			
					sum `y'_HI if dataset == `i' & PublicSchool == 1 [aw=fweight]			
					loc `y'_`i' = round((r(mean)*100), 1)	
					
				} //closes i loop

				loc `y'_diff = ``y'_1'-``y'_0'
				
				//Adding significance stars						

					logit `y'_HI dataset if PublicSchool == 1 [pw=fweight], cl(S_ID)
						loc z = _b[dataset]/_se[dataset] //Formula for z score
						loc p = 2*normal(-abs(`z')) //Formula for p value

					loc `y'_stars = ""
					
					if `p' <= .05		loc `y'_stars "*" 
					if `p' <= .01		loc `y'_stars "**"	
					if `p' <= .001		loc `y'_stars "***"
			
				post `memhold' ("`y'") (``y'_0') (``y'_1') ("``y'_diff'``y'_stars'")
			
			} //closes y loop

		postclose `memhold'    //    end the postfile
	   
		preserve
			use `rdest', clear    //     open the new dataset you've created
			export excel using "C:\Users\sal3ff\Scott\K is the new 1st Grade\Tables\Table 1", replace
		restore


	**********************************************
	* Table 2, panel B of Table 3, Appendix 1 & 2
	**********************************************

		capture program drop content
		program define content
			args outcomes title weight
		
			tempname memhold    //    where you temporarily hold the postings
			tempfile rdest        //    name of the temporary file that will become the new dataset

				#delimit ;

					postfile `memhold' str25(outcome) EK98d EK10d diff1 str4(stars1) 
													  EK98w EK10w diff2 str4(stars2) 
													  EK98n EK10n diff3 str4(stars3) using `rdest' ;

				#delimit cr
			   
				foreach y in `outcomes' {
				
					foreach x in daily weekly never	{
				
						sum `y'_`x' if dataset == 0 & PublicSchool==1 [aw=`weight']			
						loc `y'_0_`x' = round((r(mean)*100), 1)

						sum `y'_`x' if dataset == 1 & PublicSchool==1 [aw=`weight']				
						loc `y'_1_`x' = round((r(mean)*100), 1)

						loc `y'_diff_`x' = ``y'_1_`x''-``y'_0_`x''
						
						
						//Assign significance stars based on logit models
							//First see if the logit is identified					
								cap logit `y'_`x' dataset if PublicSchool == 1 [pw=`weight']

							//If yes, assign p value the normal way 
							//If no, assign p value to 1
								if _rc ==0	{
									if _b[dataset] != 0  {
										
										logit `y'_`x' dataset if PublicSchool == 1 [pw=`weight'], cl(S_ID)
											loc z = _b[dataset]/_se[dataset] //Formula for z score
											loc p = 2*normal(-abs(`z')) //Formula for p value
											
									}
									else	loc p = 1
								}
								else	loc p = 1							
							
							//Use the saved p value to determine significance stars
								loc `y'_stars_`x' = ""				

								if `p' <= .05		loc `y'_stars_`x' "*" 
								if `p' <= .01		loc `y'_stars_`x' "**"	
								if `p' <= .001		loc `y'_stars_`x' "***"

					} //closes x loop
		
				#delimit ;
					post `memhold' ("`y'")  (``y'_0_daily')  (``y'_1_daily')   (``y'_diff_daily')  ("``y'_stars_daily'")
											(``y'_0_weekly') (``y'_1_weekly')  (``y'_diff_weekly') ("``y'_stars_weekly'")
											(``y'_0_never')  (``y'_1_never')   (``y'_diff_never')  ("``y'_stars_never'") ;
				#delimit cr
				
				} //closes y loop

			postclose `memhold'    //    end the postfile
			   
			preserve
				use `rdest', clear    //     open the new dataset you've created
				export excel using "C:\Users\sal3ff\Scott\K is the New 1st Grade\Tables/`title'", replace
			restore

		end //ends program content

		//Table 2
			content "A2OFTRDL A2OFTMTH A2OFTSOC A2OFTSCI A2OFTMUS A2OFTART A2OFTDAN A2OFTHTR A2OFTFOR" "Table 2 - K" 	"sweight"
			content "A4OFTRDL A4OFTMTH A4OFTSOC A4OFTSCI A4OFTMUS A4OFTART A4OFTDAN A4OFTHTR A4OFTFLN" "Table 2 - 1st"  "oweight"
	
		//Table 3b
			content "A4ARTMAT A4MUSIC A4COSTUM A4COOK A4EQUIPM" "Table 3 - Panel B" "oweight"

		//Appendix 1 & 2
			# delimit ;	

				gl e_content " ELA1_Comp ELA1_Spell ELA1_Story ELA1_Main ELA1_Text ELA1_Rhyme ELA1_Pred ELA1_Oral    
					 ELA1_Direct ELA1_Prep ELA1_Match ELA1_Recog ELA1_WrNam ELA1_Conv" ;
	 
				gl m_content " MTH1_WordPbs MTH1_Data MTH1_Place MTH1_Count2_5_10 MTH1_Sub MTH1_Money MTH1_Add 
					MTH1_Prob MTH1_Write1_100 MTH1_Graphs  MTH1_ReadTwo MTH1_ReadThree MTH1_CountMore100 MTH1_Meas 
					MTH1_OrdNum MTH1_Write1_10 MTH1_RelQuant MTH1_SortSub MTH1_Patterns MTH1_Est MTH1_Time 
					MTH1_Fractions MTH1_NumQuant MTH1_OrderObj MTH1_Shapes " ;

				gl e_activs " ELA2_Basal ELA2_WrtWrd ELA2_WrtStory ELA2_Wrkbk ELA2_RdSilent ELA2_InventSpell 
					ELA2_Retell ELA2_ReadLd ELA2_NoPrint ELA2_Journal ELA2_MxdGrp ELA2_ChooseBk ELA2_PeerTutor 
					ELA2_Phonic ELA2_NewVoc ELA2_SeePrint ELA2_BookProj ELA2_PracLt ELA2_Skits ELA2_Dictat "; 

				gl m_activs " MTH2_MathTextbk MTH2_Chalkboard MTH2_MathSheet MTH2_ExpMath MTH2_MthPartners
					MTH2_MusicMath MTH2_CreatMath MTH2_MthRealLife MTH2_PeerTutor MTH2_Calendar MTH2_Calculator 
					MTH2_MxdGrp MTH2_CntOutLd MTH2_MathGames MTH2_CntManip MTH2_GeoManip MTH2_Rulers  ";  

			# delimit cr
		
			content "$e_content" "A1 - Topics in ELA" "sweight"	
			content "$e_activs"  "A1 - ELA activities" "sweight"
			
			content "$m_content" "A2 - Topics in math" "sweight"
			content "$m_activs"  "A2 - Math activities" "sweight"

			
	******************************
	* Table 3 - Panel A
	******************************

		tempname memhold    //    where you temporarily hold the postings
		tempfile rdest      //    name of the temporary file that will become the new dataset
		postfile `memhold' str25(outcome) EK98 EK10 str6(diff1 star1) EK98FD EK10FD str6(diff2 star2) EK98HD EK10HD str6(diff3 star3) using `rdest' 

			#delimit ;
				loc outcomes "ClassReadArea ClassListCenter ClassWriteCenter ClassMathArea ClassPlayArea 
								ClassWaterArea ClassCompArea ClassSciArea ClassDramaArea ClassArtArea" ;
			#delimit cr

		   
			foreach y in `outcomes' {
			
				foreach x in All Full Half	{
				
					sum `y' if dataset == 0 & PublicSchool == 1 & `x' ==1  [aw=fweight]			
					loc `y'_0_`x' = round((r(mean)*100),1)
					
					sum `y' if dataset == 1 & PublicSchool == 1 & `x' ==1  [aw=fweight]			
					loc `y'_1_`x' = round((r(mean)*100),1)
				
					loc `y'_diff_`x' = ``y'_1_`x''-``y'_0_`x''
					
					//Use logit for statistical tests
					
						//First see if the logit is identified					
							cap logit `y' dataset if PublicSchool == 1 & `x' ==1 [pw=fweight]

						//If yes, assign p value the normal way 
						//If no, assign p value to 1
							if _rc ==0	{
								if _b[dataset] != 0  {
									
									logit `y' dataset if PublicSchool == 1 & `x' ==1 [pw=fweight], cl(S_ID)
										loc z = _b[dataset]/_se[dataset] //Formula for z score
										loc p = 2*normal(-abs(`z')) //Formula for p value
										
								}
								else	loc p = 1
							}
							else	loc p = 1					
						
						//Using the saved p value to determine significance stars
							loc `y'_stars_`x' = ""				

							if `p' <= .05		loc `y'_stars_`x' "*" 
							if `p' <= .01		loc `y'_stars_`x' "**"	
							if `p' <= .001		loc `y'_stars_`x' "***"

				} //closes x loop
					
				#delimit ;
					post `memhold' ("`y'")  (``y'_0_All')  (``y'_1_All') ("``y'_diff_All'") ("``y'_stars_All'")
											(``y'_0_Full')   (``y'_1_Full')  ("``y'_diff_Full'")  ("``y'_stars_Full'")
											(``y'_0_Half')   (``y'_1_Half')  ("``y'_diff_Half'")  ("``y'_stars_Half'") ;
				#delimit cr
			
			} //closes y loop

		postclose `memhold'    //    end the postfile
	   
		preserve
			use `rdest', clear    //     open the new dataset you've created
			export excel using "C:\Users\sal3ff\Scott\K is the New 1st Grade\Tables\Table 3 - Panel A", replace
		restore
		

	**********************************
	* Table 4. Time use
	*********************************
		  tempname memhold 
		  tempfile rdest      
		  postfile `memhold' str25(outcome) EK98 EK10 str10(diff1) EK98FD EK10FD str10(diff2) EK98HD EK10HD str10(diff3) using `rdest' 

			# delimit ;
				loc t_use "ChildSelect_mt1 WholeClass_3om
							ELA2_Wrkbk_daily ELA2_Basal_daily MTH2_MathSheet_daily MTH2_MathTextbk_daily 
							PEDaily RecDaily" ;
			# delimit cr
  				
				foreach y in `t_use' {
				
					foreach x in All Full Half	{
				
						sum `y' if dataset == 0 & PublicSchool == 1 & `x' ==1  [aw=sweight]			
						loc `y'_0_`x' = round((r(mean)*100),1)
						
						sum `y' if dataset == 1 & PublicSchool == 1 & `x' ==1  [aw=sweight]			
						loc `y'_1_`x' = round((r(mean)*100),1)
				
						loc `y'_diff_`x' = ``y'_1_`x''-``y'_0_`x''
						
						//Use logit for statistical tests
					
							//First see if the logit is identified					
								cap logit `y' dataset if PublicSchool == 1 & `x' ==1 [pw=sweight]

							//If yes, assign p value the normal way 
							//If no, assign p value to 1
								if _rc ==0	{
									if _b[dataset] != 0  {
										
										logit `y' dataset if PublicSchool == 1 & `x' ==1 [pw=sweight], cl(S_ID)
											loc z = _b[dataset]/_se[dataset] //Formula for z score
											loc p = 2*normal(-abs(`z')) //Formula for p value
											
									}
									else	loc p = 1
								}
								else	loc p = 1	
					
							//Using the saved p value to determine significance stars
								loc `y'_s_`x' = ""				

								if `p' <= .05		loc `y'_s_`x' "*" 
								if `p' <= .01		loc `y'_s_`x' "**"	
								if `p' <= .001		loc `y'_s_`x' "***"

					} //closes x loop
	
				#delimit ;
					post `memhold' ("`y'")  (``y'_0_All')  (``y'_1_All') 	("``y'_diff_All'``y'_s_All'")
											(``y'_0_Full')  (``y'_1_Full')  ("``y'_diff_Full'``y'_s_Full'")
											(``y'_0_Half')  (``y'_1_Half')  ("``y'_diff_Half'``y'_s_Half'") ;
				#delimit cr
				
				
				} //closes y loop

			postclose `memhold'    //    end the postfile
		   
			preserve
				use `rdest', clear    //     open the new dataset you've created
				export excel using "C:\Users\sal3ff\Scott\K is the New 1st Grade\Tables\Table 4", replace
			restore


	***********************************************
	* Table 5. Beliefs about assessment practices - Not sure what testing K2010 - F1999 even tells us 
	************************************************

		tempname memhold    //    where you temporarily hold the postings
		tempfile rdest        //    name of the temporary file that will become the new dataset
		postfile `memhold' str25(outcome) KG98 KG10 str6(diff1 star1) using `rdest' 
	
		# delimit ;
			loc k_outcomes	"A2TOCLAS_HI A2TOSTND_HI A2IMPRVM_HI A2EFFO_HI A2BEHAVR_HI A2COPRTV_HI A2FLLWDR_HI
							StdTestK_Never StdTestK_Yearly StdTestK_Monthly StdTestK_Weekly" ;

			loc o_outcomes	"A4TOCLSS_HI A4TOSTDR_HI A4IMPPRG_HI A4EFFRT_HI A4CLSBHV_HI A4COOPRT_HI A4FLLDIR_HI  
							StdTest1_Never StdTest1_Yearly StdTest1_Monthly StdTest1_Weekly" ;
		# delimit cr

		   //Have to do this separately for 2 sets of outcomes because I'm using different weights
				foreach outcome in k_outcomes o_outcomes	{
			
					if "`outcome'" == "k_outcomes"		{
						loc dvs = "`k_outcomes'"
						loc weight = "sweight"
					}
					
					if "`outcome'" == "o_outcomes"	{
						loc dvs = "`o_outcomes'"
						loc weight = "oweight"
				}
	
				foreach y in `dvs' {
			
					foreach i in 0 1	{
				
						sum `y' if dataset == `i' & PublicSchool==1 [aw=`weight']
						loc `y'_`i' = round((r(mean)*100),1)
						
					} //closes i loop
			
					loc `y'_diff = ``y'_1'-``y'_0'

					//Assign significance stars based on logit models
				
						//First see if the logit is identified					
							cap logit `y' dataset if PublicSchool==1 [pw=`weight']

						//If yes, assign p value the normal way 
						//If no, assign p value to 1
							if _rc ==0	{
								if _b[dataset] != 0  {
									
									logit `y' dataset if PublicSchool==1 [pw=`weight'], cl(S_ID)
										loc z = _b[dataset]/_se[dataset] //Formula for z score
										loc p = 2*normal(-abs(`z')) //Formula for p value
										
								}
								else	loc p = 1
							}
							else	loc p = 1	

						//Using the saved p value to determine significance stars
							loc `y'_stars = ""				

							capture if `p' <= .05		loc `y'_stars "*" 
							capture if `p' <= .01		loc `y'_stars "**"	
							capture if `p' <= .001		loc `y'_stars "***"
				
					post `memhold' ("`y'") (``y'_0') (``y'_1') ("``y'_diff'") ("``y'_stars'")
			
				} // closes y loop
			} // closes outcome loop

		postclose `memhold'    //    end the postfile
	   
		preserve
			use `rdest', clear    //     open the new dataset you've created
			export excel using "C:\Users\sal3ff\Scott\K is the New 1st Grade\Tables\Table 5", replace
		restore


	*************************************************
	* Table 6. Predicting changes in teacher beliefs
	*************************************************
		
		gl fall_dvs  "PrepAlpha_HI PrepRead_HI PrepFormal_HI ClassSciArea ClassDramaArea ClassWaterArea ClassArtArea"
		gl spring_dvs "A2TOSTND_HI ELA2_Basal_daily MTH2_MathTextbk_daily WholeClass_3om ChildSelect_mt1  FreqArt FreqMusic"
	
		capture program drop logtabs
		program define logtabs
			args dv var1 var2 weight title
		
			loc controls ""
			
			# delimit ;
			
				loc vars "SmClassSize Sch_Large Sch_Small Midwest South West City Rural
							NewTeacher TeachElemCt TeachErlyCt TeachMale TeachHisp TeachBlack TeachOther 
							FullDay Sch_PreK " ;
			# delimit cr
			
			foreach x in `vars'	{			
				loc controls "`controls' `x'_K"
			}	
			
			capture estimates clear
			foreach x in `dv'	{
				logit `x' dataset `var1' `controls' if PublicSchool == 1 [pw = `weight'], cl(S_ID) or
				estimates store `x'1

				logit `x' dataset `var2' `controls' if PublicSchool == 1 [pw = `weight'], cl(S_ID) or
				estimates store `x'2
			}

			estout *1 *2 using "C:\Users\sal3ff\Scott\K is the New 1st Grade\Tables/`title'",  ///
					eform cells(b(star fmt(2))  se(par(`"="("' `")""') fmt(2))) stats(r2 N) ///
					starlevels(* .05 ** .01 *** .001) replace ///
					keep(dataset HiPctFRL_K INT_FRL_K HiPctMin_K INT_Min_K)

		end //ends program newtable2

		logtabs "${fall_dvs}" 	"HiPctFRL_K INT_FRL_K" "HiPctMin_K INT_Min_K" "fweight" "Table 6 - fall"
		logtabs "${spring_dvs}" "HiPctFRL_K INT_FRL_K" "HiPctMin_K INT_Min_K" "sweight" "Table 6 - spring"
						
							 
	******************************************************
	* Appendix 3: Science/social studies content coverage
	******************************************************
		tempname memhold    //    where you temporarily hold the postings
		tempfile rdest        //    name of the temporary file that will become the new dataset
		postfile `memhold' str25(outcome) EK98 EK10 str10(diff) using `rdest' 

			#delimit ;
				loc science "SCI_Dino SCI_Ecol SCI_Sound SCI_Body SCI_Light SCI_Solar SCI_Motor SCI_Mag 
						SCI_H2O SCI_Method SCI_Hygien SCI_Tools SCI_Plant SCI_Weath SCI_Temp " ; 
				
				loc social "SOC_Geo SOC_Cult SOC_Comm SOC_Hist SOC_Map SOC_Prob SOC_Law ";
			#delimit cr
		   
			foreach y in `science' `social' {

				sum `y' if dataset == 0 & PublicSchool==1 [aw=sweight]				
				loc `y'_0 = round((r(mean)*100),1)
				
				sum `y' if dataset == 1 & PublicSchool==1 [aw=sweight]				
				loc `y'_1 = round((r(mean)*100),1)
			
				loc `y'_diff = ``y'_1'-``y'_0'

		
				//Assign significance stars based on logit models
					//First see if the logit is identified					
						cap logit `y' dataset if PublicSchool == 1 [pw=sweight]

					//If yes, assign p value the normal way 
					//If no, assign p value to 1
						if _rc ==0	{
							if _b[dataset] != 0  {
								
								logit `y' dataset if PublicSchool == 1 [pw=sweight], cl(S_ID)
									loc z = _b[dataset]/_se[dataset] //Formula for z score
									loc p = 2*normal(-abs(`z')) //Formula for p value
									
							}
							else	loc p = 1
						}
						else	loc p = 1	

				//Using the saved p value to determine significance stars
					loc `y'_stars = ""				

					if `p' <= .05		loc `y'_stars "*" 
					if `p' <= .01		loc `y'_stars "**"	
					if `p' <= .001		loc `y'_stars "***"
			
				post `memhold' ("`y'") (``y'_0') (``y'_1') ("``y'_diff'``y'_stars'")
			
			} //closes y loop

		postclose `memhold'    //    end the postfile
	   
		preserve
			use `rdest', clear    //     open the new dataset you've created
			export excel using "C:\Users\sal3ff\Scott\K is the New 1st Grade\Tables\Appendix 3", replace
		restore

