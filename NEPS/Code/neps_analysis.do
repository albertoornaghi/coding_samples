clear 
clear matrix
clear mata
set maxvar 15000

*** set file path globals


global HELPER "/Users/albertoornaghi/Documents/GitHub/coding_samples/Helper"

local project "NEPS"
include "$HELPER/pathnames.do"

***set locals to govern running code

local summary			1
local ols				1
local panel				1
local qr				1
local mdqr				1


***load data
 
use "$DATA/neps_clean.dta"

tempfile data
save `data'






if `summary'==1{

	***sample summary table

	gen sample_size = time1+time2+time3
	label var sample_size "Full Sample"

	table () (result), stat(total time1 time2 time3 sample_size) stat(mean time1 time2 time3 sample_size) nformat(%7.2g)
	
	local table sample
	include "$HELPER/table_formatting"

	collect export "$TAB/neps_sample.tex", as(tex) replace

	***outcome variable std percentiles summary

	labvars std_score std_score_g*  "Maths Attainment (Std)" "Grade 5 (Std)" "Grade 7 (Std)" "Grade 9 (Std)"
	
	table (result) (), stat(p1 std_score std_score_g5 std_score_g7 std_score_g9) ///
	stat(p5 std_score std_score_g5 std_score_g7 std_score_g9) stat(p10 ///
	std_score std_score_g5 std_score_g7 std_score_g9) stat(p25 std_score ///
	std_score_g5 std_score_g7 std_score_g9) stat(p75 std_score std_score_g5 ///
	std_score_g7 std_score_g9) stat(p90 std_score std_score_g5 std_score_g7 ///
	std_score_g9) stat(p95 std_score std_score_g5 std_score_g7 std_score_g9) ///
	stat(p99 std_score std_score_g5 std_score_g7 std_score_g9) stat(med ///
	std_score std_score_g5 std_score_g7 std_score_g9) stat(mean std_score ///
	std_score_g5 std_score_g7 std_score_g9) stat(sd std_score std_score_g5 ///
	std_score_g7 std_score_g9)
	
	collect style cell, nformat(%7.2f)
	collect style cell, border( all, width(0.5) pattern(single))
	collect style cell, halign(left) valign(center)
	
	collect export "$TAB/neps_score_perc.tex", as(tex) replace
	
	***outcome variable non-std percentiles summary
	
	replace prop_g5 =. if wave !=1
	replace prop_g7 =. if wave !=3
	replace prop_g9 =. if wave !=5 
	
	egen prop = rowtotal (prop_g*), miss
	
	foreach x of varlist prop*{
		
		gen `x'_perc = `x'*100
		
	}
	
	labvars prop_perc prop_g*_perc "Maths Attainment (%)" "Grade 5 (%)" "Grade 7 (%)" "Grade 9 (%)"
	
	table (result) (), stat(p1 prop_perc prop_g*_perc) stat(p5 prop_perc prop_g*_perc) ///
	stat(p10 prop_perc prop_g*_perc) stat(p25 prop_perc prop_g*_perc) stat(p75 prop_perc prop_g*_perc) ///
	stat(p90 prop_perc prop_g*_perc) stat(p95 prop_perc prop_g*_perc) ///
	stat(p99 prop_perc prop_g*_perc) stat(med prop_perc prop_g*_perc) ///
	stat(mean prop_perc prop_g*_perc) stat(sd prop_perc prop_g*_perc)
	
	collect style cell, nformat(%7.2f)
	collect style cell, border( all, width(0.5) pattern(single))
	collect style cell, halign(left) valign(center)
	
	collect export "$TAB/neps_score_perc_ns.tex", as(tex) replace
	
	
	***class_size and class_size_imp table_formatting
	
	label define class_size 1 "Below 10" 2 "10 to 14" 3 "15 to 19" ///
	4 "20 to 24" 5 "25 to 29" 6 "29 to 34" 7 "35 and more"
	
	label values class_size class_size
	label values class_size_imp class_size
	
	labvars class_size class_size_imp "Class size" "Class size imputed"
	
	tab class_size, gen(size)
	tab class_size_imp, gen(size_imp)
	
	foreach x of var size* { 
		local lbl : var label `x' 
		local lbl : subinstr local lbl "class_size==" "", all
		local lbl : subinstr local lbl "class_size_imp==" "", all
		label var `x' "`lbl'" 
	} 
	
	table () (result), stat(median class_size) stat(total size1 size2 size3 size4 size5 size6 size7) ///
	stat(mean size1 size2 size3 size4 size5 size6 size7) nformat(%7.2g)
	
	local table total_prop
	include "$HELPER/table_formatting"

	collect export "$TAB/neps_size.tex", as(tex) replace
	
	table () (result), stat(median class_size_imp) stat(total size_imp*) stat(mean size_imp*) nformat(%7.2g)
	
	local table total_prop
	include "$HELPER/table_formatting"

	collect export "$TAB/neps_size_imp.tex", as(tex) replace
	
	
	***summarise most important control variables - student level
	
	//make dummies
	
	replace t_gender = 0 if t_gender==2
	rename t_gender male
	
	replace residence_ew = 0 if residence_ew==2
	rename residence_ew west_germany
	
	replace t_sen = t_sen - 1
	rename t_sen special_needs
	
	replace t_repeated = t_repeated - 1
	rename t_repeated repeated_grade

	replace t_mt = t_mt + 1
	replace t_mt = 0 if t_mt==2
	label define mt2 0 "Not German" 1 "German"
	label values t_mt mt2
	rename t_mt german_mothertongue

	drop repeat_grade t_german_speaker
	
	labvars male west_germany special_needs repeated_grade german_mothertongue t_migrant_gen t_homework_dur ///
	t_satisfaction t_absences ever_tut_math t_homework_dur_imp ///
	"Male" "West Germany" "Special needs" "Repeated grade" "German mothertongue" "Migrant generation" ///
	"Homework duration" "School satisfaction" "Days absent" "Ever tutoring Math" "Homewokr duration (imp)"
	
	
	table () (result), stat(total male west_germany special_needs repeated_grade ///
	german_mothertongue ever_tut_math ) stat(mean male west_germany special_needs ///
	repeated_grade german_mothertongue ever_tut_math t_migrant_gen t_homework_dur t_homework_dur_imp ///
	t_satisfaction t_absences ) stat(sd male west_germany special_needs repeated_grade ///
	german_mothertongue ever_tut_math t_migrant_gen t_homework_dur t_homework_dur_imp ///
	t_satisfaction t_absences) stat(median male west_germany special_needs repeated_grade ///
	german_mothertongue ever_tut_math t_migrant_gen t_homework_dur t_homework_dur_imp ///
	t_satisfaction t_absences)
	
	local table tot_prop_sd
	include "$HELPER/table_formatting"

	collect export "$TAB/neps_controls_t.tex", as(tex) replace
	
	
	***summarise most important control variables - teacher level
	
	replace e_mt = e_mt+1
	replace e_mt = 0 if e_mt ==2
	label values e_mt mt2

	replace e_migrant = 0 if e_migrant==2 | e_migrant==3
	label define mig4 0 "Born in Germany" 1 "Born abroad"
	label values e_migrant mig4

	replace e_gender = e_gender - 1
	rename e_gender e_female
	label define esex 0 "Male" 1 "Female"
	label values e_female esex
	
	label define exp 1 "0 to less than 5" 2 "5 to less than 10" 3 "10 to less than 15" ///
	4 "15 to less than 20" 5 "20 to less than 25" 6 "25 to less than 30" 7 "30 to less than 35" ///
	8 "35 and more"
	label values e_experience exp
	
	label define deg2 0 "No selective Math degree" 1 "Selective Math degree"
	
	labvars e_mt e_migrant e_female e_experience math_degree_comp "German mothertongue" ///
	"Migrant" "Female" "Years of experience" "Selective Math degree"
	
	table () (result), stat(total e_mt e_migrant e_female math_degree_comp ) ///
	stat(mean e_mt e_migrant e_female math_degree_comp e_experience ) stat(sd ///
	e_mt e_migrant e_female math_degree_comp e_experience) stat(median e_mt  ///
	e_migrant e_female math_degree_comp e_experience)
	
	local table tot_prop_sd
	include "$HELPER/table_formatting"

	collect export "$TAB/neps_controls_e.tex", as(tex) replace
	
	
	***summarise most important control variables - class level
	
	gen cc_female_perc = 100 - cc_male_perc
	
	labvars ma_lesson_num ma_lesson_min cc_migrant_perc cc_class1_perc ///
	cc_class2_perc cc_class3_perc cc_male_perc cc_female_perc room_size_cat room_quality /// 
	ma_lesson_num_imp ma_lesson_min_imp "Weekly maths lessons" "Maths lessons duration" ///
	"Migrants (%)" "Working class (%)" "Middle class (%)" "Upper class (%)" "Male (%)" ///
	"Female (%)" "Room size" "Room quality" ///
	"Weekly maths lessons (imp)" "Maths lessons duration (imp)"
	
	table () (result),  ///
	stat(mean ma_lesson_num ma_lesson_min ma_lesson_num_imp ma_lesson_min_imp cc_migrant_perc cc_class1_perc ///
	cc_class2_perc cc_class3_perc cc_male_perc cc_female_perc room_size_cat room_quality) ///
	stat(sd ma_lesson_num ma_lesson_min ma_lesson_num_imp ma_lesson_min_imp ///
	cc_migrant_perc cc_class1_perc cc_class2_perc cc_class3_perc cc_male_perc ///
	cc_female_perc room_size_cat room_quality) stat(median ma_lesson_num ///
	ma_lesson_min ma_lesson_num_imp ma_lesson_min_imp cc_migrant_perc cc_class1_perc ///
	cc_class2_perc cc_class3_perc cc_male_perc cc_female_perc room_size_cat room_quality)
	
	local table prop_sd
	include "$HELPER/table_formatting"

	collect export "$TAB/neps_controls_cc.tex", as(tex) replace
	
	***summarise school types
	
	label define type 1 "Elementary school" 2 "Hauptschule" 3 /// 
	"School with multiple courses of edcuation" 4 "Realschule" ///
	5 "Integrated Gesamtschule" 6 "Gymnasium" 7 "Special needs school"
	label values school_type type
	
	tab school_type, gen(type)
	
	foreach x of var type* { 
		local lbl : var label `x' 
		local lbl : subinstr local lbl "school_type==" "", all
		label var `x' "`lbl'" 
	} 
	
	table () (result), stat(total type*) stat(mean type*) nformat(%7.2g)
	
	local table total_prop
	include "$HELPER/table_formatting"

	collect export "$TAB/neps_school_types.tex", as(tex) replace
	
}

