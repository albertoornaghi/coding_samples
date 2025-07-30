*** Import and save all questionnaire length files in Stata format

import delimited AB_Questionnaire.Length_R7to9_21oct24.csv
save "H:\AB_questionnaure_length-r7to9.dta"
import delimited AB_Questionnaire.Length_R10_21oct24.csv, clear
save "H:\AB_questionnaire_length_r10.dta"

*** Import and save all translation files in Stata format

import excel "H:\AB Capstone Data\ANGOLA.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\ANGOLA.dta"
import excel "H:\AB Capstone Data\BENIN.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\BENIN.dta"
import excel "H:\AB Capstone Data\BFO.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\BFO.dta"
import excel "H:\AB Capstone Data\BOTSWANA.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\BOTSWANA.dta"
import excel "H:\AB Capstone Data\CAMEROON.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\CAMEROON.dta"
import excel "H:\AB Capstone Data\CBZ.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\CBZ.dta"
import excel "H:\AB Capstone Data\CDI.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\CDI.dta"
import excel "H:\AB Capstone Data\CVE.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\CVE.dta"
import excel "H:\AB Capstone Data\ESWATINI.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\ESWATINI.dta"
import excel "H:\AB Capstone Data\ETH.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\ETH.dta"
import excel "H:\AB Capstone Data\GABON.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\GABON.dta"
import excel "H:\AB Capstone Data\GAMBIA.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\GAMBIA.dta"
import excel "H:\AB Capstone Data\GHA.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\GHA.dta"
import excel "H:\AB Capstone Data\GUI.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\GUI.dta"
import excel "H:\AB Capstone Data\KEN.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\KEN.dta"
import excel "H:\AB Capstone Data\LES.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\LES.dta"
import excel "H:\AB Capstone Data\LIB.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\LIB.dta"
import excel "H:\AB Capstone Data\MAD.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\MAD.dta"
import excel "H:\AB Capstone Data\MALI.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\MALI.dta"
import excel "H:\AB Capstone Data\MAU.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\MAU.dta"
import excel "H:\AB Capstone Data\MLW.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\MLW.dta"
import excel "H:\AB Capstone Data\MOR.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\MOR.dta"
import excel "H:\AB Capstone Data\MOZ.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\MOZ.dta"
import excel "H:\AB Capstone Data\MRT.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\MRT.dta"
import excel "H:\AB Capstone Data\NAM.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\NAM.dta"
import excel "H:\AB Capstone Data\NGR.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\NGR.dta"
import excel "H:\AB Capstone Data\NIG.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\NIG.dta"
import excel "H:\AB Capstone Data\SAF.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\SAF.dta"
import excel "H:\AB Capstone Data\SEN.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\SEN.dta"
import excel "H:\AB Capstone Data\SEY.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\SEY.dta"
import excel "H:\AB Capstone Data\SRL.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\SRL.dta"
import excel "H:\AB Capstone Data\STP.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\STP.dta"
import excel "H:\AB Capstone Data\SUD.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\SUD.dta"
import excel "H:\AB Capstone Data\TAN.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\TAN.dta"
import excel "H:\AB Capstone Data\TOG.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\TOG.dta"
import excel "H:\AB Capstone Data\TUN.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\TUN.dta"
import excel "H:\AB Capstone Data\USA.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\USA.dta"
import excel "H:\AB Capstone Data\ZAM.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\ZAM.dta"
import excel "H:\AB Capstone Data\ZIM.xlsx", sheet("Sheet1") clear
save "H:\AB Capstone Data\ZIM.dta"

*** Main dataset files were saved directly to Stata format using IBM SPSS

*** merge R10 main dataset and number of questions dataset, use INTVNO (variable identifying interviewer) to code countries

use "H:\AB_round_10.dta"

*** generating variables to identify the round number and country

gen round = 10
gen countrycode = INTVNO
describe countrycode

*** clean countrycode variable to only have the three-letter identifier for the country, as it appears in the questionnaire lenth dataset

ssc install egenmore
ssc install ereplace
ereplace countrycode = sieve(countrycode), omit(1234567890)

*** merge the two files

