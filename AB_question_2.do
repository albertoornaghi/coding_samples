*** clean  and define variabes for regression

*** set any variables taking, for example, -1 or "don't know" to missing 
*** generate interaction variables, identified  by "_INT" at the end of the varibale name

replace RESP_EDUC = . if RESP_EDUC == -1|RESP_EDUC == 99
replace RESP_EDUC = . if RESP_EDUC == 98
gen LPI_EDUC_INT = LivedPoverty*RESP_EDUC
replace EMPLOY_STAT = . if EMPLOY_STAT == -1
replace EMPLOY_STAT = . if EMPLOY_STAT == 8
replace EMPLOY_STAT = . if EMPLOY_STAT == 9
replace EMPLOY_STAT = . if EMPLOY_STAT == 9994
gen EMPLOY_LPI_INT = EMPLOY_STAT*LivedPoverty
replace AGE_YEARS = . if AGE_YEARS == 998
replace AGE_YEARS = . if AGE_YEARS == 999

***generate FEMALE and RUR_DUM as dummies taking the value 1 for the category indidcated in the name

gen FEMALE = 0
replace FEMALE = 1 if RESP_GENDER == 2
replace FEMALE = . if RESP_GENDER == .
gen RUR_DUM = 0
replace RUR_DUM = 1 if URBRUR == 2

***convert endtime from seconds to hours and generate dummy taking 1 for interviews ended in the afternoon

gen ENDTIME_HRS = ENDTIME/3600
replace ENDTIME_HRS = . if ENDTIME < 0
gen ENDTIME_HRS_DUM = 1
replace ENDTIME_HRS_DUM = 0 if ENDTIME_HRS < 12
replace ENDTIME_HRS_DUM = . if ENDTIME_HRS == .

***generate NATIVE_DUM as a dummy taking the value 1 for the category indidcated in the name

gen NATIVE_DUM = 0
tab LANG_SPOKEN_HOME
tab INTERVIEW_LANG
replace NATIVE_DUM=1 if LANG_SPOKEN_HOME==INTERVIEW_LANG
tab NATIVE_DUM

*** generate rural and gender match dummies

gen GENDER_DUM = 0
replace GENDER_DUM = 1 if RESP_GENDER==INTERVIEWER_GENDER
tab GENDER_DUM
gen URBRUR_DUM = 0
replace URBRUR_DUM = 1 if URBRUR==INTERVIEWER_URBRUR
tab URBRUR_DUM
rename URBRUR_DUM URBRUR_MATCH
rename GENDER_DUM GENDER_MATCH

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
tab AGE_MATCH

***create table of summary statistics

rename total total_q
table() (result), stat(mean LENGTH duration_per_q_seconds total_q FEMALE AGE_YEARS RUR_DUM EMPLOY_STAT LivedPoverty NATIVE_DUM ENDTIME_HRS_DUM GENDER_MATCH AGE_MATCH URBRUR_MATCH ) stat(median LENGTH duration_per_q_seconds total_q FEMALE AGE_YEARS RUR_DUM EMPLOY_STAT LivedPoverty NATIVE_DUM ENDTIME_HRS_DUM GENDER_MATCH AGE_MATCH URBRUR_MATCH ) stat(sd LENGTH duration_per_q_seconds total_q FEMALE AGE_YEARS RUR_DUM EMPLOY_STAT LivedPoverty NATIVE_DUM ENDTIME_HRS_DUM GENDER_MATCH AGE_MATCH URBRUR_MATCH) stat(iqr LENGTH duration_per_q_seconds total_q FEMALE AGE_YEARS RUR_DUM EMPLOY_STAT LivedPoverty NATIVE_DUM ENDTIME_HRS_DUM GENDER_MATCH AGE_MATCH URBRUR_MATCH) stat(count LENGTH duration_per_q_seconds total_q FEMALE AGE_YEARS RUR_DUM EMPLOY_STAT LivedPoverty NATIVE_DUM ENDTIME_HRS_DUM GENDER_MATCH AGE_MATCH URBRUR_MATCH)