if `ols'==1{
	
	***RUN ON BOTH IMPUTED AND NON-IMPUTED DATA!!!! 
	
	***SEE SUMMARY STATS TO DECIDE WHICH CONTROLS TO INCLUDE!!!
	
	***pooled ols
	
	local com reg std_score
	
	foreach x of varlist class_size class_size_imp{ //ABSENCES REMOVED AS IT IS ONLY IN TWO WAVES... E_MT AND E_MIGRANT REMOVED BECAUSE OF COLLINEARITY???
		
		//DROP LESSON MINUTES DUE TO 45 OR OTHER STRUCTURE, NO CLEAR USE OR INTERPRETATION!

		`com' `x', robust //no controls
		
		est store `x'_1
		
		`com' `x' male west_germany special_needs repeated_grade /// 
		german_mothertongue ever_tut_math t_migrant_gen t_homework_dur ///
		t_satisfaction, robust // t controls
		
		est store `x'_2
		
		`com' `x' male west_germany special_needs repeated_grade /// 
		german_mothertongue ever_tut_math t_migrant_gen t_homework_dur ///
		t_satisfaction math_degree_comp ///
		e_female e_experience , robust //t and e controls
		
		est store `x'_3 
		
		`com' `x' ma_lesson_num ///
		male west_germany special_needs repeated_grade /// 
		german_mothertongue ever_tut_math t_migrant_gen t_homework_dur ///
		t_satisfaction math_degree_comp  ///
		e_female e_experience room_quality room_size_cat ///
		school_type , robust //t, e, and cc controls
		
		est store `x'_4
		
		`com' `x' ma_lesson_num_imp male west_germany special_needs repeated_grade /// 
		german_mothertongue ever_tut_math t_migrant_gen t_homework_dur ///
		t_satisfaction math_degree_comp ///
		e_female e_experience room_quality room_size_cat school_type ///
		, robust //t, e, and cc controls
		
		est store `x'_5
		
	}
	

	
	foreach x of varlist class_size class_size_imp{ //ABSENCES REMOVED AS IT IS ONLY IN TWO WAVES... E_MT AND E_MIGRANT REMOVED BECAUSE OF COLLINEARITY???
		
		//DROP LESSON MINUTES DUE TO 45 OR OTHER STRUCTURE, NO CLEAR USE OR INTERPRETATION!

		`com' `x', robust //no controls
		
		est store `x'_1_hw
		
		`com' `x' male west_germany special_needs repeated_grade /// 
		german_mothertongue ever_tut_math t_migrant_gen t_homework_dur_imp ///
		t_satisfaction, robust // t controls
		
		est store `x'_2_hw
		
		`com' `x' male west_germany special_needs repeated_grade /// 
		german_mothertongue ever_tut_math t_migrant_gen t_homework_dur_imp ///
		t_satisfaction math_degree_comp ///
		e_female e_experience , robust //t and e controls
		
		est store `x'_3_hw 
		
		`com' `x' ma_lesson_num ///
		male west_germany special_needs repeated_grade /// 
		german_mothertongue ever_tut_math t_migrant_gen t_homework_dur_imp ///
		t_satisfaction math_degree_comp  ///
		e_female e_experience room_quality room_size_cat ///
		school_type , robust //t, e, and cc controls
		
		est store `x'_4_hw
		
		`com' `x' ma_lesson_num_imp male west_germany special_needs repeated_grade /// 
		german_mothertongue ever_tut_math t_migrant_gen t_homework_dur_imp ///
		t_satisfaction math_degree_comp ///
		e_female e_experience room_quality room_size_cat school_type ///
		, robust //t, e, and cc controls
		
		est store `x'_5_hw
		
	}
	
	//SINCE COEFFICIENT ON IMP CLASS NUMBER AND NON-IMP IS BASICALLY THE SAME, PROCEED WITH IMP!!!!
	
	***ols by wave
	
	local time 1 2
	
	foreach x of varlist class_size class_size_imp{ //ABSENCES REMOVED AS IT IS ONLY IN TWO WAVES... E_MT AND E_MIGRANT REMOVED BECAUSE OF COLLINEARITY
			
		foreach t of local time{

		
			`com' `x' if time_full==`t', robust //no controls
		
			est store `x'_1_`t'
		
			`com' `x' male west_germany special_needs repeated_grade /// 
			german_mothertongue ever_tut_math t_migrant_gen t_homework_dur ///
			t_satisfaction if time_full==`t', robust // t controls
		
			est store `x'_2_`t'
		
			`com' `x' male west_germany special_needs repeated_grade /// 
			german_mothertongue ever_tut_math t_migrant_gen t_homework_dur ///
			t_satisfaction math_degree_comp ///
			e_female e_experience if time_full==`t', robust //t and e controls
		
			est store `x'_3_`t' 
			
			if `t' !=1{ //because ma_lesson non-imputed has no wave1 values!!
		
				`com' `x' ma_lesson_num ///
				male west_germany special_needs repeated_grade /// 
				german_mothertongue ever_tut_math t_migrant_gen t_homework_dur ///
				t_satisfaction math_degree_comp  ///
				e_female e_experience room_quality room_size_cat ///
				school_type if time_full==`t', robust //t, e, and cc controls
		
				est store `x'_4_`t' 
			
			}
		
			`com' `x' ma_lesson_num_imp male west_germany special_needs repeated_grade /// 
			german_mothertongue ever_tut_math t_migrant_gen t_homework_dur ///
			t_satisfaction math_degree_comp ///
			e_female e_experience room_quality room_size_cat school_type ///
			if time_full==`t', robust //t, e, and cc controls
		
			est store `x'_5_`t'
		
		}
	}
	
		foreach x of varlist class_size class_size_imp{ //ABSENCES REMOVED AS IT IS ONLY IN TWO WAVES... E_MT AND E_MIGRANT REMOVED BECAUSE OF COLLINEARITY


		
			`com' `x' if time_full==3, robust //no controls
		
			est store `x'_1_3
		
			`com' `x' male west_germany special_needs repeated_grade /// 
			german_mothertongue ever_tut_math t_migrant_gen t_homework_dur_imp ///
			t_satisfaction if time_full==3, robust // t controls
		
			est store `x'_2_3
		
			`com' `x' male west_germany special_needs repeated_grade /// 
			german_mothertongue ever_tut_math t_migrant_gen t_homework_dur_imp ///
			t_satisfaction math_degree_comp ///
			e_female e_experience if time_full==3, robust //t and e controls
		
			est store `x'_3_3 
	
		
			`com' `x' ma_lesson_num ///
			male west_germany special_needs repeated_grade /// 
			german_mothertongue ever_tut_math t_migrant_gen t_homework_dur_imp ///
			t_satisfaction math_degree_comp  ///
			e_female e_experience room_quality room_size_cat ///
			school_type if time_full==3, robust //t, e, and cc controls
		
			est store `x'_4_3 
			
			
		
			`com' `x' ma_lesson_num_imp male west_germany special_needs repeated_grade /// 
			german_mothertongue ever_tut_math t_migrant_gen t_homework_dur_imp ///
			t_satisfaction math_degree_comp ///
			e_female e_experience room_quality room_size_cat school_type ///
			if time_full==3, robust //t, e, and cc controls
		
			est store `x'_5_3
		
		}
		
	***make regression estimate tables - 10 tables to make
	
	etable, estimates(class_size_1 class_size_2 class_size_3 ///
	class_size_4 class_size_5) ///
	stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) col(depvar)  ///
	 mstat(r2) mstat(N) export("$TAB/neps_ols_baseline.tex", replace)
	
	etable, estimates(class_size_imp_1 class_size_imp_2 class_size_imp_3 ///
	class_size_imp_4 class_size_imp_5) ///
	stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) col(depvar)  ///
	 mstat(r2) mstat(N) export("$TAB/neps_ols_imp.tex", replace)
	
	etable, estimates(class_size_1_hw class_size_2_hw class_size_3_hw ///
	class_size_4_hw class_size_5_hw) ///
	stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) col(depvar)  ///
	 mstat(r2) mstat(N) export("$TAB/neps_ols_hw.tex", replace)
	
	etable, estimates(class_size_imp_1_hw class_size_imp_2_hw class_size_imp_3_hw ///
	class_size_imp_4_hw class_size_imp_5_hw) ///
	stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) col(depvar)  ///
	 mstat(r2) mstat(N) export("$TAB/neps_ols_imp_hw.tex", replace)
	
	etable, estimates(class_size_1_1 class_size_2_1 class_size_3_1 ///
	class_size_5_1) ///
	stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) col(depvar)  ///
	 mstat(r2) mstat(N) export("$TAB/neps_ols_wave1.tex", replace)
	
	etable, estimates(class_size_1_2 class_size_2_2 class_size_3_2 ///
	class_size_4_2 class_size_5_2) ///
	stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) col(depvar)  ///
	 mstat(r2) mstat(N) export("$TAB/neps_ols_wave3.tex", replace)
	
	
	etable, estimates(class_size_imp_1_1 class_size_imp_2_1 ///
	class_size_imp_3_1 class_size_imp_5_1) ///
	stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) col(depvar)  ///
	 mstat(r2) mstat(N) export("$TAB/neps_ols_wave1_imp.tex", replace)
	
	etable, estimates(class_size_imp_1_2 class_size_imp_2_2 class_size_imp_3_2 ///
	class_size_imp_4_2 class_size_imp_5_2) ///
	stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) col(depvar)  ///
	 mstat(r2) mstat(N) export("$TAB/neps_ols_wave3_imp.tex", replace)
	
	etable, estimates(class_size_1_3 class_size_2_3 class_size_3_3 ///
	class_size_4_3 class_size_5_3) ///
	stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) col(depvar)  ///
	 mstat(r2) mstat(N) export("$TAB/neps_ols_wave5.tex", replace)
	
	etable, estimates(class_size_imp_1_3 class_size_imp_2_3 class_size_imp_3_3 ///
	class_size_imp_4_3 class_size_imp_5_3) ///
	stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) col(depvar) ///
	mstat(r2) mstat(N) export("$TAB/neps_ols_wave5_imp.tex", replace)
	
	drop _est*
	
}
	


if `panel'==1{
	
	xtset ID_t time_full
	
	local com reghdfe std_score
	
	local se vce(cluster ID_cc)
	
	***repeat over with and without individual FEs
	
	local fe1 absorb(ID_cc wave)
	
	local fe2 absorb(ID_cc ID_t wave)
	
	local controls male west_germany special_needs repeated_grade /// 
		german_mothertongue ever_tut_math t_migrant_gen t_satisfaction
	
	foreach x of varlist class_size class_size_imp{
		foreach fe in fe1 fe2{
		
			`com' `x', `se' ``fe''
			
			est store `x'_`fe'_1
		
			`com' `x' lag1_score, `se' ``fe''
			
			est store `x'_`fe'_2
			
			`com' `x' ma_lesson_num, `se' ``fe''
			
			est store `x'_`fe'_3
		
			`com' `x' lag1_score ma_lesson_num, `se' ``fe''
			
			est store `x'_`fe'_4
			
			`com' `x' ma_lesson_num_imp, `se' ``fe''
			
			est store `x'_`fe'_5
		
			`com' `x' lag1_score ma_lesson_num_imp, `se' ``fe''
			
			est store `x'_`fe'_6
		
		}
	}
	
		foreach x of varlist class_size class_size_imp{

		
			`com' `x' `controls', `se' ``fe''
			
			est store `x'_fe1_1_c
		
			`com' `x' lag1_score `controls', `se' ``fe''
			
			est store `x'_fe1_2_c
			
			`com' `x' ma_lesson_num `controls', `se' ``fe''
			
			est store `x'_fe1_3_c
		
			`com' `x' lag1_score ma_lesson_num `controls', `se' ``fe''
			
			est store `x'_fe1_4_c
			
			`com' `x' ma_lesson_num_imp `controls', `se' ``fe''
			
			est store `x'_fe1_5_c
		
			`com' `x' lag1_score ma_lesson_num_imp `controls', `se' ``fe''
			
			est store `x'_fe1_6_c
	}
	
	
	
	etable, estimates(class_size_fe1_1 class_size_fe1_2 class_size_fe1_3 ///
	class_size_fe1_4 class_size_fe1_5 class_size_fe1_6) ///
	stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) col(depvar)  ///
	 mstat(r2) mstat(N) export("$TAB/neps_hdfe1.tex", replace)
	
	etable, estimates(class_size_imp_fe1_1 class_size_imp_fe1_2 class_size_imp_fe1_3 ///
	class_size_imp_fe1_4 class_size_imp_fe1_5 class_size_imp_fe1_6) ///
	stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) col(depvar)  ///
	mstat(r2) mstat(N) export("$TAB/neps_hdfe1_imp.tex", replace)
	
	etable, estimates(class_size_fe2_1 class_size_fe2_2 class_size_fe2_3 ///
	class_size_fe2_4 class_size_fe2_5 class_size_fe2_6) ///
	stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) col(depvar)  ///
	 mstat(r2) mstat(N) export("$TAB/neps_hdfe2.tex", replace)
	
	etable, estimates(class_size_imp_fe2_1 class_size_imp_fe2_2 class_size_imp_fe2_3 ///
	class_size_imp_fe2_4 class_size_imp_fe2_5 class_size_imp_fe2_6) ///
	stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) col(depvar)  ///
	mstat(r2) mstat(N) export("$TAB/neps_hdfe2_imp.tex", replace)
	
	etable, estimates(class_size_fe1_1_c class_size_fe1_2_c ///
	class_size_fe1_3_c class_size_fe1_4_c ///
	class_size_fe1_5_c class_size_fe1_6_c) ///
	stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) col(depvar)  ///
	mstat(r2) mstat(N) export("$TAB/neps_hdfe1_controls.tex", replace)
	
	etable, estimates(class_size_imp_fe1_1_c class_size_imp_fe1_2_c ///
	class_size_imp_fe1_3_c class_size_imp_fe1_4_c ///
	class_size_imp_fe1_5_c class_size_imp_fe1_6_c) ///
	stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) col(depvar)  ///
	mstat(r2) mstat(N) export("$TAB/neps_hdfe1_imp_controls.tex", replace)
	
	***PROBLEM: GIVEN THE VERY SMALL T, THE LAGGED DV IS EXTREMELY HIGHLY MULTICOLLINEAR WITH INDIVIDUAL FES!!!!
	
}	
	

	
if `qr'==1{
	
	***LOOK AT OLS RESULTS AND DECIDE WHAT MAKES SENSE TO RUN!!!!
	
	***DO NOT RUN ALL THE DIFFERENT SPECIFICATIONS - DO SOMETHING SIMILAR TO THE PANEL VERSION - DO ONLY ON POOLED SAMPLE!!!!
	
	***FUNCTIONAL OPTION ALLOWS FOR TESTING MULTIPLE HYPOTEHSIS I.E. KOLMOGOROV-SMIRNOV!!!
	
	local com qrprocess std_score
	
	local qt quantile(0.05(0.05)0.95)
	
	local controls male west_germany special_needs repeated_grade /// 
	german_mothertongue ever_tut_math t_migrant_gen t_satisfaction ///
	room_quality school_type room_size_cat
	
	foreach x of varlist class_size class_size_imp{

		`com' `x', `qt'
		
		est store `x'_1
		
		plotprocess `x' , compare(reg, robust) ///
		lcolor(blue) pcolor(stblue%50) other(note(Maths lesson number not included))
			
		graph export "$FIG/neps_`x'_qr_1.jpg", as(jpg) quality(100) replace
	
		
		`com' `x' ma_lesson_num, `qt'
			
		est store `x'_2
		
		plotprocess `x' , compare(reg, robust) ///
		lcolor(blue) pcolor(stblue%50) other(note(Maths lesson number included))
			
		graph export "$FIG/neps_`x'_qr_2.jpg", as(jpg) quality(100) replace
	
		
		`com' `x' ma_lesson_num_imp, `qt'
			
		est store `x'_3
		
		plotprocess `x' , compare(reg, robust) ///
		lcolor(blue) pcolor(stblue%50) other(note(Maths lesson number imputed included))
			
		graph export "$FIG/neps_`x'_qr_3.jpg", as(jpg) quality(100) replace
		
		
	}
	
	foreach x of varlist class_size class_size_imp{

		
		`com' `x' `controls', `qt'
			
		est store `x'_1_c
	
		plotprocess `x' , compare(reg, robust) ///
		lcolor(blue) pcolor(stblue%50) other(note("Student and class/school controls included"))
			
		graph export "$FIG/neps_`x'_qr_1_c.jpg", as(jpg) quality(100) replace
			
		`com' `x' ma_lesson_num `controls', `qt' // ERROR HERE!!!
			
		est store `x'_2_c
		
		plotprocess `x' , compare(reg, robust) ///
		lcolor(blue) pcolor(stblue%50) other(note("Student, class/school, and maths lesson number controls included"))
			
		graph export "$FIG/neps_`x'_qr_2_c.jpg", as(jpg) quality(100) replace
			
		`com' `x' ma_lesson_num_imp `controls', `qt'
			
		est store `x'_3_c
		
		plotprocess `x' , compare(reg, robust) ///
		lcolor(blue) pcolor(stblue%50) other(note("Student, class/school, and maths lesson number imputed controls included"))
			
		graph export "$FIG/neps_`x'_qr_3_c.jpg", as(jpg) quality(100) replace

	}
	

	***ONCE I HAVE RUN THESE, MAKE SURE TO RE-RUN WHICHEVER SEEMS MOST RELEVANT WITH THE FUNCTIONAL HYPOTEHSIS TESTING!!!
	
}


