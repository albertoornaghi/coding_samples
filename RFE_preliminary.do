clear

***set pathnames

if c(username)=="albertoornaghi"{
	global MAIN "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV398/Dissertation"
	
	global CODE "$MAIN/Do Files"
	
	global DATA "$MAIN/Datasets"
	
	global FIG "$MAIN/Graphs"
	global TAB "$MAIN/Tables"
	
}

***set locals for running code

local sample_dropouts		1
local other					0

use "RFE_data_clean.dta", clear

if `sample_dropouts'==1{

*****************SAVE IN TEXT FILE!!!!!****************
*******************************************************
*******************************************************
*******************************************************

***check if sample dropouts are systematic

	misstable summ post_policy_1 post_activism_radical_4 if control==1
	misstable summ post_policy_1 post_activism_radical_4 if group1==1
	misstable summ post_policy_1 post_activism_radical_4 if group2==1
	misstable summ post_policy_1 post_activism_radical_4 if group3==1

	*** run ttests for pre-treatment characteristics for those missing policy and not
	
	preserve
	
	foreach x of varlist pre_policy-pre_behaviours{
		gen `x'_miss = .
		replace `x'_miss = `x' if post_policy_1==.
		
		ttest `x'==`x'_miss, unp uneq
		
	}

	restore
	
	*** run ttests for pre-treatment characteristics for those missing activism and not 

	preserve
	
	foreach x of varlist pre_policy-pre_behaviours{
		gen `x'_miss = .
		replace `x'_miss = `x' if post_activism_moderate_1==.
		
		ttest `x'==`x'_miss, unp uneq
		
	}

	restore

}

if `other'==1{

***create table summarising sample size and treatment group allocations

gen sample_size = control+group1+group2+group3
tab sample_size
label var sample_size "Full Sample"

table () (result), stat(total control group1 group2 group3 sample_size) stat(mean control group1 group2 group3) nformat(%7.2g)

collect style cell, border( all, width(0.5) pattern(single))
collect label levels result total "Sample Size" mean "Sample Proportion (%)", modify
collect style cell, halign(left) valign(center)
collect export "sample_size", as(tex) replace

***create table summarising demographic characteristics - three separate tables: basics e.g. age, gender etc, income, partisanship

gen female = 0
replace female = 1 if gender==1 /// redefine multivalued variables to dummies to obtain proportions
label var female Female
gen male
gen male=0
replace male=1 if gender==2
label var male Male
gen non_binary = 0
replace non_binary = 1 if gender==3
label var non_binary "Non-Binary"

replace male=. if gender==.
replace female=. if gender==.
replace non_binary=. if gender==.

table () (result), stat(total female male non_binary uk_res) stat(mean female male non_binary age education uk_res) stat(sd female male non_binary age education uk_res) nformat(%7.2g)

collect style cell, border( all, width(0.5) pattern(single))
collect label levels result mean "Mean" sd "Standard Deviation", modify
collect style cell, halign(left) valign(center)
collect export "demographics", as(tex) replace

tab income
tab income, nolab
tab(income), gen(income) ///generate dummies for income levels

foreach x of varlist income1-income7 {
    local variable_label : variable label `x'
    local variable_label : subinstr local variable_label "income==" ""
    label variable `x' "`variable_label'" ///relabel dummies for income levels
}

table () (result), stat(total income1-income7) stat(mean income1-income7) stat(sd income1-income7) nformat(%7.2g)

collect style cell, border( all, width(0.5) pattern(single))
collect label levels result mean "Proportion" sd "Standard Deviation", modify
collect style cell, halign(left) valign(center)
collect export "demographics", as(tex) replace

tab partisanship
tab partisanship, generate(partisanship)

foreach x of varlist partisanship1-partisanship9 {
    local variable_label : variable label `x'
    local variable_label : subinstr local variable_label "partisanship==" ""
    label variable `x' "`variable_label'" ///relabel dummies for income levels
}

table () (result), stat(total partisanship1-partisanship9) stat(mean partisanship1-partisanship9) stat(sd partisanship1-partisanship9) nformat(%7.2g)

***create table summarising pre-experiment substantive questions

table () (result), stat(mean pre_policy_1-pre_policy_3 pre_policy pre_activism_1-pre_activism_3 pre_activism pre_anxiety_1-pre_anxiety_3 pre_anxiety pre_norms_1-pre_norms_3 pre_norms pre_justice_1-pre_justice_5 pre_justice pre_behaviours_1-pre_behaviours_5 pre_behaviours) stat(sd pre_policy_1-pre_policy_3 pre_policy pre_activism_1-pre_activism_3 pre_activism pre_anxiety_1-pre_anxiety_3 pre_anxiety pre_norms_1-pre_norms_3 pre_norms pre_justice_1-pre_justice_5 pre_justice pre_behaviours_1-pre_behaviours_5 pre_behaviours) 

