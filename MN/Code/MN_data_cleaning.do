clear

***set file path globals

local project MN
include "$HELPER/pathnames.do"

***set locals to govern running code sections

local import				0
local merge					0
local word_count			0
local final_dataset			0
local demo_dyad_vars		0

if `import'==1{

	*** Import and save all questionnaire length files in Stata format

	foreach file in AB_Questionnaire.Length_R7to9_21oct24.csv AB_Questionnaire.Length_R10_21oct24.csv{
		import delimited "$MNDATA/`file'"
		save "$MNDATA/`file'"
	}

	local filelist "$MNDATA/ANGOLA.xlsx" "$MNDATA/BENIN.xlsx" "$MNDATA/BFO.xlsx" "$MNDATA/BOTSWANA.xlsx" "$MNDATA/CAMEROON.xlsx" ///
	"$MNDATA/CBZ.xlsx" "$MNDATA/CDI.xlsx" "$MNDATA/CVE.xlsx" "$MNDATA/ESWATINI.xlsx" "$MNDATA/ETH.xlsx" "$MNDATA/GABON.xlsx" /// 
	"$MNDATA/GAMBIA.xlsx" "$MNDATA/GHA.xlsx" "$MNDATA/GUI.xlsx" "$MNDATA/KEN.xlsx" "$MNDATA/LES.xlsx" "$MNDATA/LIB.xlsx" /// 
	"$MNDATA/MAD.xlsx" "$MNDATA/MALI.xlsx" "$MNDATA/MAU.xlsx" "$MNDATA/MLW.xlsx" "$MNDATA/MOR.xlsx" "$MNDATA/MOZ.xlsx" ///
	"$MNDATA/MRT.xlsx" "$MNDATA/NAM.xlsx" "$MNDATA/NGR.xlsx" "$MNDATA/NIG.xlsx" "$MNDATA/SAF.xlsx" "$MNDATA/SEN.xlsx" ///
	"$MNDATA/SEY.xlsx" "$MNDATA/SRL.xlsx" "$MNDATA/STP.xlsx" "$MNDATA/SUD.xlsx" "$MNDATA/TAN.xlsx" "$MNDATA/TOG.xlsx" ///
	"$MNDATA/TUN.xlsx" "$MNDATA/USA.xlsx" "$MNDATA/ZAM.xlsx" "$MNDATA/ZIM.xlsx"

	*** Import and save all translation files in Stata format
	
	foreach `file' of local filelist{
		import excel "`file'", sheet("Sheet1") clear
		save "`file'.dta"
	}

	*** Main dataset files were saved directly to Stata format using IBM SPSS

}

