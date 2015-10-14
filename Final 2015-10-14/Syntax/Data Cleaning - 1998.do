/***********************************************************
* Author: Scott Latham
* Purpose: This file cleans variables from the 1998 cohort
* 			for inclusion in the "K is the new 1st" analysis
* Created: 8/26/2014
* Last modified: 8/16/2015
***********************************************************/
set more off
pause on

cd "C:\Users\sal3ff\Scott\K is the New 1st Grade\Generated Datasets"
use "K is the new 1st - 1998 Raw", clear

	//Recode missing values
	**************************
		recode CREGION-S4WHTPCT (-1=.a) (-7=.) (-8=.) (-9=.) 

			destring S1_ID S2_ID S4_ID, replace //Destring so they can be collapsed
			
	//Collapse the data to the teacher level - Needs to be done separately for each wave, then merged
	***************************************************************************************************
		//Fall of kindergarten
			preserve
				collapse S1* A1* B1* CREGION KURBAN (mean) fweight=C1CPTW0, by(T1_ID) //3133
				rename (T1_ID S1_ID) (T_ID S_ID)
				save "Fall K Teachers 98", replace
			restore
			
		//Spring of kindergarten
			preserve
				collapse S2* A2* B2* (mean) sweight=C2CPTW0, by(T2_ID) //3389
				rename (T2_ID S2_ID) (T_ID S_ID)
				save "Spring K Teachers 98", replace
			restore
			
		//Spring of 1st grade
			preserve
				collapse S4* A4* B4* R4* (mean) oweight=C4CPTW0, by(T4_ID) //5047
				rename (T4_ID S4_ID) (T_ID S_ID)
				save "Spring 1st Teachers 98", replace
			restore

		//Merge the files together
			use "Fall K teachers 98", clear

			merge 1:1 T_ID using "Spring K Teachers 98" 
			drop _merge

			merge 1:1 T_ID using "Spring 1st Teachers 98"
			drop _merge

			//Erase intermediate files
				erase "Fall K Teachers 98.dta"
				erase "Spring K Teachers 98.dta"
				erase "Spring 1st Teachers 98.dta"

		
	//Teacher beliefs about K readiness (Table 1)
	***********************************************
		
		rename (B1ATNDPR   B1FRMLIN   B1ALPHBF  B1LRNREA B1TCHPRN   B1PRCTWR    B1HMWRK  B1READAT) ///
			   (PrepPreSch PrepFormal PrepAlpha PrepRead PrepTchPrn PrepParTime PrepHmwk PrepReadAt)

		rename (B1FNSHT   B1CNT20  B1SHARE  B1PRBLMS  B1PENCIL  B1NOTDSR   B1ENGLAN) ///    				
			   (RdyFinTsk RdyCnt20 RdyShare RdyPrbSlv RdyPencil RdyNotDisr RdyEng)
			   
		rename (B1SENSTI  B1SITSTI  B1ALPHBT B1FOLWDR   B1IDCOLO B1COMM) ///
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
			rename A4OFTFOR A4OFTFLN //To match with 2010
		
			foreach x of varlist A2OFT* A4OFT* {
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
			recode B1READAR-B1ARTARE (2=0)

			rename  (B1READAR  	  	B1LISTNC 			B1WRTCNT 			B1MATHAR 		B1PLAYAR) ///
					(ClassReadArea 	ClassListCenter		ClassWriteCenter 	ClassMathArea 	ClassPlayArea)
					
			rename  (B1WATRSA			B1COMPAR	 	B1SCIAR 		B1DRAMAR 		B1ARTARE) ///
					(ClassWaterArea		ClassCompArea	ClassSciArea	ClassDramaArea	ClassArtArea)
	
		//1st grade
		
			foreach x of varlist A4ARTMAT-A4COOK A4EQUIPM {
			
				recode `x' (0=1) (1=2) (2=3) (3=4) (4=5) (5=6) (6=7)  //Recode to align with 2010
			
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

			gen WholeClass_3om = TeachDirectWhole ==5 //Only goes to 5 in 1998, in 2010 goes higher
			replace WholeClass_3om =. if TeachDirectWhole >=.
			label var WholeClass_3om "Class spent 3 or more hours/day on whole class activities"

		//PE and recess
			gen PEDaily = A2TXPE ==5
			replace PEDaily = . if A2TXPE >=.
			label var PEDaily "Class has daily physical education"

			recode A2DYRECS (0=1) (1=3) (2=3) (3=4) (4=4) (5=5) //Recode to match with 2010 cohort
			
			gen RecDaily = A2DYRECS ==5
			replace RecDaily =. if A2DYRECS ==.
			label var RecDaily "Child's class has recess every day"

				
	//Evaluation (Table 5)
	************************

		//Kindergarten
			rename 	(B2TOCLAS B2TOSTND B2IMPRVM B2EFFO B2CLASPA B2ATTND B2BEHVR  B2COPRTV B2FLLWDR) ///
					(A2TOCLAS A2TOSTND A2IMPRVM A2EFFO A2CLASPA A2ATTND A2BEHAVR A2COPRTV A2FLLWDR)

			foreach x in A2TOCLAS A2TOSTND A2IMPRVM A2EFFO A2BEHAVR A2COPRTV A2FLLWDR	{
				gen `x'_HI = `x' ==3 | `x' ==4
				replace `x'_HI = . if `x' ==.
			}
			
		//First grade
			rename  (A4TOCLAS A4TOSTND A4IMPRVM A4EFFO  A4CLASPA A4ATTND  A4BEHAVR A4COPRTV A4FLLWDR) ///
					(A4TOCLSS A4TOSTDR A4IMPPRG A4EFFRT A4CLSPAR A4ATTEND A4CLSBHV A4COOPRT A4FLLDIR)

			recode A4TOCLSS-A4FLLDIR (0=5) //0 is "N/A" in 1st in the 1998 dataset..no such option in 2010
			
			foreach x in A4TOCLSS A4TOSTDR A4IMPPRG A4EFFRT A4CLSBHV A4COOPRT A4FLLDIR	{
				gen `x'_HI = `x' ==3 | `x' ==4
				replace `x'_HI = . if `x' ==.
			}
			
			rename A4STNDRD A4STNTST
			tab A4STNTST, gen(A4STNTST)

			rename A4STNTST1 StdTest1_Never
			rename A4STNTST2 StdTest1_Yearly
			rename A4STNTST3 StdTest1_Monthly

			gen StdTest1_Weekly = A4STNTST >=4
			replace StdTest1_Weekly = . if A4STNTST >=.
			
			drop A4STNTST?
			
			
	// Logit model outcomes (Table 6)
	***********************************
	
		//Art and music
			gen FreqMusic = A2OFTMUS >=4
			replace FreqMusic = . if A2OFTMUS >=.

			gen FreqArt = A2OFTART >=4
			replace FreqArt = . if A2OFTART >=.
			
			
	//ELA and math content (Appendix 1 & 2)
	****************************************
	
		//Topics in ELA
			rename  (A2CONVNT  A2RCGNZE   A2MATCH    A2WRTNME   A2RHYMNG   A2PREPOS  A2MAINID  A2PREDIC) ///  
					(ELA1_Conv ELA1_Recog ELA1_Match ELA1_WrNam ELA1_Rhyme ELA1_Prep ELA1_Main ELA1_Pred)
					
			rename  (A2TEXTCU  A2ORALID  A2DRCTNS    A2COMPSE  A2WRTSTO   A2SPELL    A2VOCAB) ///
					(ELA1_Text ELA1_Oral ELA1_Direct ELA1_Comp ELA1_Story ELA1_Spell ELA1_Vocab)

		//ELA activities
			rename (A2PRACLT    A2NEWVOC    A2DICTAT    A2PHONIC    A2SEEPRI      A2NOPRNT     A2RETELL) ///
				   (ELA2_PracLt ELA2_NewVoc ELA2_Dictat ELA2_Phonic ELA2_SeePrint ELA2_NoPrint ELA2_Retell)
				   
			rename (A2READLD    A2BASAL    A2SILENT      A2WRKBK    A2WRTWRD    A2INVENT         A2CHSBK       A2COMPOS) ///   
				   (ELA2_ReadLd ELA2_Basal ELA2_RdSilent ELA2_Wrkbk ELA2_WrtWrd ELA2_InventSpell ELA2_ChooseBk ELA2_WrtStory) 
			
			rename (A2DOPROJ      A2SKITS    A2JRNL       A2MXDGRP    A2PRTUTR) /// 
				   (ELA2_BookProj ELA2_Skits ELA2_Journal ELA2_MxdGrp ELA2_PeerTutor)

			drop A2PUBLSH A2TELLRS //No counterpart in 2010 dataset

		//Topics in math
			rename (A2QUANTI      A21TO10        A22S5S10         A2BYD100          A2W12100        A2SHAPES    A2IDQNTY) /// 
				   (MTH1_NumQuant MTH1_Write1_10 MTH1_Count2_5_10 MTH1_CountMore100 MTH1_Write1_100 MTH1_Shapes MTH1_RelQuant) 
			
			rename (A2SUBGRP     A2SZORDR      A2PTTRNS      A2REGZCN   A2SNGDGT A2SUBSDG A2PLACE    A2TWODGT     A23DGT) /// 
				   (MTH1_SortSub MTH1_OrderObj MTH1_Patterns MTH1_Money MTH1_Add MTH1_Sub MTH1_Place MTH1_ReadTwo MTH1_ReadThree)
			
			rename (A2MIXOP    A2GRAPHS    A2DATACO  A2FRCTNS       A2ORDINL    A2ACCURA  A2TELLTI  A2ESTQNT A2PRBBTY  A2EQTN) ///  	
				   (MTH1_Mixed MTH1_Graphs MTH1_Data MTH1_Fractions MTH1_OrdNum MTH1_Meas MTH1_Time MTH1_Est MTH1_Prob MTH1_WordPbs)
	
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
			recode SOC* SCI* (1/2=0) (3/7=1)
			label values SOC* SCI* yesno
	
	
	//Control variables (suffixed w/K to refer to Kindergarten vars, and with F for 1st grade)
	******************************************************************************************
		
		//Teacher characteristics
	
			foreach x in K F 	{
			
				if "`x'" == "K"		loc i = 1
				if "`x'" == "F" 	loc i = 4
				
				recode B`i'TGEND B`i'HISP B`i'RACE1 B`i'RACE2 B`i'RACE3 B`i'RACE4 B`i'RACE5 B`i'ELEMCT B`i'ERLYCT (2=0)
			
				rename B`i'TGEND	TeachMale_`x'
				
				//Construct non-overlapping race categories (i.e. do not allow for two races)
					foreach race in RACE1 RACE2 RACE3 RACE4 RACE5 {
						replace B`i'`race' = 0 if B`i'HISP ==1 //If they are Hispanic, no other race
					}
				
					rename B`i'HISP 	TeachHisp_`x'
					rename B`i'RACE1	TeachAIAK_`x'
					rename B`i'RACE2	TeachAsian_`x'
					rename B`i'RACE3	TeachBlack_`x'
					rename B`i'RACE4 	TeachHIPI_`x'
					rename B`i'RACE5	TeachWhite_`x'
					
					gen TeachOther_`x' = TeachAIAK_`x' ==1 | TeachAsian_`x' ==1 | TeachHIPI_`x' ==1
					replace TeachOther_`x' = . if TeachWhite_`x' ==.
					
					drop TeachAIAK_`x' TeachAsian_`x' TeachHIPI_`x'
				
				//Certification
					rename B`i'ELEMCT 	TeachElemCt_`x'
					rename B`i'ERLYCT 	TeachErlyCt_`x'

		
				//New teachers (in first 3 years of teaching)
					egen YearsTeaching_`x' = rowtotal(B`i'YRSPRE-B`i'YRS6PL), missing
				
					//Topcode teaching experience at 50 years
						replace YearsTeaching_`x' = 50 if YearsTeaching_`x' >50 & YearsTeaching_`x' <. 
						
					gen NewTeacher_`x' = YearsTeaching_`x' <=3
					replace NewTeacher_`x' = . if YearsTeaching_`x' >=.

			}
			
		//School characteristics
			
			rename S2KPUPRI PublicSchool
			replace PublicSchool = S4PUPRI if PublicSchool ==. & S4PUPRI!=. 
			recode PublicSchool (2=0) (1.01/1.99 =.)
			
			rename S2PRKNDR Sch_PreK_K
			recode Sch_PreK_K (2=0)
			replace Sch_PreK_K = . if Sch_PreK_K >1 & Sch_PreK_K <2
			
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
				gen SmClassSize_K = A1TOTAG <= 18 //Bottom quartile essentially
				replace SmClassSize_K = . if A1TOTAG ==.
				
				gen SmClassSize_F = A4TOTAG <= 18 //Bottom quartile essentially
				replace SmClassSize_F = . if A4TOTAG ==.
		
			//Region & urbanicity
				
				replace CREGION = . if CREGION >2 & CREGION <3 //Rogue observation
				tab CREGION, gen(KREG) //Kindergarten
				
				rename KREG1 Northeast_K 
				rename KREG2 Midwest_K 
				rename KREG3 South_K
				rename KREG4 West_K
				
				gen City_K = KURBAN <3
				replace City_K =. if KURBAN >=.
					
				gen Rural_K = KURBAN ==7
				replace Rural_K = . if KURBAN >=.
			
				replace R4REGION = . if R4REGION >2 & R4REGION <3
				tab R4REGION, gen(FREG) //First grade
				
				rename FREG1 Northeast_F 
				rename FREG2 Midwest_F 
				rename FREG3 South_F
				rename FREG4 West_F
			
				gen City_F = R4URBAN <3
				replace City_F =. if R4URBAN >=.
				
				gen Rural_F = R4URBAN ==7
				replace Rural_F = . if R4URBAN >=.

			//Classroom characteristics
		
				gen FullDay_K = A1HRSDA >=5
				replace FullDay_K =. if A1HRSDA >=.
				label var FullDay_K "Teacher taught full day kindergarten (>= 5 hours)"

				label define fulld 0 "Half day" 1 "Full day"
				label values FullDay fulld



	//Interaction variables
	**************************
		//Percent minority
			gen PctMin_K = 100-S2WHTPCT //Kindergarten
			egen PctMin_K4 = cut(PctMin_K), group(4)

			gen HiPctMin_K = PctMin_K4 ==3
			replace HiPctMin_K = . if PctMin_K4 >=.
			label var HiPctMin_K "Student's school was in the top quartile of % minorities"
			

			gen PctMin_F = 100-S4WHTPCT //First grade
			egen PctMin_F4 = cut(PctMin_F), group(4)

			gen HiPctMin_F = PctMin_F4 ==3
			replace HiPctMin_F = . if PctMin_F4 >=.
			label var HiPctMin_F "Student's school was in the top quartile of % minorities"

			
		//Percent free/reduced lunch
			egen PctFRL_K = rowtotal(S2KFLNCH S2KRLNCH), missing //Kindergarten
			replace PctFRL_K =100 if PctFRL_K >100 & PctFRL_K <. //Topcode at 100

			egen PctFRL_K4 = cut(PctFRL_K), group(4)
						
			gen HiPctFRL_K = PctFRL_K4 ==3
			replace HiPctFRL_K = . if PctFRL_K4 >=.
			label var HiPctFRL_K "Student's school was in the top quartile of % FRPL"


			egen PctFRL_F = rowtotal(S4FLNCH S4RLNCH), missing //First grade
			replace PctFRL_F =100 if PctFRL_F >100 & PctFRL_F <. //Topcode at 100

			egen PctFRL_F4 = cut(PctFRL_F), group(4)
						
			gen HiPctFRL_F = PctFRL_F4 ==3
			replace HiPctFRL_F = . if PctFRL_F4 >=.
			label var HiPctFRL_F "Student's school was in the top quartile of % FRPL"


	//Generate an identifier variable
		gen dataset =0

	save "K is the new 1st - 1998 Clean", replace