collect style cell, border( all, width(0.5) pattern(single))
collect label levels result sd "Standard Deviation", modify
collect style cell, halign(left) valign(center)
collect export "presummary", as(tex) replace

table () (result), stat(mean pre_policy-pre_behaviours) stat(sd pre_policy-pre_behaviours) ///make shorter verion including only overall means

collect style cell, border( all, width(0.5) pattern(single))
collect label levels result sd "Standard Deviation", modify
collect style cell, halign(left) valign(center)
collect export "presummaryshort", as(tex) replace

***create table summarising post-experiment dependent variables

table () (result), stat(mean post_policy_1-post_policy_8 post_policy_mean post_activism_moderate_1 post_activism_moderate_2 post_activism_moderate_3 post_activism_moderate_4 post_moderate_mean post_activism_radical_1 post_activism_radical_2 post_activism_radical_3 post_activism_radical_4 post_radical_mean) stat( sd post_policy_1-post_policy_8 post_policy_mean post_activism_moderate_1 post_activism_moderate_2 post_activism_moderate_3 post_activism_moderate_4 post_moderate_mean post_activism_radical_1 post_activism_radical_2 post_activism_radical_3 post_activism_radical_4 post_radical_mean) nformat(%7.2g)

collect style cell, border( all, width(0.5) pattern(single))
collect label levels result sd "Standard Deviation", modify
collect style cell, halign(left) valign(center)
collect export "postsummary", as(tex) replace

table () (result), stat(mean post_policy_mean post_moderate_mean post_radical_mean) stat( sd post_policy_mean post_moderate_mean post_radical_mean) nformat(%7.3g)

collect style cell, border( all, width(0.5) pattern(single))
collect label levels result sd "Standard Deviation", modify
collect style cell, halign(left) valign(center)
collect export "postsummaryshort", as(tex) replace

***create table summarising experimental stimuli agreement

table () (result), stat(mean control_statement_1-group3_statement_14) stat(sd control_statement_1-group3_statement_14)

collect style cell, border( all, width(0.5) pattern(single))
collect label levels result sd "Standard Deviation", modify
collect style cell, halign(left) valign(center)
collect export "stimuli", as(tex) replace

***visualise pre and post treatment variables

graph hbar pre_policy pre_activism pre_anxiety pre_norms pre_justice pre_behaviours, ytitle("Mean Agreement (5-point Likert Scale)") ylabel(,nogrid) blabel(bar, format(%7.3g) size(vsmall)) legend(label(1 "Pre-treatment policy support") label(2 "Pre-treatment activism support") label(3 "Pre-treatment eco-anxiety") label(4 "Pre-treatment environmental norms") label(5 "Pre-treatment environmental justice") label(6 "Pre-treatment sustainable behaviours") pos(6) size(vsmall) r(2)) intensity(70) bargap(10)

graph save "Graph" "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV398/bar_pre.gph", replace
graph export "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV398/bar_pre.jpg", as(jpg) name("Graph") quality(100)

graph hbar post_policy_mean-post_radical_mean, ytitle("Mean Agreement (5-point Likert Scale)") ylabel(,nogrid) blabel(bar, format(%7.3g) size(vsmall)) legend(label(1 "Post-treatment policy support") label(2 "Post-treatment moderate activism support") label(3 "Post-treatment radical activism support") pos(6) size(vsmall) r(1)) intensity(70) bargap(10)

graph save "Graph" "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV398/bar_post.gph"
graph export "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV398/bar_post.jpg", as(jpg) name("Graph") quality(100)

***balance table

foreach x of varlist gender-partisanship pre_policy-pre_behaviours{
	reg `x' group1 group2 group3, robust
	estimates store bt_`x'
}

etable, estimates(bt_gender bt_age bt_uk_res bt_education bt_income bt_partisanship) stars(0.1 "*" 0.05 "**" 0.01 "***", attach(_r_b)) keep(group1 group2 group3 total) showstars showstarsnote eqrecode(gender=dv age=dv uk_res=dv education=dv income=dv partisanship=dv) col(dvlabel) export(balancetable1.tex,replace)

etable, estimates(bt_pre_policy bt_pre_activism bt_pre_anxiety bt_pre_norms bt_pre_justice bt_pre_behaviours) stars(0.1 "*" 0.05 "**" 0.01 "***", attach(_r_b)) keep(group1 group2 group3 total) showstars showstarsnote eqrecode( pre_policy=dv pre_activism=dv pre_anxiety=dv pre_norms=dv pre_justice=dv pre_behaviours=dv) col(dvlabel) export(balancetable2.tex,replace)

