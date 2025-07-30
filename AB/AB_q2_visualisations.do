*** set font to AB preferred

graph set window fontface "Century Gothic"

*** make violin plots for all categorical vars with more than two values, also make boxplots without outliers to more clearly compare medians

***label all variable values to ensure graph axes have correct values

label define lpi 0 "No Lived Poverty" 1 "Low Lived Poverty" 2 "Moderate Lived Poverty" 3 "High Lived Poverty"
label values LivedPoverty_Cat lpi
tab LivedPoverty_Cat LivedPoverty_Cat

label define age 1 "18 to 25" 2 "26 to 35" 3 "36 to 45" 4 "46 to 55" 5 "56 to 65" 6 "Over 65"
label values AGE_RESP_CAT age
tab AGE_RESP_CAT

label define urban 0 "Rural-Rural" 1 "Urban-Urban" 2 "Urban-Rural" 3 "Rural-Urban"
label values rural_dyads_count urban
tab rural_dyads_count

label define urbanrural 1 "Rural-Rural" 2 "Urban-Urban" 3 "Urban-Rural" 4 "Rural-Urban"
label values rural_dyads_count urbanrural
tab rural_dyads_count

tab gender_dyad_count 
label define genderdyad 1 "Male-Male" 2 "Female-Female" 3 "Female-Male" 4 "Male-Female"
label values gender_dyad_count genderdyad
tab gender_dyad_count

tab  language_count
label define language 1 "English" 2 "French" 3 "Portuguese" 4 "Kiswahili" 5 "Arabic"
label values language_count language

***loop over variables to create all necessary graphs in one go