if `merge'==1 {
	

	local main_datasets "AB_round_10" "AB_round_9_with_time" "AB_round_8" "AB_round_7"
	
	foreach file of local main_datasets{
		use "`file'", clear
	
		***generate round number identifier
	
		if "`file'"=="AB_round_7"{
			gen round = 7
		}
	
		if "`file'"=="AB_round_8"{
			gen round = 8
		}
	
		if "`file'"=="AB_round_9_with_time"{
			gen round = 9
		}
	
		if "`file'"=="AB_round_10"{
			gen round = 10
		}
	
		***generate countrycode identifier
	
		gen countrycode = INTVNO
		ereplace countrycode = sieve(countrycode), omit(1234567890)
	
		if "`file'"=="AB_round_10"{
		
			use "$MNDATA/`file'",clear
			
			merge m:1 countrycode using "$MNDATA/AB_questionnaire_length_r10.dta"
			
			
			tempfile `file'_merged
			save ``file'_merged'
	
		}
		
		if "`file'"!="AB_round_10"{
		
			use "$MNDATA/`file'",clear
			
			merge m:1 countrycode round using "$MNDATA/AB_questionnaire_length_r7to9.dta.dta"
			drop if _merge==2
			drop _merge
			
			tempfile `file'_merged
			save ``file'_merged'
	
		}
	}
}

if `word_count'==1{

***below we prepare the wordcount datasets for one country (Angola), this method is then repeated for all other countries - this process cannot be automated as the languages offered differ in each country and the files are not standardised

use "ANGOLA.dta" 

*** create idetifier for text type and standardise to includ eonly identifiers for type

gen text_type = A
ereplace text_type = sieve(text_type), omit(0123456789_SS)
tab text_type

*** drop all words not read out by interviewer to ensure wordcount variables do not include them 

drop if text_type == "CH"
drop if text_type == "CN"
drop if text_type == "VR"
drop if text_type == "AA"
drop if text_type == "QI"
drop if text_type == "##"
drop if text_type == "**"
tab text_type

*** create variables counting words by language in each observation

gen portuguese_count = wordcount(C)
gen english_count = wordcount(F)
gen kikongo_count = wordcount(G)
gen chokwe_count = wordcount(H)
gen kwanhama_count = wordcount(I)
gen nganguela_count = wordcount(J)
gen nhaneca_count = wordcount(K)
gen umbundu_count = wordcount(L)

*** drop variables (languages) with all missing values

drop M
drop N

*** generate variable taking the names of all the languages

gen language = "Portuguese" in 1
replace language = "English" in 2
replace language = "Kikongo" in 3
replace language = "Chokwe" in 4
replace language = "Kwanhama" in 5
replace language = "Nganguela" in 6
replace language = "Nhaneca" in 7
replace language = "Umbundu" in 8

*** generate variable with word count totals for each language

sum( portuguese_count)
display r(sum)
egen wordcount = sum( portuguese_count)
sum( english_count)
display r(sum)
replace wordcount = r(sum) in 2
sum( kikongo_count)
display r(sum)
replace wordcount = r(sum) in 3
sum( chokwe_count)
display r(sum)
replace wordcount = r(sum) in 4
sum( kwanhama_count)
display r(sum)
replace wordcount = r(sum) in 5
sum( nganguela_count)
display r(sum)
replace wordcount = r(sum) in 6
sum( nhaneca_count)
display r(sum)
replace wordcount = r(sum) in 7
sum( umbundu_count)
display r(sum)
replace wordcount = r(sum) in 8
sum( portuguese_count)
display r(sum)
replace wordcount=. if wordcount==r(sum)
sum( portuguese_count)
display r(sum)
replace wordcount = r(sum) in 1

*** through the method above we generate extra variables directly in the translation files that identify each language and the wordcount of th equestionnaire in this language
*** the same method is then used for all other languages



*** using these new files with the wordcounts we put them together into one wqordcount file for all ocuntries and languages

use "MNDATA\ANGOLA.dta"

*** Create identifiers for round and country which match those in the main dataset

gen round = 9
gen countrycode = "ANG"
drop if wordcount == .
save "MNDATA\ANGOLA_count.dta"

*** Repeat above steps for all the translation files for the different countries

*** Append to angola file the files for other countries and drop all variables except wordcounts 

append using "MNDATA\BENIN_count.dta"
keep wordcount language country round

*** repeat with all files until a full dataset including all countries,languages and their wordcounts is created

tempfile word_counts
save `word_counts'

}


if `final_dataset'==1{

	*** using each individual round dataset, we inspect the variables keeping only the necessary ///
	variables and renaming them to ensure names are identical across all rounds

	local merged_datasets "AB_round_10_merged" "AB_round_9_with_time_merged" "AB_round_8_merged" "AB_round_7_merged"
	
	foreach file of local main_dataset{
	
		use `file'_merged, clear
		
		rename Q112 INTVNO
		keep RESPNO COUNTRY COUNTRY_BY_REGION URBRUR REGION LOCATION_LEVEL_1 THISINT DATEINTR ///
		STRTIME Q1 Q2A Q2AOTHER Q2B Q2BOTHER Q94 Q95A Q95B Q97 Q98 Q98OTHER ENDTIME LENGTH Q101 ///
		Q102 Q102OTHER Q103 Q103OTHER Q106 Q107A Q107B Q107C Q107D Q107E Q108 Q108_2 Q110A Q110B ///
		Q110C Q110D Q110E Q110F INTVNO Q113 Q114 Q115 Q116 Q116OTHER Q117 Q117OTHER Q118 Q119_1 /// 
		Q119_2 Q119_3 Q119_4 Q119_5 Q119_6 Q119_7 Q119_8 Q119_9 Q119_10 Q119_11 Q119OTHER URBRUR_COND ///
		AGE_COND EDUC_COND RELIG_COND LivedPoverty LivedPoverty_CAT round countrycode country total master csq

		rename(Q1 Q2A Q2AOTHER Q2B Q2BOTHER Q94 Q95A Q95B Q97 Q98 Q101 Q102 Q102OTHER Q103 Q103OTHER ///
		Q106 Q107A Q107B Q107C Q107D Q107E Q108 Q108_2 Q110A Q110B Q110C Q110D Q110E Q110F Q113 Q114 ///
		Q115 Q116 Q116OTHER Q117 Q117OTHER Q118 Q119_1 Q119_2 Q119_3 Q119_4 Q119_5 Q119_6 Q119_7 Q119_8 ///
		Q119_9 Q119_10 Q119_11 Q119OTHER RESP_OCCUPATION APPROACH_REPR) (AGE_YEARS RESP_MOTHER_TONGUE ///
		RESP_MOTHER_TONGUE_VERBATIM LANG_SPOKEN_HOME LANG_SPOKEN_HOME_VERBATIM EMPLOY_STAT RESP_OCCUPATION ///
		RESP_EMPLOYER RESP_EDUC RESP_RELIG RESP_GENDER RESP_RACE RESP_RACE_VERBATIM INTERVIEW_LANG ///
		INTERVIEW_LANG_VERBATIM OTHERS_PRESENT CHECK_OTHERS INFLUENCE_OTHERS APPROACH_REPR THREATENED ///
		THREATENED_PHYSICAL PROP_DIFFICULTY_ANGLUSO PROP_DIFFICULTY_FRA RESP_FRIENDLY RESP_INTERESTED ///
		RESP_COOPERATIVE RESP_PATIENT RESP_EASE RESP_HONEST INTERVIEWER_AGE INTERVIEWER_GENDER INTERVIEWER_URBRUR ///
		INTERVIEWER_LANG_HOME INTERVIEWER_LANG_HOME_VERBATIM INTERVIEWER_ETH INTERVIEWER_ETH_VERBATIM ///
		INTERVIEWER_EDUC OTHER_LANG_1 OTHER_LANG_2 OTHER_LANG_3 OTHER_LANG_4 OTHER_LANG_5 OTHER_LANG_6 ///
		OTHER_LANG_7 OTHER_LANG_8 OTHER_LANG_9 OTHER_LANG_10 OTHER_LANG_11 OTHER_LANG_VERBATIM RESP_OCCUP APPROACH_COMREP)
		
		tempfile `file'_merged_clean
		save ``file'_merged_clean'
		
	}
	
	use `AB_round_7_merged_clean',clear
	
	foreach file in AB_round_8_merged_clean AB_round_9_with_time_merged_clean AB_round_10_merged_clean{
	
	append using `file'
	
	}
	
	***merge final dataset with wordcounts dataset on country round and language
	
	gen language = INTERVIEW_LANG

	***clean the language variable to improve quality of merging - remove any misspellings or differences from word_counts dataset language variable observations
	***merge

	merge m:1 language round countrycode using `word_counts'

	***drop any observations not merged becuase they are only in the using data 

	tab _merge
	drop if _merge == 2
	
	save "$MNDATA/AB_dataset_final"

	***clean and generate main dependent variables
	
	drop if LENGTH==-1
	drop if LENGTH>400

	gen duration_per_q = LENGTH/total
	gen duration_per_q_seconds = duration_per_q*60

	gen duration_per_word = LEGTH/wordcount
	gen duration_per_word_seconds = duration_per_word*60

}


if `demo_dyad_vars'==1{

	use "$MNDATA/AB_dataset_final", clear

	*** generate dummy variables coding round numbers

	levelsof round, local(rounds)

	foreach x of local rounds{
		gen round_`x'=0
		replace round_`x'=1 if round==`x'
	}

	***create variable that counts rounds over time

	gen round_counter=0
	replace round_counter=1 if round==8
	replace round_counter=2 if round==9
	replace round_counter=3 if round==10

	***generate variable counting countries

	egen country_count = group(countrycode)
	replace country_count = country_count - 1

	*** set any taking, for example, -1 or "don't know" to missing 

	foreach x of varlist RESP_EDUC EMPLOY_STAT AGE_YEARS{
	
		replace `x'=. if `x'==-1|`x'==99|`x'==98|`x'==998|`x'==999|`x'==8|`x'==9|`x'==9994
	
	}


	*** generate interaction variables, identified  by "_INT" at the end of the varibale name

	gen LPI_EDUC_INT = LivedPoverty*RESP_EDUC

	gen EMPLOY_LPI_INT = EMPLOY_STAT*LivedPoverty


	***generate dummies taking the value 1 for the category indidcated in the name

	gen FEMALE = 0
	replace FEMALE = 1 if RESP_GENDER == 2
	replace FEMALE = . if RESP_GENDER == .

	gen RUR_DUM = 0
	replace RUR_DUM = 1 if URBRUR == 2
	
	gen NATIVE_DUM = 0
	replace NATIVE_DUM=1 if LANG_SPOKEN_HOME==INTERVIEW_LANG & LANG_SPOKEN_HOME!=.
	
	gen GENDER_MATCH = 0
	replace GENDER_MATCH = 1 if RESP_GENDER==INTERVIEWER_GENDER & RESP_GENDER!=.

	gen URBRUR_MATCH = 0
	replace URBRUR_MATCH = 1 if URBRUR==INTERVIEWER_URBRUR & URBRUR!=.


	***convert endtime from seconds to hours and generate dummy taking 1 for interviews ended in the afternoon

	gen ENDTIME_HRS = ENDTIME/3600
	replace ENDTIME_HRS = . if ENDTIME < 0
	gen ENDTIME_HRS_DUM = 1
	replace ENDTIME_HRS_DUM = 0 if ENDTIME_HRS < 12
	replace ENDTIME_HRS_DUM = . if ENDTIME_HRS == .


	***generate categorical variables for interviewer and respondent age, generate dummy indicating an age category match


	gen AGE_RESP_CAT = 1
	replace AGE_RESP_CAT=2 if AGE_YEARS>=26&AGE_YEARS<=35
	replace AGE_RESP_CAT=3 if AGE_YEARS>=36&AGE_YEARS<=45
	replace AGE_RESP_CAT=4 if AGE_YEARS>=46&AGE_YEARS<=55
	replace AGE_RESP_CAT=5 if AGE_YEARS>=56&AGE_YEARS<=65
	replace AGE_RESP_CAT=6 if AGE_YEARS>=66
	
	gen AGE_INTW_CAT = 1
	replace AGE_INTW_CAT=2 if INTERVIEWER_AGE>=26&INTERVIEWER_AGE<=35
	replace AGE_INTW_CAT=3 if INTERVIEWER_AGE>=36&INTERVIEWER_AGE<=45
	replace AGE_INTW_CAT=4 if INTERVIEWER_AGE>=46&INTERVIEWER_AGE<=55
	replace AGE_INTW_CAT=5 if INTERVIEWER_AGE>=56&INTERVIEWER_AGE<=65
	replace AGE_INTW_CAT=6 if INTERVIEWER_AGE>=66
	
	gen AGE_MATCH = 0
	replace AGE_MATCH = 1 if AGE_INTW_CAT==AGE_RESP_CAT
	

	***generate language dummies

	gen english=0
	replace ENGLISH=1 if INTERVIEW_LANG==1

	gen french=0
	replace french=1 if INTERVIEW_LANG==2

	gen portuguese=0
	replace portuguese=1 if INTERVIEW_LANG==3

	gen kiswahili=0
	replace kiswahili=1 if INTERVIEW_LANG==4

	gen arabic=0
	replace arabic=1 if INTERVIEW_LANG==1500|INTERVIEW_LANG==5|INTERVIEW_LANG==1580|INTERVIEW_LANG==1580|INTERVIEW_LANG==1540

	***generate gender dyads

	gen mm_dyad = 0
	replace mm_dyad = 1 if RESP_GENDER==1&INTERVIEWER_GENDER==1

	gen ff_dyad = 0
	replace ff_dyad=1 if RESP_GENDER==2&INTERVIEWER_GENDER==2

	gen fm_dyad = 0
	replace fm_dyad=1 if RESP_GENDER==2&INTERVIEWER_GENDER==1

	gen mf_dyad=0
	replace mf_dyad=1 if RESP_GENDER==1&INTERVIEWER_GENDER==2

	***generate urban/rural dyads

	gen rr_dyad = 0
	replace rr_dyad =1 if INTERVIEWER_RUR_DUM==1&RUR_DUM==1

	gen uu_dyad = 0
	replace uu_dyad = 1 if INTERVIEWER_RUR_DUM==0&RUR_DUM==0

	gen ur_dyad = 0
	replace ur_dyad = 1 if RUR_DUM==0&INTERVIEWER_RUR_DUM==1

	gen ru_dyad = 0
	replace ru_dyad =1 if RUR_DUM==1&INTERVIEWER_RUR_DUM==0

	***define LPI as categorical variable

	gen LivedPoverty_Cat = 0
	replace LivedPoverty_Cat = 1 if LivedPoverty>=0.2 & LivedPoverty <=1
	replace LivedPoverty_Cat = 2 if LivedPoverty>=1.2 & LivedPoverty <=2
	replace LivedPoverty_Cat = 3 if LivedPoverty>=2.2 & LivedPoverty <=4

	***generate langhuage count variable

	gen language_count = 0
	replace language_count = 1 if english ==1
	replace language_count = 2 if french ==1
	replace language_count = 3 if portuguese ==1
	replace language_count = 4 if kiswahili ==1
	replace language_count = 5 if arabic ==1

	***generate gender dyads count

	gen gender_dyad_count = 0
	replace gender_dyad_count =1 if mm_dyad ==1
	replace gender_dyad_count =2 if ff_dyad ==1
	replace gender_dyad_count =3 if fm_dyad ==1
	replace gender_dyad_count =4 if mf_dyad ==1

	*** remove observations not included in any dyad (only 7 observations)

	tab gender_dyad_count
	replace gender_dyad_count=. if gender_dyad_count==0

	***generate rural/urban dyads count

	gen rural_dyads_count = 0
	replace rural_dyads_count = 1 if rr_dyad==1
	replace rural_dyads_count = 2 if uu_dyad==1
	replace rural_dyads_count = 3 if ur_dyad==1
	replace rural_dyads_count = 4 if ru_dyad==1


}

