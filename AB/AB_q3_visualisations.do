***label all variables 

label var DUR1_10_R9 "Q1-Q10"
label var DUR11_19_R9 "Q11-Q19"
label var DUR20_29_R9 "Q20-Q29"
label var DUR30_39_R9 "Q30-Q39"
label var DUR40_49_R9 "Q40-Q49"
label var DUR50_59_R9 "Q50-Q59"
label var DUR60_69_R9 "Q60-Q69"
label var DUR70_79_R9 "Q70-Q79"
label var DUR80_89_R9 "Q80-Q89"
label var DUR90_99_R9 "Q90-Q99"

label var section_1_duration_per_q_seconds "Q1-Q10"
label var section_2_duration_per_q_seconds "Q11-Q19"
label var section_3_duration_per_q_seconds "Q20-Q29"
label var section_4_duration_per_q_seconds "Q30-Q39"
label var section_5_duration_per_q_seconds "Q40-Q49"
label var section_6_duration_per_q_seconds "Q50-Q59"
label var section_7_duration_per_q_seconds "Q60-Q69"
label var section_8_duration_per_q_seconds "Q70-Q79"
label var section_9_duration_per_q_seconds "Q80-Q89"
label var sect_10_duration_per_q_seconds "Q90-Q99"

label var mean_demo_weighted "Demographic"
label var mean_mc_weighted "Multiple Choice"
label var mean_scale_weighted "Scale"
label var mean_twos_weighted "Two Statement"
label var mean_yn_weighted "Yes/No"
label var mean_oe_weighted "Open-Ended"

***make bar graph for section duration 

catcibar DUR1_10_R9-DUR90_99_R9,  ylabel(0 2 4 6 8 10 12,nogrid)  ytitle("Section Duration (Mins)") xlabel(, nogrid labsize(vsmall)) color(%85 %85 %85 %85) note(Round 9 data only) mlabel(mean) mlabf(%7.2f)
graph save "Graph" "bar_section_duration.gph", replace
graph export "bar_section_duration.pdf", as(pdf) name("Graph") replace

catcibar s1_dur_perq_secs-s10_dur_perq_secs,  ylabel(0 5 10 15 20 25 30,nogrid)  ytitle("Section Duration per Question (Secs)") xlabel(, nogrid labsize(vsmall)) color(%85 %85 %85 %85) note(Round 9 data only) mlabel(mean) mlabf(%7.2f)
graph save "Graph" "bar_section_duration_question.gph" replace
graph export "bar_section_duration_question.pdf", as(pdf) name("Graph") replace

***make graphs for duration per section minutes

graph hbox DUR1_10_R9 - DUR90_99_R9, ytitle("Interview Duration (Mins)") yline(7) ylabel(,nogrid) ylabel(0 7 10 20 30 40)

***no outliers

graph hbox DUR1_10_R9 - DUR90_99_R9, ytitle("Interview Duration (Mins)") yline(7) ylabel(,nogrid) ylabel(0 5 7 10 15 20 25) noout note(Excludes Outliers)

*** box length x

graph save "Graph" "H:\box_duration_min.gph", replace
graph export "H:\box_`x'.pdf", as(pdf) name("Graph") replace

***box length x no outliers

graph save "Graph" "H:\box_`x'_noout.gph", replace
graph export "H:\box_`x'_noout.pdf", as(pdf) name("Graph") replace
***box duration_per_q_seconds x
graph hbox duration_per_q_seconds , ylabel(0 9.6 20 40 60 80 100) ytitle("Interview Duration per Question (Secs)") yline(9.634) ylabel(,nogrid)
graph save "Graph" "H:\box_`x'_questions.gph", replace
graph export "H:\box_`x'_questions.pdf", as(pdf) name("Graph") replace 
***box duration_per_q_seconds x no outliers
graph hbox duration_per_q_seconds ,  ylabel(5 10 15 20 25 30) ytitle("Interview Duration per Question (Secs)") yline(9.634) ylabel(,nogrid) noout note(Excludes Outliers)
graph save "Graph" "H:\box_`x'_questions_noout.gph", replace
graph export "H:\box_`x'_questions_noout.pdf", as(pdf) name("Graph") replace