***table of summary stats for awareness and perception

table () (result), stat(total radical_aware_full moderate_aware_full greenpeace_aware-none_aware) stat(mean radical_aware_full moderate_aware_full greenpeace_aware-none_aware) stat(sd radical_aware_full moderate_aware_full greenpeace_aware-none_aware)

collect style cell, border( all, width(0.5) pattern(single))
collect label levels result sd "Standard Deviation", modify
collect label levels result mean "Proportion Aware", modify
collect style cell, halign(left) valign(center)
collect style cell, nformat(%7.3g)
collect export "awaresummary", as(tex) replace

table () (result), stat(total radical_percep moderate_percep greenpeace_radical-er_radical none_radical) stat(mean radical_percep moderate_percep greenpeace_radical-er_radical none_radical) stat(sd radical_percep moderate_percep greenpeace_radical-er_radical none_radical)

collect style cell, border( all, width(0.5) pattern(single))
collect label levels result sd "Standard Deviation", modify
collect label levels result mean "Proportion Aware", modify
collect style cell, halign(left) valign(center)
collect style cell, nformat(%7.3g)
collect export "perceptionsummary", as(tex) replace

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
collect export diffinmeans.tex,replace

///pairwise awareness

collect create pairwise1

foreach x of varlist greenpeace_aware-er_aware{
	foreach y of varlist greenpeace_aware-er_aware{
	quietly: collect diff=(r(mu_2)-r(mu_1)) pvalue=r(p): ttest `x'==`y', unp uneq
}
}

local numbers
forvalues i = 1/8 {
    local numbers "`numbers' `i'" 
} 

