
***run key regression of radical activism support on treatment

foreach x of varlist post_radical_mean post_radical_factor{
	reg `x'  treatment1 treatment2 treatment3 if pre_activism<2, robust
	est store `x'_1
	reg `x' treatment1 treatment2 treatment3 gender-partisanship pre_policy-pre_behaviours attention_correct if pre_activism<2, robust
	est store `x'_2
}

etable, estimates(post_radical_mean_1 post_radical_mean_2 post_radical_factor_1 post_radical_factor_2) stars(0.1 "*" 0.05 "**" 0.01 "***", attach(_r_b)) col(depvar) eqrecode(post_radical_mean=dv post_radical_factor=dv) mstat(r2) mstat(N) export(radicalols.tex)

***run key regression of moderate activism support on treatment

foreach x of varlist post_moderate_mean post_moderate_factor {
	reg `x'  treatment1 treatment2 treatment3, robust
	est store `x'_1
	reg `x' treatment1 treatment2 treatment3 gender-partisanship pre_policy-pre_behaviours attention_correct, robust
	est store `x'_2
}

etable, estimates(post_moderate_mean_1 post_moderate_mean_2 post_moderate_factor_1 post_moderate_factor_2) stars(0.1 "*" 0.05 "**" 0.01 "***", attach(_r_b)) col(depvar) eqrecode(post_moderate_mean=dv post_moderate_factor=dv) mstat(r2) mstat(N) export(moderateols.tex)

***run key regression of policy support on treatment

foreach x of varlist post_policy_mean post_policy_factor {
	reg `x'  treatment1 treatment2 treatment3, robust
	est store `x'_1
	reg `x' treatment1 treatment2 treatment3 gender-partisanship pre_policy-pre_behaviours attention_correct, robust
	est store `x'_2
}

etable, estimates(post_policy_mean_1 post_policy_mean_2 post_policy_factor_1 post_policy_factor_2) stars(0.1 "*" 0.05 "**" 0.01 "***", attach(_r_b)) col(depvar) eqrecode(post_policy_mean=dv post_policy_factor=dv) mstat(r2) mstat(N) export(policyols.tex)

***test out including an awareness control

egen awareness_mean = rmean(greenpeace_aware-er_aware)

foreach x of varlist post_policy_mean-post_radical_mean post_policy_factor-post_moderate_factor{
	reg `x' treatment1 treatment2 treatment3 gender-partisanship pre_policy-pre_behaviours attention_correct awareness_mean, robust
} ///either leaves results the same or makes them worse... no need to include this in diss results

***test radicals RFE on subsamples 

foreach x of varlist post_radical_mean post_radical_factor{
reg `x'  treatment1 treatment2 treatment3 if pre_activism>=2, robust
est store `x'_1
reg `x' treatment1 treatment2 treatment3 gender-partisanship pre_policy-pre_behaviours attention_correct if pre_activism>=2, robust
est store `x'_2
}

etable, estimates(post_radical_mean_1 post_radical_mean_2 post_radical_factor_1 post_radical_factor_2) stars(0.1 "*" 0.05 "**" 0.01 "***", attach(_r_b)) col(depvar) eqrecode(post_radical_mean=dv post_radical_factor=dv) mstat(r2) mstat(N) export(radicalolssumsample.tex)

foreach x of varlist post_radical_mean post_radical_factor{
reg `x'  treatment1 treatment2 treatment3 if pre_activism_2<=2, robust
est store `x'_1
reg `x' treatment1 treatment2 treatment3 gender-partisanship pre_policy-pre_behaviours attention_correct if pre_activism_2<=2, robust
est store `x'_2
}

etable, estimates(post_radical_mean_1 post_radical_mean_2 post_radical_factor_1 post_radical_factor_2) stars(0.1 "*" 0.05 "**" 0.01 "***", attach(_r_b)) col(depvar) eqrecode(post_radical_mean=dv post_radical_factor=dv) mstat(r2) mstat(N) export(radicalolssumsample2.tex, replace)