if `section'==1{

*** inspect distributions for mean section duration
*** clean variables to remove any negative observations and any above 400/10=40 minutes to reflect AB's guideline maximum interview length

egen section_mean_time = rmean(DUR1_10_R9 - DUR90_99_R9)

foreach x of varlist DUR1_10_R9-DUR90_99_R9{
	replace `x'=. if `x'<0|`x'>40
}

***generate variables for number of questions in section

gen section_1_qs =Q110Demo + Q110MC + Q110Scale + Q1102S + Q110YN + Q110OE
gen section_2_qs = Q1119Demo + Q1119MC + Q1119Scale + Q11192S + Q1119YN + Q1119OE
gen section_3_qs = Q2029Demo + Q2029MC + Q2029Scale + Q20292S + Q2029YN + Q2029OE
gen section_4_qs = Q3039Demo + Q3039MC + Q3039Scale + Q30392S + Q3039YN + Q3039OE
gen section_5_qs = Q4049Demo + Q4049MC + Q4049Scale + Q40492S + Q4049YN + Q4049OE
gen section_6_qs = Q5059Demo + Q5059MC + Q5059Scale + Q50592S + Q5059YN + Q5059OE
gen section_7_qs = Q6069Demo + Q6069MC + Q6069Scale + Q60692S + Q6069YN + Q6069OE
gen section_8_qs = Q7079Demo + Q7079MC + Q7079Scale + Q70792S + Q7079YN + Q7079OE
gen section_9_qs = Q8089Demo + Q8089MC + Q8089Scale + Q80892S + Q8089YN + Q8089OE
gen section_10_qs = Q9099Demo + Q9099MC + Q9099Scale + Q90992S + Q9099YN + Q9099OE

***generate variable section_duration_per_q_seconds for the duration divided by the number of questions in seconds for each question

gen section_1_duration_per_q_seconds = ( DUR1_10_R9/section_1_qs)*60
summ section_1_duration_per_q_seconds
gen section_2_duration_per_q_seconds = ( DUR11_19_R9 /section_2_qs)*60
gen section_3_duration_per_q_seconds = ( DUR20_29_R9 /section_3_qs)*60
gen section_4_duration_per_q_seconds = ( DUR30_39_R9 /section_4_qs)*60
gen section_5_duration_per_q_seconds = ( DUR40_49_R9 /section_5_qs)*60
gen section_6_duration_per_q_seconds = ( DUR50_59_R9 /section_6_qs)*60
gen section_7_duration_per_q_seconds = ( DUR60_69_R9 /section_7_qs)*60
gen section_8_duration_per_q_seconds = ( DUR70_79_R9 /section_8_qs)*60
gen section_9_duration_per_q_seconds = ( DUR80_89_R9 /section_9_qs)*60
gen sect_10_duration_per_q_seconds = ( DUR90_99_R9 /section_10_qs)*60

*** generate variables for proportion of question types in each section

gen demo_weight_1= Q110Demo/section_1_qs
gen demo_weight_2= Q1119Demo /section_2_qs
gen demo_weight_3= Q2029Demo /section_3_qs
gen demo_weight_4= Q3039Demo /section_4_qs
gen demo_weight_5 = Q4049Demo /section_5_qs
gen demo_weight_6 = Q5059Demo /section_6_qs
gen demo_weight_7 = Q6069Demo /section_7_qs
gen demo_weight_8  = Q7079Demo /section_8_qs
gen demo_weight_9  = Q8089Demo /section_9_qs
gen demo_weight_10  = Q9099Demo /section_10_qs

gen mc_weight_1= Q110MC/section_1_qs
gen mc_weight_2= Q1119MC /section_2_qs
gen mc_weight_3= Q2029MC /section_3_qs
gen mc_weight_5 = Q4049MC /section_5_qs
gen mc_weight_6 = Q5059MC /section_6_qs
gen mc_weight_7 = Q6069MC /section_7_qs
gen mc_weight_8  = Q7079MC /section_8_qs
gen mc_weight_9  = Q8089MC /section_9_qs
gen mc_weight_10  = Q9099MC /section_10_qs
gen mc_weight_4= Q3039MC /section_4_qs

gen scale_weight_1= Q110Scale/section_1_qs
gen scale_weight_2= Q1119Scale /section_2_qs
gen scale_weight_3= Q2029Scale/section_3_qs
gen scale_weight_4= Q3039Scale/section_4_qs
gen scale_weight_5 = Q4049Scale /section_5_qs
gen scale_weight_6 = Q5059Scale/section_6_qs
gen scale_weight_7 = Q6069Scale/section_7_qs
gen scale_weight_8  = Q7079Scale /section_8_qs
gen scale_weight_9  = Q8089Scale/section_9_qs
gen scale_weight_10  = Q9099Scale /section_10_qs

gen twos_weight_1= Q1102S/section_1_qs
gen twos_weight_2= Q11192S /section_2_qs
gen twos_weight_3= Q20292S/section_3_qs
gen twos_weight_4= Q30392S/section_4_qs
gen twos_weight_5 = Q40492S /section_5_qs
gen twos_weight_6 = Q50592S/section_6_qs
gen twos_weight_7 = Q60692S/section_7_qs
gen twos_weight_8  = Q70792S/section_8_qs
gen twos_weight_9  = Q80892S/section_9_qs
gen twos_weight_10  = Q90992S/section_10_qs

gen yn_weight_1= Q110YN/section_1_qs
gen yn_weight_2= Q1119YN /section_2_qs
gen yn_weight_3= Q2029YN/section_3_qs
gen yn_weight_4= Q3039YN/section_4_qs
gen yn_weight_5 = Q4049YN /section_5_qs
gen yn_weight_6 = Q5059YN/section_6_qs
gen yn_weight_7 = Q6069YN/section_7_qs
gen yn_weight_8  = Q7079YN/section_8_qs
gen yn_weight_9  = Q8089YN/section_9_qs
gen yn_weight_10  = Q9099YN/section_10_qs

gen oe_weight_1= Q110OE/section_1_qs
gen oe_weight_2= Q1119OE /section_2_qs
gen oe_weight_3= Q2029OE/section_3_qs
gen oe_weight_4= Q3039OE/section_4_qs
gen oe_weight_5 = Q4049OE /section_5_qs
gen oe_weight_6 = Q5059OE/section_6_qs
gen oe_weight_7 = Q6069OE/section_7_qs
gen oe_weight_8  = Q7079OE/section_8_qs
gen oe_weight_9  = Q8089OE/section_9_qs
gen oe_weight_10  = Q9099OE/section_10_qs

***create variables for overall proportion of questions

gen demo_weight=TotalDemo/total_q
gen mc_weight= TotalMC/total_q
gen scale_weight= TotalScale/total_q
gen twos_weight= Total2S/total_q
gen yn_weight= TotalYN/total_q
gen oe_weight= TotalOE/total_q

***use weights for each question-type and section generated earlier to create proportion of qtypes table

gen mean_demo_weighted = (demo_weight_1* DUR1_10_R9+demo_weight_2* DUR11_19_R9+demo_weight_3* DUR20_29_R9+demo_weight_4* DUR30_39_R9+demo_weight_5* DUR40_49_R9+demo_weight_6* DUR50_59_R9+demo_weight_7* DUR60_69_R9+demo_weight_8* DUR70_79_R9+demo_weight_9* DUR80_89_R9+demo_weight_10* DUR90_99_R9)/( demo_weight_1+ demo_weight_2+ demo_weight_3+ demo_weight_4+ demo_weight_5+ demo_weight_6+ demo_weight_7+ demo_weight_8+ demo_weight_9+ demo_weight_10)

gen mean_mc_weighted = (mc_weight_1* DUR1_10_R9+mc_weight_2* DUR11_19_R9+mc_weight_3* DUR20_29_R9+mc_weight_4* DUR30_39_R9+mc_weight_5* DUR40_49_R9+mc_weight_6* DUR50_59_R9+mc_weight_7* DUR60_69_R9+mc_weight_8* DUR70_79_R9+mc_weight_9* DUR80_89_R9+mc_weight_10* DUR90_99_R9)/( mc_weight_1+ mc_weight_2+ mc_weight_3+ mc_weight_4+ mc_weight_5+ mc_weight_6+ mc_weight_7+ mc_weight_8+ mc_weight_9+ mc_weight_10)

gen mean_scale_weighted = (scale_weight_1* DUR1_10_R9+scale_weight_2* DUR11_19_R9+scale_weight_3* DUR20_29_R9+scale_weight_4* DUR30_39_R9+scale_weight_5* DUR40_49_R9+scale_weight_6* DUR50_59_R9+scale_weight_7* DUR60_69_R9+scale_weight_8* DUR70_79_R9+scale_weight_9* DUR80_89_R9+scale_weight_10* DUR90_99_R9)/( scale_weight_1+ scale_weight_2+ scale_weight_3+ scale_weight_4+ scale_weight_5+ scale_weight_6+ scale_weight_7+ scale_weight_8+ scale_weight_9+ scale_weight_10)

gen mean_twos_weighted = (twos_weight_1* DUR1_10_R9+twos_weight_2* DUR11_19_R9+twos_weight_3* DUR20_29_R9+twos_weight_4* DUR30_39_R9+twos_weight_5* DUR40_49_R9+twos_weight_6* DUR50_59_R9+twos_weight_7* DUR60_69_R9+twos_weight_8* DUR70_79_R9+twos_weight_9* DUR80_89_R9+twos_weight_10* DUR90_99_R9)/(twos_weight_1+ twos_weight_2+ twos_weight_3+ twos_weight_4+ twos_weight_5+ twos_weight_6+ twos_weight_7+ twos_weight_8+ twos_weight_9+ twos_weight_10)

gen mean_yn_weighted = (yn_weight_1* DUR1_10_R9+yn_weight_2* DUR11_19_R9+yn_weight_3* DUR20_29_R9+yn_weight_4* DUR30_39_R9+yn_weight_5* DUR40_49_R9+yn_weight_6* DUR50_59_R9+yn_weight_7* DUR60_69_R9+yn_weight_8* DUR70_79_R9+yn_weight_9* DUR80_89_R9+yn_weight_10* DUR90_99_R9)/(yn_weight_1+ yn_weight_2+ yn_weight_3+ yn_weight_4+ yn_weight_5+ yn_weight_6+ yn_weight_7+ yn_weight_8+ yn_weight_9+ yn_weight_10)

gen mean_oe_weighted = (oe_weight_1* DUR1_10_R9+oe_weight_2* DUR11_19_R9+oe_weight_3* DUR20_29_R9+oe_weight_4* DUR30_39_R9+oe_weight_5* DUR40_49_R9+oe_weight_6* DUR50_59_R9+oe_weight_7* DUR60_69_R9+oe_weight_8* DUR70_79_R9+oe_weight_9* DUR80_89_R9+oe_weight_10* DUR90_99_R9)/(oe_weight_1+ oe_weight_2+ oe_weight_3+ oe_weight_4+ oe_weight_5+ oe_weight_6+ oe_weight_7+ oe_weight_8+ oe_weight_9+ oe_weight_10)
summ mean_demo_weighted mean_mc_weighted mean_scale_weighted mean_twos_weighted mean_yn_weighted mean_oe_weighted

save "MNDATA\AB_dataset_final.dta", replace


}