collect layout (cmdset[`numbers']) (result[diff])
collect style title, font(, bold)
collect style cell, border( all, width(0.5) pattern(single) )
collect style cell, halign(left) valign(center)
collect stars p .01 `"***"' .05 `"**"' .1 `"*"', attach(diff) shownote
collect style cell, nformat(%7.3g)
collect export pairwise.tex,replace

foreach x of local numbers{
	
    local updated = `x' + 8
    local numbers1 "`numbers1' `updated'"
}

collect layout (cmdset[`numbers1' ]) (result[diff])
collect style title, font(, bold)
collect style cell, border( all, width(0.5) pattern(single) )
collect style cell, halign(left) valign(center)
collect stars p .01 `"***"' .05 `"**"' .1 `"*"', attach(diff) shownote
collect style cell, nformat(%7.3g)
collect export pairwise1.tex,replace

foreach x of local numbers1{
	
    local updated = `x' + 8
    local numbers2 "`numbers2' `updated'"
}

collect layout (cmdset[`numbers2' ]) (result[diff])
collect style title, font(, bold)
collect style cell, border( all, width(0.5) pattern(single) )
collect style cell, halign(left) valign(center)
collect stars p .01 `"***"' .05 `"**"' .1 `"*"', attach(diff) shownote
collect style cell, nformat(%7.3g)
collect export pairwise2.tex,replace

foreach x of local numbers2{
	
    local updated = `x' + 8
    local numbers3 "`numbers3' `updated'"
}

collect layout (cmdset[`numbers3' ]) (result[diff])
collect style title, font(, bold)
collect style cell, border( all, width(0.5) pattern(single) )
collect style cell, halign(left) valign(center)
collect stars p .01 `"***"' .05 `"**"' .1 `"*"', attach(diff) shownote
collect style cell, nformat(%7.3g)
collect export pairwise3.tex,replace

foreach x of local numbers3{
	
    local updated = `x' + 8
    local numbers4 "`numbers4' `updated'"
}

collect layout (cmdset[`numbers4' ]) (result[diff])
collect style title, font(, bold)
collect style cell, border( all, width(0.5) pattern(single) )
collect style cell, halign(left) valign(center)
collect stars p .01 `"***"' .05 `"**"' .1 `"*"', attach(diff) shownote
collect style cell, nformat(%7.3g)
collect export pairwise4.tex,replace

foreach x of local numbers4{
	
    local updated = `x' + 8
    local numbers5 "`numbers5' `updated'"
}

collect layout (cmdset[`numbers5' ]) (result[diff])
collect style title, font(, bold)
collect style cell, border( all, width(0.5) pattern(single) )
collect style cell, halign(left) valign(center)
collect stars p .01 `"***"' .05 `"**"' .1 `"*"', attach(diff) shownote
collect style cell, nformat(%7.3g)
collect export pairwise5.tex,replace

foreach x of local numbers5{
	
    local updated = `x' + 8
    local numbers6 "`numbers6' `updated'"
}

collect layout (cmdset[`numbers6' ]) (result[diff])
collect style title, font(, bold)
collect style cell, border( all, width(0.5) pattern(single) )
collect style cell, halign(left) valign(center)
collect stars p .01 `"***"' .05 `"**"' .1 `"*"', attach(diff) shownote
collect style cell, nformat(%7.3g)
collect export pairwise6.tex,replace


foreach x of local numbers6{
	
    local updated = `x' + 8
    local numbers7 "`numbers7' `updated'"
}

collect layout (cmdset[`numbers7' ]) (result[diff])
collect style title, font(, bold)
collect style cell, border( all, width(0.5) pattern(single) )
collect style cell, halign(left) valign(center)
collect stars p .01 `"***"' .05 `"**"' .1 `"*"', attach(diff) shownote
collect style cell, nformat(%7.3g)
collect export pairwise7.tex,replace



///pairwise perception


collect create pairwise2

foreach x of varlist greenpeace_radical-er_radical{
	foreach y of varlist greenpeace_radical-er_radical{
	quietly: collect diff=(r(mu_2)-r(mu_1)) pvalue=r(p): ttest `x'==`y', unp uneq
}
}

local numbers
forvalues i = 1/8 {
    local numbers "`numbers' `i'" 
} 

collect layout (cmdset[`numbers']) (result[diff])
collect style title, font(, bold)
collect style cell, border( all, width(0.5) pattern(single) )
collect style cell, halign(left) valign(center)
collect stars p .01 `"***"' .05 `"**"' .1 `"*"', attach(diff) shownote
collect style cell, nformat(%7.3g)


foreach x of local numbers{
	
    local updated = `x' + 8
    local numbers1 "`numbers1' `updated'"
}

collect layout (cmdset[`numbers1' ]) (result[diff])
collect style title, font(, bold)
collect style cell, border( all, width(0.5) pattern(single) )
collect style cell, halign(left) valign(center)
collect stars p .01 `"***"' .05 `"**"' .1 `"*"', attach(diff) shownote
collect style cell, nformat(%7.3g)


foreach x of local numbers1{
	
    local updated = `x' + 8
    local numbers2 "`numbers2' `updated'"
}

collect layout (cmdset[`numbers2' ]) (result[diff])
collect style title, font(, bold)
collect style cell, border( all, width(0.5) pattern(single) )
collect style cell, halign(left) valign(center)
collect stars p .01 `"***"' .05 `"**"' .1 `"*"', attach(diff) shownote
collect style cell, nformat(%7.3g)


foreach x of local numbers2{
	
    local updated = `x' + 8
    local numbers3 "`numbers3' `updated'"
}

collect layout (cmdset[`numbers3' ]) (result[diff])
collect style title, font(, bold)
collect style cell, border( all, width(0.5) pattern(single) )
collect style cell, halign(left) valign(center)
collect stars p .01 `"***"' .05 `"**"' .1 `"*"', attach(diff) shownote
collect style cell, nformat(%7.3g)


foreach x of local numbers3{
	
    local updated = `x' + 8
    local numbers4 "`numbers4' `updated'"
}

collect layout (cmdset[`numbers4' ]) (result[diff])
collect style title, font(, bold)
collect style cell, border( all, width(0.5) pattern(single) )
collect style cell, halign(left) valign(center)
collect stars p .01 `"***"' .05 `"**"' .1 `"*"', attach(diff) shownote
collect style cell, nformat(%7.3g)


foreach x of local numbers4{
	
    local updated = `x' + 8
    local numbers5 "`numbers5' `updated'"
}

collect layout (cmdset[`numbers5' ]) (result[diff])
collect style title, font(, bold)
collect style cell, border( all, width(0.5) pattern(single) )
collect style cell, halign(left) valign(center)
collect stars p .01 `"***"' .05 `"**"' .1 `"*"', attach(diff) shownote
collect style cell, nformat(%7.3g)


foreach x of local numbers5{
	
    local updated = `x' + 8
    local numbers6 "`numbers6' `updated'"
}

collect layout (cmdset[`numbers6' ]) (result[diff])
collect style title, font(, bold)
collect style cell, border( all, width(0.5) pattern(single) )
collect style cell, halign(left) valign(center)
collect stars p .01 `"***"' .05 `"**"' .1 `"*"', attach(diff) shownote
collect style cell, nformat(%7.3g)



foreach x of local numbers6{
	
    local updated = `x' + 8
    local numbers7 "`numbers7' `updated'"
}

collect layout (cmdset[`numbers7' ]) (result[diff])
collect style title, font(, bold)
collect style cell, border( all, width(0.5) pattern(single) )
collect style cell, halign(left) valign(center)
collect stars p .01 `"***"' .05 `"**"' .1 `"*"', attach(diff) shownote
collect style cell, nformat(%7.3g)




}
