***generate key dependent variables for duration/question

gen duration_per_q = LENGTH/total
summ duration_per_q
gen duration_per_q_seconds = duration_per_q*60

gen duration_per_word = LEGTH/wordcount
summ duration_per_word
gen duration_per_word_seconds = duration_per_word*60


***generate table of summary stats for key DVs and questionnaire length

table (round) (result), stat(mean LENGTH duration_per_q_seconds total_q) stat(median LENGTH duration_per_q_seconds total_q) stat(sd LENGTH duration_per_q_seconds total_q) stat(iqr LENGTH duration_per_q_seconds total_q)

***format table

collect style cell, halign(center) valign(center)
collect style cell, border( right, pattern(single) )
collect style cell, border(left, pattern(single))
collect style cell, border(bottom,pattern(single))
collect style cell, border(top,pattern(single))
collect style cell, border( all, width(0.5) )
collect title "Figure X: Duration and Questionnaire Length Statistics"
collect style title, font(, bold)
collect style cell, halign(left)
collect label levels var LENGTH "Interview Duration (Mins)" duration_per_q_seconds "Interview Duration per Question (Secs)" total_q "Total Questions Asked", modify
collect style cell, nformat(%7.4g)
collect label dim round "", modify
collect label dim round " ", modify
collect label levels round 7 "Round 7" 8 "Round 8" 9 "Round 9" 10 "Round 10" .m "All Rounds", modify
collect label levels round 7 "Round 7" 8 "Round 8" 9 "Round 9" 10 "Round 10" .m "All Rounds", modify
collect label levels command 0 "Statistic", modify
collect style row stack, nodelimiter nospacer indent length(.) wrapon(word) noabbreviate wrap(.) truncate(tail)
collect style row stack, delimiter(`" # "') atdelimiter(`" @ "') bardelimiter(`" | "') binder(`"="') nospacer indent length(.) wrapon(word) noabbreviate wrap(.) truncate(tail)
collect style header round[7], title(hide)
collect export "q1_summary_stats", as(docx) replace

***produce bar graps summarising key DVs
*** produce bar graph for mean duration, most editing was done in graph editor

graph bar (mean) LENGTH, over(round) over(country) bargap(10000)nofill ytitle("Mean (Minutes)") title("Figure 1: Mean Interview Duration")subtitle("By Country and Round") legend( label( 1 "Round 7")label(2 "Round 8")label(3 "Round 9") label(4 "Round 10")) asyvars

***create new variable that excludes countries with only one round as those were making the graph very difficult to read and are not useful for answering Q1

gen country_graph = country
replace country_graph="" if country=="Congo-Brazzaville"
replace country_graph="" if country=="Seychelles"
replace country_graph="" if country=="Mauritania"

***create graph of mean duration excluding countries with only one round for neater presentation

graph bar (mean) LENGTH, over(round) over(country_graph) bargap(10000)nofill ytitle("Mean (Minutes)") title("Figure 1: Mean Interview Duration")subtitle("By Country and Round") legend( label( 1 "Round 7")label(2 "Round 8")label(3 "Round 9") label(4 "Round 10")) asyvars

*** similar commands to create graphs for mean per question and mean per wordcount


graph bar (mean) duration_per_q_seconds, over(round) over(country) bargap(10000)nofill ytitle("Mean (Seconds)") title("Figure 2: Mean Time Per Question")subtitle("By Country and Round") legend( label( 1 "Round 7")label(2 "Round 8")label(3 "Round 9") label(4 "Round 10")) asyvars

graph bar (mean) duration_per_q_seconds, over(round) over(country_graph) bargap(10000)nofill ytitle("Mean (Seconds)") title("Figure 2: Mean Time Per Question")subtitle("By Country and Round") legend( label( 1 "Round 7")label(2 "Round 8")label(3 "Round 9") label(4 "Round 10")) asyvars

graph bar (mean) duration_per_word_seconds, over(language) bargap(10000)nofill ytitle("Mean (Seconds)") title("Figure 3: Mean Time Per Word")subtitle("By Country and Round") legend(label(1 "Round 9") )

***begin running somew first regressions to find changes in duration over time 
*** generate dummy variables coding round numbers

gen round_7 = 0
replace round_7=1 if round==7
gen round_8 = 0
replace round_8 = 1 if round == 8
gen round_9 = 0
replace round_9=1 if round == 9
gen round_10 =0
replace round_10 = 1 if round==10
tab round round_9

*** run dummy regression on full sample to get chnages in duration overall

reg LENGTH round_8 round_9 round_10, robust
estimates store lengthdummy
reg duration_per_q_seconds round_8 round_9 round_10, robust
estimates store lengthperqsecondsdummy

***create variable that counts rounds over time

gen round_counter=0
replace round_counter=1 if round==8
replace round_counter=2 if round==9
replace round_counter=3 if round==10
tab round_counter

*** regress duration measures against round counter to find average increase in duration over time (by round)
*** include here a control for number of questions as, using full sample and counter variable, there is no perfect collinearity

reg LENGTH round_counter,robust
estimates store averageincreaselength
reg duration_per_q_seconds round_counter, robust
estimates store avgincreaselengthperq
reg LENGTH round_counter total, robust
estimates store avgincreaselengthcontrol

*** create and format table

etable, estimates(lengthdummy lengthperqsecondsdummy averageincreaselength avgincreaselengthcontrol avgincreaselengthperq) stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) keep(_cons round_8 round_9 round_10 round_counter total) showstars showstarsnote title(Figure 4: Coefficient Estimates from Dummy Regression - Full Sample) export(dummy_reg_full_sample.docx,replace)


*** run regressions for each country, save estimates
*** could not run this analysis for MRT, SEY and CBZ due to them only being included in one round

reg LENGTH round_9 round_10 if countrycode=="ANG", robust
estimates store ANG
reg LENGTH round_8 round_9 round_10 if countrycode=="BEN", robust
estimates store BEN
reg LENGTH round_8 round_9 if countrycode=="BFO", robust
estimates store BFO
reg LENGTH round_8 round_9 if countrycode=="BOT", robust
estimates store BOT
reg LENGTH round_8 round_9 round_10 if countrycode=="CAM", robust
estimates store CAM
reg LENGTH round_8 round_9 round_10 if countrycode=="CDI", robust
estimates store CDI
reg LENGTH round_8 round_9 if countrycode=="CVE", robust
estimates store CVE
reg LENGTH round_8 round_9 if countrycode=="SWZ"|countrycode=="ESW", robust
estimates store ESW
reg LENGTH round_9 if countrycode=="ETH", robust
estimates store ETH
reg LENGTH round_8 round_9 round_10 if countrycode=="GAB", robust
estimates store GAB
reg LENGTH round_8 round_9 round_10 if countrycode=="GAM", robust
estimates store GAM
reg LENGTH round_8 round_9 if countrycode=="GHA", robust
estimates store GHA
reg LENGTH round_8 round_9 round_10 if countrycode=="GUI", robust
estimates store GUI
reg LENGTH round_8 round_9 round_10 if countrycode=="KEN", robust
estimates store KEN
reg LENGTH round_8 round_9 round_10 if countrycode=="LES", robust
estimates store LES
reg LENGTH round_8 round_9 if countrycode=="LIB", robust
estimates store LIB
reg LENGTH  round_9  if countrycode=="MAD", robust
estimates store MAD
reg LENGTH round_8 round_9  if countrycode=="MLI", robust
estimates store MLI
reg LENGTH round_8 round_9 round_10 if countrycode=="MAU", robust
estimates store MAU
reg LENGTH round_8 round_9  if countrycode=="MLW", robust
estimates store MLW
reg LENGTH round_8 round_9 round_10 if countrycode=="MOR", robust
estimates store MOR
reg LENGTH round_8 round_9 if countrycode=="MOZ", robust
estimates store MOZ
reg LENGTH round_8 round_9 round_10 if countrycode=="NAM", robust
estimates store NAM
reg LENGTH round_8 round_9 if countrycode=="NGR", robust
estimates store NGR
reg LENGTH round_8 round_9  if countrycode=="NIG", robust
estimates store NIG
reg LENGTH round_8 round_9  if countrycode=="SAF", robust
estimates store SAF
reg LENGTH round_8 round_9  if countrycode=="SEN", robust
estimates store SEN
reg LENGTH round_8 round_9  if countrycode=="SRL", robust
estimates store SRL
reg LENGTH  round_9  if countrycode=="STP", robust
estimates store STP
reg LENGTH round_8 round_9  if countrycode=="SUD", robust
estimates store SUD
reg LENGTH round_8 round_9  if countrycode=="TAN", robust
estimates store TAN
reg LENGTH round_8 round_9 if countrycode=="TOG", robust
estimates store TOG
reg LENGTH round_8 round_9 round_10 if countrycode=="TUN", robust
estimates store TUN
reg LENGTH round_8 round_9 round_10 if countrycode=="UGA", robust
estimates store UGA
reg LENGTH round_8 round_9 if countrycode=="ZAM", robust
estimates store ZAM
reg LENGTH round_8 round_9 if countrycode=="ZIM", robust
estimates store ZIM

*** produce and format regression estimates tables, split into sets of 6 countries for visualisation

etable, estimates(ANG BEN BFO BOT CAM CDI) stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) keep(_cons round_8 round_9 round_10) showstars showstarsnote title(Figure 4: Coefficient Estimates from Dummy Regression) showeq column(index) export(dummy_reg_A.docx,replace)
etable, estimates(CVE ESW ETH GAB GAM GHA) stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) keep(_cons round_8 round_9 round_10) showstars showstarsnote title(Figure 4: Coefficient Estimates from Dummy Regression) showeq column(index) export(dummy_reg_B.docx,replace)
etable, estimates(GUI KEN LES LIB MAD MLI) stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) keep(_cons round_8 round_9 round_10) showstars showstarsnote title(Figure 4: Coefficient Estimates from Dummy Regression) showeq column(index) export(dummy_reg_B.docx,replace)
etable, estimates(CVE ESW ETH GAB GAM GHA) stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) keep(_cons round_8 round_9 round_10) showstars showstarsnote title(Figure 4: Coefficient Estimates from Dummy Regression) showeq column(index) export(dummy_reg_B.docx,replace)
etable, estimates(GUI KEN LES LIB MAD MLI) stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) keep(_cons round_8 round_9 round_10) showstars showstarsnote title(Figure 4: Coefficient Estimates from Dummy Regression) showeq column(index) export(dummy_reg_C.docx,replace)
etable, estimates(MAU MLW MOR MOZ NAM NGR) stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) keep(_cons round_8 round_9 round_10) showstars showstarsnote title(Figure 4: Coefficient Estimates from Dummy Regression) showeq column(index) export(dummy_reg_D.docx,replace)
etable, estimates(NIG SAF SEN SRL STP SUD) stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) keep(_cons round_8 round_9 round_10) showstars showstarsnote title(Figure 4: Coefficient Estimates from Dummy Regression) showeq column(index) export(dummy_reg_E.docx,replace)
etable, estimates(TAN TOG TUN UGA ZAM ZIM) stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) keep(_cons round_8 round_9 round_10) showstars showstarsnote title(Figure 4: Coefficient Estimates from Dummy Regression) showeq column(index) export(dummy_reg_F.docx,replace)


*** repeat process to regress time per question against round dummies
*** drop all estimates from prior regs

drop _est_ANG _est_BEN _est_BFO _est_BOT _est_CAM _est_CDI _est_CVE _est_ESW _est_ETH _est_GAB _est_GAM _est_GHA _est_GUI _est_KEN _est_LES _est_LIB _est_MAD _est_MLI _est_MAU _est_MLW _est_MOR _est_MOZ _est_NAM _est_NGR _est_NIG _est_SAF _est_SEN _est_SRL _est_STP _est_SUD _est_TAN _est_TOG _est_TUN _est_UGA _est_ZAM _est_ZIM

*** run regressions for each country, save estimates

reg duration_per_q_seconds round_9 round_10 if countrycode=="ANG", robust
estimates store ANG
reg duration_per_q_seconds round_8 round_9 round_10 if countrycode=="BEN", robust
estimates store BEN
reg duration_per_q_seconds round_8 round_9 if countrycode=="BFO", robust
estimates store BFO
reg duration_per_q_seconds round_8 round_9 if countrycode=="BOT", robust
estimates store BOT
reg duration_per_q_seconds round_8 round_9 round_10 if countrycode=="CAM", robust
estimates store CAM
reg duration_per_q_seconds round_8 round_9 round_10 if countrycode=="CDI", robust
estimates store CVI
reg duration_per_q_seconds round_8 round_9  if countrycode=="CVE", robust
estimates store CVE
reg duration_per_q_seconds round_8 round_9 if countrycode=="ESW"|countrycode=="SWZ", robust
estimates store ESW
reg duration_per_q_seconds round_9 if countrycode=="ETH", robust
estimates store ETH
reg duration_per_q_seconds round_8 round_9 round_10 if countrycode=="GAB", robust
estimates store GAB
reg duration_per_q_seconds round_8 round_9 round_10 if countrycode=="GAM", robust
estimates store GAM
reg duration_per_q_seconds round_8 round_9 if countrycode=="GHA", robust
estimates store GHA
reg duration_per_q_seconds round_8 round_9 round_10 if countrycode=="GUI", robust
estimates store GUI
reg duration_per_q_seconds round_8 round_9 round_10 if countrycode=="KEN", robust
estimates store KEN
reg duration_per_q_seconds round_8 round_9 round_10 if countrycode=="LES", robust
estimates store LES
reg duration_per_q_seconds round_8 round_9 if countrycode=="LIB", robust
estimates store LIB
reg duration_per_q_seconds  round_9  if countrycode=="MAD", robust
estimates store MAD
reg duration_per_q_seconds round_8 round_9 round_10 if countrycode=="MAU", robust
estimates store MAU
reg duration_per_q_seconds round_8 round_9 if countrycode=="MLI", robust
estimates store MLI
reg duration_per_q_seconds round_8 round_9 if countrycode=="MLW", robust
estimates store MLW
reg duration_per_q_seconds round_8 round_9 round_10 if countrycode=="MOR", robust
estimates store MOR
reg duration_per_q_seconds round_8 round_9 if countrycode=="MOZ", robust
estimates store MOZ
reg duration_per_q_seconds round_8 round_9 round_10 if countrycode=="NAM", robust
estimates store NAM
reg duration_per_q_seconds round_8 round_9 if countrycode=="NGR", robust
estimates store NGR
reg duration_per_q_seconds round_8 round_9  if countrycode=="NIG", robust
estimates store NIG
reg duration_per_q_seconds round_8 round_9 if countrycode=="SAF", robust
estimates store SAF
reg duration_per_q_seconds round_8 round_9 if countrycode=="SEN", robust
estimates store SEN
reg duration_per_q_seconds round_8 round_9 if countrycode=="SRL", robust
estimates store SRL
reg duration_per_q_seconds round_9 if countrycode=="STP", robust
estimates store STP
reg duration_per_q_seconds round_8 round_9 if countrycode=="SUD", robust
estimates store SUD
reg duration_per_q_seconds round_8 round_9 if countrycode=="TAN", robust
estimates store TAN
reg duration_per_q_seconds round_8 round_9 if countrycode=="TOG", robust
estimates store TOG
reg duration_per_q_seconds round_8 round_9 round_10 if countrycode=="TUN", robust
estimates store TUN
reg duration_per_q_seconds round_8 round_9 round_10 if countrycode=="UGA", robust
estimates store UGA
reg duration_per_q_seconds round_8 round_9 if countrycode=="ZAM", robust
estimates store ZAM
reg duration_per_q_seconds round_8 round_9 if countrycode=="ZIM", robust
estimates store ZIM

*** create and format table

etable, estimates(ANG BEN BFO BOT CAM CVI) stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) keep(_cons round_8 round_9 round_10) showstars showstarsnote title(Figure 5A: Coefficient Estimates from Dummy Regression Adjusting for Total Questions) showeq column(index) export(dummy_reg_q_A.docx,replace)
etable, estimates(CVE ESW ETH GAB GAM GHA) stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) keep(_cons round_8 round_9 round_10) showstars showstarsnote title(Figure 5B: Coefficient Estimates from Dummy Regression Adjusting for Total Questions) showeq column(index) export(dummy_reg_q_B.docx,replace)
etable, estimates(GUI KEN LES LIB MAD MAU) stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) keep(_cons round_8 round_9 round_10) showstars showstarsnote title(Figure 5C: Coefficient Estimates from Dummy Regression Adjusting for Total Questions) showeq column(index) export(dummy_reg_q_C.docx,replace)
etable, estimates(MLI MLW MOR MOZ NAM NGR) stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) keep(_cons round_8 round_9 round_10) showstars showstarsnote title(Figure 5D: Coefficient Estimates from Dummy Regression Adjusting for Total Questions) showeq column(index) export(dummy_reg_q_D.docx,replace)
etable, estimates(NIG SAF SEN SRL STP SUD) stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) keep(_cons round_8 round_9 round_10) showstars showstarsnote title(Figure 5E: Coefficient Estimates from Dummy Regression Adjusting for Total Questions) showeq column(index) export(dummy_reg_q_E.docx,replace)
etable, estimates(TAN TOG TUN UGA ZAM ZIM) stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) keep(_cons round_8 round_9 round_10) showstars showstarsnote title(Figure 5F: Coefficient Estimates from Dummy Regression Adjusting for Total Questions) showeq column(index) export(dummy_reg_q_F.docx,replace)

***run dummy regressions on full sample inlcuding round and also country dummies to find effect of being in a given contry on duration 

***generate variable that counts contries and sets BFO as the base year because its duration mean is closests to the full sample mean

gen country_count = 0
replace country_count=1 if countrycode=="BEN"
replace country_count=2 if countrycode=="BOT"
replace country_count=3 if countrycode=="CAM"
replace country_count=4 if countrycode=="CDI"
replace country_count=5 if countrycode=="CVE"
replace country_count=6 if countrycode=="ESW"
replace country_count=6 if countrycode=="SWZ"
replace country_count=7 if countrycode=="GAB"
replace country_count=8 if countrycode=="GAM"
replace country_count=9 if countrycode=="GHA"
replace country_count=10 if countrycode=="GUI"
replace country_count=11 if countrycode=="KEN"
replace country_count=12 if countrycode=="LES"
replace country_count=13 if countrycode=="LIB"
replace country_count=14 if countrycode=="MAD"
replace country_count=15 if countrycode=="MAU"
replace country_count=16 if countrycode=="MLI"
replace country_count=17 if countrycode=="MLW"
replace country_count=18 if countrycode=="MOR"
replace country_count=19 if countrycode=="MOZ"
replace country_count=20 if countrycode=="NAM"
replace country_count=21 if countrycode=="NGR"
replace country_count=22 if countrycode=="NIG"
replace country_count=23 if countrycode=="SAF"
replace country_count=24 if countrycode=="SEN"
replace country_count=25 if countrycode=="SRL"
replace country_count=26 if countrycode=="STP"
replace country_count=27 if countrycode=="SUD"
replace country_count=28 if countrycode=="TAN"
replace country_count=29 if countrycode=="TOG"
replace country_count=30 if countrycode=="TUN"
replace country_count=31 if countrycode=="UGA"
replace country_count=32 if countrycode=="ZAM"
replace country_count=33 if countrycode=="ZIM"
replace country_count=34 if countrycode=="ANG"
replace country_count=35 if countrycode=="ETH"
replace country_count=36 if countrycode=="CBZ"
replace country_count=37 if countrycode=="MTA"
replace country_count=38 if countrycode=="SEY"

***run regs and store results

reg LENGTH i.country_count, robust
estimates store LEN_COUN
reg LENGTH i.country_count i.round, robust
estimates store LEN_COUN_ROU
reg duration_per_q_seconds i.country_count, robust
 estimates store QUESTDUR_COUN
reg duration_per_q_seconds i.country_count i.round, robust
estimates store QUESTDUR_COUN_ROU

***generate and format table

etable, estimates(LEN_COUN LEN_COUN_ROU QUESTDUR_COUN QUESTDUR_COUN_ROU) stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) showstars showstarsnote title(Figure 8: Country/Round Effects on Duration) showeq column(index) export(coun_round_effects.docx,replace)

*** rest of formatting for tables done in word

*** run analysis on duration per word comparing it to target length by language, cannot compare across survey rounds becqause we only have translation data for round 9
*** generate variables for the target length (45mins) per word

summ total
gen targetduration = 45
gen target_duration_per_word=targetduration/wordcount
gen target_duration_per_word_seconds = target_length_per_word*60
summ target_duration_per_word_seconds duration_per_word_seconds

*** sort observations by language and run initial ttest for equality of actual and target duration per word

sort language, stable
by language:ttest duration_per_word_seconds== target_duration_per_word_seconds, unpaired unequal

***run test and collect results in specified "testing" collection

collect create testing
sort language, stable
quietly: collect ActualMean=r(mu_1) TargetMean=r(mu_2) SampleSize=r(N_1) Diff=(r(mu_2)-r(mu_1)): by language:ttest duration_per_word_seconds== target_duration_per_word_seconds, unpaired unequal
collect layout (language) (result)

*** format the table

collect title "Figure 7: Difference Between Actual and Target Mean Duration per Word by Language"
collect style title, font(, bold)
collect style cell, border( all, width(0.5) pattern(single) )
collect style cell, halign(left) valign(center)
collect label levels result Diff "Diff-in-Means", modify
collect label levels result ActualMean "Actual Mean", modify
collect label levels result TargetMean "Target Mean", modify
collect label levels result SampleSize "Sample Size", modify
*** create statistical significance stars
collect stars p .001 `"***"' .01 `"**"' .05 `"*"', attach(Diff) shownote
collect stars p .001 `"***"' .01 `"**"' .05 `"*"', attach(Diff) prefix(Statistical Significance:)
collect style cell, nformat(%7.3g)
collect export "diff_in_mean_AB_final", as(docx) replace

*** define country_count variable that counts the countrycodes and set BFO as base counry (ie country_count=0) because its mean duration is near th eoverall sample mean

*** regress LENGTH and duration_per_q_seconds against country and round dummies to find the effect of country on duration_per_q

reg LENGTH i.country_count,robust
estimates store reg1
reg LENGTH i.country_count i.round,robust
estimates store reg2
reg duration_per_q_seconds i.country_count,robust
estimates store reg3
reg duration_per_q_seconds i.country_count i.round,robust
estimates store reg4

*** create and format table

etable, estimates(reg1 reg2 reg3 reg4) stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) keep(_cons round_8 round_9 round_10 round_counter total) showstars showstarsnote title(Figure 8: Country/Round Effects on Duration) export(coun_round_effects.docx,replace)

***estimate effects of top 5 languages that are used across multiple countries

reg LENGTH english french portuguese kiswahili arabic, robust
estimates store reglang
reg duration_per_q_seconds english french portuguese kiswahili arabic, robust
estimates store reglang2

***create and format table

etable, estimates(reglang reglang2) stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) showstars showstarsnote title(Figure X: Effect of Language on Mean Interview Duration) export(dummy_reg_language.docx,replace)