clear


***set file path globals

local project MN
include "$HELPER/pathnames.do"


***set locals to govern running code sections

local word_count		1
local duration_round	1
local cleveland			1
local difference		1	
local questions			1
local language			1
local dyads				1
local endtime			1
local sections			1


***bring in dataset

use "$MNDATA/AB_dataset_final",clear

tempfile data
save `data'

*** set font to AB preferred

graph set window fontface "Century Gothic"

if `word_count'==1{
	
	
	***generate variable with only languages that have more that 50 observations
	
	gen language_sample=""
	
	***clean language variable to ensure local is saved correctly
	
	gen language_sieve=language
	ereplace language_sieve=sieve(language_sieve), omit( /)
	
	***insert languages with over 50 observations into new variable
	
	levelsof language_sieve, local(languages)
	
	foreach x of local languages{
	
		count if language_sieve=="`x'"
		replace language_sample=language if `r(N)'>50 & language_sieve=="`x'"
	
	}

	*** duration per word by language bar graph

	graph hbar LENGTH, over(language_sample, sort(1) descending label(ang(h) labsize(*0.3))) yline(45) ylabel(,nogrid) ///
	ytitle("Interview Duration (Mins)") name("length",replace) inten(*0.85) linten(*0.85)

	graph export "$MNFIG/bar_language.jpg", as(jpg) quality(100)replace

	*** graph duration per word over languages

	graph hbar duration_per_word_seconds, over(language_sample, sort(1) descending label(ang(h) labsize(*0.3))) yline(0.333) ///
	ylabel(,nogrid)  ytitle("Interview Duration per Word (Secs)") nofill name("word",replace) inten(*0.85) linten(*0.85)

	graph export "$MNFIG/bar_language_word.jpg", as(jpg) quality(100) replace


	
}


