*** inspect distributions for mean section duration
*** clean variables to remove any negative observations and any above 400/10=40 minutes to reflect AB's guideline maximum interview length


summ DUR1_10_R9
summ DUR1_10_R9 DUR11_19_R9 DUR20_29_R9 DUR30_39_R9 DUR40_49_R9 DUR50_59_R9 DUR60_69_R9 DUR70_79_R9 DUR80_89_R9 DUR90_99_R9
summ DUR1_10_R9 DUR11_19_R9 DUR20_29_R9 DUR30_39_R9 DUR40_49_R9 DUR50_59_R9 DUR60_69_R9 DUR70_79_R9 DUR80_89_R9 DUR90_99_R9 if DUR1_10_R9>40& DUR11_19_R9>40& DUR20_29_R9>40& DUR30_39_R9>40& DUR40_49_R9>40& DUR50_59_R9>40& DUR60_69_R9>40& DUR70_79_R9>40& DUR80_89_R9>40& DUR90_99_R9>40
summ DUR1_10_R9 if DUR1_10_R9>40
summ DUR1_10_R9 if DUR1_10_R9<0
summ DUR1_10_R9 if DUR1_10_R9 <5

summ DUR1_10_R9 if DUR1_10_R9>40
summ DUR11_19_R9 if DUR11_19_R9>40
summ DUR20_29_R9 if DUR20_29_R9>40
summ DUR30_39_R9 if DUR30_39_R9>40
summ DUR40_49_R9 if DUR40_49_R9>40
summ DUR50_59_R9 if DUR50_59_R9>40

foreach x of varlist DUR1_10_R9-DUR90_99_R9 {
	replace `x'=. if `x'<0
	replace `x'=. if `x'>40
}


*** create table of section duration summary stats

table() (result), stat(mean DUR1_10_R9 DUR11_19_R9 DUR20_29_R9 DUR30_39_R9 DUR40_49_R9 DUR50_59_R9 DUR60_69_R9 DUR70_79_R9 DUR80_89_R9 DUR90_99_R9 ) stat(median DUR1_10_R9 DUR11_19_R9 DUR20_29_R9 DUR30_39_R9 DUR40_49_R9 DUR50_59_R9 DUR60_69_R9 DUR70_79_R9 DUR80_89_R9 DUR90_99_R9 ) stat(sd DUR1_10_R9 DUR11_19_R9 DUR20_29_R9 DUR30_39_R9 DUR40_49_R9 DUR50_59_R9 DUR60_69_R9 DUR70_79_R9 DUR80_89_R9 DUR90_99_R9 ) stat(iqr DUR1_10_R9 DUR11_19_R9 DUR20_29_R9 DUR30_39_R9 DUR40_49_R9 DUR50_59_R9 DUR60_69_R9 DUR70_79_R9 DUR80_89_R9 DUR90_99_R9 )

*** format table

collect style cell, halign(center) valign(center)
collect style cell, border( right, pattern(single) )
collect style cell, border(left, pattern(single))
collect style cell, border(bottom,pattern(single))
collect style cell, border(top,pattern(single))
collect style cell, border( all, width(0.5) )
collect title "Figure 11: Section Duration Statistics"
collect style title, font(, bold)
collect style cell, halign(left)
collect style cell, nformat(%7.3g)
collect export "section_duration_stats", as(docx) replace

***create table summarising total number of questions per section

table() (result), stat(mean section_1_qs section_2_qs section_3_qs section_4_qs section_5_qs section_6_qs section_7_qs section_8_qs section_9_qs section_10_qs ) stat(median section_1_qs section_2_qs section_3_qs section_4_qs section_5_qs section_6_qs section_7_qs section_8_qs section_9_qs section_10_qs ) stat(sd section_1_qs section_2_qs section_3_qs section_4_qs section_5_qs section_6_qs section_7_qs section_8_qs section_9_qs section_10_qs ) stat(iqr section_1_qs section_2_qs section_3_qs section_4_qs section_5_qs section_6_qs section_7_qs section_8_qs section_9_qs section_10_qs )

***format table

collect style cell, halign(center) valign(center)
collect style cell, border( right, pattern(single) )
collect style cell, border(left, pattern(single))
collect style cell, border(bottom,pattern(single))
collect style cell, border(top,pattern(single))
collect style cell, border( all, width(0.5) )
collect title "Figure 11: Section Question Count Statistics"
collect style title, font(, bold)
collect style cell, halign(left)
collect style cell, nformat(%7.3g)
collect export "section_q_count_stats", as(docx) replace

***generate variables for number of questions in section

