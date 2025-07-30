
*** for the probability models, I now create a new dataset by transposing the original, and hence turn my unit of analysis to individual-statements

use "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV398/GV398_dataset_transpose.dta" ///save a new copy of original dataset

drop Progress-pre_behaviours_5
drop attention-post_activism_radical_4
drop greenpeace_aware-er_radical
drop post_policy_mean-_est_factorpol

xpose, clear varname /// transpose dataset to turn variables into observations and observations into variables - then, each variable represents one individual so, within each variable, the rows include responses to each statement

save "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV398/GV398_dataset_transpose.dta", replace

stack v1-v116, into(combined) /// stack all the variables into 1 so I have a single variable that includes each individual-statement observation (and controls)

save "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV398/GV398_dataset_transpose.dta", replace

gen gender =. /// build new variables to populate with controls
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
gen treatment1=.
gen treatment2=.
gen treatment3=.
gen attention_correct=.
gen awareness_mean=.
rename _stack individual 
rename combined agree
gen radical_speaker=0 ///define regressors of interest
gen radical_language=0

***add controls to each individual-statement oberservation from within the "agree" variable

local numbers
forvalues i = 1/116 {
    local numbers "`numbers' `i'" /// define local for counting out individuals
} 

local n = 57 ///define local for counting observations