merge m:1 countrycode using H:\AB_questionnaire_length_r10.dta
drop _merge
save "H:\AB_round_10.dta", replace

*** merge R9 main dataset and number of questions dataset

use "H:\AB_round_9_with_time.dta"
gen round = 9
gen countrycode = INTVNO
ereplace countrycode = sieve(countrycode), omit(1234567890)
merge m:1 countrycode round using H:\AB_questionnaire_length_r7to9.dta

*** drop oberservation of question numbers for other rounds

drop if _merge == 2
drop _merge
save "H:\AB_round_9_with_time_merged.dta"

*** merge R8 main dataset and number of questions dataset

use "H:\AB_round_8.dta"
gen round = 8
gen countrycode = INTVNO
ereplace countrycode = sieve(countrycode), omit(1234567890)
merge m:1 round countrycode using H:\AB_questionnaire_length_r7to9.dta

*** drop oberservations of question numbers for other rounds

drop if _merge == 2
drop _merge
save "H:\AB_round_8_merged.dta"

*** merge R7 main dataset and number of questions dataset, here we used the variable RESPNO (which identifies the respondent) to code countries as no variable INTVNO was found

use "H:\AB_round_7.dta"
gen round = 7
gen countrycode = RESPNO
ereplace countrycode = sieve(countrycode), omit(0123456789)
merge m:1 round countrycode using H:\AB_questionnaire_length_r7to9

*** drop oberservations of question numbers for other rounds

drop if _merge == 2
drop _merge
save "H:\AB_round_7_merged.dta"

***now all datasets for each round also include questionnaire length data

***below we prepare the wordcount datasets for one country (Angola), this method is then repeated for all other countries

use "C:\Users\ornaghi\AppData\Local\Temp\be0422ce-b94c-4a41-bfe1-5f3556ced3b5_Stata-20241104T125742Z-001.zip.3b5\Stata\ANGOLA.dta" 

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

use "H:\ANGOLA.dta"

*** Create identifiers for round and country which match those in the main dataset

gen round = 9
gen countrycode = "ANG"
drop if wordcount == .
save "H:\ANGOLA_count.dta"

*** Repeat above steps for all the translation files for the different countries

*** Append to angola file the files for other countries and drop all variables except wordcounts 

append using "H:\BENIN_count.dta"
keep wordcount language country round

*** repeat with all files until a full dataset including all countries,languages and their wordcounts is created

save "H:\word_counts.dta"

*** using each individual round dataset, we inspect the variables keeping only the necessary variables and renaming them to ensure names are identical across all rounds
*** this ten allows us to append the files for rounds 8,9 and 10 to that for round 7 with eavch variable correctly including observations for all rounds

use "H:\AB_round_7_merged (1).dta" 
rename Q112 INTVNO
keep RESPNO COUNTRY COUNTRY_BY_REGION URBRUR REGION LOCATION_LEVEL_1 THISINT DATEINTR STRTIME Q1 Q2A Q2AOTHER Q2B Q2BOTHER Q94 Q95A Q95B Q97 Q98 Q98OTHER ENDTIME LENGTH Q101 Q102 Q102OTHER Q103 Q103OTHER Q106 Q107A Q107B Q107C Q107D Q107E Q108 Q108_2 Q110A Q110B Q110C Q110D Q110E Q110F INTVNO Q113 Q114 Q115 Q116 Q116OTHER Q117 Q117OTHER Q118 Q119_1 Q119_2 Q119_3 Q119_4 Q119_5 Q119_6 Q119_7 Q119_8 Q119_9 Q119_10 Q119_11 Q119OTHER URBRUR_COND AGE_COND EDUC_COND RELIG_COND LivedPoverty LivedPoverty_CAT round countrycode country total master csq

save "H:\AB_round_7_merged.dta"