gen section_1_qs =Q110Demo + Q110MC + Q110Scale + Q1102S + Q110YN + Q110OE
gen section_2_qs = Q1119Demo + Q1119MC + Q1119Scale + Q11192S + Q1119YN + Q1119OE
gen section_3_qs = Q2029Demo + Q2029MC + Q2029Scale + Q20292S + Q2029YN + Q2029OE
gen section_4_qs = Q3039Demo + Q3039MC + Q3039Scale + Q30392S + Q3039YN + Q3039OE
gen section_5_qs = Q4049Demo + Q4049MC + Q4049Scale + Q40492S + Q4049YN + Q4049OE
gen section_6_qs = Q5059Demo + Q5059MC + Q5059Scale + Q50592S + Q5059YN + Q5059OE
gen section_7_qs = Q6069Demo + Q6069MC + Q6069Scale + Q60692S + Q6069YN + Q6069OE
gen section_8_qs = Q7079Demo + Q7079MC + Q7079Scale + Q70792S + Q7079YN + Q7079OE
gen section_9_qs = Q8089Demo + Q8089MC + Q8089Scale + Q80892S + Q8089YN + Q8089OE
gen section_10_qs = Q9099Demo + Q9099MC + Q9099Scale + Q90992S + Q9099YN + Q9099OE

***generate variable section_duration_per_q_seconds for the duration divided by the number of questions in seconds for each question

gen section_1_duration_per_q_seconds = ( DUR1_10_R9/section_1_qs)*60
summ section_1_duration_per_q_seconds
gen section_2_duration_per_q_seconds = ( DUR11_19_R9 /section_2_qs)*60
gen section_3_duration_per_q_seconds = ( DUR20_29_R9 /section_3_qs)*60
gen section_4_duration_per_q_seconds = ( DUR30_39_R9 /section_4_qs)*60
gen section_5_duration_per_q_seconds = ( DUR40_49_R9 /section_5_qs)*60
gen section_6_duration_per_q_seconds = ( DUR50_59_R9 /section_6_qs)*60
gen section_7_duration_per_q_seconds = ( DUR60_69_R9 /section_7_qs)*60
gen section_8_duration_per_q_seconds = ( DUR70_79_R9 /section_8_qs)*60
gen section_9_duration_per_q_seconds = ( DUR80_89_R9 /section_9_qs)*60
gen sect_10_duration_per_q_seconds = ( DUR90_99_R9 /section_10_qs)*60

***create table of summary stats for duration/questions in the section

table() (result), stat(mean section_1_duration_per_q_seconds section_2_duration_per_q_seconds section_3_duration_per_q_seconds section_4_duration_per_q_seconds section_5_duration_per_q_seconds section_6_duration_per_q_seconds section_7_duration_per_q_seconds section_8_duration_per_q_seconds section_9_duration_per_q_seconds sect_10_duration_per_q_seconds ) stat(median section_1_duration_per_q_seconds section_2_duration_per_q_seconds section_3_duration_per_q_seconds section_4_duration_per_q_seconds section_5_duration_per_q_seconds section_6_duration_per_q_seconds section_7_duration_per_q_seconds section_8_duration_per_q_seconds section_9_duration_per_q_seconds sect_10_duration_per_q_seconds ) stat(sd section_1_duration_per_q_seconds section_2_duration_per_q_seconds section_3_duration_per_q_seconds section_4_duration_per_q_seconds section_5_duration_per_q_seconds section_6_duration_per_q_seconds section_7_duration_per_q_seconds section_8_duration_per_q_seconds section_9_duration_per_q_seconds sect_10_duration_per_q_seconds ) stat(iqr section_1_duration_per_q_seconds section_2_duration_per_q_seconds section_3_duration_per_q_seconds section_4_duration_per_q_seconds section_5_duration_per_q_seconds section_6_duration_per_q_seconds section_7_duration_per_q_seconds section_8_duration_per_q_seconds section_9_duration_per_q_seconds sect_10_duration_per_q_seconds )

***format table

collect style cell, halign(center) valign(center)
collect style cell, border( right, pattern(single) )
collect style cell, border(left, pattern(single))
collect style cell, border(bottom,pattern(single))
collect style cell, border(top,pattern(single))
collect style cell, border( all, width(0.5) )
collect title "Figure 15: Section Duration per Question Statistics"
collect style title, font(, bold)
collect style cell, halign(left)
collect style cell, nformat(%7.4g)
collect export "section_duration_per_q_stats", as(docx) replace

***create table of summary stats for the types of questions

table() (result), stat(mean TotalDemo TotalMC TotalScale Total2S TotalYN TotalOE) stat(median TotalDemo TotalMC TotalScale Total2S TotalYN TotalOE) stat(sd TotalDemo TotalMC TotalScale Total2S TotalYN TotalOE) stat(iqr TotalDemo TotalMC TotalScale Total2S TotalYN TotalOE)