if `duration_round'==1{

***label round counter variable for graph axis labels

	label define round_1 0 "Round 7 (16/18)" 1 "Round 8 (19/21)" 2 "Round 9 (21/23)" 3 "Round 10 (24)"
	label define round_2 0 "16/18" 1 "19/21" 2 "21/23" 3 "24"

***graph mean duration by survey round with CIs

	local durations LENGTH duration_per_q_seconds
	
	foreach x of local durations{

		preserve
		
			statsby mean_duration=r(mean) upper=r(ub) lower=r(lb), by(round_counter) clear : ci mean `x'

			label define round_2 0 "16/18" 1 "19/21" 2 "21/23" 3 "24"
			label values round_counter round_2

			if "`x'"=="LENGTH"{
				twoway (bar mean_duration round_counter, barwidth(0.5) color(%85 %85 %85 %85)) ///
					   (rcap lower upper round_counter) ///
					   (scatter mean_duration round_counter, msymbol(none) mlabel(mean_duration) mlabposition(12) mlabformat(%7.1f)) ///
					   ,legend(off) ytitle("Interview Duration (Mins)") xtitle("Survey Rounds") ylabel(0 20 40 60 80 100,nogrid) ///
					   xlabel(,nogrid valuelabel) yline(45) note(All available countries used) name(`x',replace)
			}

			if "`x'"=="duration_per_q_seconds"{
				twoway (bar mean_duration round_counter, barwidth(0.5) color(%85 %85 %85 %85)) ///
					   (rcap lower upper round_counter) ///
					   (scatter mean_duration round_counter, msymbol(none) mlabel(mean_duration) mlabposition(12) mlabformat(%7.1f)) ///
					   ,legend(off) ytitle("Average Question Duration (Secs)") xtitle("Survey Rounds") ylabel(0 5 10 15 20,nogrid) ///
					   xlabel(,nogrid valuelabel) yline(45) note(All available countries used) name(`x',replace)
			}

			graph export "$MNFIG/bar_round_duration_`x'.jpg", as(jpg) name("`x'") quality(100) replace

		restore



	}

***boxplot of duration across rounds with outliers and min/max value labels

graph hbox LENGTH, over(round_counter) ylabel(0 45 100 200 300 400) ytitle("Interview Duration (Mins)") yline(45) ylabel(,nogrid)

graph export "$MNFIG/box_round_duration.jpg", as(jpg) name("Graph") quality(100) replace


}


if `cleveland'==1{

	*** Cleveland plot of country/round mean durations

	preserve 
	
		collapse LENGTH duration_per_q_seconds, by (round_counter country_count) 

		label define countries 0 "BFO" 1 "BEN" 2 "BOT" 3 "CAM" 4 "CDI" 5 "CVE" 6 "ESW"  7 "GAB" 8 "GAM" ///
		9 "GHA" 10 "GUI" 11 "KEN" 12 "LES" 13 "LIB" 14 "MAD" 15 "MAU" 16 "MLI" 17 "MLW" 18 "MOR" 19 "MOZ" ///
		20 "NAM" 21 "NGR" 22 "NIG" 23 "SAF" 24 "SEN" 25 "SRL" 26 "STP" 27 "SUD" 28 "TAN" 29 "TOG" 30 "TUN" ///
		31 "UGA" 32 "ZAM" 33 "ZIM" 34 "ANG" 35 "ETH" 36 "CBZ" 37 "MTA" 38 "SEY"

		label values country_count countries
		
		label values round_counter round_1
		
		***order by R9 mean
		
		tempfile country_round
		save `country_round'
		
		drop if round_counter!=2
		egen order = rank(LENGTH)
		
		tempfile order
		save `order'
		
		use `country_round'
		merge m:1 country_count using `order', assert(3) nogen
		
		sort order
		
		label define order 1 "TUN" 2 "SUD" 3 "ESW" 4 "SEY" 5 "MTA" 6 "LIB" 7 "MOR" 8 "BOT" 9 "GAM" ///
		10 "NIG" 11 "CVE" 12 "NAM" 13 "MAU" 14 "GHA" 15 "SAF" 16 "TAN" 17 "ETH" 18 "CBZ" 19 "NGR" ///
		20 "STP" 21 "ZIM" 22 "MAD" 23 "SRL" 24 "BFO" 25 "ANG" 26 "LES" 27 "MLI" 28 "MLW" 29 "GUI" ///
		30 "GAB" 31 "ZAM" 32 "KEN" 33 "UGA" 34 "CDI" 35 "CAM" 36 "BEN" 37 "SEN" 38 "TOG" 39 "MOZ"

		label values order order
		
		twoway (dot LENGTH order if round_counter == 0, sort msym(o) vert xlab(#39, labels valuelabel nogrid labsize(vsmall) ///
		angle(vert)) dc(%20) dfc(%20) ytitle("") xlabel(,nogrid) ylabel(,nogrid) dotextend(no)) ///
		(dot LENGTH order if round_counter == 1, msym(t) vert dotextend(no) dc(%20) dfc(%20)) ///
		(dot LENGTH order if round_counter == 2, msym(s) vert xtitle("Mean Interview Duration(Mins)") dotextend(no) dc(%20) dfc(%20)) ///
		(dot LENGTH order if round_counter == 3, msym(d) vert ///
		leg(order(1 "Round 7 (16/18)" 2 "Round 8 (19/21)" 3 "Round 9 (21/23)" 4 "Round 10 (24)") position(6) rows(1)) dotextend(no) dc(%20) dfc(%20))
		

		graph export "$MNFIG/cleveland_country_round.jpg", as(jpg) name("Graph") quality(100) replace

	restore 
	
}


if `difference'==1{

	***create graph of R7 to R9 differences

	local durations LENGTH duration_per_q_seconds
	
	foreach var of local durations{
	
	preserve

		collapse `var', by(round_counter country_count)

		***bring R7 and R9 means into the same observations over different variables
		
		gen r7_mean =.
		replace r7_mean=`var' if round_counter==0
		gen r9_mean =.
		replace r9_mean=`var' if round_counter==2
		drop if round_counter==1 | round_counter==3
		duplicates tag country_count, gen(dup)
		tab dup
		drop if dup==0
		drop dup

		local i = 1

		local n = 35

		foreach x in country_count {
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
			replace r9_mean = r9_mean[`n'] in `i' if country_count==`x' 
			local i = `i' +1
			local n = `n' +1
	
		} 
	

		label define countries_l 0 "Burkina Faso" 1 "Benin" 2 "Botswana" 3 "Cameroon" 4 "Cote d'Ivoire" ///
		5 "Cabo Verde" 6 "Eswatini"  7 "Gabon" 8 "Gambia" 9 "Ghana" 10 "Guinea" 11 "Kenya" 12 "Lesotho" ///
		13 "Liberia" 14 "Madagascar" 15 "Mauritius" 16 "Mali" 17 "Malawi" 18 "Morocco" 19 "Mozambique" ///
		20 "Namibia" 21 "Niger" 22 "Nigeria" 23 "South Africa" 24 "Senegal" 25 "Sierra Leone" 26 "Sao Tome" ///
		27 "Sudan" 28 "Tanazania" 29 "Togo" 30 "Tunisia" 31 "Uganda" 32 "Zambia" 33 "Zimbabwe" 34 "Angola" ///
		35 "Ethiopia" 36 "Congo-Brazzaville" 37 "Mauritania" 38 "Seychelles"

		label values country_count countries_l

		gen diff=r9_mean-r7_mean
		
		
		if "`var'"=="LENGTH"{
		graph bar diff, over(country_count, sort(1) label(labsize(vsmall))) horiz ylabel(,nogrid) ///
		ytitle("Difference between Round 7 and Round 9 Duration (Mins)") sort(diff) yline(0) blab(bar, size(vsmall) format(%7.1f) pos(out)) name("`x'", replace)
		}
		
		if "`var'"=="duration_per_q_seconds"{
		graph bar diff, over(country_count, sort(1) label(labsize(vsmall))) horiz ylabel(,nogrid) ///
		ytitle("Difference between Round 7 and Round 9 Question Duration (Secs)") sort(diff) yline(0) blab(bar, size(vsmall) format(%7.1f) pos(out)) name("`x'", replace)
		}
		
		graph export "$MNFIG/bar_country_difference_`var'.jpg", as(jpg) name("Graph") quality(100) replace

	restore

	}
}


