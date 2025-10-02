clear

***set pathnames

local project "RFE"
include "/Users/albertoornaghi/Documents/GitHub/coding_samples/Helper/pathnames.do"

***set locals for running code

local data_policy				1
local data_moderates			1
local data_radicals				1
local merge						1		
local did						1


use "$RFEDATA/RFE_data_clean.dta", clear


if `data_policy'==1{

***prepare policy dataset for DiD - then merge with others for radical and moderate etc


drop Progress-post_activism_radical_4
drop greenpeace_aware-none_radical
drop post_moderate_mean-post_moderate_factor
*drop _est_post_moderate_mean_1-_est_post_policy_factor_2 _est_post_radical_mean_1-_est_post_radical_factor_2

xpose, varname clear //transpose dataset

stack v1-v116, into(policy_support) clear //stack individauls into one variable

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
gen group1=.
gen group2=.
gen group3=.
gen attention_correct=.
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
	replace group1 = policy_support[`n'] if individual == `x'
	local n = `n' + 1
	replace group2 = policy_support[`n'] if individual == `x'
	local n = `n' + 1
	replace group3 = policy_support[`n'] if individual == `x'
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

***set every other observation to post_group 

gen post_group=0

local numbers
forvalues i = 2(2)226 {
    local numbers "`numbers' `i'" 
} 

foreach x of local numbers{
	replace post_group=1 in `x'
}

***drop all observations for which post-group measure is missing - i.e. all unique values of individual

duplicates tag individual, gen(dup)
drop if dup==0

***repeat process to obtain similar datasets for the moderates and radicals support then merge them using an id variable - datasets should be structered the same way so the observation numbers will match exactly across them, thus merging both individuals and timing perfectly

gen merge_id = _n

tempfile transpose_policy
save `transpose_policy' // save policy transpose as tempfile

}

if `data_moderates'==1{

/// prepare moderates file

use "$RFEDATA/RFE_data_clean.dta", clear

egen pre_activism_moderate = rmean(pre_activism_1 pre_activism_3)

drop Progress-post_activism_radical_4
drop greenpeace_aware-none_radical
drop post_policy_mean-post_moderate_factor
*drop _est_post_moderate_mean_1-_est_post_policy_factor_2 _est_post_radical_mean_1-_est_post_radical_factor_2

xpose, varname clear 

stack v1-v116, into(moderate_support) clear

gen gender=.
gen age=.
gen uk_res=.
gen education=.
gen income=.
gen partisanship=.
gen pre_policy=.
gen pre_anxiety=.
gen pre_norms=.
gen pre_justice=.
gen pre_behaviours=.
gen control=.
gen group1=.
gen group2=.
gen group3=.
gen attention_correct=.
rename _stack individual

***extract control variable values from moderates support variable

local numbers
forvalues i = 1/116 {
    local numbers "`numbers' `i'" 
} 

local n = 1

foreach x of local numbers{
	replace gender = moderate_support[`n'] if individual == `x' 
	local n = `n' + 1 
	replace age = moderate_support[`n'] if individual == `x' 
	local n = `n' + 1
	replace uk_res = moderate_support[`n'] if individual == `x'
	local n = `n' + 1
	replace education = moderate_support[`n'] if individual == `x'
	local n = `n' + 1
	replace income = moderate_support[`n'] if individual == `x'
	local n = `n' + 1
	replace partisanship = moderate_support[`n'] if individual == `x'
	local n = `n' + 1
	replace pre_policy = moderate_support[`n'] if individual == `x'
	local n = `n' + 2
	replace pre_anxiety = moderate_support[`n'] if individual == `x'
	local n = `n' + 1
	replace pre_norms = moderate_support[`n'] if individual == `x'
	local n = `n' + 1
	replace pre_justice = moderate_support[`n'] if individual == `x'
	local n = `n' + 1
	replace pre_behaviours = moderate_support[`n'] if individual == `x'
	local n = `n' + 1
	replace control = moderate_support[`n'] if individual == `x'
	local n = `n' + 1
	replace group1 = moderate_support[`n'] if individual == `x'
	local n = `n' + 1
	replace group2 = moderate_support[`n'] if individual == `x'
	local n = `n' + 1
	replace group3 = moderate_support[`n'] if individual == `x'
	local n = `n' + 1
	replace attention_correct = moderate_support[`n'] if individual== `x'
	local n = `n' + 2
}

***set control variable values to missing within moderate support

local numbers
forvalues i = 1/116 {
    local numbers "`numbers' `i'" 
} 

local n = 1

foreach x of local numbers{
	replace moderate_support =. in `n' if individual == `x' 
	local n = `n' + 1 
	replace moderate_support =. in `n' if individual == `x' 
	local n = `n' + 1
	replace moderate_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace moderate_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace moderate_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace moderate_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace moderate_support =. in `n' if individual == `x'
	local n = `n' + 2
	replace moderate_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace moderate_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace moderate_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace moderate_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace moderate_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace moderate_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace moderate_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace moderate_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace moderate_support =. in `n' if individual== `x'
	local n = `n' + 2
}

drop if moderate_support==.

gen merge_id = _n

duplicates tag individual, gen(dup)
drop if dup==0 //drop all observations for which post-group measure is missing

tempfile transpose_moderate
save `transpose_moderate'

}

if `data_radicals'==1{

///prepare radicals file

use "$RFEDATA/RFE_data_clean.dta", clear

gen pre_activism_radical = pre_activism_2

drop Progress-post_activism_radical_4
drop greenpeace_aware-none_radical
drop post_policy_mean-post_moderate_factor
*drop _est_post_moderate_mean_1-_est_post_policy_factor_2 _est_post_radical_mean_1-_est_post_radical_factor_2

xpose, varname clear

stack v1-v116, into(radical_support) clear

gen gender=.
gen age=.
gen uk_res=.
gen education=.
gen income=.
gen partisanship=.
gen pre_policy=.
gen pre_anxiety=.
gen pre_norms=.
gen pre_justice=.
gen pre_behaviours=.
gen control=.
gen group1=.
gen group2=.
gen group3=.
gen attention_correct=.
rename _stack individual

***extract control variable values from moderates support variable

local numbers
forvalues i = 1/116 {
    local numbers "`numbers' `i'" 
} 