***format table

collect style cell, halign(center) valign(center)
collect style cell, border( right, pattern(single) )
collect style cell, border(left, pattern(single))
collect style cell, border(bottom,pattern(single))
collect style cell, border(top,pattern(single))
collect style cell, border( all, width(0.5) )
collect title "Figure 14: Question Type Statistics"
collect style title, font(, bold)
collect style cell, halign(left)
collect label levels var TotalDemo "Total Demographic Questions" TotalMC "Total Multiple Choice Questions" TotalScale "Total Scale Questions" Total2S "Total Two-Statement Questions" TotalYN "Total Yes/No Questions" TotalOE "Total Open-Ended Questions", modify
collect style cell, nformat(%7.3g)
collect export "question_type_stats", as(docx) replace

***create table for proportions of types of questions by section
*** generate variables for proportion of question types in each section

summ section_1_qs section_2_qs section_3_qs section_4_qs section_5_qs section_6_qs section_7_qs section_8_qs section_9_qs section_10_qs

gen demo_weight_1= Q110Demo/section_1_qs
gen demo_weight_2= Q1119Demo /section_2_qs
gen demo_weight_3= Q2029Demo /section_3_qs
gen demo_weight_4= Q3039Demo /section_4_qs
gen demo_weight_5 = Q4049Demo /section_5_qs
gen demo_weight_6 = Q5059Demo /section_6_qs
gen demo_weight_7 = Q6069Demo /section_7_qs
gen demo_weight_8  = Q7079Demo /section_8_qs
gen demo_weight_9  = Q8089Demo /section_9_qs
gen demo_weight_10  = Q9099Demo /section_10_qs

gen mc_weight_1= Q110MC/section_1_qs
gen mc_weight_2= Q1119MC /section_2_qs
gen mc_weight_3= Q2029MC /section_3_qs
gen mc_weight_5 = Q4049MC /section_5_qs
gen mc_weight_6 = Q5059MC /section_6_qs
gen mc_weight_7 = Q6069MC /section_7_qs
gen mc_weight_8  = Q7079MC /section_8_qs
gen mc_weight_9  = Q8089MC /section_9_qs
gen mc_weight_10  = Q9099MC /section_10_qs
gen mc_weight_4= Q3039MC /section_4_qs

gen scale_weight_1 = Q110Scale/section_1_qs
gen scale_weight_2 = Q1119Scale /section_2_qs
gen scale_weight_3 = Q2029Scale/section_3_qs
gen scale_weight_4 = Q3039Scale/section_4_qs
gen scale_weight_5 = Q4049Scale /section_5_qs
gen scale_weight_6 = Q5059Scale/section_6_qs
gen scale_weight_7 = Q6069Scale/section_7_qs
gen scale_weight_8 = Q7079Scale /section_8_qs
gen scale_weight_9 = Q8089Scale/section_9_qs
gen scale_weight_10 = Q9099Scale /section_10_qs

gen twos_weight_1 = Q1102S/section_1_qs
gen twos_weight_2 = Q11192S /section_2_qs
gen twos_weight_3 = Q20292S/section_3_qs
gen twos_weight_4 = Q30392S/section_4_qs
gen twos_weight_5 = Q40492S /section_5_qs
gen twos_weight_6 = Q50592S/section_6_qs
gen twos_weight_7 = Q60692S/section_7_qs
gen twos_weight_8 = Q70792S/section_8_qs
gen twos_weight_9 = Q80892S/section_9_qs
gen twos_weight_10 = Q90992S/section_10_qs

gen yn_weight_1 = Q110YN/section_1_qs
gen yn_weight_2 = Q1119YN /section_2_qs
gen yn_weight_3 = Q2029YN/section_3_qs
gen yn_weight_5 = Q4049YN /section_5_qs
gen yn_weight_6 = Q5059YN/section_6_qs
gen yn_weight_7 = Q6069YN/section_7_qs
gen yn_weight_8 = Q7079YN/section_8_qs
gen yn_weight_9 = Q8089YN/section_9_qs
gen yn_weight_10 = Q9099YN/section_10_qs

gen yn_weight_4= Q3039YN/section_4_qs
gen oe_weight_1= Q110OE/section_1_qs
gen oe_weight_2= Q1119OE /section_2_qs
gen oe_weight_3= Q2029OE/section_3_qs
gen oe_weight_4= Q3039OE/section_4_qs
gen oe_weight_5 = Q4049OE /section_5_qs
gen oe_weight_6 = Q5059OE/section_6_qs
gen oe_weight_7 = Q6069OE/section_7_qs
gen oe_weight_8  = Q7079OE/section_8_qs
gen oe_weight_9  = Q8089OE/section_9_qs
gen oe_weight_10  = Q9099OE/section_10_qs

