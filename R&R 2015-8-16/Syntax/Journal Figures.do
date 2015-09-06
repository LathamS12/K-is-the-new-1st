/***********************************************************
* Author: Scott Latham
* Purpose: This file creates bar charts for the academicization
* 			project
* Created: 5/26/2014
* Last modified: 3/23/2015
***********************************************************/
pause on
cd "C:\Users\sal3ff\Scott\K is the New 1st Grade\Generated Datasets"

use "ECLS-K waves appended", clear
	

////////// Content coverage //////////////			
	
		capture program drop content
		program content
			args outcome stub weight L1 L2 L3 L4 L5 L6 title sub
		
	
				keep T_ID dataset PublicSchool fweight sweight `outcome'
				loc count =1
				foreach x in `outcome'	{	
					if `count' ==1 	loc let = "A"
					if `count' ==2 	loc let = "B"
					if `count' ==3 	loc let = "C"
					if `count' ==4 	loc let = "D"
					if `count' ==5 	loc let = "E"
					if `count' ==6 	loc let = "F"

					rename `x' `stub'_`let'
					loc count = `count' +1
				}

				reshape long `stub', i(T_ID dataset) j(outcome, string)
				
				graph bar (mean) `stub' if PublicSchool==1 [pw=`weight'], ///
					over(dataset) ///
					over(outcome, relabel(1 "`L1'" 2 "`L2'" 3 "`L3'" 4 "`L4'" 5 "`L5'" 6 "`L6'") label(labsize(small)))  ///
					blabel(bar, size(vsmall) format(%5.2f)) ///
					ytitle(Proportion of teachers) ylab(, nogrid) ///
					title("`title'", size(medlarge)) subtitle("`sub'", size(medsmall)) ///
					scheme(s1mono) ///
					note("Note. Stars indicate significant differences across years. * p<.05  ** p<.01  *** p<.001 ")
			
				*graph export "C:\Users\sal3ff\K is the New 1st Grade\Figures/`title'.pdf", replace
			

		end //ends program "content"
	
		//Had to manually add significance stars, and move note!!
		content "SCI_Ecol SCI_Dino SCI_Sound SCI_Light SCI_Solar SCI_Body" 	///
					"SCI" "sweight" ///
					"Ecology" "Dinosaurs" "Sound" "Light" "Solar System" "Human body" ///
					"Kindergarten Science Content Exposure, 1998-2010" ///
					"Proportion of teachers that indicate topic is covered in the kindergarten year"



		content "SOC_Comm SOC_Cult SOC_Hist SOC_Geo" "SOC"	///
					"Social studies" "sweight"			///		
					"Resources" "Cultures" "History" "Geography"

	

