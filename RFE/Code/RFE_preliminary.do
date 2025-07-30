clear

***set pathnames

local project "RFE"
include "/Users/albertoornaghi/Documents/GitHub/coding_samples/Helper/pathnames.do"

***set locals for running code

local sample_dropouts			0
local summary_tables			0
local graphs					0
local balance_table				0
local diff_in_means				0

use "$RFEDATA/RFE_data_clean.dta", clear

if `sample_dropouts'==1{


***check if sample dropouts are systematic and write in text file
	
	file open tbl using "$RFETAB/sample_dropouts", write replace
	
	foreach x of varlist post_policy_1 post_activism_radical_4{
		foreach y of varlist control-group3{
			misstable summ `x' if `y'==1
			file write tbl "`x' `y' missing = " "`r(N_eq_dot)'" _n
		}
	}


	*** run ttests for pre-treatment characteristics for those missing policy and not and write p-value in text file
	
	preserve
	
	foreach x of varlist pre_policy-pre_behaviours{
		gen `x'_miss = .
		replace `x'_miss = `x' if post_policy_1==.
		
		ttest `x'==`x'_miss, unp uneq
		
		file write tbl "`x' == `x'_miss missing policy p-value = " "`r(p)'" _n
	}

	restore
	
	*** run ttests for pre-treatment characteristics for those missing activism and not and write p-value in text file

	preserve
	
	foreach x of varlist pre_policy-pre_behaviours{
		gen `x'_miss = .
		replace `x'_miss = `x' if post_activism_moderate_1==.
		
		ttest `x'==`x'_miss, unp uneq
		
		file write tbl "`x' == `x'_miss missing activism p-value" "`r(p)'" _n
		
	}

	restore
	
	file close tbl
	
}