local n = 1

foreach x of local numbers{
	replace gender = radical_support[`n'] if individual == `x' 
	local n = `n' + 1 
	replace age = radical_support[`n'] if individual == `x' 
	local n = `n' + 1
	replace uk_res = radical_support[`n'] if individual == `x'
	local n = `n' + 1
	replace education = radical_support[`n'] if individual == `x'
	local n = `n' + 1
	replace income = radical_support[`n'] if individual == `x'
	local n = `n' + 1
	replace partisanship = radical_support[`n'] if individual == `x'
	local n = `n' + 1
	replace pre_policy = radical_support[`n'] if individual == `x'
	local n = `n' + 2
	replace pre_anxiety = radical_support[`n'] if individual == `x'
	local n = `n' + 1
	replace pre_norms = radical_support[`n'] if individual == `x'
	local n = `n' + 1
	replace pre_justice = radical_support[`n'] if individual == `x'
	local n = `n' + 1
	replace pre_behaviours = radical_support[`n'] if individual == `x'
	local n = `n' + 1
	replace control = radical_support[`n'] if individual == `x'
	local n = `n' + 1
	replace group1 = radical_support[`n'] if individual == `x'
	local n = `n' + 1
	replace group2 = radical_support[`n'] if individual == `x'
	local n = `n' + 1
	replace group3 = radical_support[`n'] if individual == `x'
	local n = `n' + 1
	replace attention_correct = radical_support[`n'] if individual== `x'
	local n = `n' + 2
}

***set control variable values to missing within moderate support

local numbers
forvalues i = 1/116 {
    local numbers "`numbers' `i'" 
} 

local n = 1

foreach x of local numbers{
	replace radical_support =. in `n' if individual == `x' 
	local n = `n' + 1 
	replace radical_support =. in `n' if individual == `x' 
	local n = `n' + 1
	replace radical_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace radical_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace radical_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace radical_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace radical_support =. in `n' if individual == `x'
	local n = `n' + 2
	replace radical_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace radical_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace radical_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace radical_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace radical_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace radical_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace radical_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace radical_support =. in `n' if individual == `x'
	local n = `n' + 1
	replace radical_support =. in `n' if individual== `x'
	local n = `n' + 2
}


gen merge_id = _n

drop if radical_support==.

duplicates tag individual, gen(dup)
drop if dup==0
drop dup

tempfile transpose_radical
save `transpose_radical'

}

if `merge'==1{

///merge on individual and merging tag (i.e. observation number)

use `transpose_policy',clear
merge 1:1 merge_id individual using `transpose_moderate'
drop if _merge!=1
drop _merge //remove irrelevant observations such as control variables

tempfile transpose_merge_1
save `transpose_merge_1'

///merge with transpose 1 on individual and merge_id

use `transpose_merge_1',clear

merge 1:1 merge_id individual using `transpose_radical'
drop if _merge!=1
drop _merge //remove irrelevant observations such as control variables

order moderate_support radical_support
order individual policy_support

drop merge_id

save "$RFEDATA/RFE_did_transpose.data", replace

}

if `did'==1{

***dataset for DiD is now complete with tags for pre- and psot-group and all three necessary DVs - now run the DiD using a modified TWFE model

foreach x of varlist control group1 group2 group3{
	gen `x'post = `x' * post_group
}

foreach x of varlist policy_support-radical_support{
	reg `x' group1post group2post group3post i.individual i.post_group, robust
	est store `x'
}

etable, est(policy_support radical_support moderate_support) keep(group1post group2post group3post _cons) mstat(N) mstat(r2) stars(0.1 "*" 0.05 "**" 0.01 "***", attach(_r_b)) eqrecode(policy_support=dv radical_support=dv moderate_support=dv) col(depvar) 


}