summ oe_weight_1 oe_weight_2 oe_weight_3 oe_weight_4 oe_weight_5 oe_weight_6 oe_weight_7 oe_weight_8 oe_weight_9 oe_weight_10
summ yn_weight_1 yn_weight_2 yn_weight_3 yn_weight_5 yn_weight_6 yn_weight_7 yn_weight_8 yn_weight_9 yn_weight_10 yn_weight_4
summ twos_weight_1 twos_weight_2 twos_weight_3 twos_weight_4 twos_weight_5 twos_weight_6 twos_weight_7 twos_weight_8 twos_weight_9 twos_weight_10

***create variables for overall proportion of questions gen demo_weight= TotalDemo/total_q

gen demo_weight=TotalDemo/total_q
gen mc_weight= TotalMC/total_q
gen scale_weight= TotalScale/total_q
gen twos_weight= Total2S/total_q
gen yn_weight= TotalYN/total_q
gen oe_weight= TotalOE/total_q

***create table of summary stats fist for overall proportions

table() (result), stat(mean demo_weight mc_weight scale_weight twos_weight yn_weight oe_weight ) stat(median demo_weight mc_weight scale_weight twos_weight yn_weight oe_weight ) stat(sd demo_weight mc_weight scale_weight twos_weight yn_weight oe_weight ) stat(iqr demo_weight mc_weight scale_weight twos_weight yn_weight oe_weight)

***format table

collect style cell, halign(center) valign(center)
collect style cell, border( right, pattern(single) )
collect style cell, border(left, pattern(single))
collect style cell, border(bottom,pattern(single))
collect style cell, border(top,pattern(single))
collect style cell, border( all, width(0.5) )
collect title "Figure 16: Question Type Proportion Statistics"
collect style title, font(, bold)
collect style cell, halign(left)
collect style cell, nformat(%7.3g)
collect label levels var demo_weight "Demographic Question Proportion" mc_weight "Multiple Choice Question Proportion" scale_weight "Scale Question Proportion" twos_weight "Two-Statement Question Proportion" yn_weight "Yes/No Question Proportion" oe_weight "Open-Ended Question Proportion", modify
collect export "question_types_proportion_stats", as(docx) replace

***show same data graphically - COULD NOT ADD ERROR BARS SO MAKE SURE TO TALK ABOUT SD OF PROPORTIONS USING DATA FROM THE TABLE

graph bar (mean) demo_weight mc_weight scale_weight twos_weight yn_weight oe_weight , bargap(10000)nofill ytitle("Question Type Proportion") title("Figure 16: Question Type Proportion")

***create table of summary stats by section