if `questions'==1{

	*** create graphs that plot mean interview duration against the number of questions asked

	preserve

		collapse LENGTH duration_per_q_seconds total_q, by(round_counter country_count)

		label var total_q "Total Questions"
	
		label values country_count countries

		drop if round_counter !=2

		pwcorr LENGTH duration_per_q_seconds total_q, sig star(0.1)


		twoway scatter LENGTH total_q, mlabel(country_count) mlabsize(tiny) mlabpos(6) ///
		|| lfit LENGTH total_q, ///
		legend(off) xlabel(,nogrid) ylabel(,nogrid) ytitle(Mean Interview Duration (Mins)) ///
		note("Round 9 data only. Pearson Correlation Coefficient: 0.2566, P-value: 0.1148", size(vsmall) pos(8) ring(0))
		
		graph export "$MNFIG/scatter_duration_total.pdf", as(pdf) name("Graph") replace

		twoway scatter duration_per_q_seconds total_q, mlabel(country_count) mlabsize(tiny) mlabpos(6) ///
		|| lfit duration_per_q_seconds total_q, legend(off) xlabel(,nogrid) ylabel(,nogrid) ///
		ytitle(Mean Interview Duration Per Question (Secs)) note("Round 9 data only. Pearson Correlation Coefficient: 0.0918, P-value: 0.5782" ///
		, size(vsmall) pos(8) ring(0))

		graph export "$MNFIG/scatter_duration_question_total.pdf", as(pdf) name("Graph") replace

	restore

}


if `language'==1{

	***create bar graph for duration by language with error bars

	foreach x of varlist LENGTH wordcount duration_per_word_seconds{

		preserve

			statsby mean_`x'=r(mean) upper=r(ub) lower=r(lb), by(language_count round_9) clear : ci mean `x'
			
			drop if round_9==0

			label define languages 1 "English" 2 "French" 3 "Portuguese" 4 "Kiswahili" 5 "Arabic"
			label values language_count language


			if "`x'"=="LENGTH"{
				twoway (bar mean_`x' language_count, barwidth(0.5) color(%85 %85 %85 %85)) ///
				(rcap lower upper language_count) ///
				(scatter mean_`x' language_count,msymbol(none) mlabel(mean_`x') mlabposition(12) mlabformat(%7.1f)) ///
				,legend(off) ytitle("Interview Duration (Mins)") xtitle("Languages") ylabel(0 20 40 60 80 100,nogrid) ///
				xlabel(,nogrid valuelabel) yline(45) note(Round 9 data only)
			}

			if "`x'"=="wordcount"{
				twoway (bar mean_`x' language_count, barwidth(0.5) color(%85 %85 %85 %85)) ///
				(rcap lower upper language_count) ///
				(scatter mean_`x' language_count, msymbol(none) mlabel(mean_`x') mlabposition(12) mlabformat(%7.1f)) ///
				,legend(off) ytitle("Average Word Count") xtitle("Languages") ylabel(0 2000 4000 6000 8000 10000,nogrid) ///
				xlabel(,nogrid valuelabel) note(Round 9 data only)
			}

			if "`x'"=="duration_per_word_seconds"{
				twoway (bar mean_`x' language_count, barwidth(0.5) color(%85 %85 %85 %85)) ///
				(rcap lower upper language_count) ///
				(scatter mean_`x' language_count, msymbol(none) mlabel(mean_`x') mlabposition(12) mlabformat(%7.1f)) ///
				,legend(off) ytitle("Average Word Duration (Secs)") xtitle("Languages") ylabel(0 0.2 0.4 0.6 0.8,nogrid) ///
				xlabel(,nogrid valuelabel) note(Round 9 data only)
			}

			graph export "$MNFIG/bar_languages_`x'.jpg", as(jpg) quality(100) name("Graph") replace

		restore


	}

	***native language plots

	gen respondent_native = NATIVE_DUM
	gen interviewer_native = 0
	replace interviewer_native = 1 if INTERVIEWER_LANG_HOME== INTERVIEW_LANG
	gen fluency_match = 0
	replace fluency_match = 1 if respondent_native==interviewer_native

	preserve

		collapse LENGTH, by(interviewer_native respondent_native fluency_match round_9)

		drop if round_9==0
		drop round_9

		egen interviewer_mean = mean(LENGTH), by(interviewer_native)
		egen respondent_mean = mean(LENGTH), by(respondent_native)
		egen fluency_mean = mean(LENGTH), by(fluency_match)

		labvars interviewer_mean respondent_mean fluency_mean "Interviewer Native" "Respondent Native" "Fluency Match"

		twoway (scatter interviewer_mean interviewer_native, connect(l) mlabel(interviewer_mean) mlabposition(6) mlabformat(%7.1f)) ///
		(scatter respondent_mean respondent_native, connect(l) mlabel(respondent_mean) mlabposition(12) mlabformat(%7.1f)) ///
		(scatter fluency_mean fluency_match, connect(l) mlabel(fluency_mean) mlabposition(3) mlabformat(%7.1f)) ///
		, ylabel(,nogrid) ytitle("Interview Duration (Mins)") xlabel(0 1,nogrid) xtitle("") xlabel(0 "No" 1 "Yes") note(Round 9 data only)

		graph export "$MNFIG/scatter_fluency.jpg", as(jpg) quality(100) name("Graph") replace

	restore

}


