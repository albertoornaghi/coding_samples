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

local clean_data		1

*** import dataset from qualtrics

import excel "$DATA/RFE_data_raw.xlsx", clear firstrow

if `clean_data'==1{

	*** drop unneeded variables - Q12-Q14 represents the consent from questions

	drop Status IPAddress RecordedDate RecipientLastName RecipientFirstName RecipientEmail ///
	ExternalReference LocationLatitude LocationLongitude DistributionChannel UserLanguage ///
	Q_StraightliningCount Q_StraightliningPercentage Q_StraightliningQuestions Q_UnansweredPercentage ///
	Q_UnansweredQuestions StartDate EndDate Durationinseconds Q12-Q14 DT

	*** rename all variables to something clearer

	rename Q31 awareness
	rename Q32 awareness_radical

	forvalues i = 1/3{
		rename Q42_`i' pre_policy_`i'
		rename Q52_`i' pre_activism_`i'
		rename Q62_`i' pre_anxiety_`i'
		rename Q72_`i' pre_norms_`i'
	}

	forvalues i = 1/5{
		rename Q82_`i' pre_justice_`i'
		rename Q92_`i' pre_behaviours_`i'
	}

	local i = 1 /// define local for numbering

	foreach x in Q108 Q109 Q1010 Q1011 Q1012 Q1013 Q1014 Q1015 Q1016 Q1017 Q1018 Q1019 Q1020 Q1021{
		rename `x' control_statement_`i'
		local i = `i' + 1
	}

	local i = 1 /// define local for numbering

	foreach x in Q156 Q157 Q158 Q159 Q160 Q161 Q162 Q163 Q164 Q165 Q166 Q167 Q168 Q169 {
		rename `x' group1_statement_`i'
		local i = `i' + 1
	}

	local i = 1 /// define local for numbering

	foreach x in Q141 Q142 Q143 Q144 Q145 Q146 Q147 Q148 Q149 Q150 Q151 Q152 Q153 Q154{
		rename `x' group2_statement_`i'
		local i = `i' + 1
	}

	local i = 1 /// define local for numbering

	foreach x in Q118 Q119 Q1110 Q1111 Q1112 Q1113 Q1114 Q1115 Q1116 Q1117 Q1118 Q1119 Q1120 Q1121{
		rename `x' group3_statement_`i'
		local i = `i' + 1
	}

	forvalues i = 1/8{
		rename Q132_`i' post_policy_`i'
		rename Q142_`i' post_activism_`i'
	}

	rename (post_activism_1 post_activism_2 post_activism_3 post_activism_4 post_activism_5 ///
	post_activism_6 post_activism_7 post_activism_8) (post_activism_moderate_1 post_activism_moderate_2 ///
	post_activism_radical_1 post_activism_moderate_3 post_activism_radical_2 post_activism_radical_3 ///
	post_activism_moderate_4 post_activism_radical_4)

	rename (Q21 Q22 Q23 Q24 Q25 Q26) (gender age uk_res education income partisanship)

	***label all varibles with the specific content of the question (excluding treatment statements)

	foreach x of varlist control_statement_1-group3_statement_14{
		label var `x' "" 
	} /// remove qualtrics lavels from treatment statement variables

	rename Q123 attention
	
	labvars awareness  awareness_radical "Awareness of Activism Groups" "Perception of Radical Tactics"

	labvars pre_policy_1 pre_policy_2 pre_policy_3 pre_activism_1 pre_activism_2 pre_activism_3 ///
	"Extra Taxes" "5% Levy on Bills" "Energy-Efficiency Grants" "Lobbying" "Blocking Roads" "Donating"

	labvars pre_anxiety_1 pre_anxiety_2 pre_anxiety_3 pre_norms_1 pre_norms_2 pre_norms_3 "Depression" ///
	"Anxiety" "Worry" "Most of my friends are trying to act in ways that reduce climate change" ///
	"My friends think it is important that I take action to reduce climate change" "My friends make an effort to reduce climate change"

	labvars pre_justice_1 pre_justice_2 pre_justice_3 pre_justice_4 pre_justice_5 pre_behaviours_1 ///
	pre_behaviours_2 pre_behaviours_3 pre_behaviours_4 pre_behaviours_5 "Least responsible suffer most" ///
	"Climate change will worsen inequalities" "Solving climate change requires redistribution" ///
	"Affected communities should have more say" "Colonial forced extraction has driven climate change" ///
	"Recycling" "Recyclable packaging" "Recycle before throwing away" "Close tap while brushing teeth" ///
	"Walk/cycle to travel short distances"

	labvars attention post_policy_1 post_policy_2 post_policy_3 post_policy_4 post_policy_5 ///
	post_policy_6 post_policy_7 post_policy_8 post_activism_moderate_1 post_activism_moderate_2 ///
	post_activism_radical_1 post_activism_moderate_3 post_activism_radical_2 post_activism_radical_3 ///
	post_activism_moderate_4 post_activism_radical_4 age uk_res education income partisanship gender ///
	"Attention to stimuli" "5% levy on bills" "3 pence fee on each litre gasoline" ///
	"Carbon tax on fossil fuel companies" "Regulating carbon dioxide as a pollutant" ///
	"Energy-efficiency grants" "Requiring all utilities to produce 100% from renewable sources by 2035" ///
	"Funding to protect communities from climate change" "Establising a Civilian Conservation Corps" "Litigation" ///
	"Peaceful protest" "Highly disruptive protest" "Lobbying" "Blocking roads" "Violent Protest" "Donating" ///
	"Damaging property of fossil fuel companies" "Age" "UK Resident" "Years of education" ///
	"Personal income" "UK political party" "Gender"

	***destring all relevant variables

	destring pre_policy_1-group3_statement_14 post_policy_1-partisanship, replace force

	***recode variables to dummies when relevant - likert scale variables are already correctly coded

	foreach x of varlist control_statement_1-group3_statement_14{
		replace `x'=0 if `x'==2
	} /// turn variables into dummies taking the value 1 if a responded agreed with the statement

	***label all values

	label define likertoppose 0 "Strongly oppose" 1 "Somewhat oppose" 2 "Neither support nor oppose" 3 "Somewhat support" 4 "Strongly support"

	label define likertagree 0 "Strongly disagree" 1 "Somewhat disagree" 2 "Neither agree nor disagree" 3 "Somewhat agree" 4 "Strongly agree"

	foreach x of varlist pre_policy_1-pre_activism_3{
		label values `x' likertoppose
	}

	foreach x of varlist pre_anxiety_1-pre_behaviours_5{
		label values `x' likertagree
	}

	foreach x of varlist post_policy_1-post_activism_radical_4{
		label values `x' likertoppose
	}

	label define agree 0 "Disagree" 1 "Agree"

	foreach x of varlist control_statement_1-group3_statement_14{
		label values `x' agree
	}

	label define gender 1 "Female" 2 "Male" 3 "Non-binary"
	label values gender gender

	label define res 0 "Not UK resident" 1 "UK resident"
	label values uk_res res

	label define income 1 "Less than £20,000" 2 "Between £20,001 and £40,000" ///
	3 "Between £40,001 and £60,000" 4 "Between £60,001 and £80,000" ///
	5 "Between £80,001 and £100,000" 6 "More than £100,001" 7 "Prefer not to say"
	label values income income

	label define party 0 "Conservative" 1 "Labour" 2 "Lib Dem" 3 "Green" 4 "Reform" ///
	5 "Other" 6 "Do not identify with any UK parties" 7 "Prefer not to say" 8 "Don't know"
	label values partisanship party

	***define dummies indicating a respondent was aware of some activism group

	local groups greenpeace fote jso gndr ffl ib tcc er none
	
	foreach x of local groups{
		
		if "`x'"=="greenpeace"{
			local pos = 1
		}
		
		if "`x'"=="fote"{
			local pos = 2
		}
		
		if "`x'"=="jso"{
			local pos = 3
		}
		
		if "`x'"=="gndr"{
			local pos = 4
		}
		
		if "`x'"=="ffl"{
			local pos = 5
		}
		
		if "`x'"=="ib"{
			local pos = 6
		}
		
		if "`x'"=="tcc"{
			local pos = 7
		}
		
		if "`x'"=="er"{
			local pos = 8
		}
		
		if "`x'"=="none"{
			local pos = 9
		}
		
		gen `x'_aware=0
		replace `x'_aware=1 if strpos(awareness, "`pos'") > 0
		
	}

	***define dummies indicating a respondent percieved a group as using radical tactics 

	foreach x of local groups{
		
		if "`x'"=="greenpeace"{
			local pos = 2
		}
		
		if "`x'"=="fote"{
			local pos = 3
		}
		
		if "`x'"=="jso"{
			local pos = 4
		}
		
		if "`x'"=="gndr"{
			local pos = 5
		}
		
		if "`x'"=="ffl"{
			local pos = 6
		}
		
		if "`x'"=="ib"{
			local pos = 7
		}
		
		if "`x'"=="tcc"{
			local pos = 8
		}
		
		if "`x'"=="er"{
			local pos = 9
		}
		
		if "`x'"!="none"{
			gen `x'_radical=0 if `x'_aware==1
			replace `x'_radical=1 if strpos(awareness_radical, "`pos'") > 0 & `x'_aware==1
		}
		
		if "`x'"=="none"{
			gen `x'_radical=0 if `x'_aware==0
			replace `x'_radical=1 if strpos(awareness_radical, "1") > 0 & `x'_aware==0
		}
		
	}
	

	***label awareness and radical dummies
	
	labvars greenpeace_aware fote_aware jso_aware gndr_aware ffl_aware ib_aware tcc_aware ///
	er_aware none_aware "Aware of Greenpeace" "Aware of FotE" "Aware of JSO" "Aware of GNDR" ///
	"Aware of FFL" "Aware of IB" "Aware of TCC" "Aware of ER" "Aware of none"

	labvars greenpeace_radical fote_radical jso_radical gndr_radical ffl_radical ib_radical ///
	tcc_radical er_radical none_radical "Percieves Greenpeace as radical" "Percieves FotE as radical" ///
	"percieves JSO as radical" "Percieves GNDR as radical" "Percieves FFL as radical" ///
	"Percieves IB as radical" "Percieves TCC as radical" "Percieves ER as radical" "Percieves none as radical"

	label define aware 0 "Not aware" 1 "Aware"
	label define radical 0 "No radical tactics" 1 "Radical tactics"

	foreach x of varlist greenpeace_aware-none_aware{
		label values `x' aware
	}

	foreach x of varlist greenpeace_radical-none_radical{
		label values `x' radical
	}

	***define control variables from pre-treatment likert scale variables 

	egen pre_policy = rmean(pre_policy_1-pre_policy_3)
	egen pre_activism = rmean(pre_activism_1-pre_activism_3)
	egen pre_anxiety = rmean(pre_anxiety_1-pre_anxiety_3)
	egen pre_norms = rmean(pre_norms_1-pre_norms_3)
	egen pre_justice = rmean(pre_justice_1-pre_justice_5)
	egen pre_behaviours = rmean(pre_behaviours_1-pre_behaviours_5)

	labvars pre_policy pre_activism pre_anxiety pre_norms pre_justice pre_behaviours ///
	"Pre-treatment policy support" "Pre-treatment activism support" "Pre-treatment eco-anxiety" ///
	"Pre-treatment environmental norms" "Pre-treatment environmental justice beliefs" "Pre-treatment sustainable behaviours"

	***create treatment group indicator dummies

	local treatment control group1 group2 group3
	
	foreach x of local treatment{

		gen `x'=0
		replace `x'=1 if `x'_statement_14 !=.
	
	}
	

	labvars `treatment' "Control Group" "Treatment Group 1" "Treatment Group 2" "Treatment Group 3"

	***drop observations where respondent did not complete treatment

	drop if control_statement_14 ==. & group1_statement_14 ==. & group2_statement_14 ==. & group3_statement_14 ==. 

	***generate indicator for correct attention questions

	gen attention_correct = 0
	
	replace attention_correct = 1 if control==1 & attention=="9"
	replace attention_correct = 1 if group1==1 & attention=="3,6,8"
	replace attention_correct = 1 if group2==1 & attention=="9"
	replace attention_correct = 1 if group3==1 & attention=="3,6,8"
	
	label var attention_correct "Correctly answered attention question"
	label define att 0 "Incorrect" 1 "Correct"
	label values attention_correct att

	***generate standard mean indices for dvs

	egen post_policy_mean = rmean(post_policy_1-post_policy_8)
	egen post_moderate_mean = rmean(post_activism_moderate_1 post_activism_moderate_2 ///
	post_activism_moderate_3 post_activism_moderate_4)
	egen post_radical_mean = rmean(post_activism_radical_1 post_activism_radical_2 ///
	post_activism_radical_3 post_activism_radical_4)

	labvars post_policy_mean post_moderate_mean post_radical_mean ///
	"Post-experiment policy support (mean)" "Post-treatment moderate activism support (mean)" ///
	"Post-treatment radical activism support (mean)"


	***generate means for awareness by radical/moderate group classification

	egen radical_aware_full= rmean(jso_aware ffl_aware ib_aware er_aware) 
	egen moderate_aware_full = rmean(tcc_aware gndr_aware fote_aware greenpeace_aware)
	egen radical_aware_exclffl = rmean(ib_aware er_aware jso_aware)

	labvars radical_aware_full moderate_aware_full radical_aware_exclffl ///
	"Aware of Radical Groups" "Aware of Moderate Groups" "Aware of Radical Groups excl. FFL"
}


save "RFE_data_clean.dta", replace

