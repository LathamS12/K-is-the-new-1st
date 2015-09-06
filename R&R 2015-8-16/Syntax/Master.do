/******************************************************************************
* Author: Scott Latham
* Purpose: This is the master do file that performs all of the data cleaning
*			 and analysis for the "K is the new 1st" manuscript
*						
* Created: 4/27/2014
* Last modified: 8/15/2015
*******************************************************************************/

	//Data folder
	
	//Syntax folder
		gl path "C:\Users\sal3ff\Scott\K is the New 1st Grade\Syntax"
	
	
	//Data cleaning
		do "${path}\Variable Selection - 1998"
		do "${path}\Data Cleaning - 1998"

		do "${path}\Variable Selection - 2010"
		do "${path}\Data cleaning - 2010"

		do "${path}\Appending 2 ECLS-K Waves"

	//Data analysis
	
