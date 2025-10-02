clear

***set pathnames

local project "RFE"
include "/Users/albertoornaghi/Documents/GitHub/coding_samples/Helper/pathnames.do"


***set locals for running code

local main_regressions					1
local additional_tests					1


use "$RFEDATA/RFE_data_clean.dta", clear


if `main_regressions'==1{

	***run all baseline RFE regressions i.e. radical activism support, moderate activism support, and policy support on group

	foreach x of varlist post_radical_mean post_radical_factor post_moderate_mean post_moderate_factor post_policy_mean post_policy_factor{
		reg `x'  group1 group2 group3, robust
		est store `x'_1
		reg `x' group1 group2 group3 gender-partisanship pre_policy-pre_behaviours attention_correct, robust
		est store `x'_2
	}

	etable, estimates(post_radical_mean_1 post_radical_mean_2 post_radical_factor_1 post_radical_factor_2) ///
	stars(0.1 "*" 0.05 "**" 0.01 "***", attach(_r_b)) col(depvar) eqrecode(post_radical_mean=dv ///
	post_radical_factor=dv) mstat(r2) mstat(N) export("$RFETAB/radicalols.tex", replace)

	etable, estimates(post_moderate_mean_1 post_moderate_mean_2 post_moderate_factor_1 post_moderate_factor_2) ///
	stars(0.1 "*" 0.05 "**" 0.01 "***", attach(_r_b)) col(depvar) eqrecode(post_moderate_mean=dv ///
	post_moderate_factor=dv) mstat(r2) mstat(N) export("$RFETAB/moderateols.tex", replace)

	etable, estimates(post_policy_mean_1 post_policy_mean_2 post_policy_factor_1 post_policy_factor_2) ///
	stars(0.1 "*" 0.05 "**" 0.01 "***", attach(_r_b)) col(depvar) eqrecode(post_policy_mean=dv ///
	post_policy_factor=dv) mstat(r2) mstat(N) export("$RFETAB/policyols.tex", replace)

}

if `additional_tests'==1{

	***test out including an awareness control

	egen awareness_mean = rmean(greenpeace_aware-er_aware)

	foreach x of varlist post_policy_mean-post_radical_mean post_policy_factor-post_moderate_factor{
		reg `x' group1 group2 group3 gender-partisanship pre_policy-pre_behaviours attention_correct awareness_mean, robust
	}

	***test radicals RFE on subsamples 

	foreach x of varlist post_radical_mean post_radical_factor{
		reg `x'  group1 group2 group3 if pre_activism>=2, robust
		est store `x'_1
		reg `x' group1 group2 group3 gender-partisanship pre_policy-pre_behaviours attention_correct if pre_activism>=2, robust
		est store `x'_2
	}

	etable, estimates(post_radical_mean_1 post_radical_mean_2 post_radical_factor_1 post_radical_factor_2) ///
	stars(0.1 "*" 0.05 "**" 0.01 "***", attach(_r_b)) col(depvar) eqrecode(post_radical_mean=dv post_radical_factor=dv) ///
	mstat(r2) mstat(N) export("$RFETAB/radicalolssumsample.tex", replace)

	foreach x of varlist post_radical_mean post_radical_factor{
		reg `x'  group1 group2 group3 if pre_activism_2<=2, robust
		est store `x'_1
		reg `x' group1 group2 group3 gender-partisanship pre_policy-pre_behaviours attention_correct if pre_activism_2<=2, robust
		est store `x'_2
	}

	etable, estimates(post_radical_mean_1 post_radical_mean_2 post_radical_factor_1 post_radical_factor_2) ///
	stars(0.1 "*" 0.05 "**" 0.01 "***", attach(_r_b)) col(depvar) eqrecode(post_radical_mean=dv post_radical_factor=dv) ///
	mstat(r2) mstat(N) export("$RFETAB/radicalolssumsample2.tex", replace)

}