table() (result), stat(mean demo_weight_1 demo_weight_2 demo_weight_3 demo_weight_4 demo_weight_5 demo_weight_6 demo_weight_7 demo_weight_8 demo_weight_9 demo_weight_10 mc_weight_1 mc_weight_2 mc_weight_3 mc_weight_4 mc_weight_5 mc_weight_6 mc_weight_7 mc_weight_8 mc_weight_9 mc_weight_10 scale_weight_1 scale_weight_2 scale_weight_3 scale_weight_4 scale_weight_5 scale_weight_6 scale_weight_7 scale_weight_8 scale_weight_9 scale_weight_10 twos_weight_1 twos_weight_2 twos_weight_3 twos_weight_4 twos_weight_5 twos_weight_6 twos_weight_7 twos_weight_8 twos_weight_9 twos_weight_10 yn_weight_1 yn_weight_2 yn_weight_3 yn_weight_4 yn_weight_5 yn_weight_6 yn_weight_7 yn_weight_8 yn_weight_9 yn_weight_10 oe_weight_1 oe_weight_2 oe_weight_3 oe_weight_4 oe_weight_5 oe_weight_6 oe_weight_7 oe_weight_8 oe_weight_9 oe_weight_10 ) stat(median demo_weight_1 demo_weight_2 demo_weight_3 demo_weight_4 demo_weight_5 demo_weight_6 demo_weight_7 demo_weight_8 demo_weight_9 demo_weight_10 mc_weight_1 mc_weight_2 mc_weight_3 mc_weight_4 mc_weight_5 mc_weight_6 mc_weight_7 mc_weight_8 mc_weight_9 mc_weight_10 scale_weight_1 scale_weight_2 scale_weight_3 scale_weight_4 scale_weight_5 scale_weight_6 scale_weight_7 scale_weight_8 scale_weight_9 scale_weight_10 twos_weight_1 twos_weight_2 twos_weight_3 twos_weight_4 twos_weight_5 twos_weight_6 twos_weight_7 twos_weight_8 twos_weight_9 twos_weight_10 yn_weight_1 yn_weight_2 yn_weight_3 yn_weight_4 yn_weight_5 yn_weight_6 yn_weight_7 yn_weight_8 yn_weight_9 yn_weight_10 oe_weight_1 oe_weight_2 oe_weight_3 oe_weight_4 oe_weight_5 oe_weight_6 oe_weight_7 oe_weight_8 oe_weight_9 oe_weight_10  ) stat(sd demo_weight_1 demo_weight_2 demo_weight_3 demo_weight_4 demo_weight_5 demo_weight_6 demo_weight_7 demo_weight_8 demo_weight_9 demo_weight_10 mc_weight_1 mc_weight_2 mc_weight_3 mc_weight_4 mc_weight_5 mc_weight_6 mc_weight_7 mc_weight_8 mc_weight_9 mc_weight_10 scale_weight_1 scale_weight_2 scale_weight_3 scale_weight_4 scale_weight_5 scale_weight_6 scale_weight_7 scale_weight_8 scale_weight_9 scale_weight_10 twos_weight_1 twos_weight_2 twos_weight_3 twos_weight_4 twos_weight_5 twos_weight_6 twos_weight_7 twos_weight_8 twos_weight_9 twos_weight_10 yn_weight_1 yn_weight_2 yn_weight_3 yn_weight_4 yn_weight_5 yn_weight_6 yn_weight_7 yn_weight_8 yn_weight_9 yn_weight_10 oe_weight_1 oe_weight_2 oe_weight_3 oe_weight_4 oe_weight_5 oe_weight_6 oe_weight_7 oe_weight_8 oe_weight_9 oe_weight_10 ) stat(iqr demo_weight_1 demo_weight_2 demo_weight_3 demo_weight_4 demo_weight_5 demo_weight_6 demo_weight_7 demo_weight_8 demo_weight_9 demo_weight_10 mc_weight_1 mc_weight_2 mc_weight_3 mc_weight_4 mc_weight_5 mc_weight_6 mc_weight_7 mc_weight_8 mc_weight_9 mc_weight_10 scale_weight_1 scale_weight_2 scale_weight_3 scale_weight_4 scale_weight_5 scale_weight_6 scale_weight_7 scale_weight_8 scale_weight_9 scale_weight_10 twos_weight_1 twos_weight_2 twos_weight_3 twos_weight_4 twos_weight_5 twos_weight_6 twos_weight_7 twos_weight_8 twos_weight_9 twos_weight_10 yn_weight_1 yn_weight_2 yn_weight_3 yn_weight_4 yn_weight_5 yn_weight_6 yn_weight_7 yn_weight_8 yn_weight_9 yn_weight_10 oe_weight_1 oe_weight_2 oe_weight_3 oe_weight_4 oe_weight_5 oe_weight_6 oe_weight_7 oe_weight_8 oe_weight_9 oe_weight_10 )

***format table

collect style cell, halign(center) valign(center)
collect style cell, border( right, pattern(single) )
collect style cell, border(left, pattern(single))
collect style cell, border(bottom,pattern(single))
collect style cell, border(top,pattern(single))
collect style cell, border( all, width(0.5) )
collect style title, font(, bold)
collect style cell, halign(left)
collect style cell, nformat(%7.3g)
collect title "Figure 17: Question Type Proportion Statistics by Section"
collect export "question_type_stats_by_section", as(docx) replace

***create table testing for difference-in-means between section duration per question and overall duration per question to see which sections to particularly long or particularly little time

***overall mean will differ across these tests due to different missing values for the section time variables causing slight changes in what observations are used to calculate each OverallMean

table (command) (result), command(SectionMean = r(mu_1) OverallMean = r(mu_2) Diff = (r(mu_2)-r(mu_1)) : ttest section_1_duration_per_q_seconds == duration_per_q_seconds ) command(SectionMean = r(mu_1) OverallMean = r(mu_2) Diff = (r(mu_2)-r(mu_1)) : ttest section_2_duration_per_q_seconds == duration_per_q_seconds ) command(SectionMean = r(mu_1) OverallMean = r(mu_2) Diff = (r(mu_2)-r(mu_1)) : ttest section_3_duration_per_q_seconds == duration_per_q_seconds ) command(SectionMean = r(mu_1) OverallMean = r(mu_2) Diff = (r(mu_2)-r(mu_1)) : ttest section_4_duration_per_q_seconds == duration_per_q_seconds ) command(SectionMean = r(mu_1) OverallMean = r(mu_2) Diff = (r(mu_2)-r(mu_1)) : ttest section_5_duration_per_q_seconds == duration_per_q_seconds ) command(SectionMean = r(mu_1) OverallMean = r(mu_2) Diff = (r(mu_2)-r(mu_1)) : ttest section_6_duration_per_q_seconds == duration_per_q_seconds ) command(SectionMean = r(mu_1) OverallMean = r(mu_2) Diff = (r(mu_2)-r(mu_1)) : ttest section_7_duration_per_q_seconds == duration_per_q_seconds ) command(SectionMean = r(mu_1) OverallMean = r(mu_2) Diff = (r(mu_2)-r(mu_1)) : ttest section_8_duration_per_q_seconds == duration_per_q_seconds ) command(SectionMean = r(mu_1) OverallMean = r(mu_2) Diff = (r(mu_2)-r(mu_1)) : ttest section_9_duration_per_q_seconds == duration_per_q_seconds ) command(SectionMean = r(mu_1) OverallMean = r(mu_2) Diff = (r(mu_2)-r(mu_1)) : ttest sect_10_duration_per_q_seconds == duration_per_q_seconds )


