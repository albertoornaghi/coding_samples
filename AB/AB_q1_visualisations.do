*** set font to AB preferred

graph set window fontface "Century Gothic"

***label round counter variable for graph axis labels

tab round_counter

label define round_1 0 "Round 7 (2016/2018)" 1 "Round 8 (2019/2021)" 2 "Round 9 (2021/2023)" 3 "Round 10 (2024/2025)"
label values round_counter round_1
tab round_counter



foreach x of varlist round_counter  {
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

foreach x of varlist countrycode  {

*** box length x
graph hbox LENGTH, over( `x' , label(labsize(*0.6))) ylabel(0 45 100 200 300 400) ytitle("Interview Duration (Mins)") yline(45) ylabel(,nogrid)
graph save "Graph" "H:\box_`x'.gph", replace
graph export "H:\box_`x'.pdf", as(pdf) name("Graph") replace
***box length x no outliers
graph hbox LENGTH, over( `x', label(labsize(*0.6))) ylabel(0 45 50 100 150) ytitle("Interview Duration (Mins)") yline(45) ylabel(,nogrid) noout note(Excludes Outliers)
graph save "Graph" "H:\box_`x'_noout.gph", replace
graph export "H:\box_`x'_noout.pdf", as(pdf) name("Graph") replace
***box duration_per_q_seconds x
graph hbox duration_per_q_seconds , over( `x', label(labsize(*0.6))) ylabel(0 9.6 20 40 60 80 100) ytitle("Interview Duration per Question (Secs)") yline(9.634) ylabel(,nogrid)
graph save "Graph" "H:\box_`x'_questions.gph", replace
graph export "H:\box_`x'_questions.pdf", as(pdf) name("Graph") replace 
***box duration_per_q_seconds x no outliers
graph hbox duration_per_q_seconds , over( `x', label(labsize(*0.6))) ylabel(5 10 15 20 25 30) ytitle("Interview Duration per Question (Secs)") yline(9.634) ylabel(,nogrid) noout note(Excludes Outliers)
graph save "Graph" "H:\box_`x'_questions_noout.gph", replace
graph export "H:\box_`x'_questions_noout.pdf", as(pdf) name("Graph") replace
}


***graph round means by countrycode

foreach x of varlist round_counter  {

*** box length x
graph hbox LENGTH, over( `x' ) by(countrycode, note(" ")) ylabel(0 100 200 300 400) ytitle("Interview Duration (Mins)") yline(45) ylabel(,nogrid)
graph save "Graph" "H:\box_`x'_country.gph", replace
graph export "H:\box_`x'_country.pdf", as(pdf) name("Graph") replace
***box length x no outliers
graph hbox LENGTH, over( `x') by(countrycode, note(" ")) ylabel(0 50 100 150) ytitle("Interview Duration (Mins)") yline(45) ylabel(,nogrid) noout note(Excludes Outliers)
graph save "Graph" "H:\box_`x'_country_noout.gph", replace
graph export "H:\box_`x'_country_noout.pdf", as(pdf) name("Graph") replace
***box duration_per_q_seconds x
graph hbox duration_per_q_seconds , over( `x') by(countrycode, note(" ")) ylabel(0 20 40 60 80 100) ytitle("Interview Duration per Question (Secs)") yline(9.634) ylabel(,nogrid)
graph save "Graph" "H:\box_`x'_country_questions.gph", replace
graph export "H:\box_`x'_country_questions.pdf", as(pdf) name("Graph") replace 
***box duration_per_q_seconds x no outliers
graph hbox duration_per_q_seconds , over( `x') by(countrycode, note(" ")) ylabel(5 10 15 20 25 30) ytitle("Interview Duration per Question (Secs)") yline(9.634) ylabel(,nogrid) noout note(Excludes Outliers)
graph save "Graph" "H:\box_`x'_country_questions_noout.gph", replace
graph export "H:\box_`x'_country_questions_noout.pdf", as(pdf) name("Graph") replace
}


*** duration per word by language bar graph

graph bar LENGTH, over(language, sort(1) descending label(ang(v) labsize(*0.4))) yline(45)  ylabel(,nogrid)  ytitle("Interview Duration (Mins)")
graph save "Graph" "H:\bar_language.gph"
graph export "H:\bar_language.pdf", as(pdf) name("Graph")

graph bar duration_per_q_seconds, over(language, sort(1) descending label(ang(v) labsize(*0.4))) yline(9.634)  ylabel(,nogrid)  ytitle("Interview Duration per Question (Secs)")
graph save "Graph" "H:\bar_language_question.gph"
graph export "H:\bar_language_question.pdf", as(pdf) name("Graph")

***deriving reccomened duration per word 

egen mean_words = mean(wordcount)
tab mean_words

*** graph duration per word over languages

graph bar duration_per_word_seconds, over(language, sort(1) descending label(ang(v) labsize(*0.4))) yline(0.333)  ylabel(,nogrid)  ytitle("Interview Duration per Word (Secs)") nofill
graph save "Graph" "H:\bar_language_word.gph"
graph export "H:\bar_language_word.pdf", as(pdf) name("Graph")

***graph mean duration by survey round with CIs

catcibar LENGTH, over(round_counter)  ylabel(0 20 40 60 80 100,nogrid)  ytitle("Interview Duration (Mins)") xtitle(Survey Rounds) xlabel(none, nogrid) yline(45) color(%85 %85 %85 %85) note(All available countries used) mlabel(mean) mlabf(%7.2f)
graph save "Graph" "bar_round.gph", replace
graph export "bar_round.pdf", as(pdf) name("Graph") replace

catcibar duration_per_q_seconds, over(round_counter)  ylabel(0 5 10 15 20,nogrid)  ytitle("Interview Duration per Question (Secs)") xlabel(none, nogrid) yline(9.634) color(%85 %85 %85 %85) note(All available countries used) mlabel(mean) mlabf(%7.2f)
graph save "Graph" "bar_round_questions.gph", replace
graph export "bar_round_questions.pdf", as(pdf) name("Graph") replace

*** Cleveland plot of country/round mean durations

preserve 
collapse LENGTH duration_per_q_seconds, by (round_counter country_count) /// collapses dataset to keep only those variables, preserve ensures the original dataset is kept

label define countries 0 "BFO" 1 "BEN" 2 "BOT" 3 "CAM" 4 "CDI" 5 "CVE" 6 "ESW"  7 "GAB" 8 "GAM" 9 "GHA" 10 "GUI" 11 "KEN" 12 "LES" 13 "LIB" 14 "MAD" 15 "MAU" 16 "MLI" 17 "MLW" 18 "MOR" 19 "MOZ" 20 "NAM" 21 "NGR" 22 "NIG" 23 "SAF" 24 "SEN" 25 "SRL" 26 "STP" 27 "SUD" 28 "TAN" 29 "TOG" 30 "TUN" 31 "UGA" 32 "ZAM" 33 "ZIM" 34 "ANG" 35 "ETH" 36 "CBZ" 37 "MTA" 38 "SEY"
label values country_count countries

twoway (dot LENGTH country_count if round_counter == 0, msym(o) horiz ylab(#39, labels valuelabel nogrid labsize(vsmall)) ytitle("") xlabel(,nogrid)) (dot LENGTH country_count if round_counter == 1, msym(t) horiz) (dot LENGTH country_count if round_counter == 2, msym(s) horiz xtitle("Mean Interview Duration(Mins)")) (dot LENGTH country_count if round_counter == 3, msym(d) horiz leg(order( 1 "Round 7 (16/18)" 2 "Round 8 (19/21)" 3 "Round 9 (21/23)" 4 "Round 10 (24/25)") position(6) rows(1)))
graph save "Graph" "cleveland_country_round.gph"
graph export "cleveland_country_round.pdf", as(pdf) name("Graph")

twoway (dot duration_per_q_seconds country_count if round_counter == 0, msym(o) horiz ylab(#39, labels valuelabel nogrid labsize(vsmall)) ytitle("") xlabel(,nogrid)) (dot duration_per_q_seconds country_count if round_counter == 1, msym(t) horiz) (dot duration_per_q_seconds country_count if round_counter == 2, msym(s) horiz xtitle("Mean Interview Duration per Question (Secs)")) (dot duration_per_q_seconds country_count if round_counter == 3, msym(d) horiz leg(order( 1 "Round 7 (16/18)" 2 "Round 8 (19/21)" 3 "Round 9 (21/23)" 4 "Round 10 (24/25)") position(6) rows(1)))
graph save "Graph" "cleveland_country_round_questions.gph"
graph export "cleveland_country_round_questions.pdf", as(pdf) name("Graph")

restore 
