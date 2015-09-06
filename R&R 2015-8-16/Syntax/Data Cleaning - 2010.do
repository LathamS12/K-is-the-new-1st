/***********************************************************
* Author: Scott Latham
* Purpose: This file cleans variables from the ECLS-B
* 			for inclusion in the academicization analysis
* Created: 4/1/2014
* Last modified: 8/16/2015
***********************************************************/
set more off
pause on

cd "C:\Users\sal3ff\Scott\K is the New 1st Grade\Generated Datasets"
use "K is the new 1st - 2010 Raw", clear

	//Recode missing values
	************************
		order *_ID
		recode X1LOCALE-S4WHITPT (-1=.a) (-5=.) (-7=.) (-8=.) (-9=.) 

		destring S1_ID S2_ID S4_ID, replace //Destring so they can be collapsed
		
	//Collapse the data to the teacher level - Needs to be done separately for each wave, then merged
	******************************************************************************************************	
		//Fall of kindergarten	
			preserve
				collapse S1* A1* X1* (mean) fweight=W1A0, by(T1_ID)	//3167
				rename (T1_ID S1_ID) (T_ID S_ID)
				save "Fall K Teachers 10", replace
			restore

		//Spring of kindergarten
			preserve
				collapse S2* A2* X2* (mean) sweight=W12AC0, by(T2_ID) //3867
				rename (T2_ID S2_ID) (T_ID S_ID)
				save "Spring K Teachers 10", replace
			restore

		//Spring of 1st grade
			preserve
				collapse S4* A4* X4*  (mean) oweight=W4CS4P_2T0, by(T4_ID) //5015
				rename (T4_ID S4_ID) (T_ID S_ID)
				save "Spring 1st Teachers 10", replace
			restore
		
		//Merge the files together
			use "Fall K teachers 10", clear
			
			merge 1:1 T_ID using "Spring K Teachers 10"
			drop _merge

			merge 1:1 T_ID using "Spring 1st Teachers 10"
			drop _merge
			
			replace S_ID = S_ID + 6500 //Adding 6500 to every ID (so they won't overlap w/1998 data)

			//Erase intermediate files
				erase "Fall K Teachers 10.dta"
				erase "Spring K Teachers 10.dta"
				erase "Spring 1st Teachers 10.dta"

				
	//Teacher beliefs about K readiness (Table 1)
	***********************************************
		
		rename (A1ATNDPR   A1FRMLIN   A1ALPHBF  A1LRNREA A1TCHPRN   A1PRCTWR    A1HMWRK  A1READAT) ///
			   (PrepPreSch PrepFormal PrepAlpha PrepRead PrepTchPrn PrepParTime PrepHmwk PrepReadAt)

		rename (A1FNSHT   A1CNT20  A1SHARE  A1PRBLMS  A1PENCIL  A1NOTDSR   A1ENGLAN) ///    				
			   (RdyFinTsk RdyCnt20 RdyShare RdyPrbSlv RdyPencil RdyNotDisr RdyEng)
			   
		rename (A1SENSTI  A1SITSTI  A1ALPHBT A1FOLWDR   A1IDCOLO A1COMM) ///
			   (RdySensit RdySitSti RdyAlpha RdyFllwDir RdyColor RdyComm)

			   
		#delimit ;
			loc beliefs "PrepPreSch PrepFormal PrepAlpha PrepRead PrepTchPrn PrepParTime PrepHmwk PrepReadAt
							RdyFinTsk RdyCnt20 RdyShare RdyPrbSlv RdyPencil RdyNotDisr RdyEng
							RdySensit RdySitSti RdyAlpha RdyFllwDir RdyColor RdyComm " ;   
		#delimit cr

		foreach x in `beliefs' 	{
			gen `x'_HI = `x' ==4 | `x'==5 //The item was rated "very important" or "essential"
			replace `x'_HI = . if `x' ==.
		}



	//General time use (Table 2)
	*****************************
		
		//Generate weekly, daily, never categories for time use		
			foreach x of varlist A2OFT* A4OFT* {
			
				recode `x' (3=3) (4=3) (5=4) (6=4) (7=5)
				
				gen `x'_never = `x' ==1
				replace `x'_never = . if `x' >=.

				gen `x'_weekly = `x' > 2
				replace `x'_weekly = . if `x' >=.

				gen `x'_daily = `x' == 5
				replace `x'_daily = . if `x' >=.
			}

		
	//Classroom materials (Table 3)
	*********************************
	
		
		//Kindergarten
			recode A1READAR-A1ARTARE (2=0)

			rename  (A1READAR  	  	A1LISTNC 			A1WRTCNT 			A1MATHAR 		A1PLAYAR) ///
					(ClassReadArea 	ClassListCenter		ClassWriteCenter 	ClassMathArea 	ClassPlayArea)
					
			rename  (A1WATRSA			A1COMPAR	 	A1SCIAR 		A1DRAMAR 		A1ARTARE) ///
					(ClassWaterArea		ClassCompArea	ClassSciArea	ClassDramaArea	ClassArtArea)

		
		//1st grade
			foreach x of varlist A4ARTMAT-A4COOK A4EQUIPM {
			
				gen `x'_never = `x' <=2
				replace `x'_never = . if `x' >=.

				gen `x'_weekly = `x' >= 5
				replace `x'_weekly = . if `x' >=.

				gen `x'_daily = `x' == 7
				replace `x'_daily = . if `x' >=.
			}

		
	//Approaches to instruction (Table 4)
	*************************************
		
		//Instructional approach
			rename (A2WHLCLS A2CHCLDS) (TeachDirectWhole TeachChildSelect)

			gen ChildSelect_mt1 = TeachChildSelect >2
			replace ChildSelect_mt1 =. if TeachChildSelect >=.
			label var ChildSelect_mt1 "Class spent more than one hour/day on child selected activities"

			gen WholeClass_3om = TeachDirectWhole >=5
			replace WholeClass_3om =. if TeachDirectWhole >=.
			label var WholeClass_3om "Class spent 3 or more hours/day on whole class activities"

		//PE, lunch, and recess --Need to recode this before other things!

			rename A2OFTPE A2TXPE
			gen PEDaily = A2TXPE ==5
			replace PEDaily = . if A2TXPE >=.
			label var PEDaily "Class has daily physical education"

			recode A2DYRECS (0=1) (1=3) (2=3) (3=4) (4=4) (5=5) 
			recode A2DYRECS (7=.)

			gen RecDaily = A2DYRECS ==5
			replace RecDaily =. if A2DYRECS >=.
			label var RecDaily "Child's class has recess every day"		
			
			
	//Evaluation (Table 5)
	************************			
		
		//Kindergarten	
		
			foreach x in A2TOCLAS A2TOSTND A2IMPRVM A2EFFO A2BEHAVR A2COPRTV A2FLLWDR	{
				gen `x'_HI = `x' ==3 | `x' ==4
				replace `x'_HI = . if `x' >=.
			}
			
			rename A2STNDRD A2STNTST //This question was only asked in 1st grade in the 1998 cohort
			tab A2STNTST, gen(A2STNTST)

			rename A2STNTST1 StdTestK_Never
			rename A2STNTST2 StdTestK_Yearly
			rename A2STNTST3 StdTestK_Monthly

			gen StdTestK_Weekly = A2STNTST >=4
			replace StdTestK_Weekly = . if A2STNTST >=.
			
		//1st grade

			foreach x in A4TOCLSS A4TOSTDR A4IMPPRG A4EFFRT A4CLSBHV A4COOPRT A4FLLDIR	{
				gen `x'_HI = `x' ==3 | `x' ==4
				replace `x'_HI = . if `x' >=.
			}
			
			gen StdTest1_Never = A4STNTST ==1
			replace StdTest1_Never = . if A4STNTST >=.

			gen StdTest1_Weekly = A4STNTST >=5
			replace StdTest1_Weekly = . if A4STNTST >=.
			
			

	// Logit model outcomes (Table 6)
	***********************************		

		//Art and music
			gen FreqMusic = A2OFTMUS >=5
			replace FreqMusic = . if A2OFTMUS >=.

			gen FreqArt = A2OFTART >=5
			replace FreqArt = . if A2OFTART >=.
			
	
	//ELA and math content (Appendix 1 & 2)
	****************************************
		
		//Topics in ELA
			rename  (A2CONVNT  A2RCGNZE   A2MATCH    A2WRTNME   A2RHYMNG   A2PREPOS  A2MAINID  A2PREDIC) ///  
					(ELA1_Conv ELA1_Recog ELA1_Match ELA1_WrNam ELA1_Rhyme ELA1_Prep ELA1_Main ELA1_Pred)
					
			rename  (A2TEXTCU  A2ORALID  A2DRCTNS    A2COMPSE  A2WRTSTO   A2SPELL) ///
					(ELA1_Text ELA1_Oral ELA1_Direct ELA1_Comp ELA1_Story ELA1_Spell)
	
		//ELA activities
			rename (A2PRACLT    A2NEWVOC    A2DICTAT    A2PHONIC    A2SEEPRI      A2NOPRNT     A2RETELL) ///
				   (ELA2_PracLt ELA2_NewVoc ELA2_Dictat ELA2_Phonic ELA2_SeePrint ELA2_NoPrint ELA2_Retell)
				   
			rename (A2READLD    A2BASAL    A2SILENT      A2WRKBK    A2WRTWRD    A2INVENT         A2CHSBK       A2COMPOS) ///   
				   (ELA2_ReadLd ELA2_Basal ELA2_RdSilent ELA2_Wrkbk ELA2_WrtWrd ELA2_InventSpell ELA2_ChooseBk ELA2_WrtStory) 
			
			rename (A2DOPROJ      A2SKITS    A2JRNL       A2MXDGRP    A2PRTUTR) /// 
				   (ELA2_BookProj ELA2_Skits ELA2_Journal ELA2_MxdGrp ELA2_PeerTutor)


		//Topics in math
			rename (A2QUANTI      A21TO10        A22S5S10         A2BYD100          A2W12100        A2SHAPES    A2IDQNTY) /// 
				   (MTH1_NumQuant MTH1_Write1_10 MTH1_Count2_5_10 MTH1_CountMore100 MTH1_Write1_100 MTH1_Shapes MTH1_RelQuant) 
			
			rename (A2SUBGRP     A2SZORDR      A2PTTRNS      A2REGZCN   A2SNGDGT A2SUBSDG A2PLACE    A2TWODGT     A23DGT) /// 
				   (MTH1_SortSub MTH1_OrderObj MTH1_Patterns MTH1_Money MTH1_Add MTH1_Sub MTH1_Place MTH1_ReadTwo MTH1_ReadThree)
			
			rename ( A2GRAPHS    A2DATACO  A2FRCTNS       A2ORDINL    A2ACCURA  A2TELLTI  A2ESTQNT A2PRBBTY  A2EQTN) ///  	
				   ( MTH1_Graphs MTH1_Data MTH1_Fractions MTH1_OrdNum MTH1_Meas MTH1_Time MTH1_Est MTH1_Prob MTH1_WordPbs)
	
	
		//Math activities
			rename (A2OUTLOU      A2GEOMET      A2MANIPS      A2MTHGME       A2CALCUL        A2MUSMTH       A2CRTIVE)  ///
				   (MTH2_CntOutLd MTH2_GeoManip MTH2_CntManip MTH2_MathGames MTH2_Calculator MTH2_MusicMath MTH2_CreatMath)
			
			rename (A2RULERS    A2EXPMTH     A2CALEND      A2MTHSHT       A2MTHTXT        A2CHLKBD        A2PRTNRS)  ///
				   (MTH2_Rulers MTH2_ExpMath MTH2_Calendar MTH2_MathSheet MTH2_MathTextbk MTH2_Chalkboard MTH2_MthPartners) 
			
			rename (A2REALLI         A2MXMATH    A2PEER) ///
				   (MTH2_MthRealLife MTH2_MxdGrp MTH2_PeerTutor)
		 

		//Generating daily, weekly, never variables for ELA/math content
		
			recode ELA1* MTH1* (2=1) (3=2) (4=3) (5=4) (6=5) (7=6) //Recode so responses are consistent across types of vars
			foreach x of varlist ELA1* MTH1* ELA2* MTH2*	{

				gen `x'_never = `x' ==1
				replace `x'_never = . if `x' >=.
				label var `x'_never "Teacher never taught `x' in kindergarten"

				gen `x'_weekly = `x' >=4 & `x' <.
				replace `x'_weekly = . if `x' >=.
				label var `x'_weekly "Teacher taught `x' at least weekly in kindergarten"

				gen `x'_daily = `x' ==6
				replace `x'_daily =. if `x' >=.
				label var `x'_daily "Teacher taught `x' daily in kindergarten"
			
			} //Closes x loop


	//Science & social studies content (Appendix 3)
	************************************************
	
		//Science
			rename (A2BODY   A2PLANT   A2DINOSR A2SOLAR   A2WTHER   A2TEMP   A2WATER A2SOUND) ///
				   (SCI_Body SCI_Plant SCI_Dino SCI_Solar SCI_Weath SCI_Temp SCI_H2O SCI_Sound)

			rename (A2LIGHT   A2MAGNET A2MOTORS  A2TOOLS   A2HYGIEN   A2ECOLOG A2SCMTHD) ///
				   (SCI_Light SCI_Mag  SCI_Motor SCI_Tools SCI_Hygien SCI_Ecol SCI_Method)

				   
		//Social studies
			rename (A2HISTOR A2CMNITY A2MAPRD A2CULTUR A2LAWS  A2GEORPH A2SOCPRO) ///
				   (SOC_Hist SOC_Comm SOC_Map SOC_Cult SOC_Law SOC_Geo  SOC_Prob)		   


			label define yesno 0 "No" 1 "Yes"
			recode SOC* SCI* (2=0)
			label values SOC* SCI* yesno
	
	
		
	//Control variables (suffixed w/K to refer to Kindergarten vars, and with F for 1st grade)
	******************************************************************************************
	
		//Teacher characteristics
	
			foreach x in K F 	{
		
				if "`x'" == "K"		loc i = 1
				if "`x'" == "F" 	loc i = 4
				
				recode A`i'TGEND A`i'HISP A`i'AMINAN A`i'ASIAN A`i'BLACK A`i'HAWPI A`i'WHITE A`i'ELEMCT A`i'ERLYCT (2=0)
			
				rename A`i'TGEND	TeachMale_`x'
				
				//Construct non-overlapping race categories (i.e. do not allow for two races)
					foreach race in AMINAN ASIAN BLACK HAWPI WHITE {
						replace A`i'`race' = 0 if A`i'HISP ==1
					}
				
					rename A`i'HISP 	TeachHisp_`x'
					rename A`i'AMINAN	TeachAIAK_`x'
					rename A`i'ASIAN	TeachAsian_`x'
					rename A`i'BLACK	TeachBlack_`x'
					rename A`i'HAWPI 	TeachHIPI_`x'
					rename A`i'WHITE	TeachWhite_`x'
				
					gen TeachOther_`x' = TeachAIAK_`x' ==1 | TeachAsian_`x' ==1 | TeachHIPI_`x' ==1
					replace TeachOther_`x' = . if TeachWhite_`x' ==.
					
					drop TeachAIAK_`x' TeachAsian_`x' TeachHIPI_`x'
				
				//Certification
					rename A`i'ELEMCT 	TeachElemCt_`x'
					rename A`i'ERLYCT 	TeachErlyCt_`x'

	
				//New teachers (in first 3 years of teaching)
					egen YearsTeaching_`x' = rowtotal(A`i'YRSPRE-A`i'YRS6PL), missing
				
					//Topcode teaching experience at 50 years
						replace YearsTeaching_`x' = 50 if YearsTeaching_`x' >50 & YearsTeaching_`x' <. 
						
					gen NewTeacher_`x' = YearsTeaching_`x' <=3
					replace NewTeacher_`x' = . if YearsTeaching_`x' >=.

			}
			
		//School characteristics
	
			rename X2PUBPRI PublicSchool
			replace PublicSchool = X4PUBPRI if PublicSchool ==. & X4PUBPRI !=.
			recode PublicSchool (2=0) (-10/-.00001 = .)

			rename S2PRKNDR Sch_PreK_K
			recode Sch_PreK_K (2=0) (1.01/1.99 = .)
			
			//Indicator variables for large/small schools
				gen Sch_Large_K = S2ANUMCH >750
				replace Sch_Large_K = . if S2ANUMCH ==.
				
				gen Sch_Small_K = S2ANUMCH <250
				replace Sch_Small_K = . if S2ANUMCH ==.
				
				gen Sch_Large_F = S4ANUMCH >750
				replace Sch_Large_F = . if S4ANUMCH ==.
				
				gen Sch_Small_F = S4ANUMCH <250
				replace Sch_Small_F = . if S4ANUMCH ==.
				
			//Small class size
			
				egen A1TOTAG = rowmean(A1ATOTAG A1PTOTAG)
				replace A1TOTAG = A1DTOTAG if A1DTOTAG <. //This prioritizes full day values (which were much more plausible)
				
				gen SmClassSize_K = A1TOTAG <= 18 //Bottom quartile essentially
				replace SmClassSize_K = . if A1TOTAG ==.
				
				gen SmClassSize_F = A4TOTAG <= 18 //Bottom quartile essentially
				replace SmClassSize_F = . if A4TOTAG ==.
		
				
			//Region & urbanicity
				tab X1REGION, gen(KREG) //Kindergarten
				
				rename KREG1 Northeast_K 
				rename KREG2 Midwest_K 
				rename KREG3 South_K
				rename KREG4 West_K

				gen City_K = X1LOCALE >=10 & X1LOCALE <14
				replace City_K = . if X1LOCALE ==.

				gen Rural_K = X1LOCALE >40 & X1LOCALE <.
				replace Rural_K = . if X1LOCALE ==.

				
				replace X4REGION = . if X4REGION >2 & X4REGION <3 //Rogue observation
				tab X4REGION, gen(FREG) //First grade
				
				rename FREG1 Northeast_F 
				rename FREG2 Midwest_F 
				rename FREG3 South_F
				rename FREG4 West_F

				gen City_F = X4LOCALE >=10 & X4LOCALE <14
				replace City_F = . if X4LOCALE ==.

				gen Rural_F = X4LOCALE >40 & X4LOCALE <.
				replace Rural_F = . if X4LOCALE ==.


			//Classroom characteristics
				egen halfhours = rowmean(A1AHRSDA A1PHRSDA)
				gen A1HOURS = A1DHRSDA //Prioritizes half day values
				replace A1HOURS = halfhours if halfhours <.
				drop halfhours

				gen FullDay_K = A1HOURS>=5
				replace FullDay_K =. if A1HOURS >=.
				label var FullDay_K "Teacher taught full day kindergarten (Based on reported hours)"

				label define fulld 0 "Half day" 1 "Full day"
				label values FullDay fulld
				
	
	//Interaction variables
	************************
		//Percent minority
			gen PctMin_K = 100-S2WHITPT //Kindergarten
			egen PctMin_K4 = cut(PctMin_K), group(4)

			gen HiPctMin_K = PctMin_K4 ==3
			replace HiPctMin_K = . if PctMin_K4 >=.
			label var HiPctMin_K "Student's school was in the top quartile of % minorities"
			

			gen PctMin_F = 100-S4WHITPT //First grade
			egen PctMin_F4 = cut(PctMin_F), group(4)

			gen HiPctMin_F = PctMin_F4 ==3
			replace HiPctMin_F = . if PctMin_F4 >=.
			label var HiPctMin_F "Student's school was in the top quartile of % minorities"
		

		//Percent free/reduced lunch		
			egen PctFRL_K = rowtotal(X2FLCH2_I X2RLCH2_I), missing //Kindergarten
			replace PctFRL_K =100 if PctFRL_K >100 & PctFRL_K <. //Topcode at 100

			egen PctFRL_K4 = cut(PctFRL_K), group(4)
						
			gen HiPctFRL_K = PctFRL_K4 ==3
			replace HiPctFRL_K = . if PctFRL_K4 >=.
			label var HiPctFRL_K "Student's school was in the top quartile of % FRPL"


			egen PctFRL_F = rowtotal(X4FMEAL_I X4RMEAL_I), missing //First grade
			replace PctFRL_F =100 if PctFRL_F >100 & PctFRL_F <. //Topcode at 100

			egen PctFRL_F4 = cut(PctFRL_F), group(4)
						
			gen HiPctFRL_F = PctFRL_F4 ==3
			replace HiPctFRL_F = . if PctFRL_F4 >=.
			label var HiPctFRL_F "Student's school was in the top quartile of % FRPL"

		
	//Generate an identifier variable
		gen dataset =1

	save "K is the new 1st - 2010 Clean", replace