foreach x of varlist language_count gender_dyad_count rural_dyads_count AGE_RESP_CAT LivedPoverty_Cat RESP_EDUC EMPLOY_STAT  {
	*** violin length x 
vioplot LENGTH, over( `x' ) ytitle("Interview Duration (Mins)") xlabel(, nogrid) ylabel(0 45 100 200 300 400,nogrid) yline(45) den(col(dknavy))
graph save "Graph" "H:\violin_`x'.gph", replace
graph export "H:\violin_`x'.pdf", as(pdf) name("Graph") replace
***violin duration_per_q x
vioplot duration_per_q_seconds , over( `x' ) ytitle("Interview Duration per Question (Secs)")  xlabel(, nogrid) yline(9.634) den(col(dknavy)) ylabel(0 9.6 20 40 60 80 100,nogrid)
graph save "Graph" "H:\violin_`x'_question.gph", replace
graph export "H:\violin_`x'_question.pdf", as(pdf) name("Graph") replace
*** box length x
graph hbox LENGTH, over( `x' ) ylabel(0 45 100 200 300 400) ytitle("Interview Duration (Mins)") yline(45) ylabel(,nogrid)
graph save "Graph" "H:\box_`x'.gph", replace
graph export "H:\box_`x'.pdf", as(pdf) name("Graph") replace
***box length x no outliers
graph hbox LENGTH, over( `x') ylabel(0 45 50 100 150) ytitle("Interview Duration (Mins)") yline(45) ylabel(,nogrid) noout note(Excludes Outliers)
graph save "Graph" "H:\box_`x'_noout.gph", replace
graph export "H:\box_`x'_noout.pdf", as(pdf) name("Graph") replace
***box duration_per_q_seconds x
graph hbox duration_per_q_seconds , over( `x') ylabel(0 9.6 20 40 60 80 100) ytitle("Interview Duration per Question (Secs)") yline(9.634) ylabel(,nogrid)
graph save "Graph" "H:\box_`x'_questions.gph", replace
graph export "H:\box_`x'_questions.pdf", as(pdf) name("Graph") replace 
***box duration_per_q_seconds x no outliers
graph hbox duration_per_q_seconds , over( `x') ylabel(5 10 15 20 25 30) ytitle("Interview Duration per Question (Secs)") yline(9.634) ylabel(,nogrid) noout note(Excludes Outliers)
graph save "Graph" "H:\box_`x'_questions_noout.gph", replace
graph export "H:\box_`x'_questions_noout.pdf", as(pdf) name("Graph") replace
}


*** create graphs that plot mean interview duration against the number of questions asked

label var total_q "Total Questions"

***generate mean duration variables using R9 data only
egen m_duration_byq_byc = mean(LENGTH) if round_9 == 1, by(total_q countrycode)
egen m_duration_perq_byq_byc = mean( duration_per_q_seconds) if round_9==1, by(total_q countrycode)

*** find correlations with significance

pwcorr m_duration_byq_byc m_duration_perq_byq_byc total_q, sig

***create graph for overall length
twoway scatter m_duration_byq_byc total_q, mlabel(countrycode) mlabsize(tiny) mlabpos(6) || lfit m_duration_byq total_q, legend(off) xlabel(,nogrid) ylabel(,nogrid) ytitle(Mean Interview Duration (Mins)) note("Round 9 data only. Pearson Correlation Coefficient: 0.2355, P-value: 0.0000", size(vsmall) pos(8) ring(0))
graph save "Graph" "scatter_duration_total.gph", replace
graph export "scatter_duration_total.pdf", as(pdf) name("Graph") replace

***create graph for length per questions

twoway scatter m_duration_perq_byq_byc total_q, mlabel(countrycode) mlabsize(tiny) mlabpos(6) || lfit m_duration_perq_byq total_q, legend(off) xlabel(,nogrid) ylabel(,nogrid) ytitle(Mean Interview Duration Per Question (Secs)) note("Round 9 data only. Pearson Correlation Coefficient: 0.0569, P-value: 0.0000", size(vsmall) pos(8) ring(0))
graph save "Graph" "scatter_duration_question_total.gph", replace
graph export "scatter_duration_question_total.pdf", as(pdf) name("Graph") replace

***create bar graph for duration by language with error bars

catcibar LENGTH if round_9==1, over(language_count)  ylabel(0 20 40 60 80 100,nogrid)  ytitle("Interview Duration (Mins)") xtitle(Language) xlabel(none, nogrid) yline(45) color(%85 %85 %85 %85) note(Round 9 data only) mlabel(mean) mlabf(%7.2f)
graph save "Graph" "bar_languages.gph", replace
graph export "bar_languages.pdf", as(pdf) name("Graph") replace

catcibar duration_per_q_seconds if round_9==1, over(language_count)  ylabel(0 5 10 15 20,nogrid)  ytitle("Interview Duration per Question (Secs)") xtitle(Language) xlabel(none, nogrid) yline(9.643) color(%85 %85 %85 %85) note(Round 9 data only) mlabel(mean) mlabf(%7.2f)
graph save "Graph" "bar_languages_questions.gph", replace
graph export "bar_languages_questions.pdf", as(pdf) name("Graph") replace

***create bar graph for mean duration by all demographic variables together
label define rural 0 "Urbal" 1 "Rural"
label values RUR_DUM rural

graph bar LENGTH if round_9==1, over(FEMALE) horiz name(female) blabel(bar, format(%7.2f)) note(Round 9 data only) ylabel(,nogrid) ytitle("Mean Interview Duration(Mins)")

graph bar LENGTH if round_9==1, over(RUR_DUM) horiz name(rural) blabel(bar, format(%7.2f)) note(Round 9 data only) ylabel(,nogrid) ytitle("Mean Interview Duration(Mins)")

graph bar LENGTH if round_9==1, over(AGE_RESP_CAT) horiz name(age) blabel(bar, format(%7.2f)) note(Round 9 data only) ylabel(,nogrid) ytitle("Mean Interview Duration(Mins)")

graph bar LENGTH if round_9==1, over(LivedPoverty_Cat) horiz name(LPI) blabel(bar, format(%7.2f)) note(Round 9 data only) ylabel(,nogrid) ytitle("Mean Interview Duration(Mins)")

graph bar LENGTH if round_9==1, over(RESP_EDUC) horiz name(education) blabel(bar, format(%7.2f)) note(Round 9 data only) ylabel(,nogrid) ytitle("Mean Interview Duration(Mins)")

graph bar LENGTH if round_9==1, over(EMPLOY_STAT) horiz name(employment) blabel(bar, format(%7.2f)) note(Round 9 data only) ylabel(,nogrid) ytitle("Mean Interview Duration(Mins)")

graph bar LENGTH if round_9==1, horiz name(overall) blabel(bar, format(%7.2f)) note(Round 9 data only) ylabel(,nogrid) ytitle("Mean Interview Duration(Mins)")

graph combine female rural age LPI education employment overall, xcommon ycommon

***gender dyads plots 

label define match 0 "No Gender Match" 1 "Gender Match"
label values GENDER_MATCH match

label define afternoon 0 "Morning" 1 "Afternoon"
label values ENDTIME_HRS_DUM afternoon

label define match1 0 "No Age Match" 1 "Age Match"
label values AGE_MATCH match1

foreach x of varlist LivedPoverty_Cat GENDER_MATCH  ENDTIME_HRS_DUM AGE_MATCH{

*** box length x
graph hbox LENGTH, over( `x') ylabel(0 100 200 300 400) ytitle("Interview Duration (Mins)") ylabel(,nogrid)
graph save "Graph" "box_`x'.gph", replace
graph export "box_`x'.pdf", as(pdf) name("Graph") replace
graph export "box_`x'.jpg", as(jpg) name("Graph") quality(100) replace
***box length x no outliers
graph hbox LENGTH, over( `x') ylabel(0 50 100 150) ytitle("Interview Duration (Mins)") ylabel(,nogrid) noout note(Excludes Outliers)
graph save "Graph" "box_`x'_noout.gph", replace
graph export "box_`x'_noout.pdf", as(pdf) name("Graph") replace
graph export "box_`x'.jpg", as(jpg) name("Graph") quality(100) replace
***box duration_per_q_seconds x
graph hbox duration_per_q_seconds , over( `x') ylabel(0 20 40 60 80 100) ytitle("Interview Duration per Question (Secs)") ylabel(,nogrid)
graph save "Graph" "box_`x'_questions.gph", replace
graph export "box_`x'_questions.pdf", as(pdf) name("Graph") replace 
graph export "box_`x'.jpg", as(jpg) name("Graph") quality(100) replace
***box duration_per_q_seconds x no outliers
graph hbox duration_per_q_seconds , over( `x') ylabel(0 5 10 15 20 25 30) ytitle("Interview Duration per Question (Secs)") ylabel(,nogrid) noout note(Excludes Outliers)
graph save "Graph" "box_`x'_questions_noout.gph", replace
graph export "box_`x'_questions_noout.pdf", as(pdf) name("Graph") replace
graph export "box_`x'.jpg", as(jpg) name("Graph") quality(100) replace
}