***format table - ROWS NEED TO BE SORTED AGAIN IN WORD: Section 10 Result is in second row due to automatic alphabetical ordering

collect title "Figure 16: Difference Between Section and Overall Mean Duration per Question"
collect style title, font(, bold)
collect style cell, border( all, width(0.5) pattern(single) )
collect style cell, halign(left) valign(center)
collect label levels result Diff "Diff-in-Means", modify
collect label levels result SectionMean "Section Mean", modify
collect label levels result OverallMean "Overall Mean", modify
*** create statistical significance stars
collect stars p .001 `"***"' .01 `"**"' .05 `"*"', attach(Diff) shownote
collect stars p .001 `"***"' .01 `"**"' .05 `"*"', attach(Diff) prefix(Statistical Significance:)
collect style cell, nformat(%7.3g)
collect label levels command 1 "Section 1 Difference" 2 "Section 2 Difference" 3 "Section 3 Difference" 4 "Section 4 Difference" 5 "Section 5 Difference" 6 "Section 6 Difference" 7 "Section 7 Difference" 8 "Section 8 Difference" 9 "Section 9 Difference" 10 "Section 10 Difference", modify
collect style cell, nformat(%7.4g)
collect export "diff_in_means_sections", as(docx) replace

***create question-type weighted average time for all question types - test the difference somehow????

***use weights for each question-type and section generated earlier to create proportion of qtypes table

gen mean_demo_weighted = (demo_weight_1* DUR1_10_R9+demo_weight_2* DUR11_19_R9+demo_weight_3* DUR20_29_R9+demo_weight_4* DUR30_39_R9+demo_weight_5* DUR40_49_R9+demo_weight_6* DUR50_59_R9+demo_weight_7* DUR60_69_R9+demo_weight_8* DUR70_79_R9+demo_weight_9* DUR80_89_R9+demo_weight_10* DUR90_99_R9)/( demo_weight_1+ demo_weight_2+ demo_weight_3+ demo_weight_4+ demo_weight_5+ demo_weight_6+ demo_weight_7+ demo_weight_8+ demo_weight_9+ demo_weight_10)

gen mean_mc_weighted = (mc_weight_1* DUR1_10_R9+mc_weight_2* DUR11_19_R9+mc_weight_3* DUR20_29_R9+mc_weight_4* DUR30_39_R9+mc_weight_5* DUR40_49_R9+mc_weight_6* DUR50_59_R9+mc_weight_7* DUR60_69_R9+mc_weight_8* DUR70_79_R9+mc_weight_9* DUR80_89_R9+mc_weight_10* DUR90_99_R9)/( mc_weight_1+ mc_weight_2+ mc_weight_3+ mc_weight_4+ mc_weight_5+ mc_weight_6+ mc_weight_7+ mc_weight_8+ mc_weight_9+ mc_weight_10)

gen mean_scale_weighted = (scale_weight_1* DUR1_10_R9+scale_weight_2* DUR11_19_R9+scale_weight_3* DUR20_29_R9+scale_weight_4* DUR30_39_R9+scale_weight_5* DUR40_49_R9+scale_weight_6* DUR50_59_R9+scale_weight_7* DUR60_69_R9+scale_weight_8* DUR70_79_R9+scale_weight_9* DUR80_89_R9+scale_weight_10* DUR90_99_R9)/( scale_weight_1+ scale_weight_2+ scale_weight_3+ scale_weight_4+ scale_weight_5+ scale_weight_6+ scale_weight_7+ scale_weight_8+ scale_weight_9+ scale_weight_10)