***format table

collect style cell, halign(center) valign(center)
collect style cell, border( right, pattern(single) )
collect style cell, border(left, pattern(single))
collect style cell, border(bottom,pattern(single))
collect style cell, border(top,pattern(single))
collect style cell, border( all, width(0.5) )
collect title "Figure 9: Overall Sample Characteristics"
collect style title, font(, bold)
collect style cell, halign(left)
collect label levels var LENGTH "Interview Duration (Mins)" duration_per_q_seconds "Interview Duration per Question (Secs)" FEMALE "Female (Proportion)" AGE_YEARS "Age (Years)" RUR_DUM "Rural (Proportion)" EMPLOY_STAT "Employment (Code)" LivedPoverty "Lived Poverty Index" NATIVE_DUM "Interviewed in Native Language (Proportion)" total_q "Total Questions Asked" ENDTIME_HRS_DUM "Interviewed in Afternoon (Proportion)" GENDER_MATCH "Respondent-Interviewer Gender Match (Proportion)" AGE_MATCH "Respondent-Interviewer Age Category Match (Proportion)" URBRUR_MATCH "Respondent-Interviewer Urban/Rural Match (Proportion)", modify
collect style cell, nformat(%7.3g)
collect export "overall_sample_stats", as(docx) replace
save "H:\AB_dataset_final (1).dta", replace

***generate language dummies

tab language
tab INTERVIEW_LANG
gen english=0
replace ENGLISH=1 if INTERVIEW_LANG==1

gen french=0
replace french=1 if INTERVIEW_LANG==2

gen portuguese=0
replace portuguese=1 if INTERVIEW_LANG==3

gen kiswahili=0
replace kiswahili=1 if INTERVIEW_LANG==4

gen sesotho=0
gen int_lang_code = INTERVIEW_LANG
tab int_lang_code language if language=="Sesotho"
replace sesotho=1 if INTERVIEW_LANG==340

gen creole=0
tab int_lang_code language if language=="Creole"
replace creole=1 if INTERVIEW_LANG==220

tab int_lang_code language if language=="Crioulu"

tab int_lang_code language if language=="Moroccan Arabic"
gen arabic=0
replace arabic=1 if INTERVIEW_LANG==1500
tab int_lang_code if language=="Arabic"
replace arabic =1 if INTERVIEW_LANG==5|INTERVIEW_LANG==1580
tab int_lang_code if language=="Sudanese Arabic"
replace arabic=1 if INTERVIEW_LANG==1540
replace arabic=1 if INTERVIEW_LANG==1580

*** remove languages that occur in only one country

tab creole countrycode
drop creole
tab arabic countrycode
tab kiswahili countrycode
tab sesotho countrycode
drop sesotho

*** run regressions

reg LENGTH LivedPoverty RESP_EDUC LPI_EDUC_INT EMPLOY_STAT EMPLOY_LPI_INT AGE_YEARS FEMALE RUR_DUM ENDTIME_HRS_DUM NATIVE_DUM english french portuguese kiswahili arabic GENDER_MATCH URBRUR_MATCH AGE_MATCH i.country_count i.round,robust
estimates store reg1

reg LENGTH LivedPoverty RESP_EDUC LPI_EDUC_INT EMPLOY_STAT EMPLOY_LPI_INT AGE_YEARS FEMALE RUR_DUM total_q ENDTIME_HRS_DUM NATIVE_DUM english french portuguese kiswahili arabic GENDER_MATCH URBRUR_MATCH AGE_MATCH,robust
estimates store reg2

reg duration_per_q_seconds LivedPoverty RESP_EDUC LPI_EDUC_INT EMPLOY_STAT EMPLOY_LPI_INT AGE_YEARS FEMALE RUR_DUM ENDTIME_HRS_DUM NATIVE_DUM english french portuguese kiswahili arabic GENDER_MATCH URBRUR_MATCH AGE_MATCH,robust
estimates store reg3