rename(Q1 Q2A Q2AOTHER Q2B Q2BOTHER Q94 Q95A Q95B Q97 Q98 Q101 Q102 Q102OTHER Q103 Q103OTHER Q106 Q107A Q107B Q107C Q107D Q107E Q108 Q108_2 Q110A Q110B Q110C Q110D Q110E Q110F Q113 Q114 Q115 Q116 Q116OTHER Q117 Q117OTHER Q118 Q119_1 Q119_2 Q119_3 Q119_4 Q119_5 Q119_6 Q119_7 Q119_8 Q119_9 Q119_10 Q119_11 Q119OTHER RESP_OCCUPATION APPROACH_REPR) (AGE_YEARS RESP_MOTHER_TONGUE RESP_MOTHER_TONGUE_VERBATIM LANG_SPOKEN_HOME LANG_SPOKEN_HOME_VERBATIM EMPLOY_STAT RESP_OCCUPATION RESP_EMPLOYER RESP_EDUC RESP_RELIG RESP_GENDER RESP_RACE RESP_RACE_VERBATIM INTERVIEW_LANG INTERVIEW_LANG_VERBATIM OTHERS_PRESENT CHECK_OTHERS INFLUENCE_OTHERS APPROACH_REPR THREATENED THREATENED_PHYSICAL PROP_DIFFICULTY_ANGLUSO PROP_DIFFICULTY_FRA RESP_FRIENDLY RESP_INTERESTED RESP_COOPERATIVE RESP_PATIENT RESP_EASE RESP_HONEST INTERVIEWER_AGE INTERVIEWER_GENDER INTERVIEWER_URBRUR INTERVIEWER_LANG_HOME INTERVIEWER_LANG_HOME_VERBATIM INTERVIEWER_ETH INTERVIEWER_ETH_VERBATIM INTERVIEWER_EDUC OTHER_LANG_1 OTHER_LANG_2 OTHER_LANG_3 OTHER_LANG_4 OTHER_LANG_5 OTHER_LANG_6 OTHER_LANG_7 OTHER_LANG_8 OTHER_LANG_9 OTHER_LANG_10 OTHER_LANG_11 OTHER_LANG_VERBATIM RESP_OCCUP APPROACH_COMREP)


save "H:\AB_round_7_merged.dta", replace

***the same process is then repeated for rounds 8,9 and 10 ensuring that all the variable names are identical
***using the files with only relevant and renamed variables, we append them all and thus create a single file with all observations across rounds

use "H:\AB_round_7_mergedclean.dta"

append using "H:\AB_round_8_merged_LPI.dta"
append using "H:\AB_round_9_with_time_LPI_merged.dta"
append using "H:\AB_round_10_with_time_LPI_merged.dta"

save "H:\AB_dataset_final"

***so we have a full dataset with all observations for rounds

***merge final dataset with wordcounts dataset on country round and language

use "H:\AB_dataset_final"

gen language = INTERVIEW_LANG

***clean the language variable to improve quality of merging - remove any misspellings or differences from word_counts dataset language variable observations
***merge

merge m:1 language round countrycode using "word_counts.dta"

***drop any observations not merged becuase they are only in the using data 

tab _merge
drop if _merge == 2

***now the full final datset includes data for all rounds with word counts, question counts and all the necessary variables for analysis (from which we also construct further variables)

***clean key dependent variable for interview duration 

use "H:\AB_dataset_final.dta" 

*** look at distribution of LENGTH variable

summ LENGTH
summ LENGTH if LENGTH==-1
summ LENGTH if LENGTH>400
summ duration_per_q if duration_per_q<0
summ LENGTH if LENGTH==0
summ LENGTH if LENGTH<10
summ LENGTH if LENGTH<10&LENGTH>0
summ LENGTH if LENGTH<20&LENGTH>0
summ LENGTH if LENGTH<30&LENGTH>0
summ LENGTH if LENGTH>0&LENGTH<=400
summ LENGTH if LENGTH>=100
summ LENGTH if LENGTH>=100&LENGTH<=400
summ LENGTH if LENGTH>=100&LENGTH<=300

***remove any observations where LENGTH=-1

drop if LENGTH==-1

***check if LENGTH is missing for any observations

tab LENGTH if LENGTH==.

***remove all observation where LENGTH>400 due to the likelihood of these being driven by people taking breaks rather than actually being ridiculously long interviews

drop if LENGTH>400

***this method will also automatically clean all vatriables that are created using LENGTH, such as duration_per_q

save "H:\AB_dataset_final.dta", replace