gen mean_twos_weighted = (twos_weight_1* DUR1_10_R9+twos_weight_2* DUR11_19_R9+twos_weight_3* DUR20_29_R9+twos_weight_4* DUR30_39_R9+twos_weight_5* DUR40_49_R9+twos_weight_6* DUR50_59_R9+twos_weight_7* DUR60_69_R9+twos_weight_8* DUR70_79_R9+twos_weight_9* DUR80_89_R9+twos_weight_10* DUR90_99_R9)/(twos_weight_1+ twos_weight_2+ twos_weight_3+ twos_weight_4+ twos_weight_5+ twos_weight_6+ twos_weight_7+ twos_weight_8+ twos_weight_9+ twos_weight_10)

gen mean_yn_weighted = (yn_weight_1* DUR1_10_R9+yn_weight_2* DUR11_19_R9+yn_weight_3* DUR20_29_R9+yn_weight_4* DUR30_39_R9+yn_weight_5* DUR40_49_R9+yn_weight_6* DUR50_59_R9+yn_weight_7* DUR60_69_R9+yn_weight_8* DUR70_79_R9+yn_weight_9* DUR80_89_R9+yn_weight_10* DUR90_99_R9)/(yn_weight_1+ yn_weight_2+ yn_weight_3+ yn_weight_4+ yn_weight_5+ yn_weight_6+ yn_weight_7+ yn_weight_8+ yn_weight_9+ yn_weight_10)

gen mean_oe_weighted = (oe_weight_1* DUR1_10_R9+oe_weight_2* DUR11_19_R9+oe_weight_3* DUR20_29_R9+oe_weight_4* DUR30_39_R9+oe_weight_5* DUR40_49_R9+oe_weight_6* DUR50_59_R9+oe_weight_7* DUR60_69_R9+oe_weight_8* DUR70_79_R9+oe_weight_9* DUR80_89_R9+oe_weight_10* DUR90_99_R9)/(oe_weight_1+ oe_weight_2+ oe_weight_3+ oe_weight_4+ oe_weight_5+ oe_weight_6+ oe_weight_7+ oe_weight_8+ oe_weight_9+ oe_weight_10)
summ mean_demo_weighted mean_mc_weighted mean_scale_weighted mean_twos_weighted mean_yn_weighted mean_oe_weighted

***create table of summary stats for these weighted averages

table() (result), stat(mean mean_demo_weighted mean_mc_weighted mean_scale_weighted mean_twos_weighted mean_yn_weighted mean_oe_weighted ) stat(median  mean_demo_weighted mean_mc_weighted mean_scale_weighted mean_twos_weighted mean_yn_weighted mean_oe_weighted ) stat(sd  mean_demo_weighted mean_mc_weighted mean_scale_weighted mean_twos_weighted mean_yn_weighted mean_oe_weighted ) stat(iqr  mean_demo_weighted mean_mc_weighted mean_scale_weighted mean_twos_weighted mean_yn_weighted mean_oe_weighted)

***format table

collect style cell, halign(center) valign(center)
collect style cell, border( right, pattern(single) )
collect style cell, border(left, pattern(single))
collect style cell, border(bottom,pattern(single))
collect style cell, border(top,pattern(single))
collect style cell, border( all, width(0.5) )
collect title "Figure 18: Question Type Proportion-Weighted Average Statistics"
collect style title, font(, bold)
collect style cell, halign(left)
collect style cell, nformat(%7.4g)
collect label levels var mean_demo_weighted "Demographic Questions" mean_mc_weighted "Multiple Choice Questions" mean_scale_weighted "Scale Questions" mean_twos_weighted "Two-Statement Questions" mean_yn_weighted "Yes/No Questions" mean_oe_weighted "Open-Ended Questions", modify
collect export "question_type_weighted_stats", as (docx) replace

***test difference between weighted mean by question type and overall section mean - THIS IS PROBABLY THE MOST USEFUL ANALYSIS ON ITS OWN: SHOWS HOW PROPORTIONS OF ONE TYPE OF QUESTION AFFECTS THE MEAN RELATIVE TO THE OVERALL UNWEIGHTED MEAN, AND RESULTS ARE REALLY GOOD AND BROADLY AS EXPECTED

gen mean_duration_section = ( DUR1_10_R9+ DUR11_19_R9+ DUR20_29_R9+ DUR30_39_R9+ DUR40_49_R9+ DUR50_59_R9+ DUR60_69_R9+ DUR70_79_R9+ DUR80_89_R9+ DUR90_99_R9)/10

