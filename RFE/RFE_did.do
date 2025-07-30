
***prepare policy dataset for DiD - then merge with others for radical and moderate etc

use "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV398/Dissertation/Datasets/GV398_transpose_policy.dta", clear

drop Progress-post_activism_radical_4
drop greenpeace_aware-er_radical
drop post_moderate_mean-_est_moderate_difference_2

xpose, varname clear

stack v1-v116, into(policy)

gen gender=.
gen age=.
gen uk_res=.
gen education=.
gen income=.
gen partisanship=.
gen pre_activism=.
gen pre_anxiety=.
gen pre_norms=.
gen pre_justice=.
gen pre_behaviours=.
gen control=.
gen treatment1=.
gen treatment2=.
gen treatment3=.
gen attention_correct=.

rename policy policy_support
rename _stack individual

***extract control variables from policy_support variable and place them into the relevant variables

local numbers
forvalues i = 1/116 {
    local numbers "`numbers' `i'" 
} 

local n = 1

foreach x of local numbers{
	replace gender = policy_support[`n'] if individual == `x' 
	local n = `n' + 1 
	replace age = policy_support[`n'] if individual == `x' 
	local n = `n' + 1
	replace uk_res = policy_support[`n'] if individual == `x'
	local n = `n' + 1
	replace education = policy_support[`n'] if individual == `x'
	local n = `n' + 1
	replace income = policy_support[`n'] if individual == `x'
	local n = `n' + 1
	replace partisanship = policy_support[`n'] if individual == `x'
	local n = `n' + 2
	replace pre_activism = policy_support[`n'] if individual == `x'
	local n = `n' + 1
	replace pre_anxiety = policy_support[`n'] if individual == `x'
	local n = `n' + 1
	replace pre_norms = policy_support[`n'] if individual == `x'
	local n = `n' + 1
	replace pre_justice = policy_support[`n'] if individual == `x'
	local n = `n' + 1
	replace pre_behaviours = policy_support[`n'] if individual == `x'
	local n = `n' + 1
	replace control = policy_support[`n'] if individual == `x'
	local n = `n' + 1
	replace treatment1 = policy_support[`n'] if individual == `x'
	local n = `n' + 1
	replace treatment2 = policy_support[`n'] if individual == `x'
	local n = `n' + 1
	replace treatment3 = policy_support[`n'] if individual == `x'
	local n = `n' + 1
	replace attention_correct = policy_support[`n'] if individual== `x'
	local n = `n' + 2
}

***set all control values in policy_support variable to missing

local numbers
forvalues i = 1/116 {
    local numbers "`numbers' `i'" 
} 

local n = 1

foreach x of local numbers{
	replace policy_support =. in `n' if individual == `x' 
	local n = `n' + 1 
	replace policy_support =. in `n' if individual == `x' 
	local n = `n' + 1
	replace policy_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace policy_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace policy_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace policy_support =. in `n' if individual == `x'
	local n = `n' + 2
	replace policy_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace policy_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace policy_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace policy_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace policy_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace policy_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace policy_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace policy_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace policy_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace policy_support =. in `n' if individual== `x'
	local n = `n' + 2
}

drop if policy_support==.

***set every other observation to post_treatment 

gen post_treatment=0

local numbers
forvalues i = 2(2)226 {
    local numbers "`numbers' `i'" 
} 

foreach x of local numbers{
	replace post_treatment=1 in `x'
}

***drop all observations for which post-treatment measure is missing - i.e. all unique values of individual

duplicates tag individual, gen(dup)
drop if dup==0

***repeat process to obtain similar datasets for the moderates and radicals support then merge them using an id variable - datasets should be structered the same way so the observation numbers will match exactly across them, thus merging both individuals and timing perfectly

gen merge_id = _n

/// prepare moderates file

use "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV398/Dissertation/Datasets/GV398_transpose_moderate.dta"

drop Progress-post_policy_mean
drop post_radical_mean-post_activism_full_mean
drop pre_activism_radical policy_difference-_est_moderate_difference_2

order pre_activism_moderate

xpose, varname clear
save "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV398/Dissertation/Datasets/GV398_transpose_moderate.dta", replace

stack v1-v116, into(moderate_support)

rename _stack individual

gen merge_id = _n

///drop all observations for which post-treatment measure is missing

drop if moderate_support==.

duplicates tag individual, gen(dup)
drop if dup==0

///merge on individual and merging tag (i.e. observation number)

merge 1:1 merge_id individual using "GV398_transpose_moderate.dta"

///prepare radicals file

use "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV398/Dissertation/Datasets/GV398_transpose_radical.dta"

drop Progress-post_moderate_mean
drop none_radical-post_activism_full_mean
drop pre_activism_moderate-_est_moderate_difference_2
order pre_activism_radical

xpose, varname clear
save "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV398/Dissertation/Datasets/GV398_transpose_radical.dta", replace

stack v1-v116, into(radical_support)
save "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV398/Dissertation/Datasets/GV398_transpose_radical.dta", replace

rename _stack individual

gen merge_id = _n

drop if radical_support==.

duplicates tag individual, gen(dup)
drop if dup==0
drop dup

///merge with policy transpose file on individual and merge_id

merge 1:1 merge_id individual using "GV398_transpose_radical.dta"

order moderate_support radical_support
order individual policy_support

drop merge_id

***dataset for DiD is now complete with tags for pre- and psot-treatment and all three necessary DVs - now run the DiD using a modified TWFE model

foreach x of varlist policy_support-radical_support{
	reg `x' treatment1post treatment2post treatment3post i.individual i.post_treatment, robust
	est store `x'
}

etable, est(policy_support radical_support moderate_support) keep(treatment1post treatment2post treatment3post _cons) mstat(N) mstat(r2) stars(0.1 "*" 0.05 "**" 0.01 "***", attach(_r_b)) eqrecode(policy_support=dv radical_support=dv moderate_support=dv) col(depvar) 