reg duration_per_q_seconds LivedPoverty RESP_EDUC LPI_EDUC_INT EMPLOY_STAT EMPLOY_LPI_INT AGE_YEARS FEMALE RUR_DUM ENDTIME_HRS_DUM NATIVE_DUM english french portuguese kiswahili arabic GENDER_MATCH URBRUR_MATCH AGE_MATCH i.country_count i.round,robust
estimates store reg4

*** visualise with and without repporting round/country dummy coefficients

etable, estimates(reg1 reg2 reg3 reg4) stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) showstars showstarsnote title(Figure 10: Regressin Reulsts Full) note(Regressions 1 and 4 include round and country fixed effects) export(q2_reg_results_full.docx,replace)

etable, estimates(reg1 reg2 reg3 reg4) stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) showstars showstarsnote title(Figure 10: Regression Results) keep(_cons LivedPoverty RESP_EDUC LPI_EDUC_INT EMPLOY_STAT EMPLOY_LPI_INT AGE_YEARS FEMALE RUR_DUM total_q ENDTIME_HRS_DUM NATIVE_DUM english french portuguese kiswahili arabic GENDER_MATCH URBRUR_MATCH AGE_MATCH) note(Regressions 1 and 4 include round and country fixed effects) export(q2_reg_results_short.docx,replace)

***run regressions of only DV and language dummies

drop _est_reg1 _est_reg2 _est_reg3 _est_reg4

reg LENGTH english french portuguese kiswahili arabic, robust
estimates store reg1

reg duration_per_q_seconds english french portuguese kiswahili arabic, robust
estimates store reg2

etable, estimates(reg1 reg2) stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) showstars showstarsnote title(Figure X: Effect of Language on Mean Interview Duration)  export(dummy_reg_language.docx,replace)

***investigate further the impact of respondent-interviewer dyads on interview length
***define dummies taking the value 1 to indicate various dyads based on gender and urban/rural - xy_dyad indicates the respondent is of group x and interviewer is of group y

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

***run regressions of DVs against dyad dummies

reg LENGTH ff_dyad fm_dyad mf_dyad uu_dyad ur_dyad ru_dyad AGE_MATCH, robust
estimates store reg1

reg duration_per_q_seconds ff_dyad fm_dyad mf_dyad uu_dyad ur_dyad ru_dyad AGE_MATCH, robust
estimates store reg2

***create and format table 

etable, estimates(reg1 reg2) stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) showstars showstarsnote title(Figure X: Effect of Dyads on Mean Interview Duration) export(dummy_reg_dyads.docx,replace)

*** create boxplots by all the variables used in regression