foreach x of local numbers{
	replace gender = agree[`n'] if individual == `x' /// for all observations for the individual of the relevant number `x', replace all entries in their gender variable with the `n'th observation, which is their response to the gender question from the original dataset, obtained as observations in the main agree variable due to transposing and stacking
	local n = `n' + 1 ///change observation number to that of the next control variable entry
	replace age = agree[`n'] if individual == `x' /// repeat for next control variable
	local n = `n' + 1
	replace uk_res = agree[`n'] if individual == `x'
	local n = `n' + 1
	replace education = agree[`n'] if individual == `x'
	local n = `n' + 1
	replace income = agree[`n'] if individual == `x'
	local n = `n' + 1
	replace partisanship = agree[`n'] if individual == `x'
	local n = `n' + 1
	replace pre_policy = agree[`n'] if individual == `x'
	local n = `n' + 1
	replace pre_activism = agree[`n'] if individual == `x'
	local n = `n' + 1
	replace pre_anxiety = agree[`n'] if individual == `x'
	local n = `n' + 1
	replace pre_norms = agree[`n'] if individual == `x'
	local n = `n' + 1
	replace pre_justice = agree[`n'] if individual == `x'
	local n = `n' + 1
	replace pre_behaviours = agree[`n'] if individual == `x'
	local n = `n' + 1
	replace control = agree[`n'] if individual == `x'
	local n = `n' + 1
	replace treatment1 = agree[`n'] if individual == `x'
	local n = `n' + 1
	replace treatment2 = agree[`n'] if individual == `x'
	local n = `n' + 1
	replace treatment3 = agree[`n'] if individual == `x'
	local n = `n' + 1
	replace attention_correct = agree[`n'] if individual== `x'
	local n = `n' + 1
	replace awareness_mean = agree[`n'] if individual== `x'
	local n = `n' + 57
}

local n = 57

foreach x of local numbers{
	replace agree=. in `n' if individual == `x' ///set all entries in main agree variable that included control values to missing
	local n = `n' + 1
	replace agree=. in `n' if individual == `x'
	local n = `n' + 1
	replace agree=. in `n' if individual == `x'
	local n = `n' + 1
	replace agree=. in `n' if individual == `x'
	local n = `n' + 1
	replace agree=. in `n' if individual == `x'
	local n = `n' + 1
	replace agree=. in `n' if individual == `x'
	local n = `n' + 1
	replace agree=. in `n' if individual == `x'
	local n = `n' + 1
	replace agree=. in `n' if individual == `x'
	local n = `n' + 1
	replace agree=. in `n' if individual == `x'
	local n = `n' + 1
	replace agree=. in `n' if individual == `x'
	local n = `n' + 1
	replace agree=. in `n' if individual == `x'
	local n = `n' + 1
	replace agree=. in `n' if individual == `x'
	local n = `n' + 1
	replace agree=. in `n' if individual == `x'
	local n = `n' + 1
	replace agree=. in `n' if individual == `x'
	local n = `n' + 1
	replace agree=. in `n' if individual == `x'
	local n = `n' + 1
	replace agree=. in `n' if individual == `x'
	local n = `n' + 1
	replace agree=. in `n' if individual == `x'
	local n = `n' + 1
	replace agree=. in `n' if individual == `x'
	local n = `n' + 57
}

rename agree support

drop if support==. ///drop all observations that are missing to remove entries for other treatment groups and controls


***flip coding of support variable for negatively worded statements in survey - i.e. control and group1 statements 7, 9, 12, 13

local numbers
forvalues i = 1/116 {
    local numbers "`numbers' `i'" 
} 

local n = 7

foreach x of local numbers{
	replace support = support - 1 in `n' if individual == `x' & control ==1
	replace support = 1 in `n' if support == -1 & individual == `x' & control ==1
	replace support = support - 1 in `n' if individual == `x' & treatment1==1
	replace support = 1 in `n' if support == -1 & individual == `x' & treatment1==1
	
	local n = `n' + 2
	
	replace support = support - 1 in `n' if individual == `x' & control ==1
	replace support = 1 in `n' if support == -1 & individual == `x' & control ==1
	replace support = support - 1 in `n' if individual == `x' & treatment1==1
	replace support = 1 in `n' if support == -1 & individual == `x' & treatment1==1
	
	local n = `n' + 3
	
	replace support = support - 1 in `n' if individual == `x' & control ==1
	replace support = 1 in `n' if support == -1 & individual == `x' & control ==1
	replace support = support - 1 in `n' if individual == `x' & treatment1==1
	replace support = 1 in `n' if support == -1 & individual == `x' & treatment1==1
	
	local n = `n' + 1
	
	replace support = support - 1 in `n' if individual == `x' & control ==1
	replace support = 1 in `n' if support == -1 & individual == `x' & control ==1
	replace support = support - 1 in `n' if individual == `x' & treatment1==1
	replace support = 1 in `n' if support == -1 & individual == `x' & treatment1==1
	
	local n = `n' + 8
	
}

***define regressors of interest

replace radical_speaker=1 if treatment1==1 | treatment3==1
replace radical_language=1 if treatment2==1 | treatment3==1
tab treatment2 radical_language

***summary statistics for individual-statements!!

foreach x of varlist control-treatment3{
	table (`x') (result) if `x'==1, stat(fvfreq support) stat(fvperc support) notot

collect style title, font(, bold)
collect style cell, border( all, width(0.5) pattern(single) )
collect style cell, halign(left) valign(center)
collect label levels result fvfrequency "Total individual-statements", modify
collect label levels result fvpercent "Percentage of individual-statements", modify

collect style row stack, delimiter(`" # "') atdelimiter(`" @ "') bardelimiter(`" | "') binder(`"="') nospacer noindent length(.) wrapon(word) noabbreviate wrap(.) truncate(tail)
collect style header `x', level(hide)

collect export "summary_`x'.tex", as(tex) replace
}



***label variables

labvars gender age uk_res education income partisanship pre_policy pre_activism pre_anxiety pre_norms pre_justice pre_behaviours attention_correct awareness_mean radical_speaker radical_language "Gender" "Age" "UK Resdient" "Education" "Income" "Partisanship" "Policy support" "Activism support" "Eco-anxiety" "Norms" "Justice" "Behaviours" "Attention" "Awareness" "Radical Speaker" "Radical Language"

***run regressions and calculate APE



logit support radical_speaker radical_language, robust
margins, dydx(*) 
est store logit1

logit support radical_speaker radical_language gender-pre_behaviours attention_correct, robust
margins, dydx(*) 
est store logit2

probit support radical_speaker radical_language, robust
margins, dydx(*) 
est store probit1

probit support radical_speaker radical_language gender-pre_behaviours attention_correct, robust
margins, dydx(*)
est store probit2

etable, estimates(logit1 logit2 probit1 probit2) stars(0.1 "*" 0.05 "**" 0.01 "***", attach(_r_b)) col(command) export(probcoefficients.tex, replace)


drop _est_logit1-_est_probit2

logit support radical_speaker radical_language, robust
margins, dydx(*) post
est store logit1

logit support radical_speaker radical_language gender-pre_behaviours attention_correct, robust
margins, dydx(*) post
est store logit2

probit support radical_speaker radical_language, robust
margins, dydx(*) post
est store probit1

probit support radical_speaker radical_language gender-pre_behaviours attention_correct, robust
margins, dydx(*) post
est store probit2

etable, estimates(logit1 logit2 probit1 probit2) stars(0.1 "*" 0.05 "**" 0.01 "***", attach(_r_b)) col(estimates) export(probmargins.tex, replace)

***calculate margins at different levels and plot them - do for just one of the two CDFs

logit support radical_speaker radical_language gender-pre_behaviours attention_correct, robust
margins, dydx(radical_language) at(pre_norms=(0(0.5)4)) post
est store margins1

logit support radical_speaker radical_language gender-pre_behaviours attention_correct, robust
margins, dydx(radical_language) at(pre_justice=(0(0.5)4)) post
est store margins2

logit support radical_speaker radical_language gender-pre_behaviours attention_correct, robust
margins, dydx(radical_language) at(pre_anxiety=(0(0.5)4)) post
est store margins3

logit support radical_speaker radical_language gender-pre_behaviours attention_correct, robust
margins, dydx(radical_language) at(pre_behaviours=(0(0.5)4)) post
est store margins4

logit support radical_speaker radical_language gender-pre_behaviours attention_correct, robust
margins, dydx(radical_language) at(pre_activism=(0(0.5)4)) post
est store margins5

logit support radical_speaker radical_language gender-pre_behaviours attention_correct, robust
margins, dydx(radical_language) at(pre_policy=(0(0.5)4)) post
est store margins6

coefplot margins1 margins2 margins3 margins4 margins5 margins6, at xtitle("Level of pre-treatment covariate") ytitle("Pr(Support = 1)") noci recast(line) xlabel(,nogrid) ylabel(,nogrid) legend(label(1 "Norms") label(2 "Justice") label(3 "Anxiety") label(4 "Behaviours") label(5 "Activism") label(6 "Policy"))

***extra analysis to understand why margins are decreasing or flat - focus on pre_treatment activism support

***margins analysis on radical_speaker

logit support radical_speaker radical_language gender-pre_behaviours attention_correct, robust
margins, dydx(radical_speaker) at(pre_norms=(0(0.5)4)) post
est store margins1

logit support radical_speaker radical_language gender-pre_behaviours attention_correct, robust
margins, dydx(radical_speaker) at(pre_justice=(0(0.5)4)) post
est store margins2

logit support radical_speaker radical_language gender-pre_behaviours attention_correct, robust
margins, dydx(radical_speaker) at(pre_anxiety=(0(0.5)4)) post
est store margins3

logit support radical_speaker radical_language gender-pre_behaviours attention_correct, robust
margins, dydx(radical_speaker) at(pre_behaviours=(0(0.5)4)) post
est store margins4

logit support radical_speaker radical_language gender-pre_behaviours attention_correct, robust
margins, dydx(radical_speaker) at(pre_activism=(0(0.5)4)) post
est store margins5

logit support radical_speaker radical_language gender-pre_behaviours attention_correct, robust
margins, dydx(radical_speaker) at(pre_policy=(0(0.5)4)) post
est store margins6

coefplot margins1 margins2 margins3 margins4 margins5 margins6, at xtitle("Level of pre-treatment covariate") ytitle("Pr(Support = 1)") noci recast(line) xlabel(,nogrid) ylabel(,nogrid) legend(label(1 "Norms") label(2 "Justice") label(3 "Anxiety") label(4 "Behaviours") label(5 "Activism") label(6 "Policy"))

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

drop _est_logit1-_est_probit2

logit support_ex_least radical_speaker radical_language, robust
margins, dydx(*) post
est store logit1

logit support_ex_least radical_speaker radical_language gender-pre_behaviours attention_correct, robust
margins, dydx(*) post
est store logit2

probit support_ex_least radical_speaker radical_language, robust
margins, dydx(*) post
est store probit1

probit support_ex_least radical_speaker radical_language gender-pre_behaviours attention_correct, robust
margins, dydx(*) post
est store probit2

etable, estimates(logit1 logit2 probit1 probit2) stars(0.1 "*" 0.05 "**" 0.01 "***", attach(_r_b)) col(command)


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

drop _est_logit1-_est_probit2

logit support_ex_most radical_speaker radical_language, robust
margins, dydx(*) post
est store logit1

logit support_ex_most radical_speaker radical_language gender-pre_behaviours attention_correct, robust
margins, dydx(*) post
est store logit2

probit support_ex_most radical_speaker radical_language, robust
margins, dydx(*) post
est store probit1

probit support_ex_most radical_speaker radical_language gender-pre_behaviours attention_correct, robust
margins, dydx(*) post
est store probit2

etable, estimates(logit1 logit2 probit1 probit2) stars(0.1 "*" 0.05 "**" 0.01 "***", attach(_r_b)) col(command)

***estimate full sample probability models with awareness control

logit support radical_speaker radical_language, robust
margins, dydx(*) post
est store logit1

logit support radical_speaker radical_language gender-pre_behaviours attention_correct awareness_mean, robust
margins, dydx(*) post
est store logit2

probit support radical_speaker radical_language, robust
margins, dydx(*) post
est store probit1

probit support radical_speaker radical_language gender-pre_behaviours attention_correct awareness_mean, robust
margins, dydx(*) post
est store probit2

etable, estimates(logit1 logit2 probit1 probit2) stars(0.1 "*" 0.05 "**" 0.01 "***", attach(_r_b)) col(estimates) export(marginsawareness.tex)


***margins analysis with awareness control


logit support radical_speaker radical_language gender-pre_behaviours attention_correct awareness_mean, robust
margins, dydx(radical_language) at(pre_norms=(0(0.5)4)) post
est store margins1

logit support radical_speaker radical_language gender-pre_behaviours attention_correct awareness_mean, robust
margins, dydx(radical_language) at(pre_justice=(0(0.5)4)) post
est store margins2

logit support radical_speaker radical_language gender-pre_behaviours attention_correct awareness_mean, robust
margins, dydx(radical_language) at(pre_anxiety=(0(0.5)4)) post
est store margins3

logit support radical_speaker radical_language gender-pre_behaviours attention_correct awareness_mean, robust
margins, dydx(radical_language) at(pre_behaviours=(0(0.5)4)) post
est store margins4

logit support radical_speaker radical_language gender-pre_behaviours attention_correct awareness_mean, robust
margins, dydx(radical_language) at(pre_activism=(0(0.5)4)) post
est store margins5

logit support radical_speaker radical_language gender-pre_behaviours attention_correct awareness_mean, robust
margins, dydx(radical_language) at(pre_policy=(0(0.5)4)) post
est store margins6

coefplot margins1 margins2 margins3 margins4 margins5 margins6, at xtitle("Level of pre-treatment covariate") ytitle("Pr(Support = 1)") noci recast(line) xlabel(,nogrid) ylabel(,nogrid) legend(label(1 "Norms") label(2 "Justice") label(3 "Anxiety") label(4 "Behaviours") label(5 "Activism") label(6 "Policy"))

///no differences detected compared to standard model w/out awareness

***create new variables to indicate the specific speaker in the radical statements - JSO is 4, 7, 10, 13, 14  - IB is 1, 2, 8, 11, 12 - ER is 3, 5, 6, 9

local numbers
forvalues i = 1/116 {
    local numbers "`numbers' `i'" 
} 

local n = 1

foreach x of local numbers{
	
	replace ib_speaker =1 in `n' if individual==`x' & (treatment1==1 | treatment3==1)
	
	local n = `n' + 1
	
	replace ib_speaker =1 in `n' if individual==`x' & (treatment1==1 | treatment3==1)
	
	local n = `n' + 1
	
	replace er_speaker =1 in `n' if individual==`x' & (treatment1==1 | treatment3==1)
	
	local n = `n' + 1
	
	replace jso_speaker =1 in `n' if individual==`x' & (treatment1==1 | treatment3==1)
	
	local n = `n' + 1
	
	replace er_speaker =1 in `n' if individual==`x' & (treatment1==1 | treatment3==1)
	
	local n = `n' + 1
	
	replace er_speaker =1 in `n' if individual==`x' & (treatment1==1 | treatment3==1)
	
	local n = `n' + 1
	
	replace jso_speaker =1 in `n' if individual==`x' & (treatment1==1 | treatment3==1)
	
	local n = `n' + 1
	
	replace ib_speaker =1 in `n' if individual==`x' & (treatment1==1 | treatment3==1)
	
	local n = `n' + 1
	
	replace er_speaker =1 in `n' if individual==`x' & (treatment1==1 | treatment3==1)
	
	local n = `n' + 1
	
	replace jso_speaker =1 in `n' if individual==`x' & (treatment1==1 | treatment3==1)
	
	local n = `n' + 1
	
	replace ib_speaker =1 in `n' if individual==`x' & (treatment1==1 | treatment3==1)
	
	local n = `n' + 1
	
	replace ib_speaker =1 in `n' if individual==`x' & (treatment1==1 | treatment3==1)
	
	local n = `n' + 1
	
	replace jso_speaker =1 in `n' if individual==`x' & (treatment1==1 | treatment3==1)
	
	local n = `n' + 1
	
	replace jso_speaker =1 in `n' if individual==`x' & (treatment1==1 | treatment3==1)
	
	local n = `n' + 1
	
}

logit support jso_speaker ib_speaker er_speaker radical_language, robust
margins, dydx(*) post
est store logit1

logit support jso_speaker ib_speaker er_speaker radical_language gender-pre_behaviours attention_correct awareness_mean, robust
margins, dydx(*) post
est store logit2

probit support jso_speaker ib_speaker er_speaker radical_language, robust
margins, dydx(*) post
est store probit1

probit support jso_speaker ib_speaker er_speaker radical_language gender-pre_behaviours attention_correct awareness_mean, robust
margins, dydx(*) post
est store probit2

etable, estimates(logit1 logit2 probit1 probit2) stars(0.1 "*" 0.05 "**" 0.01 "***", attach(_r_b)) col(estimates)


***test only on first 7 statements to see if respondent fatigue and hence them paying less attention to speakers is causing the null effect

gen support_first_7 = support


local numbers
forvalues i = 1/116 {
    local numbers "`numbers' `i'" 
} 

local n = 8


foreach x of local numbers{
	replace support_first_7=. in `n' if individual == `x' 
	local n = `n' + 1
	replace support_first_7=. in `n' if individual == `x'
	local n = `n' + 1
	replace support_first_7=. in `n' if individual == `x'
	local n = `n' + 1
	replace support_first_7=. in `n' if individual == `x'
	local n = `n' + 1
	replace support_first_7=. in `n' if individual == `x'
	local n = `n' + 1
	replace support_first_7=. in `n' if individual == `x'
	local n = `n' + 1
	replace support_first_7=. in `n' if individual == `x'
	local n = `n' + 8
	
}