if `mdqr'==1{
	
	***I HAVE IDENTIFIED THE KEY REGRESSIONS: REG OF SCORE ON CLASS_SIZE, LAG, AND LESSON NUMBER WITH CLASS EFFECTS AND WAVE EFFECTS - NO INDIVIDUAL EFFECTS - MAYBE HERE TRY TO INCLUDE INDIVIDUAL CONTROLS AND SEE WHAT HAPPENS!!!!
	
	local com mdqr std_score
	
	local qt quantile(0.05(0.05)0.95)
	
	local est est_command(reghdfe)
	
	local gp group(ID_cc wave)
	
	local fe est_opts(absorb(ID_cc wave))
	
	local se1 ""
	local se2 cluster(ID_cc)

	
	local controls male west_germany special_needs repeated_grade /// 
		german_mothertongue ever_tut_math t_migrant_gen t_satisfaction
	 
	
	//careful - MDQR does not work without at least one non-group variable!!! - THIS IS BECAUSE OF THE FIRST-STAGE ESTIMATION PROCEDURE!!!
	
	//add in basic student controls: gender, west german, repeated grade, german mt, sen, tutoring math, migrant, school satistfaction
	
	foreach x of varlist class_size class_size_imp{
		foreach se in se1 se2{
		
			quietly: `com' `x' `controls', ``se'' `est' `gp' `qt' `fe'
			
			est store `x'_`se'_1
			
			plotprocess `x' , compare(reghdfe, absorb(ID_cc time_full) vce(cluster ID_cc)) ///
			lcolor(blue) pcolor(stblue%50) other(note("No lag included. Student controls included."))
			
			graph export "$FIG/neps_`x'_`se'_1.jpg", as(jpg) quality(100) replace
			
			quietly: `com' `x' lag1_score `controls', ``se'' `est' `gp' `qt' `fe'
			
			est store `x'_`se'_2
			
			plotprocess `x', compare(reghdfe, absorb(ID_cc time_full) vce(cluster ID_cc)) ///
			lcolor(blue) pcolor(stblue%50) other(note("Lag and student controls included"))
			
			graph export "$FIG/neps_`x'_`se'_2.jpg", as(jpg) quality(100) replace
			
			quietly: `com' `x' ma_lesson_num `controls', ``se'' `est' `gp' `qt' `fe'
			
			est store `x'_`se'_3
			
			plotprocess `x', compare(reghdfe, absorb(ID_cc time_full) vce(cluster ID_cc)) ///
			lcolor(blue) pcolor(stblue%50) other(note("No lag included. Student and class number controls included."))
			
			graph export "$FIG/neps_`x'_`se'_3.jpg", as(jpg) quality(100) replace
			
			quietly: `com' `x' lag1_score ma_lesson_num `controls', ``se'' `est' `gp' `qt' `fe'
			
			est store `x'_`se'_4
			
			plotprocess `x', compare(reghdfe, absorb(ID_cc time_full) vce(cluster ID_cc)) ///
			lcolor(blue) pcolor(stblue%50) other(note("Lag, student and class number controls included."))
			
			graph export "$FIG/neps_`x'_`se'_4.jpg", as(jpg) quality(100) replace
			
			quietly: `com' `x' ma_lesson_num_imp `controls', ``se'' `est' `gp' `qt' `fe'
			
			est store `x'_`se'_5
			
			plotprocess `x' , compare(reghdfe, absorb(ID_cc time_full) vce(cluster ID_cc)) ///
			lcolor(blue) pcolor(stblue%50) other(note("No lag included. Student and class number imputed controls included."))
			
			graph export "$FIG/neps_`x'_`se'_5.jpg", as(jpg) quality(100) replace
			
			quietly: `com' `x' lag1_score ma_lesson_num_imp `controls', ``se'' `est' `gp' `qt' `fe'
			
			est store `x'_`se'_6
			
			plotprocess `x' , compare(reghdfe, absorb(ID_cc time_full) vce(cluster ID_cc)) ///
			lcolor(blue) pcolor(stblue%50) other(note("Lag, student, and class number imputed control included."))
			
			graph export "$FIG/neps_`x'_`se'_6.jpg", as(jpg) quality(100) replace
			
		} //first se does not allow for intra-group correlation, the second does??? not clear - second se introduces stochasticity... 
	}
	

	
}
	

