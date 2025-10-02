clear

***set pathnames

local project "RFE"
include "/Users/albertoornaghi/Documents/GitHub/coding_samples/Helper/pathnames.do"


***set locals for running code

local first_transpose					1
local summary							1
local prob_models_baseline				1
local prob_models_subsample				1
local prob_models_awareness				1						
local prob_models_speaker				1





use "$RFEDATA/RFE_data_clean.dta", clear

*** for the probability models, I now create a new dataset by transposing the original, and hence turn my unit of analysis to individual-statements

save "$RFEDATA/RFE_dataset_transpose.dta", replace //save a new copy of original dataset

if `first_transpose'==1{
	
	egen awareness_mean= rmean(radical_aware_full moderate_aware_full)

	drop Progress-pre_behaviours_5
	drop attention-post_activism_radical_4
	drop greenpeace_aware-none_radical
	drop post_policy_mean-moderate_percep

	xpose, clear varname // transpose dataset to turn variables into observations and observations into variables ///
	//- then, each variable represents one individual so, within each variable, the rows include responses to each statement

	stack v1-v116, into(support) clear // stack all the variables into 1 so I have a single variable that includes each individual-statement observation (and controls)

	gen gender =. // generate new variables to populate with controls
	gen age=.
	gen uk_res=.
	gen education=.
	gen income=.
	gen partisanship=.
	gen pre_policy=.
	gen pre_activism=.
	gen pre_anxiety=.
	gen pre_norms =.
	gen pre_justice=.
	gen pre_behaviours=.
	gen control =.
	gen group1=.
	gen group2=.
	gen group3=.
	gen attention_correct=.
	gen awareness_mean=.
	rename _stack individual 
	gen radical_speaker=0 //define regressors of interest
	gen radical_language=0

	***add controls to each individual-statement oberservation from within the "support" variable

	local numbers
	
	forvalues i = 1/116 {
		local numbers "`numbers' `i'" // define local for counting out individuals
	} 

	local n = 57 //define local for counting observations

	foreach x of local numbers{
		replace gender = support[`n'] if individual == `x' // for all observations for the individual of the relevant number `x', replace all entries in their gender variable with the `n'th observation, which is their response to the gender question from the original dataset, obtained as observations in the main support variable due to transposing and stacking
		local n = `n' + 1 //change observation number to that of the next control variable entry
		replace age = support[`n'] if individual == `x' // repeat for next control variable
		local n = `n' + 1
		replace uk_res = support[`n'] if individual == `x'
		local n = `n' + 1
		replace education = support[`n'] if individual == `x'
		local n = `n' + 1
		replace income = support[`n'] if individual == `x'
		local n = `n' + 1
		replace partisanship = support[`n'] if individual == `x'
		local n = `n' + 1
		replace pre_policy = support[`n'] if individual == `x'
		local n = `n' + 1
		replace pre_activism = support[`n'] if individual == `x'
		local n = `n' + 1
		replace pre_anxiety = support[`n'] if individual == `x'
		local n = `n' + 1
		replace pre_norms = support[`n'] if individual == `x'
		local n = `n' + 1
		replace pre_justice = support[`n'] if individual == `x'
		local n = `n' + 1
		replace pre_behaviours = support[`n'] if individual == `x'
		local n = `n' + 1
		replace control = support[`n'] if individual == `x'
		local n = `n' + 1
		replace group1 = support[`n'] if individual == `x'
		local n = `n' + 1
		replace group2 = support[`n'] if individual == `x'
		local n = `n' + 1
		replace group3 = support[`n'] if individual == `x'
		local n = `n' + 1
		replace attention_correct = support[`n'] if individual== `x'
		local n = `n' + 1
		replace awareness_mean = support[`n'] if individual== `x'
		local n = `n' + 57
	}

	local n = 57

	foreach x of local numbers{
		forvalues i = 1/18{
	
			replace support=. in `n' if individual == `x' //set all entries in main support variable that included control values to missing
			local n = `n' + 1
		}
	local n = `n' + 56
	}

	drop if support==. //drop all observations that are missing to remove entries for other group groups and controls


	***flip coding of support variable for negatively worded statements in survey - i.e. control and group1 statements 7, 9, 12, 13

	local numbers
	
	forvalues i = 1/116 {
		local numbers "`numbers' `i'" 
	} 

	local n = 7

	foreach x of local numbers{ //can't loop over control and group1 becuase value of local will change 
		
		replace support = support - 1 in `n' if individual == `x' & control ==1
		replace support = 1 in `n' if support == -1 & individual == `x' & control ==1
		replace support = support - 1 in `n' if individual == `x' & group1==1
		replace support = 1 in `n' if support == -1 & individual == `x' & group1==1
	
		local n = `n' + 2
	
		replace support = support - 1 in `n' if individual == `x' & control ==1
		replace support = 1 in `n' if support == -1 & individual == `x' & control ==1
		replace support = support - 1 in `n' if individual == `x' & group1==1
		replace support = 1 in `n' if support == -1 & individual == `x' & group1==1
	
		local n = `n' + 3
	
		replace support = support - 1 in `n' if individual == `x' & control ==1
		replace support = 1 in `n' if support == -1 & individual == `x' & control ==1
		replace support = support - 1 in `n' if individual == `x' & group1==1
		replace support = 1 in `n' if support == -1 & individual == `x' & group1==1
	
		local n = `n' + 1
	
		replace support = support - 1 in `n' if individual == `x' & control ==1
		replace support = 1 in `n' if support == -1 & individual == `x' & control ==1
		replace support = support - 1 in `n' if individual == `x' & group1==1
		replace support = 1 in `n' if support == -1 & individual == `x' & group1==1
	
		local n = `n' + 8
	
	}

	***define regressors of interest

	replace radical_speaker=1 if group1==1 | group3==1
	replace radical_language=1 if group2==1 | group3==1
	tab group2 radical_language

	save "$RFEDATA/RFE_dataset_transpose.dta", replace
	
}



if `summary'==1{

	***summary statistics for individual-statements!!

	foreach x of varlist control-group3{
		table (`x') (result) if `x'==1, stat(fvfreq support) stat(fvperc support) notot

		collect style title, font(, bold)
		collect style cell, border( all, width(0.5) pattern(single) )
		collect style cell, halign(left) valign(center)
		collect label levels result fvfrequency "Total individual-statements", modify
		collect label levels result fvpercent "Percentage of individual-statements", modify

		collect style row stack, delimiter(`" # "') atdelimiter(`" @ "') bardelimiter(`" | "') ///
		binder(`"="') nospacer noindent length(.) wrapon(word) noabbreviate wrap(.) truncate(tail)
		collect style header `x', level(hide)

		collect export "$RFETAB/summary_`x'.tex", as(tex) replace
	}

}


if `prob_models_baseline'==1{
	
	***label variables

	labvars gender age uk_res education income partisanship pre_policy pre_activism pre_anxiety ///
	pre_norms pre_justice pre_behaviours attention_correct awareness_mean radical_speaker radical_language ///
	"Gender" "Age" "UK Resdient" "Education" "Income" "Partisanship" "Policy support" "Activism support" ///
	"Eco-anxiety" "Norms" "Justice" "Behaviours" "Attention" "Awareness" "Radical Speaker" "Radical Language"

	***run regressions and calculate APE

	foreach comm in logit probit {
	
		`comm' support radical_speaker radical_language, robust
		margins, dydx(*) 
		est store `comm'1

		`comm' support radical_speaker radical_language gender-pre_behaviours attention_correct, robust
		margins, dydx(*) 
		est store `comm'2

	}

	etable, estimates(logit1 logit2 probit1 probit2) stars(0.1 "*" 0.05 "**" 0.01 "***", attach(_r_b)) col(command) export("$RFETAB/probcoefficients.tex", replace)

	drop _est_logit1-_est_probit2

	foreach comm in logit probit {
	
		`comm' support radical_speaker radical_language, robust
		margins, dydx(*) post
		est store `comm'1

		`comm' support radical_speaker radical_language gender-pre_behaviours attention_correct, robust
		margins, dydx(*) post
		est store `comm'2

	
	}

	etable, estimates(logit1 logit2 probit1 probit2) stars(0.1 "*" 0.05 "**" 0.01 "***", ///
	attach(_r_b)) col(estimates) export("$RFETAB/probmargins.tex", replace)

	drop _est_logit1-_est_probit2

	***calculate margins at different levels and plot them - do for just one of the two CDFs

		local y1 radical_language
		local y2 radical_speaker

		foreach x of varlist pre_policy-pre_behaviours {
			foreach y in y1 y2{
				logit support radical_speaker radical_language gender-pre_behaviours attention_correct, robust
				margins, dydx(``y'') at(`x'=(0(0.5)4)) post
				est store margins_`x'_`y'
			}
		}
	

	
	coefplot margins_pre_norms_y1 margins_pre_justice_y1 margins_pre_anxiety_y1 margins_pre_behaviours_y1 ///
	margins_pre_activism_y1 margins_pre_policy_y1, at xtitle("Level of pre-treatment covariate") ///
	ytitle("Pr(Support = 1)") noci recast(line) xlabel(,nogrid) ylabel(,nogrid) legend(label(1 "Norms") ///
	label(2 "Justice") label(3 "Anxiety") label(4 "Behaviours") label(5 "Activism") label(6 "Policy"))
	
	coefplot margins_pre_norms_y2 margins_pre_justice_y2 margins_pre_anxiety_y2 margins_pre_behaviours_y2 ///
	margins_pre_activism_y2 margins_pre_policy_y2, at xtitle("Level of pre-treatment covariate") ///
	ytitle("Pr(Support = 1)") noci recast(line) xlabel(,nogrid) ylabel(,nogrid) legend(label(1 "Norms") ///
	label(2 "Justice") label(3 "Anxiety") label(4 "Behaviours") label(5 "Activism") label(6 "Policy"))


}


if `prob_models_subsample'==1{

	***run probability models on a subset of statements by removing the least extreme ones (1, 11, 14)
	
	gen support_ex_least = support
	
	local numbers
	forvalues i = 1/116 {
		local numbers "`numbers' `i'" 
	} 

	local n = 1

	foreach x of local numbers{
	
		replace support_ex_least =. in `n' if individual==`x'
		
		local n = `n' + 10
	
		replace support_ex_least =. in `n' if individual==`x'
		
		local n = `n' + 3
	
		replace support_ex_least =. in `n' if individual==`x'
	
		local n = `n' + 1
	
	}

	foreach comm in logit probit{
	
		`comm' support_ex_least radical_speaker radical_language, robust
		margins, dydx(*) post
		est store `comm'1

		`comm' support_ex_least radical_speaker radical_language gender-pre_behaviours attention_correct, robust
		margins, dydx(*) post
		est store `comm'2
	
	}

	etable, estimates(logit1 logit2 probit1 probit2) stars(0.1 "*" 0.05 "**" 0.01 "***", ///
	attach(_r_b)) col(command) export("$RFETAB/margins_least.tex",replace)

	drop _est_logit1-_est_probit2

	***run probability models on a subset of statements by removing the most extreme ones (2, 4, 5, 9, 12, 13)

	gen support_ex_most = support

	local numbers

	forvalues i = 1/116 {
		local numbers "`numbers' `i'" 
	} 

	local n = 2

	foreach x of local numbers{
	
		replace support_ex_most =. in `n' if individual==`x'
		
		local n = `n' + 2
	
		replace support_ex_most =. in `n' if individual==`x'
	
		local n = `n' + 1
	
		replace support_ex_most =. in `n' if individual==`x'
	
		local n = `n' + 4
	
		replace support_ex_most =. in `n' if individual==`x'
	
		local n = `n' + 3
	
		replace support_ex_most =. in `n' if individual==`x'
	
		local n = `n' + 1
	
		replace support_ex_most =. in `n' if individual==`x'
	
		local n = `n' + 3
	}

	foreach comm in logit probit{
	
		`comm' support_ex_most radical_speaker radical_language, robust
		margins, dydx(*) post
		est store `comm'1

		`comm' support_ex_most radical_speaker radical_language gender-pre_behaviours attention_correct, robust
		margins, dydx(*) post
		est store `comm'2
	
	}

	etable, estimates(logit1 logit2 probit1 probit2) stars(0.1 "*" 0.05 "**" 0.01 "***" ///
	, attach(_r_b)) col(command) export("$RFETAB/margins_most.tex",replace)
}

if `prob_models_awareness'==1{

	***estimate full sample probability models with awareness control

	foreach comm in logit probit{

		`comm' support radical_speaker radical_language, robust
		margins, dydx(*) post
		est store `comm'1

		`comm' support radical_speaker radical_language gender-pre_behaviours attention_correct awareness_mean, robust
		margins, dydx(*) post
		est store `comm'2

	}

	etable, estimates(logit1 logit2 probit1 probit2) stars(0.1 "*" 0.05 "**" 0.01 "***" ///
	, attach(_r_b)) col(estimates) export("$RFETAB/marginsawareness.tex",replace)


***margins analysis with awareness control

	foreach x of varlist pre_policy-pre_behaviours{

		logit support radical_speaker radical_language gender-pre_behaviours attention_correct awareness_mean, robust
		margins, dydx(radical_language) at(`x'=(0(0.5)4)) post
		est store margins_`x'

	}

	coefplot margins_pre_norms margins_pre_justice margins_pre_anxiety margins_pre_behaviours margins_pre_activism margins_pre_policy ///
	, at xtitle("Level of pre-treatment covariate") ytitle("Pr(Support = 1)") noci recast(line) ///
	xlabel(,nogrid) ylabel(,nogrid) legend(label(1 "Norms") label(2 "Justice") label(3 "Anxiety") ///
	label(4 "Behaviours") label(5 "Activism") label(6 "Policy"))
	
	graph export "$RFETAB/marginsplot_awareness.jpg", as(jpg) quality(100) replace

///no differences detected compared to standard model w/out awareness

}

if `prob_models_speaker'==1{

***create new variables to indicate the specific speaker in the radical statements - JSO is 4, 7, 10, 13, 14  - IB is 1, 2, 8, 11, 12 - ER is 3, 5, 6, 9

	gen ib_speaker=0
	gen er_speaker=0
	gen jso_speaker=0


	local numbers
	
	forvalues i = 1/116 {
		local numbers "`numbers' `i'" 
	} 

	local n = 1

	foreach x of local numbers{
	
		replace ib_speaker =1 in `n' if individual==`x' & (group1==1 | group3==1)
	
		local n = `n' + 1
	
		replace ib_speaker =1 in `n' if individual==`x' & (group1==1 | group3==1)
	
		local n = `n' + 1
	
		replace er_speaker =1 in `n' if individual==`x' & (group1==1 | group3==1)
	
		local n = `n' + 1
	
		replace jso_speaker =1 in `n' if individual==`x' & (group1==1 | group3==1)
	
		local n = `n' + 1
	
		replace er_speaker =1 in `n' if individual==`x' & (group1==1 | group3==1)
	
		local n = `n' + 1
	
		replace er_speaker =1 in `n' if individual==`x' & (group1==1 | group3==1)
	
		local n = `n' + 1
	
		replace jso_speaker =1 in `n' if individual==`x' & (group1==1 | group3==1)
	
		local n = `n' + 1
	
		replace ib_speaker =1 in `n' if individual==`x' & (group1==1 | group3==1)
	
		local n = `n' + 1
		
		replace er_speaker =1 in `n' if individual==`x' & (group1==1 | group3==1)
	
		local n = `n' + 1
	
		replace jso_speaker =1 in `n' if individual==`x' & (group1==1 | group3==1)
		
		local n = `n' + 1
	
		replace ib_speaker =1 in `n' if individual==`x' & (group1==1 | group3==1)
	
		local n = `n' + 1
	
		replace ib_speaker =1 in `n' if individual==`x' & (group1==1 | group3==1)
	
		local n = `n' + 1
	
		replace jso_speaker =1 in `n' if individual==`x' & (group1==1 | group3==1)
	
		local n = `n' + 1
	
		replace jso_speaker =1 in `n' if individual==`x' & (group1==1 | group3==1)
	
		local n = `n' + 1
	
	}

	foreach comm in logit probit{
		
		`comm' support jso_speaker ib_speaker er_speaker radical_language, robust
		margins, dydx(*) post
		est store `comm'1

		`comm' support jso_speaker ib_speaker er_speaker radical_language gender-pre_behaviours attention_correct awareness_mean, robust
		margins, dydx(*) post
		est store `comm'2
		
	}
	

	etable, estimates(logit1 logit2 probit1 probit2) stars(0.1 "*" 0.05 "**" 0.01 "***", attach(_r_b)) col(estimates) export("$RFETAB/margins_speaker.tex", replace)


}