if `dyads'==1{
	
	***gender dyad plot

	label define gendermatch 0 "No Gender Match" 1 "Gender Match"
	label values GENDER_MATCH gendermatch

	preserve

		collapse LENGTH, by(GENDER_MATCH mm_dyad ff_dyad mf_dyad fm_dyad round_9)

		drop if round_9==0
		drop round_9

		egen match_mean = mean(LENGTH), by(GENDER_MATCH)
		egen mm_mean = mean(LENGTH), by(mm_dyad)
		egen ff_mean = mean(LENGTH), by(ff_dyad)
		egen mf_mean = mean(LENGTH), by(mf_dyad)
		egen fm_mean = mean(LENGTH), by(fm_dyad)

		labvars match_mean mm_mean ff_mean mf_mean fm_mean "Gender Match" "Male-Male" "Female-Female" "Male-Female" "Female-Male"

		twoway (scatter match_mean GENDER_MATCH, connect(l) mlabel(match_mean) mlabposition(12) mlabformat(%7.1f)) ///
		(scatter mm_mean mm_dyad, connect(l) mlabel(mm_mean) mlabposition(6) mlabformat(%7.1f)) ///
		(scatter ff_mean ff_dyad, connect(l) mlabel(ff_mean) mlabposition(6) mlabformat(%7.1f)) ///
		(scatter mf_mean mf_dyad, connect(l) mlabel(mf_mean) mlabposition(3) mlabformat(%7.1f)) ///
		(scatter fm_mean fm_dyad, connect(l) mlabel(fm_mean) mlabposition(12) mlabformat(%7.1f)) ///
		, ylabel(,nogrid) ytitle("Interview Duration (Mins)") xlabel(0 "No" 1 "Yes", val nogrid) xtitle("") note(Round 9 data only)


		graph export "$MNFIG/scatter_genderdyad.jpg", as(jpg) quality(100) name("Graph") replace

	restore

	***define age dyads variable

	gen young_match = 0
	replace young_match = 1 if AGE_RESP_CAT==1 & AGE_INTW_CAT==1

	gen young_old=0
	replace young_old=1 if AGE_RESP_CAT==6 & AGE_INTW_CAT==1

	gen age_dyads = 0
	replace age_dyads = 1 if AGE_MATCH==1
	replace age_dyads = 2 if young_match==1
	replace age_dyads = 3 if young_old==1 /// defined a further variable that counts dyads to allow for graphing

	label define agedyad 0 "No Age Match" 1 "Age Match" 2 "Young Match" 3 "Young-Old"
	label values age_dyads agedyad
	tab age_dyads

	***age dyads language plots

	preserve

		collapse LENGTH, by(AGE_MATCH young_match young_old round_9)
		
		drop if round_9==0
		drop round_9

		egen match_mean = mean(LENGTH), by(AGE_MATCH)
		egen yy_mean = mean(LENGTH), by(young_match)
		egen yo_mean = mean(LENGTH), by(young_old)

		labvars match_mean yy_mean yo_mean "Age Match" "Young-Young" "Young-Old"

		twoway (scatter match_mean AGE_MATCH, connect(l) mlabel(match_mean) mlabposition(6) mlabformat(%7.1f)) ///
		(scatter yy_mean young_match, connect(l) mlabel(yy_mean) mlabposition(1) mlabformat(%7.1f)) ///
		(scatter yo_mean young_old, connect(l) mlabel(yo_mean) mlabposition(12) mlabformat(%7.1f)) ///
		, ylabel(,nogrid) ytitle("Interview Duration (Mins)") xlabel(0 1,nogrid) xtitle("") xlabel(0 "No" 1 "Yes") note(Round 9 data only)

		graph export "$MNFIG/scatter_age.jpg", as(jpg) quality(100) name("Graph") replace

	restore

}


if `endtime'==1{

	***endtime plot

	preserve

		collapse LENGTH, by(ENDTIME_HRS_DUM round_9)
		
		drop if round_9==0
		drop round_9

		label define endtime 0 "Morning" 1 "Afternoon"
		label values ENDTIME_HRS_DUM endtime

		label var LENGTH "Afternoon Endtime"

		twoway (scatter LENGTH ENDTIME_HRS_DUM, connect(l) mlabel(LENGTH) mlabposition(3) mlabformat(%7.1f)) ///
		, ylabel(,nogrid) ytitle("Interview Duration (Mins)") xlabel(0 1,nogrid) xtitle("") xlabel(0 "No" 1 "Yes") note(Round 9 data only) legend(on)

		graph export "$MNFIG/scatter_endtime.jpg", as(jpg) quality(100) name("Graph") replace

	restore

}


