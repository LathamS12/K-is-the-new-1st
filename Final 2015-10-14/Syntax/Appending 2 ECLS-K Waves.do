/***********************************************************
* Author: Scott Latham
* Purpose: This file appends the ECLS-K 1998 and ECLS-K 2010 datasets
*
* Created: 4/14/2014
* Last modified: 8/15/2015
***********************************************************/
set more off
pause on

	cd "C:\Users\sal3ff\Scott\K is the New 1st Grade\Generated Datasets"
		
	use "K is the new 1st - 1998 Clean", clear	
	append using "K is the new 1st - 2010 Clean"

	//Clean waves as necessary
		label define data 0 "98" 1 "10"
		label values dataset data

	//Generate half day, full day, all student variables
		gen All = 1
		
		gen Full = FullDay_K ==1
		replace Full = . if FullDay_K ==.
		
		gen Half = FullDay_K ==0
		replace Half = . if FullDay_K ==.
		
	//Generate interaction variables
	***********************************	
		gen INT_Min_K = dataset ==1 & HiPctMin_K ==1
		replace INT_Min_K =. if HiPctMin_K ==.
		label var INT_Min_K "Teacher was in a high minority school in the 2010 cohort"

		gen INT_FRL_K = dataset ==1 & HiPctFRL_K ==1
		replace INT_FRL_K =. if HiPctFRL_K ==.
		label var INT_FRL_K "Teacher was in a high poverty school in the 2010 cohort"

		gen INT_Min_FRL_K = dataset*HiPctMin_K*HiPctFRL_K
		replace INT_Min_FRL_K = . if HiPctMin_K ==. | HiPctFRL_K ==.
		label var INT_Min_FRL_K "Three way interaction between cohort, pct frlk & pct min"
		
		
		gen INT_Min_F = dataset ==1 & HiPctMin_F ==1
		replace INT_Min_F =. if HiPctMin_F ==.
		label var INT_Min_F "Teacher was in a high minority school in the 2010 cohort"

		gen INT_FRL_F = dataset ==1 & HiPctFRL_F ==1
		replace INT_FRL_F =. if HiPctFRL_F ==.
		label var INT_FRL_F "Teacher was in a high poverty school in the 2010 cohort"

		gen INT_Min_FRL_F = dataset*HiPctMin_F*HiPctFRL_F
		replace INT_Min_FRL_F = . if HiPctMin_F ==. | HiPctFRL_F ==.
		label var INT_Min_FRL_F "Three way interaction between cohort, pct frl & pct min"


		save "ECLS-K waves appended", replace