if `summary_tables'==1{

***create table summarising sample size and treatment group allocations

gen sample_size = control+group1+group2+group3
tab sample_size
label var sample_size "Full Sample"

table () (result), stat(total control group1 group2 group3 sample_size) stat(mean control group1 group2 group3) nformat(%7.2f)

	local table "sample"
	include "$HELPER/table_formatting.do"
	collect export "$RFETAB/sample_size", as(tex) replace

***create table summarising demographic characteristics - three separate tables: basics e.g. age, gender etc, income, partisanship

	local genders female male non_binary
	
	local i = 1
	
	foreach x of local genders{
		/// redefine multivalued variables to dummies to obtain proportions
		gen `x' = 0 if gender!=.
		replace `x' = 1 if gender == `i'
		local i = `i' + 1
	} 
	
	table () (result), stat(total `genders' uk_res) stat(mean `genders' age education uk_res) stat(sd `genders' age education uk_res) nformat(%7.2f)

	local table "mean_sd"
	include "$HELPER/table_formatting.do"
	collect export "$RFETAB/demographics", as(tex) replace




	
	tab(income), gen(income) ///generate dummies and relabel for income levels

	foreach x of varlist income1-income7 {
		local variable_label : variable label `x'
		local variable_label : subinstr local variable_label "income==" ""
		label variable `x' "`variable_label'" 
	}

	table () (result), stat(total income1-income7) stat(mean income1-income7) stat(sd income1-income7) nformat(%7.2f)

	local table "proportion_sd"
	include "$HELPER/table_formatting.do"
	collect export "$RFETAB/income", as(tex) replace
	
	
	
	tab partisanship, generate(partisanship) ///generate dummies and relabel for partisanship

	foreach x of varlist partisanship1-partisanship9 {
		local variable_label : variable label `x'
		local variable_label : subinstr local variable_label "partisanship==" ""
		label variable `x' "`variable_label'"
	}

	table () (result), stat(total partisanship1-partisanship9) stat(mean partisanship1-partisanship9) stat(sd partisanship1-partisanship9) nformat(%7.2f)

	local table "mean_sd"
	include "$HELPER/table_formatting.do"
	collect export "$RFETAB/demographics", as(tex) replace
	
	***create table summarising pre-experiment substantive questions

	local pre_vars_full pre_policy_1-pre_policy_3 pre_policy pre_activism_1-pre_activism_3 pre_activism ///
	pre_anxiety_1-pre_anxiety_3 pre_anxiety pre_norms_1-pre_norms_3 pre_norms pre_justice_1-pre_justice_5 ///
	pre_justice pre_behaviours_1-pre_behaviours_5 pre_behaviours
	
	local pre_vars_short pre_policy-pre_behaviours
	
	local post_vars_full post_policy_1-post_policy_8 post_policy_mean post_activism_moderate_1 ///
	post_activism_moderate_2 post_activism_moderate_3 post_activism_moderate_4 post_moderate_mean ///
	post_activism_radical_1 post_activism_radical_2 post_activism_radical_3 post_activism_radical_4 post_radical_mean
	
	local post_vars_short post_policy_mean post_moderate_mean post_radical_mean

	
	table () (result), stat(mean `pre_vars_full') stat(sd `pre_vars_full')  nformat(%7.2f)

	local table "mean_sd"
	include "$HELPER/table_formatting.do"
	collect export "$RFETAB/presummary", as(tex) replace

	table () (result), stat(mean `pre_vars_short') stat(sd `pre_vars_short')  nformat(%7.2f) ///make shorter verion including only overall means

	local table "mean_sd"
	include "$HELPER/table_formatting.do"
	collect export "$RFETAB/presummaryshort", as(tex) replace

	***create table summarising post-experiment dependent variables

	table () (result), stat(mean `post_vars_full') stat( sd `post_vars_full') nformat(%7.2f)

	local table "mean_sd"
	include "$HELPER/table_formatting.do"
	collect export "$RFETAB/postsummary", as(tex) replace

	table () (result), stat(mean `post_vars_short') stat( sd `post_vars_short') nformat(%7.2f)

	local table "mean_sd"
	include "$HELPER/table_formatting.do"
	collect export "$RFETAB/postsummaryshort", as(tex) replace

	***create table summarising experimental stimuli agreement

	table () (result), stat(mean control_statement_1-group3_statement_14) stat(sd control_statement_1-group3_statement_14)  nformat(%7.2f)

	local table "mean_sd"
	include "$HELPER/table_formatting.do"
	collect export "$RFETAB/stimuli", as(tex) replace

	***table of summary stats for awareness and perception

	local aware radical_aware_full moderate_aware_full greenpeace_aware-none_aware
	local percep radical_percep moderate_percep greenpeace_radical-er_radical none_radical
	
	table () (result), stat(total `aware') stat(mean `aware') stat(sd `aware') nformat(%7.2f)

	local table "proportion_sd"
	include "$HELPER/table_formatting.do"
	collect export "$RFETAB/awaresummary", as(tex) replace

	table () (result), stat(total `percep') stat(mean `percep') stat(sd `percep') nformat(%7.2f)

	local table "proportion_sd"
	include "$HELPER/table_formatting.do"
	collect export "$RFETAB/perceptionsummary", as(tex) replace
	
}


if `graphs'==1{

	***visualise pre and post treatment variables

	graph hbar `pre_vars_short', ytitle("Mean Agreement (5-point Likert Scale)") ///
	ylabel(,nogrid) blabel(bar, format(%7.3g) size(vsmall)) legend(label(1 "Pre-treatment 	policy support") ///
	label(2 "Pre-treatment activism support") label(3 "Pre-treatment eco-anxiety") ///
	label(4 "Pre-treatment environmental norms") label(5 "Pre-treatment environmental justice") ///
	label(6 "Pre-treatment sustainable behaviours") pos(6) size(vsmall) r(2)) intensity(70) bargap(10)

	graph save "Graph" "$RFEFIG/bar_pre.gph", replace
	graph export "$RFEFIG/bar_pre.jpg", as(jpg) name("Graph") quality(100) replace

	graph hbar `post_vars_short', ytitle("Mean Agreement (5-point Likert Scale)") ///
	ylabel(,nogrid) blabel(bar, format(%7.3g) size(vsmall)) legend(label(1 "Post-treatment policy support") ///
	label(2 "Post-treatment moderate activism support") label(3 "Post-treatment radical activism support") ///
	pos(6) size(vsmall) r(1)) intensity(70) bargap(10)

	graph save "Graph" "$RFEFIG/bar_post.gph", replace
	graph export "$RFEFIG/bar_post.jpg", as(jpg) name("Graph") quality(100) replace

	
}

if `balance_table'==1{	
***balance table

foreach x of varlist gender-partisanship pre_policy-pre_behaviours{
	reg `x' group1 group2 group3, robust
	estimates store bt_`x'
}

etable, estimates(bt_gender bt_age bt_uk_res bt_education bt_income bt_partisanship) stars(0.1 "*" 0.05 "**" 0.01 "***", attach(_r_b)) keep(group1 group2 group3 total) showstars showstarsnote eqrecode(gender=dv age=dv uk_res=dv education=dv income=dv partisanship=dv) col(dvlabel) export($RFETAB/balancetable1.tex,replace)

etable, estimates(bt_pre_policy bt_pre_activism bt_pre_anxiety bt_pre_norms bt_pre_justice bt_pre_behaviours) stars(0.1 "*" 0.05 "**" 0.01 "***", attach(_r_b)) keep(group1 group2 group3 total) showstars showstarsnote eqrecode( pre_policy=dv pre_activism=dv pre_anxiety=dv pre_norms=dv pre_justice=dv pre_behaviours=dv) col(dvlabel) export($RFETAB/balancetable2.tex,replace)

}

if `diff_in_means'==1{

	***test diff-in-means for respondents' awareness and perception of activism groups split by tactics

	ttest radical_aware_full == moderate_aware_full, unp uneq 
	ttest radical_percep == moderate_percep, unp uneq

	collect style title, font(, bold)
	collect style cell, border( all, width(0.5) pattern(single) )
	collect style cell, halign(left) valign(center)
	collect label levels result Diff "Diff-in-Means", modify
	collect label levels result Mean1 "Mean 1", modify
	collect label levels result Mean2 "Mean 2", modify
	collect label levels command 1 "Radical Awareness = Moderate Awareness" 2 "Radical Perception = Moderate Perception", modify
	collect label levels result Sample1 "Sample 1", modify	
	collect label levels result Sample2 "Sample 2", modify
	collect stars p .01 `"***"' .05 `"**"' .1 `"*"', attach(Difference) shownote
	collect export "$RFETAB/diffinmeans.tex",replace

	*** test pairwise awareness

	collect create pairwise1, replace

	foreach x of varlist greenpeace_aware-er_aware{
		foreach y of varlist greenpeace_aware-er_aware{
			quietly: collect diff=(r(mu_2)-r(mu_1)) pvalue=r(p): ttest `x'==`y', unp uneq
		}
	}

	***create tables with results for each "column" variable in matrix
	
	*** Number of macros to create
	local num_macros = 8

	*** Loop through each macro
	forvalues i = 0/`=`num_macros'-1' {
		local start = `i'*8 + 1
		local end = `start' + 7

		***Generate the list of 8 numbers
		
		local numbers`i' ""
		forvalues j = `start'/`end' {
			local numbers`i' "`numbers`i'' `j'"
		}
	}

	***create 8 separate tables
	
	local table "diff_pairwise"
	
	foreach x in numbers0 numbers1 numbers2 numbers3 numbers4 numbers5 numbers6 numbers7{
	
		collect layout (cmdset[``x'']) (result[diff])
		include "$HELPER/table_formatting"
		collect export "$RFETAB/pairwise_aware_`x'.tex",replace
	
	}


	*** test pairwise radical perception


	collect create pairwise2

	foreach x of varlist greenpeace_radical-er_radical{
		foreach y of varlist greenpeace_radical-er_radical{
		quietly: collect diff=(r(mu_2)-r(mu_1)) pvalue=r(p): ttest `x'==`y', unp uneq
		}
	}

		***create tables with results for each "column" variable in matrix
	
	*** Number of macros to create
	local num_macros = 8

	*** Loop through each macro
	forvalues i = 0/`=`num_macros'-1' {
		local start = `i'*8 + 1
		local end = `start' + 7

		***Generate the list of 8 numbers
		
		local numbers`i' ""
		
		forvalues j = `start'/`end' {
			local numbers`i' "`numbers`i'' `j'"
		}
	}

	***create 8 separate tables
	
	local table "diff_pairwise"
	
	foreach x in numbers0 numbers1 numbers2 numbers3 numbers4 numbers5 numbers6 numbers7{
	
	collect layout (cmdset[``x'']) (result[diff])
		include "$HELPER/table_formatting"
		collect export "$RFETAB/pairwise_percep_`x'.tex",replace
	}
	
}