if `sections'==1{

	***label all section/question-type duration variables 

	label var DUR1_10_R9 "Q1-Q10"
	label var DUR11_19_R9 "Q11-Q20"
	label var DUR20_29_R9 "Q21-Q30"
	label var DUR30_39_R9 "Q31-Q40"
	label var DUR40_49_R9 "Q41-Q50"
	label var DUR50_59_R9 "Q51-Q60"
	label var DUR60_69_R9 "Q61-Q70"
	label var DUR70_79_R9 "Q71-Q80"
	label var DUR80_89_R9 "Q81-Q90"
	label var DUR90_99_R9 "Q91-Q99"

	label var s1_dur_perq_secs "Q1-Q10"
	label var s2_dur_perq_secs "Q11-Q20"
	label var s3_dur_perq_secs "Q21-Q30"
	label var s4_dur_perq_secs "Q31-Q40"
	label var s5_dur_perq_secs "Q41-Q50"
	label var s6_dur_perq_secs "Q51-Q60"
	label var s7_dur_perq_secs "Q61-Q70"
	label var s8_dur_perq_secs "Q71-Q80"
	label var s9_dur_perq_secs "Q81-Q90"
	label var s10_dur_perq_secs "Q91-Q99"



	***make bar graph for section duration 
	
	catcibar DUR1_10_R9-DUR90_99_R9 ///
	,  ylabel(0 2 4 6 8 10 12,nogrid)  ytitle("Section Duration (Mins)") xlabel(, nogrid labsize(vsmall)) ///
	color(%85 %85 %85 %85) note(	Round 9data only) mlabel(mean) mlabf(%7.1f) mlabc(green*0.7)

	graph export "$MNFIG/bar_section_duration.jpg", as(jpg) quality(100) name("Graph") replace

	catcibar s1_dur_perq_secs-s10_dur_perq_secs ///
	,  ylabel(0 5 10 15 20 25 30,nogrid)  ytitle("Section Duration per Question (Secs)") ///
	xlabel(, nogrid labsize(vsmall)) color(%85 %85 %85 %85) note(Round 9 data only) mlabel(mean) mlabf(%7.1f) mlabc(green*0.7)

	graph export "$MNFIG/bar_section_duration_question.jpg", as(jpg) quality(100) name("Graph") replace

}