table (command) (result), command(SectionMean = r(mu_1) OverallMean = r(mu_2) Diff = (r(mu_2)-r(mu_1)) : ttest mean_demo_weighted == mean_duration_section) command(SectionMean = r(mu_1) OverallMean = r(mu_2) Diff = (r(mu_2)-r(mu_1)) : ttest mean_mc_weighted == mean_duration_section ) command(SectionMean = r(mu_1) OverallMean = r(mu_2) Diff = (r(mu_2)-r(mu_1)) : ttest mean_scale_weighted == mean_duration_section ) command(SectionMean = r(mu_1) OverallMean = r(mu_2) Diff = (r(mu_2)-r(mu_1)) : ttest mean_twos_weighted == mean_duration_section ) command(SectionMean = r(mu_1) OverallMean = r(mu_2) Diff = (r(mu_2)-r(mu_1)) : ttest mean_yn_weighted == mean_duration_section ) command(SectionMean = r(mu_1) OverallMean = r(mu_2) Diff = (r(mu_2)-r(mu_1)) : ttest mean_oe_weighted == mean_duration_section )

collect title "Figure 21: Difference Between Weighted and Overall Mean Duration"
collect style title, font(, bold)
collect style cell, border( all, width(0.5) pattern(single) )
collect style cell, halign(left) valign(center)
collect label levels result Diff "Diff-in-Means", modify
collect label levels result SectionMean "Weighted Mean", modify
collect label levels result OverallMean "Overall Mean", modify
*** create statistical significance stars
collect stars p .001 `"***"' .01 `"**"' .05 `"*"', attach(Diff) shownote
collect stars p .001 `"***"' .01 `"**"' .05 `"*"', attach(Diff) prefix(Statistical Significance:)
collect style cell, nformat(%7.3g)
collect label levels command 1 "Demographic Questions" 2 "Multiple Choice Questions" 3 "Scale Questions" 4 "Two-Statement Questions" 5 "Yes/No Questions" 6 "Open-Ended Questions" , modify
collect style cell, nformat(%7.4g)
collect export "diff_in_means_weighted", as(docx) replace

***create table of 95% CIs to be able to make statistical comparisons of the difference across all these means, if the mean of one is outside the CI of another they stAstically differ

ci mean mean_demo_weighted mean_mc_weighted mean_scale_weighted mean_twos_weighted mean_yn_weighted mean_oe_weighted

collect create CIs

collect: mean mean_demo_weighted mean_mc_weighted mean_scale_weighted mean_twos_weighted mean_yn_weighted mean_oe_weighted

***format table

collect layout (colname) (_r_b _r_se _r_ci)
collect style cell, halign(center) valign(center)
collect style cell, border( right, pattern(single) )
collect style cell, border(left, pattern(single))
collect style cell, border(bottom,pattern(single))
collect style cell, border(top,pattern(single))
collect style cell, border( all, width(0.5) )
collect title "Figure 19: Question Type Proportion-Weighted Average Confidence Intervals"
collect style title, font(, bold)
collect style cell, halign(left)
collect label levels colname mean_demo_weighted "Demographic Questions" mean_mc_weighted "Multiple Choice Questions" mean_scale_weighted "Scale Questions" mean_twos_weighted "Two-Statement Questions" mean_yn_weight "Yes/No Questions" mean_oe_weighted "Open-Ended Questions", modify
collect label levels result _r_b "Weighted Average" _r_se "Standard Error" _r_ci "__LEVEL__% CI", modify
collect style cell, nformat(%7.4g)
collect label levels colname mean_demo_weighted "Demographic Questions" mean_mc_weighted "Multiple Choice Questions" mean_scale_weighted "Scale Questions" mean_twos_weighted "Two-Statement Questions" mean_yn_weighted "Yes/No Questions" mean_oe_weighted "Open-Ended Questions", modify
collect export "question_type_weighted_average_CIs", as(docx) replace

***regress question type counts on overall interview duration - CAREFUL WHEN INTERPRETING THESE: THESE IS VERY VERY LITTLE VARIATION IN SOME OF THE REGRESSONS (ESPECIALLY DEMO AND OE) SO POINT ESTIMATES COULD BE EXTREMELY FAR FROM THEIR TRUE VALUE

reg LENGTH TotalDemo TotalMC TotalScale Total2S TotalYN TotalOE, robust
estimates store reg1
reg duration_per_q_seconds TotalDemo TotalMC TotalScale Total2S TotalYN TotalOE, robust
estimates store reg2
reg LENGTH TotalMC TotalScale Total2S TotalYN, robust
estimates store reg3
reg duration_per_q_seconds TotalMC TotalScale Total2S TotalYN, robust
estimates store reg4
reg LENGTH Total2S, robust
estimates store reg5
reg duration_per_q_seconds Total2S, robust
estimates store reg6

***create and format table

etable, estimates(reg1 reg2 reg3 reg4 reg5 reg6) stars(0.05 "*" 0.01 "**" 0.001 "***", attach(_r_b)) showstars showstarsnote title(Figure 20: Question-Type Count Effects of Duration) export(question_count_effects.docx,replace)