***gender boxplots with and without outaside values
graph hbox LENGTH, over(FEMALE, relabel(1 "Male" 2 "Female")) ylabel(#10) title(Distribution of Duration by Gender)
graph save "Graph" "H:\boxplot_gender.gph"
graph export "H:\boxplot_gender.pdf", as(pdf) name("Graph")

graph hbox LENGTH, over(FEMALE, relabel(1 "Male" 2 "Female")) ylabel(#10) noout note(Excludes Outside Values) title(Distribution of Duration by Gender)
graph save "Graph" "H:\gender_boxplot_noout.gph"
graph export "H:\gender_boxplot_noout.pdf", as(pdf) name("Graph")

***age category boxplots

graph hbox LENGTH, over(AGE_RESP_CAT, relabel(1 "18 to 25" 2 "26 to 35" 3 "36 to 45" 4 "46 to 55" 5 "56 to 65" 6 "Over 65")) ylabel(#10) title(Distribution of Duration by Age Category)
graph save "Graph" "H:\age_boxplot.gph"
graph export "H:\age_boxplot.pdf", as(pdf) name("Graph")

graph hbox LENGTH, over(AGE_RESP_CAT, relabel(1 "18 to 25" 2 "26 to 35" 3 "36 to 45" 4 "46 to 55" 5 "56 to 65" 6 "Over 65")) ylabel(#10) noout note(Excludes Outside Values) title(Distribution of Duration by Age Category)
graph save "Graph" "H:\age_boxplot_noout.gph"
graph export "H:\age_boxplot_noout.pdf", as(pdf) name("Graph")

***define LPI as categorical variable

gen LivedPoverty_Cat = 0
replace LivedPoverty_Cat = 1 if LivedPoverty>=0.2 & LivedPoverty <=1
replace LivedPoverty_Cat = 2 if LivedPoverty>=1.2 & LivedPoverty <=2
replace LivedPoverty_Cat = 3 if LivedPoverty>=2.2 & LivedPoverty <=4

***LPI category boxplots

graph hbox LENGTH, over(LivedPoverty_Cat, relabel(1 "No Lived Poverty" 2 "Low Lived Poverty" 3 "Moderate Lived Poverty" 4 "High Lived Poverty" )) ylabel(#10) title(Distribution of Duration by LPI Category)
graph save "Graph" "H:\LPI_Boxplot.gph"
graph export "H:\LPI_Boxplot.pdf", as(pdf) name("Graph")

graph hbox LENGTH, over(LivedPoverty_Cat, relabel(1 "No Lived Poverty" 2 "Low Lived Poverty" 3 "Moderate Lived Poverty" 4 "High Lived Poverty" )) ylabel(#10) noout note(Excludes Outside Values) title(Distribution of Duration by LPI Category)
graph save "Graph" "H:\LPI_boxplot_noout.gph"
graph export "H:\LPI_boxplot_noout.pdf", as(pdf) name("Graph")

***Education Boxplots

graph hbox LENGTH, over(RESP_EDUC, relabel(1 "No Formal" 2 "Informal Only" 3 "Some Primary" 4 "Primary Completed" 5 "Some Seondary" 6 "Secondary Completed" 7 "Post-Secondary" 8 "Some University" 9 "University Completed" 10 "Post-Graduate" )) ylabel(#10) title(Distribution of Duration by Education)
graph save "Graph" "H:\education_boxplot.gph"
graph export "H:\education_boxplot.pdf", as(pdf) name("Graph")

graph hbox LENGTH, over(RESP_EDUC, relabel(1 "No Formal" 2 "Informal Only" 3 "Some Primary" 4 "Primary Completed" 5 "Some Seondary" 6 "Secondary Completed" 7 "Post-Secondary" 8 "Some University" 9 "University Completed" 10 "Post-Graduate" )) ylabel(#10) noout note(Excludes Outside Values) title(Distribution of Duration by Education)
graph save "Graph" "H:\education_boxplot_noout.gph"
graph export "H:\education_boxplot_noout.pdf", as(pdf) name("Graph")

***Employment Boxplots

graph hbox LENGTH, over(EMPLOY_STAT, relabel(1 "No, not looking" 2 "No, looking" 3 "Yes, part-time" 4 "Yes, full time"  )) ylabel(#10) title(Distribution of Duration by Employment Status)
graph save "Graph" "H:\employment_boxplot.gph"
graph export "H:\employment_boxplot.pdf", as(pdf) name("Graph")

graph hbox LENGTH, over(EMPLOY_STAT, relabel(1 "No, not looking" 2 "No, looking" 3 "Yes, part-time" 4 "Yes, full time"  )) ylabel(#10) noout note(Excludes Outside Values) title(Distribution of Duration by Employment Status)
graph save "Graph" "H:\employment_boxplot_noout.gph"
graph export "H:\employment_boxplot_noout.pdf", as(pdf) name("Graph")

***Rural Boxplot

graph hbox LENGTH, over(RUR_DUM, relabel(1 "Urban" 2 "Rural" )) ylabel(#10) title(Distribution of Duration by Urban/Rural)
graph save "Graph" "H:\rural_boxplot.gph"
graph export "H:\rural_boxplot.pdf", as(pdf) name("Graph")

graph hbox LENGTH, over(RUR_DUM, relabel(1 "Urban" 2 "Rural" )) ylabel(#10)  noout note(Excludes Outside Values) title(Distribution of Duration by Urban/Rural)
graph save "Graph" "H:\rural_boxplot_noout.gph"
graph export "H:\rural_boxplot_noout.pdf", as(pdf) name("Graph")

***Endtime Boxplot

graph hbox LENGTH, over( ENDTIME_HRS_DUM , relabel(1 "Morning" 2 "Afternoon" )) ylabel(#10) title(Distribution of Duration by End Time Category)
graph save "Graph" "H:\endtime_boxplot.gph"
graph export "H:\endtime_boxplot.pdf", as(pdf) name("Graph")

graph hbox LENGTH, over( ENDTIME_HRS_DUM , relabel(1 "Morning" 2 "Afternoon" )) ylabel(#10) noout note(Excludes Outside Values) title(Distribution of Duration by End Time Category)
graph save "Graph" "H:\endtime_boxplot_noout.gph"
graph export "H:\endtime_boxplot_noout.pdf", as(pdf) name("Graph")

***Native Boxplot

graph hbox LENGTH, over( NATIVE_DUM , relabel(1 "Non-Native" 2 "Native" )) ylabel(#10) title(Distribution of Duration by Interview Language Fluency)
graph save "Graph" "H:\native_boxplot.gph"
graph export "H:\native_boxplot.pdf", as(pdf) name("Graph")

graph hbox LENGTH, over( NATIVE_DUM , relabel(1 "Non-Native" 2 "Native" )) ylabel(#10) noout note(Excludes Outside Values) title(Distribution of Duration by Interview Language Fluency)
graph save "Graph" "H:\native_boxplot_noout.gph"
graph export "H:\native_boxplot_noout.pdf", as(pdf) name("Graph")

***generate langhuage count variable

gen language_count = 0
replace language_count = 0 if english ==1
replace language_count = 1 if english ==1
replace language_count = 2 if french ==1
replace language_count = 3 if portuguese ==1
replace language_count = 4 if kiswahili ==1
replace language_count = 5 if arabic ==1

***language boxplot

graph hbox LENGTH, over( language_count , relabel(1 "All Omitted Languages" 2 "English" 3 "French" 4 "Portuguese" 5 "Kiswahili" 6 "Arabic" )) ylabel(#10) title(Distribution of Duration by Interview Language)
graph save "Graph" "H:\languages_boxplot.gph"
graph export "H:\languages_boxplot.pdf", as(pdf) name("Graph")

graph hbox LENGTH, over( language_count , relabel(1 "All Omitted Languages" 2 "English" 3 "French" 4 "Portuguese" 5 "Kiswahili" 6 "Arabic" )) ylabel(#10)  noout note(Excludes Outside Values) title(Distribution of Duration by Interview Language)
graph save "Graph" "H:\languages_boxplot_noout.gph"
graph export "H:\languages_boxplot_noout.pdf", as(pdf) name("Graph")

***generate gender dyads count

gen gender_dyad_count = 0
replace gender_dyad_count =1 if mm_dyad ==1
replace gender_dyad_count =2 if ff_dyad ==1
replace gender_dyad_count =3 if fm_dyad ==1
replace gender_dyad_count =4 if mf_dyad ==1

*** remove observations not included in any dyad (only 7 observations)

tab gender_dyad_count
replace gender_dyad_count=. if gender_dyad_count==0

***gender dyad boxplot

graph hbox LENGTH, over( gender_dyad_count , relabel(1 "Male-Male" 2 "Female-Female" 3 "Female-Male" 4 "Male-Female" )) ylabel(#10) title(Distribution of Duration by Interviewer-Respondent Gender Dyads)
graph save "Graph" "H:\gender_dyad_boxplot.gph"
graph export "H:\gender_dyad_boxplot.pdf", as(pdf) name("Graph")

graph hbox LENGTH, over( gender_dyad_count , relabel(1 "Male-Male" 2 "Female-Female" 3 "Female-Male" 4 "Male-Female" )) ylabel(#10) noout note(Excluted Outside Values) title(Distribution of Duration by Interviewer-Respondent Gender Dyads)
graph save "Graph" "H:\gender_dyads_boxplot_noout.gph"
graph export "H:\gender_dyads_boxplot_noout.pdf", as(pdf) name("Graph")

***generate rural/urban dyads count

gen rural_dyads_count = 0
replace rural_dyads_count = 1 if rr_dyad==1
replace rural_dyads_count = 2 if uu_dyad==1
replace rural_dyads_count = 3 if ur_dyad==1
replace rural_dyads_count = 4 if ru_dyad==1
tab rural_dyads_count

***rural/urban boxplots

graph hbox LENGTH, over( rural_dyads_count , relabel(1 "Rural-Rural" 2 "Urban-Urban" 3 "Urban-Rural" 4 "Rural-Urban" )) ylabel(#10) title(Distribution of Duration by Interviewer-Respondent Urban/Rural Dyads)
graph save "Graph" "H:\urban_dyad_boxplot.gph"
graph export "H:\urban_dyad_boxplot.pdf", as(pdf) name("Graph")

graph hbox LENGTH, over( rural_dyads_count , relabel(1 "Rural-Rural" 2 "Urban-Urban" 3 "Urban-Rural" 4 "Rural-Urban" )) ylabel(#10) noout note(Excludes Outside Values) title(Distribution of Duration by Interviewer-Respondent Urban/Rural Dyads)
graph save "Graph" "H:\rural_dyad_boxplot_noout.gph"
graph export "H:\rural_dyad_boxplot_noout.pdf", as(pdf) name("Graph")

***age match boxplots

graph hbox LENGTH, over( AGE_MATCH , relabel(1 "No Age Match" 2 "Age Match")) ylabel(#10) title(Distribution of Duration by Interviewer-Respondent Age Category Match)
graph save "Graph" "H:\age_match_boxplot.gph"
graph export "H:\age_match_boxplot.pdf", as(pdf) name("Graph")

graph hbox LENGTH, over( AGE_MATCH , relabel(1 "No Age Match" 2 "Age Match")) ylabel(#10) noout note(Excludes Outside Values) title(Distribution of Duration by Interviewer-Respondent Age Category Match)
graph save "Graph" "H:\age_match_boxplot_noout.gph"
graph export "H:\age_match_boxplot_noout.pdf", as(pdf) name("Graph")
save "H:\AB_dataset_final (1).dta", replace

***overall by round for each DV

graph hbox LENGTH , over( round_counter , relabel(1 "Round 7" 2 "Round 8" 3 "Round 9" 4 "Round 10")) ylabel(#10) title(Distribution of Duration by Round)
graph save "Graph" "H:\round_boxplot.gph"
graph export "H:\round_boxplot.pdf", as(pdf) name("Graph")

graph hbox LENGTH  , over(round_counter , relabel(1 "Round 7" 2 "Round 8" 3 "Round 9" 4 "Round 10")) ylabel(#10) noout note(Excludes Outside Values) title(Distribution of Duration by Round)
graph save "Graph" "H:\round_boxplot_noout.gph"
graph export "H:\round_boxplot_noout.pdf", as(pdf) name("Graph")

graph hbox duration_per_q_seconds , over( round_counter , relabel(1 "Round 7" 2 "Round 8" 3 "Round 9" 4 "Round 10")) ylabel(#10) title(Distribution of Duration per Question by Round)
graph save "Graph" "H:\round_q_boxplot.gph"
graph export "H:\round_q_boxplot.pdf", as(pdf) name("Graph")

graph hbox duration_per_q_seconds  , over(round_counter , relabel(1 "Round 7" 2 "Round 8" 3 "Round 9" 4 "Round 10")) ylabel(#10) noout note(Excludes Outside Values) title(Distribution of Duration per Question by Round)
graph save "Graph" "H:\round_q_boxplot_noout.gph"
graph export "H:\round_q_boxplot_noout.pdf", as(pdf) name("Graph")