//////// Shifts in curriculum
	pause on	
	capture program drop curriculum
		program curriculum
			args weekly never L1 L2 L3 L4 L5 L6 title sub n1 n2 n3

			preserve

				keep T_ID dataset PublicSchool sweight `weekly' `never'
			
				foreach how_often in weekly never	{
					
					loc count = 1
				
					foreach x in ``how_often''		{	
						loc stub = "`how_often'"
						
						if `count' ==1  loc let = "A"	
						if `count' ==2 	loc let = "B"
						if `count' ==3 	loc let = "C"
						if `count' ==4 	loc let = "D"
						if `count' ==5 	loc let = "E"
						if `count' ==6 	loc let = "F"

						rename `x' `how_often'_`let'
						loc count = `count' +1

					} // close x loop
				} // close how_often loop

				reshape long weekly never, i(T_ID dataset) j(freq, string)

				graph bar (mean) never if PublicSchool==1 [pw=sweight],											///		
					over(dataset, label(labsize(vsmall)))  																///
					over(freq, label(labsize(vsmall)) relabel(1 "`L1'" 2 "`L2'" 3 "`L3'" 4 "`L4'" 5 "`L5'" 6 "`L6'"))	///
					blabel(bar, format(%5.2f) size(tiny)) 																///
					ytitle(Proportion of teachers)  ylab(, nogrid)														///
					title("`title'", size(medlarge)) subtitle("`sub'")	scheme(s1mono)									///							
					legend(label(1 "At least once per week") label(2 "Never"))											///		
					caption("`n1'" "`n2'" "`n3'", size(vsmall))
					
				graph export "C:\Users\sal3ff\Scott\K is the New 1st Grade\Figures/`title'.pdf", replace
			restore

		end //ends program "curriculum"
	

		
		
		curriculum "ELA1_Spell_weekly ELA1_Comp_weekly ELA1_Story_weekly MTH1_Place_weekly MTH1_WordPbs_weekly MTH1_Prob_weekly " 	///
					"ELA1_Spell_never ELA1_Comp_never ELA1_Story_never MTH1_Place_never MTH1_WordPbs_never MTH1_Prob_never " 		///
					"Spelling" "Sentences" "Stories" "Place value" "Writing equations" "Probability"  								///
					"Kindergarten Language and Math Content Exposure, 1998-2010" 													///
					"How often are each of these skills taught in your class?" 														///
																																	///
					"Sentences: Composing and writing complete sentences" 															///
					"Stories: Composing and writing stories with an understandable beginning, middle, and end" 						///
					"Writing equations: Writing math equations to solve word problems" 


		curriculum "ELA1_Spell_never ELA1_Comp_never ELA1_Story_never MTH1_Place_never MTH1_WordPbs_never MTH1_Prob_never "			///					
					"Spelling" "Sentences" "Stories" "Place value" "Writing equations" "Probability"  								///
					"Kindergarten Language and Math Content Exposure, 1998-2010" 													///
					"How often are each of these skills taught in your class?" 														///
																																	///
					"Sentences: Composing and writing complete sentences" 															///
					"Stories: Composing and writing stories with an understandable beginning, middle, and end" 						///
					"Writing equations: Writing math equations to solve word problems" 


	//////// Shifts in curriculum
		pause on	
		capture program drop curriculum
		program curriculum
			args vars L1 L2 L3 L4 L5 L6 title sub n1 n2 n3

				expand 2, generate(never)
				
				foreach x in `vars'	{

					gen `x'_K98 = `x'_never if dataset ==0 & never ==1
					replace `x'_K98 = `x'_weekly if dataset==0 & never ==0
					
					gen `x'_K10 = `x'_never if dataset ==1 & never ==1
					replace `x'_K10 = `x'_weekly if dataset==1 & never ==0
						
				}

				keep T_ID dataset never PublicSchool sweight *_K98 *_K10
				
				foreach cohort in K98 K10	{
					
					loc count = 1
				
					foreach x in `vars'	{	
					
						if `count' ==1  loc let = "A"	
						if `count' ==2 	loc let = "B"
						if `count' ==3 	loc let = "C"
						if `count' ==4 	loc let = "D"
						if `count' ==5 	loc let = "E"
						if `count' ==6 	loc let = "F"

						rename `x'_`cohort' `cohort'_`let'
						loc count = `count' +1

					} // close x loop
				} // close cohort loop

				reshape long K98 K10, i(T_ID dataset never) j(freq, string)
				label define nvr 0 "Weekly" 1 "Never"
				label values never nvr
	
		#delimit ;				
				graph bar (mean) K98 K10 if PublicSchool==1 [pw=sweight],														
					over(never, label(labsize(vsmall)))  																
					over(freq, label(labsize(vsmall)) relabel(1 "`L1'" 2 "`L2'" 3 "`L3'" 4 "`L4'" 5 "`L5'" 6 "`L6'"))	
					blabel(bar, format(%5.2f) size(tiny)) 																
					ytitle(Proportion of teachers)  ylab(, nogrid)														
					title("`title'", size(medlarge)) subtitle("`sub'")	scheme(s1mono)																
					legend(label(1 "1998") label(2 "2010"))																	
					caption("Note. Weekly: At least once per week. Stars indicate significant differences across years. * p<.05  ** p<.01  *** p<.001 " 
								"`n1'" "`n2'" "`n3'", size(vsmall)) ;
		#delimit cr				
					
					
				//graph export "C:\Users\sal3ff\Scott\K is the New 1st Grade\Figures/`title'.pdf", replace
		

		end //ends program "curriculum"
	
		curriculum "ELA1_Spell ELA1_Comp ELA1_Story MTH1_Place MTH1_WordPbs MTH1_Prob " 	///
					"Spelling" "Sentences" "Stories" "Place value" "Writing equations" "Probability"  								///
					"Kindergarten Language and Math Content Exposure, 1998-2010" 													///
					"How often are each of these skills taught in your class?" 														///
																																	///
					"Sentences: Composing and writing complete sentences" 															///
					"Stories: Composing and writing stories with an understandable beginning, middle, and end" 						///
					"Writing equations: Writing math equations to solve word problems" 
