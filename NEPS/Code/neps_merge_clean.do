clear 
clear matrix
clear mata
set maxvar 15000

*** set file path globals

global HELPER "/Users/albertoornaghi/Documents/GitHub/coding_samples/Helper"

local project "NEPS"
include "$HELPER/pathnames.do"



*** set locals to govern running code


local merge_1 				1
local merge_2				1
local clean1 				1
local attainment			1
local clean2				1
local impute				1



*** list out all the useful NEPS files
	
local files Stata14\SC3_CohortProfile_D_13-0-0 Stata14\SC3_Education_D_13-0-0 ///
Stata14\SC3_pCourseClass_D_13-0-0 Stata14\SC3_pCourseGerman_D_13-0-0 Stata14\SC3_pCourseMath_D_13-0-0 ///
Stata14\SC3_pEducator_D_13-0-0 Stata14\SC3_pParent_D_13-0-0 Stata14\SC3_pTarget_D_13-0-0 ///
 Stata14\SC3_xTargetCompetencies_D_13-0-0 ///
	
	
***open each file and save as tempfile
	
foreach file of local files{
		
	use "$DATA/`file'.dta", clear
		
	label language en
		
	local name "`file'"
	local name : subinstr local name "Stata14\SC3_" "", all
	local name : subinstr local name "_D_13-0-0" "", all
		
	tempfile `name'
	save ``name''
			
}


if `merge_1'==1{
	

	********************************************************
	**********merge files using individual ids**************
	********************************************************
	
	use `CohortProfile', clear
	
	duplicates tag ID_t wave, gen(dup) //check for duplicate student-waves
	drop if dup==1 
	drop dup
	
	merge 1:m ID_t wave using `pTarget'
	drop _merge
	
	duplicates tag ID_t wave, gen(dup) //check for duplicate student-waves
	drop if dup==1 
	drop dup
	
	tempfile merge1
	save `merge1'
	
	***courseclass generic
	
	use `pCourseClass', clear
	
	keep if ex20100==1 // remove all lines not reccomended for linkage that are duplicates - this removes all lines not recc for linkage
	
	duplicates tag ID_cc wave, gen(dup) //check for duplicate class-waves
	drop if dup==1 
	drop dup
	
	merge 1:m ID_cc wave using `merge1', assert(2 3) nogen
	
	tempfile merge2
	save `merge2'
	
	***german classes
	
	use `pCourseGerman', clear
	
	keep if ex20100==1 //remove all lines not reccomended for linkage
	
	duplicates tag ID_cg wave, gen(dup) //check for duplicate class-waves
	drop if dup==1 
	drop dup
	
	merge 1:m ID_cg wave using `merge2', assert(2 3) nogen

	tempfile merge3	
	save `merge3'
	
	***maths classes
	
	use `pCourseMath', clear
	
	keep if ex20100==1 //remove all lines not reccomended for linkage
	
	duplicates tag ID_cm wave, gen(dup) //check for duplicate class-waves
	drop if dup==1 
	drop dup
	
	merge 1:m ID_cm wave using `merge3', assert(2 3) nogen

	tempfile merge4	
	save `merge4'
	
	***teacher
	
	use `pEducator', clear
	
	
	
	sort ID_e wave
	drop wave
	duplicates drop ID_e, force //data is time-invariant!
	
	
	merge 1:m ID_e using `merge4', nogen //careful: NEPS instructions say that we should be able to assert (using match) but there are some ID_e observations that appear only in the master data!!! FIX THIS LATER ON!!! DO NOT IGNORE THIS PROBLEM!!!!
	
	drop if ID_t ==. & wave==. //termporary code to fix the problem above CAREFUL!!
	
	tempfile merge5
	save `merge5'
	
	
	***parents
	
	use `pParent', clear
	
	duplicates tag ID_t wave, gen(dup) //check for duplicate class-waves
	drop if dup==1 
	drop dup
	
	merge 1:m ID_t wave using `merge5', assert(2 3) nogen
	
	tempfile merge6
	save `merge6'
	
}



if `merge_2'==1{
	
	
	***run a second set of merges to bring in each competency data for maths
	
	***this file is in cross-sectional format, and hence needs to be split into the relevant
	***waves to correctly match each student-wave observation to the relevant scores
	
	
	
	local waves 1 3 5 9 //waves in which maths was tested
	
	local merge_no = 6 //index the merge
	
	foreach n of local waves{
		
		use `xTargetCompetencies'
		
		gen wave=`n'
		
		drop if wave_w`n'==0
		
		ds ma*  //keep only items that are from the maths scores
		keep ID_t wave `r(varlist)'
			
		merge 1:1 ID_t wave using `merge`merge_no'', assert(2 3) nogen 
		
		local merge_no = `merge_no' + 1
		
		tempfile merge`merge_no'
		save `merge`merge_no''
		
		
	}
	
	tempfile full_merge
	save `full_merge'
	
	order ID_t wave ID_i ID_cc ID_cg ID_cm ID_e

	
	
}


if `clean1'==1{
	
	***CLEAN DATA: KEEP ONLY VARIABLES I NEED, RECODE MISSING VALUES ETC ETC ETC, DROP DATA ON POST GRADUATION WAVES I.E. DATA FOR WHICH TARGET COMPETENCIES IS NOT AVAILABLE!
	
	tempfile first_clean
	save `first_clean'
	
	***drop observations missing key variables
	
	drop if !inlist(wave,1,3,5,9) //remove waves w/out maths test
	
	duplicates drop ID_t wave, force //drop duplicate student-waves
	
	drop if ID_cm==. | ID_cm <=0 //drop observations without maths class data - retains waves 1,3,5
	

	***keep only the variables that I need - first round
	
	keep ID_t-ID_e ma* p400090_g1D-p400010_g2R p66802e_g1-p400500_g1 p400500_g3R ///
	p407050_g1R p400500_g3v1R p400500_g1v1 p412001_g1R p412001_g2R p413000_g1D ///
	p413000_g2R p30300a p712040 p412000 p712051 p712050 p728000 p72801h p416200-p416210 ///
	p416020 p416010 p32903c pb00080 pb00120 p428000 p731701 p406000 p725000 p726000 ///
	p727000 p190200 p190100 p728060 p724102 pb00020 p261100 p262101 p262106 p261101 ///
	pc0304m pc0305m pc03060 pc0306h p67801e p67801c p67801f p400000 p731801 p731914 ///
	p731915 p410000_g2R p410000_g1D p410002_g1D p410002_g2R p410040 p410050 p410030 ///
	p741001 p742001 p510005-p510009 p286711-p286715 p751001_g1-p751001_g7 e229821_D ///
	e229821_R e229820_R ed1008a-ed1009c ed1011a-ed1011i e22282x-e22240s ///
	e22200a_v1-e22200k_v1 e22680a-e22682l e537041 e537090-e537141 e41100a_g1-e412600 ///
	e400000 e762110 e22540a-e22540l ID_i ed0025h_R-ed00027 ed0028a-ed0031j ///
	ed0033a-ed0033g e538011-e538018 ed0001h_R ed0001h_D ed0001m_R ed0002h_R ///
	ed0002h_D ed0003h e190041-e190045 e451010-e79201c_R e79202a_D-e199008_D ///
	e227400_D-e451000_D e451000_R e22740a e22740b e22740c e22740d e22740e ///
	e22740f e229400_D e229400_R e22941a-e22940e e190011_D e190011_R e190012 ///
	e190013 cohort ID_tg_w1 ID_tg_w2 sample tx80106-tx80232 tx80522 tx80531 ///
	tx80533 tx80535 tx80523 tx80524 tx80525 tx80526 tx80527 tx80501 tx8050m ///
	tx8050y tx80504 tx80505_R tx80505_D t723080_g1 td0002a_v1 t523010 t410020 ///
	t27111s t27111t_O t42805x t731426 t731427 t731429 t731405 t731406_D t731406_R ///
	t731403_g1 t731403_g2 t731403_g3 t731403_g4 t731403_g5-t731403_g16 ///
	t731439-t731322 t731451-t731360 t405500 t405530 t514008 t514009 th18030_v1 ///
	th18002 tf41000 tf41021 t34001e_g1 t732100 tg50200 tg13003 tg52020 ///
	t405620_g1R-t405500_g1 td0021x_O t416110-t28161e t31135a t31035a ///
	t416140 t416340 t22550a-t22350i t66210a-t66210k t320401 t320402 tf00010 ///
	tf00020 tf00040 t725020 t725021 t400030 t400031 tf0035a-tf0035h t724113-t724116 ///
	t261200 t66005a-t66005e t66004a-t66004e t66201a-t66208d t524510 t524610 ///
	t724121-t724128 t731424-t731473 t732101 t732102 t731207-t731466_R t731467 ///
	t66411b t66411d t429010 tf30001 tf30003 t32111a t32111b t32111c t724111-t724112 ///
	t261110 t26212a_O-t26611n te15010 te15020 te16011-te16052 t41000a_g1-t41000a_g5D ///
	t27111v_g1-tf11406 t41012a_g1-t41010a_g5R t700031 t405000 t514006 ///
	t751004_g1D-t406100_g2R t66208a_g1-t66004a_g1 t731413_g1-t731413_g16 ///
	t751010-t406060 t406120-t725000 tf11120 tf11140 tf1115y tf11155 ///
	tx44401_g1-tf11105 th09212 t742003 tf33101 t744001 t744002 t745001 ///
	t745002 t745003 t745004 t271040 t271041 t271820 t524200-t742001 ///
	t510025-t510014 tf61107-tf61111 t400500_g1v1-t414002_g2R te00001-te00014 ///
	t724101-te14116_g1 t66400a_g1-te03080 t66401a-t66401d t67005a-t67005c ///
	t523000 t27111a-t27111d_O t66000a_g1-te01030_v1 te16010_O-t23302h t428000 ///
	t428060 t428500 t42850x_O t428120 t428130 t525008 t525015 t525209 ///
	ts11202_g1-ts11202_g4O 
	
	***keep only the variables that I need - second round
	
	drop p400090_g2R p400090_g1R p400070_g1R p400070_g2R p400010_g1R p400010_g2R //drop anonymised
	
	drop *g12* //drop grade 12 i.e. wave 9 maths test variables
	
	drop p66802e_g1-p66802a_g1 p727002_D p400500_g3v1R p400500_g1v1 
	
	drop p412001_g1R p412001_g2R p413000_g2R p712040 p712050
	
	drop p712051 p416200-p416210 p416020 p416010 p428000 p727000 p190100 p190200
	
	drop p67801c-p67801f p731801 p731914 p410000_g2R p410002_g2R p410000_g1D p410002_g1D p410030 p286711-p286714
	
	drop ed1011d ed1011g e22282x e22200a_v1-e22200k_v1 
	
	drop e537110_g1-e537110_g4R e537121-e537127 e41100a_g1 e41100a_g2R ///
	e41100a_g3R e41100a_g3D e41100a_g4R e41100a_g4D e41100a_g5R e41100a_g5D
	
	drop e412600 e190041-e190045 e199002_R-e227400_D e22740a-e22740e e22740f ///
	e190012 e190013 ID_tg_w1 ID_tg_w2 tx80505_R
	
	drop t27111t_O t731426-t731403_g16 t731439 t731312-t731302_O ///
	t731314-t731322 t731451-t731457  t731362-t731360 t405500 t405530 ///
	t34001e_g1 t732100 tg50200 tg13003 tg52020 t405620_g1R-t405570_g2R ///
	t405560_g1R t405560_g1R-t405560_g2R t28161a-t28161e t320401 ///
	t320402 tf00040 tf0035a-tf0035h
	
	drop t724113-t724116 t261200-t66004e t66208a t66208b t66208c ///
	t66208d t724121-t724128 t731424-t731473 t731411-t731467
	
	drop t751001_g1-t751001_g7 t406100_g1R t406100_g2R t731413_g1-t731413_g16 ///
	tf1115y tf11155 th09212-t745004 t271040-t271820 t521000-t742001 ///
	t510025-t510014 tf61107-tf61111 t400280_g1R-t400220_g2R te01030 ///
	te01010 te01050-te01080 te14010-te14116_g1 te03010-te03080 ///
	t27111a-t27111d_O
	
	drop t66000a_g1 t66000a t66000b t66000c t724601-t724609 ///
	te16010_O-te16053 t23101a t428000 t428060 t42850x_O t428120 ///
	t428130 t525008 t525015 t525209 td0021x_O
	
	drop *_O //drop open response variables, these are all empty for anonymisation
	

	foreach x of varlist _all{
		
		replace `x'= . if `x'<= -20
		
	} //recode all missing values from the neps numeric to stata-readable

	
	***define and label timing variable from waves variable
	
	gen time_full = .
	replace time_full = 1 if wave==1
	replace time_full =2 if wave ==3
	replace time_full = 3 if wave == 5
	
	label define waves 1 "Wave 1" 2 "Wave 3" 3 "Wave 5"
	label values time_full waves
	
	label var time_full "Wave"
	
	tab time_full, gen(time)
	
	labvars time1 time2 time3 "Wave 1" "Wave 3" "Wave 5"
}


if `attainment'==1{
	
	***design maths score values, math attainment etc - total questions answered, questions answered correctly, proportion, z-score, put all in a single variable 
	
	local grades g5 g7 g9
	
	//standardise the names of the math text variables to have the right grade identifier
	
	local i = 1
	
	foreach x of varlist mag5_sc1u-mag5_sc2{

		
		rename (`x') (mag5_`i')
		
		local i = `i' + 1
			
	} //standardise variable names for grade 5 items
	
	
	local i = 1
	
	foreach x of varlist mag9q071_sc3g7_c-mag7_sc1u{

		
		rename (`x') (mag7_`i')
		
		local i = `i' + 1
			
	} //standardise variable names for grade 7 items
	
	
	local i = 1
	
	foreach x of varlist mag9d151_sc3g9_c-mag9_sc1u{

		
		rename (`x') (mag9_`i')
		
		local i = `i' + 1
			
	} //standardise variable names for grade 9 items
	
	drop mag5_1 mag5_2 mag5_27 mag5_28 mag7_24 mag7_25 ///
	mag7_26 mag7_27 mag9_35 mag9_36 mag9_37 mag9_38 //drop wles
	
	foreach grade of local grades{
		
		egen points_`grade' = rowtotal(ma`grade'_*), miss 
		
	} //sum points each student obtained within the relevant maths test
	
	foreach grade of local grades{
		
		gen total_`grade' =.
		
		gen prop_`grade'=.
		
	} //generate blank variables
	
	replace total_g5 = 28
	replace total_g7 = 24
	replace total_g9 = 35  //count total number of points available, assume refused/not reached/implausible means wrong
	
	
	foreach grade of local grades{
		
		replace prop_`grade' = points_`grade'/total_`grade' if points_`grade' != .
		
	}
	
	foreach grade of local grades{
		
		egen std_score_`grade'=std(prop_`grade')
		
	}
	
	labvars std_score_g5 std_score_g7 std_score_g9 "Maths Attainment Grade 5" "Maths Attainment Grade 7" "Maths Attainment Grade 9"
	
	drop mag*
	
	***generate overall score variable
	
	gen std_score = std_score_g5 if wave==1 & std_score_g5!=.
	replace std_score = std_score_g7 if wave==3 & std_score_g7!=.
	replace std_score = std_score_g9 if wave==5 & std_score_g9!=.
	
	***generate lagged dv
	
	xtset ID_t time_full
	
	bys ID_t (time_full): gen lag1_score = L.std_score
	bys ID_t (time_full): gen lag2_score = L.lag1_score
	
}



if `clean2'==1{


	***continue dropping unnecessary variables and observations
	
	//drop variables that are all empty
	
	foreach x of varlist _all{
		
		quietly: misstable summ `x'
		
		if r(N_lt_dot) <= 10 {
			
			drop `x'
		
		} //drops all variables that are empty and those almost all empty e.g. third mothertongue
		
	}
	
	//continue dropping unnecessary variables by hand
	
	drop p727001_D p72801h p32903c pb00080 pb00120 pb00020 p262106 p261101 p400000
	
	drop p510005 p510007 p510008 p510009 p751001_g7 ed1008a-ed1009c ed1011b-ed1011i ///
	e22240a e22240b e22240d e22240e e22240f e22240g e22240h e22240i e22240j e22240l ///
	e22240n e22240o e22240q e22240r e22240s e22680a e22680b e22680c e22680d e22680e ///
	e22680f e22680g e22680h e22681a e22681c e22681d e22681e e22681f e22681g e22681h ///
	e22681i e22681j
	
	drop e22682a e22682c-e22682l e537090 e53710y_D e537141 e22540a-e22540l ed0033a-e538011 
	
	drop cohort tx8050m tx8050y t27111s t22550a-t22350i t66210a-t66210k t66005a-t66005e ///
	t32111b t32111c t32111c t41000a_g1 t41000a_g3D t41000a_g4D t41000a_g5D t27111v_g1 ///
	t27111v_g4 t27111w_g1 t27111w_g4 t27111x_g1-t27111d_g1 t41012a_g1 t41012a_g3D-t41012a_g5D ///
	t41010a_g1 t41010a_g3D-t41010a_g5D t66005a_g1 t66004a_g1 t724101-t724108 t66001a_g1-t66001c
	
	//drop observations missing courseclass data
	
	drop if ID_cc ==.
	
	//drop observations missing competence tests
	
	drop if tx80522 == 0
	

	***generate class facilities variable - done at this stage to be able to drop a large number of facilities vars
	
	
	foreach x of varlist e22941a-e22941i e229410-e22940e{
		
		replace `x' = `x' - 1 if `x' !=.
		
	}
	
	tempfile check
	save `check'
	
	foreach x of varlist e22941a-e22941i  e22940c-e22940e{
		
		replace `x' = 0 if `x'==2
		
	} //redefine room quality vars to be dummies taking 1 if the object is present
	
	egen room_quality = rowtotal(e22941a-e22941i e229410-e22940e), missing 

	drop e22941a-e22941i e229410 e22940a e22940c e22940d e22940e //drop all facilities vars except room size
	
	***rename variables
	
	rename (p400090_g1D p400070_g1D p400500_g1 p413000_g1D p30300a p412000 ///
	p728000 p406000 p725000 p726000 p724102 p261100 p262101) (native_born_father ///
	native_born_mother immigrant_gen parent_mt economic_situation household_lang ///
	special_needs t_native_born repeat_grade skip_grade maths_grade tutoring tutoring_math)
	
	rename (p731915 p410040 p410050 p741001 p742001 p510006 p286715 p751001_g1 ///
	e229821_D ed1011a e22240c e22240k e22240m e22240p e22681b e22682b e537041 ///
	e537130 e537161_g1 e537162_g1 e537163_g1 e537140 e41100a_g2D e400000 e762110 ///
	ed0025h_D ed0025m_D ed00035_D ed00027) (benefits t_german_speaker t_bilingual ///
	hh_size hh_under_14 hh_income t_school_sat residence_ew e_experience e_enjoy ///
	e_action1 e_action2 e_action3 e_action4 e_action5 e_action6 e_grade e_selective ///
	e_degree_subj1 e_degree_subj2 e_degree_subj3 e_degree e_mt e_migrant e_gender ///
	ma_lesson_num ma_lesson_min ma_lesson_rem ma_lesson_canc )
	
	rename (ed0028a ed0028b ed0028c ed0028d ed0028e ed0028f ed0028g ed0028h ed0028i ///
	ed0028j ed0029a ed0029b ed0029c ed0029d ed0029e ed0030a ed0030b ed0030c ed0030d ///
	ed0031a ed0031b ed0031c ed0031d ed0031e ed0031f ed0031g ed0031h ed0031i ed0031j ///
	e538012 e538013 e538014 e538015 e538016 e538017 e538018) (ma_social1 ma_social2 ///
	ma_social3 ma_social4 ma_social5 ma_social6 ma_social7 ma_social8 ma_social9 ///
	ma_social10 ma_forms1 ma_forms2 ma_forms3 ma_forms4 ma_forms5 ma_forms6 ma_forms7 ///
	ma_forms8 ma_forms9 ma_success1 ma_success2 ma_success3 ma_success4 ma_success5 ///
	ma_success6 ma_success7 ma_success8 ma_success9 ma_success10 ma_time1 ma_time2 ///
	ma_time3 ma_time4 ma_time5 ma_time6 ma_time7 )
	
	rename (ed0001h_D ed0002h_D ed0003h) (gm_lesson_num gm_lesson_rem gm_lesson_canc)
	
	rename (e451010 e79201a_D e79201b_D e79201c_D e199001_D e227400_g1D) ///
	(cc_migrant_cat cc_class1_perc cc_class2_perc cc_class3_perc cc_sen_num class_size_cat) 
	
	drop tx80533 tx80535 tx80230
	
	rename (e227401_D e451000_D e229400_D e22940b e190011_D sample tx80106 ///
	tx80107 tx80109_g1 tx80231 tx80522 tx80531 tx80523 tx80524 tx80525 ///
	tx80526 tx80527 tx80501 tx80504 tx80505_D t723080_g1 td0002a_v1 t523010 ///
	t410020 t416110 t416310 td1001a td1001b td1001c td1001d t281600 t31035a ///
	t31135a t416140 t416340) (cc_male_perc cc_migrant_num room_size_cat room_size_e ///
	cc_sen_perc sample_wave school_type first_wave school_ew individual_tracing ///
	comp_available drop p_available i_available cc_available gm_available ma_available ///
	t_gender t_migrant t_sen school_type1 drop1 t_days_absent  drop2 drop3 drop4 t_ma_eff1 ///
	t_ma_eff2 t_ma_eff3 t_ma_eff4 t_homework_dur drop5 drop6 drop7 drop8 )
	
	rename (tf00010 tf00020 t725020 t725021 t400030 t400031 t41000a_g2D t41012a_g2D ///
	t41010a_g2D t700031 t514006 t400500_g1v1 t400500_g1 t400500_g2v1 t400500_g2 ///
	t400090_g1D t400070_g1D t400000_g1D t523000 t66002a t66002b t66002c) (drop9 drop10 ///
	t_repeated t_repeated_freq t_immigration_age1 t_immigration_age2 t_mt t_mt_father ///
	t_mt_mother t_gender1 t_satisfaction t_migrant_gen1 t_migrant_gen2 contradictory1 ///
	contradictory2 drop11 drop12 t_country_birth t_absences  t_sc1 t_sc2 t_sc3)
	
	***drop variables final
	
	drop drop* p731701 e79202a_D
	
	rename tx80220 dropout
	
	drop t_migrant_gen2
	
	drop contradictory1 contradictory2
	
	drop t_ma_eff1-t_ma_eff4 t_immigration_age1 t_immigration_age2 t_mt_father ///
	t_mt_mother native_born_father native_born_mother parent_mt economic_situation
	
	drop t_migrant t_repeated_freq first_wave individual_tracing school_type1 t_days_absent ///
	immigrant_gen household_lang special_needs maths_grade benefits hh_under_14 t_school_sat
	
	drop ma_social1 ma_social2 ma_social3 ma_social4 ma_social5 ma_social6 ma_social7 ///
	ma_social8 ma_social9 ma_social10 ma_forms1 ma_forms2 ma_forms3 ma_forms4 ma_forms5 ///
	ma_forms6 ma_forms7 ma_forms8 ma_forms9 ma_success1 ma_success2 ma_success3 ma_success4 ///
	ma_success5 ma_success6 ma_success7 ma_success8 ma_success9 ma_success10 ma_time1 ///
	ma_time2 ma_time3 ma_time4 ma_time5 ma_time6 ma_time7
	
	drop e_enjoy e_action1 e_action2 e_action3 e_action4 e_action5 e_action6 sample_wave ///
	school_ew e_degree_subj2 e_degree_subj3 skip_grade t_bilingual gm_lesson_num ///
	gm_lesson_rem gm_lesson_canc
	
	rename (cc_migrant_num cc_sen_num) (cc_migrant_perc cc_sen_perc1)
	
	
}

if `impute'==1{	
	
	***impute class-size by wave and ID_cc, drop if missing
	
	rename class_size_cat  class_size
	
	tempfile clean1
	save `clean1'
	
	//created separate class size with imputed values - test both later on!
	
	***I CAN DEFINITELY IMPROVE THE CODE BELOW WITH PROBABLY ONLY A COUPLE OF COLLAPSE COMMANDS, I CAN ///
	GROUP ALL THE ONES THAT ARE BY THE SAME VARIABLE!!! DON'T WORRY ABOUT THIS, JUST MAYBE DO IT LATER IF ///
	I UPLOAD THIS AS A CODING SAMPLE
	
	***BIG BIG PROBLEM: THIS IMPUTATION PROCEDURE MAKES ALL IMPUTED VARIABLES TIME-INVARIANT!!!!! PROBLEM FOR E.G. CLASS SIZE - IMPUTE ONLY THE MISSING VALUES UNLESS TRULY TIME-INVARIANT!!!
	
	preserve
	
		collapse (mean) class_size, by(ID_cc wave)
		
		replace class_size = round(class_size, 1.0)

		bysort ID_cc: egen mean_cc = mean(class_size)
		replace class_size = mean_cc if missing(class_size)
		drop mean_cc

		replace class_size = round(class_size, 1.0)

		rename class_size class_size_imp
	
		tempfile cs
		save `cs'
	
	restore
	
	merge m:1 ID_cc wave using `cs', assert(3) nogen
	


	***impute t_sen variable across waves
	
	preserve
	
		collapse (max) t_sen, by(ID_t)
		
		rename t_sen t_sen_imp
		
		tempfile sen
		save `sen'
		
	restore
	
	merge m:1 ID_t using `sen', assert(3) nogen

	drop t_sen
	
	rename t_sen_imp t_sen
	
	
	***impute t_repeated
	
	preserve
	
		collapse (max) t_repeated, by(ID_t)
		
		rename t_repeated t_repeated_imp
		
		tempfile rep
		save `rep'
		
	restore
	
	merge m:1 ID_t using `rep', assert(3) nogen

	drop t_repeated
	
	rename t_repeated_imp t_repeated
	
	
	***impute t_mt
	
	preserve
	
		collapse (max) t_mt, by(ID_t)
		
		rename t_mt t_mt_imp
		
		tempfile mt
		save `mt'
		
	restore
	
	merge m:1 ID_t using `mt', assert(3) nogen

	drop t_mt
	
	rename t_mt_imp t_mt
	
	label define mt 0 "German" 1 "Not German"
	label values t_mt mt
	
	***impute t_migrant_gen1
	
	preserve
	
		collapse (mean) t_migrant_gen1, by(ID_t)
		
		replace t_migrant_gen1 = round(t_migrant_gen1, 1.0)
		
		rename t_migrant_gen1 t_migrant_gen1_imp
		
		tempfile mig
		save `mig'
		
	restore
	
	merge m:1 ID_t using `mig', assert(3) nogen

	drop t_migrant_gen1
	
	rename t_migrant_gen1_imp t_migrant_gen
	
	label define mig 0 "No migrant background"  1 "1st generation" 2  "1.5th generation" ///
	3 "2nd generation" 4 "2.25th generation" 5 "2.5th generation" 6 "2.75th generation" /// 
	7 "3rd generation"  8 "3.25th generation" 9 "3.5th generation"

	label values t_migrant_gen mig
	
	
	***impute t_native_born
	
	preserve
	
		collapse (max) t_native_born, by(ID_t)
		
		rename t_native_born t_native_born_imp
		
		tempfile native
		save `native'
		
	restore
	
	merge m:1 ID_t using `native', assert(3) nogen

	drop t_native_born
	
	rename t_native_born_imp t_native_born
	
	label define native 1 "Born in Germany" 2 "Not born in Germany"

	label values t_native_born native
	
	
	***impute repeat_grade
	
	preserve
	
		collapse (min) repeat_grade, by(ID_t) //use min to make sure I am catching all the yes (1) responses
		
		rename repeat_grade repeat_grade_imp
		
		tempfile rep
		save `rep'
		
	restore
	
	merge m:1 ID_t using `rep', assert(3) nogen

	drop repeat_grade
	
	rename repeat_grade_imp repeat_grade
	
	label define rep 1 "Repeated" 2 "Never repeated"

	label values repeat_grade rep
	
	
	***impute tutoring, tutoring_math variables, create variable for ever having math tutoring
	
	
	preserve
		
		//I want var for ever having had tutoring, and ever having had amth tutoring
		
		collapse (min) tutoring (max) tutoring_math, by(ID_t) //use min to make sure I am catching all the yes (1) responses, max to catch all the yes (2) variables
		
		rename (tutoring tutoring_math) (tutoring_imp tutoring_math_imp)
		
		tempfile tut
		save `tut'
		
	restore
	
	merge m:1 ID_t using `tut', assert(3) nogen

	drop tutoring tutoring_math 
	
	rename (tutoring_imp tutoring_math_imp) (tutoring tutoring_math)
	
	label define tut 1 "Tutoring" 2 "No  tutoring"
	label values tutoring tutoring
	
	label define tut1 0 "No tutoring math" 1 "Tutoring math"
	label values tutoring_math tut1
	
	//define ever math tutoring variable as "interaction"
	
	replace tutoring = 0 if tutoring==2 //dummy variable 
	
	gen ever_tut_math = .
	replace ever_tut_math = 0 if tutoring == 0 | tutoring_math==0
	replace ever_tut_math = 1 if tutoring == 1 & tutoring_math==1
	
	label values ever_tut_math tut1 //THERE IS SOMETHING VERY WRONG HERE!!!!!
	
	***impute t_german_speaker CONTINUE FROM HERE!!!!
	
	
	preserve
		
		collapse (min) t_german_speaker, by(ID_t) 
		
		rename t_german_speaker t_german_speaker_imp
		
		tempfile gs
		save `gs'
		
	restore
	
	merge m:1 ID_t using `gs', assert(3) nogen

	drop t_german_speaker 
	
	rename (t_german_speaker_imp) t_german_speaker
	
	label define gs 1 "German speaker" 2 "Not  German speaker"
	label values t_german_speaker gs
	
	
	***impute hh_size, hh_income, residency //HH_INCOME HAS A VERY VERY LARGE NUMBER OF MISSING, MAYBE SELECT A DIFFERENT "INCOME" VARIABLE!!
	
	
	preserve
		
		collapse (max) hh_size  residence_ew (mean) hh_income, by(ID_t) 
		
		rename (hh_size hh_income residence_ew) (hh_size_imp hh_income_imp residence_ew_imp)
		
		tempfile hh
		save `hh'
		
	restore
	
	merge m:1 ID_t using `hh', assert(3) nogen

	drop hh_size hh_income residence_ew
	
	rename (hh_size_imp hh_income_imp residence_ew_imp) (hh_size hh_income residence_ew)
	


	***impute teacher-level variables 
	
	
	preserve
		
		collapse (max) e_grade e_selective e_degree_subj1 e_degree e_mt ///
		e_migrant e_gender (mean) e_experience , by(ID_e) 
		
		replace e_experience = round(e_experience, 1.0)
		
		rename (e_grade e_selective e_degree_subj1 e_degree e_mt ///
		e_migrant e_gender e_experience) (e_grade_imp e_selective_imp e_degree_subj1_imp e_degree_imp e_mt_imp ///
		e_migrant_imp e_gender_imp e_experience_imp)
		
		tempfile e
		save `e'
		
	restore
	
	merge m:1 ID_e using `e', assert(3) nogen

	drop e_grade e_selective e_degree_subj1 e_degree e_mt e_migrant e_gender e_experience
	
	rename (e_grade_imp e_selective_imp e_degree_subj1_imp e_degree_imp e_mt_imp ///
	e_migrant_imp e_gender_imp e_experience_imp) (e_grade e_selective e_degree_subj1 e_degree e_mt ///
	e_migrant e_gender e_experience) 
	
	label define sel 1 "Selective" 2 "Not selective"
	label values e_selective sel
	
	label define sub 2 "Protestant theology/religious education" ///
    3 "Catholic theology/religious education " 4 "Philosophy" 5 "History" ///
    8 "Classical philology, Modern Greek" ///
	9 "German Studies (German, Germanic Language)" ///
	10        "English and American studies" ///
	11                     "Romance studies" ///
	12 "Slavic, Baltic, Finno-Ugrian studies" ///
	16               "Educational sciences" ///
    17                "Special education" ///
    22             "Sport, sport science" ///
	23 "Law, economics and social science in ge" ///
	25                  "Political sciences " ///
	26                   "Social sciences" ///
    30                       "Economics" ///
	31 "Industrial engineering and management" ///
    37                        "Mathematics" ///
    38                 "Computer science" ///
	39             "Physics, astronomy" ///
    40                    "Chemistry" ///
    42                   "Biology" ///
    44               "Geography" ///
	57 "Landscape conservation, environmental" /// 
	60   "Nutritional and domestic sciences" ///
    61           "Engineering in general" ///
	68               "Civil engineering" ///
	74    "Arts, art science in general" ///
	75                     "Fine arts" ///
	76                      "Design" ///
	78         "Music, musicology"
	label values e_degree_subj1 sub
	
	label define deg 1 "Degree" 2 "No degree"
	label values e_degree deg
	
	label values e_mt mt
	
	label define gen 1 "Male" 2 "Female"
	label values e_gender gen
	
	label define mig1 1 "Born abroad" 2 "One parent born abroad" 3 "Born in Germany"
	label values e_migrant mig1
	
	//define variable for having completed, competitive degree in math
	
	gen math_degree_comp = .
	replace math_degree_comp = 0 if e_degree_subj1 != 37 | e_degree==2 | e_selective == 2
	replace math_degree_comp = 1 if e_degree_subj1 == 37 & e_degree==1 & e_selective == 1
	
	***impute maths class duration,number 
	
	preserve
		
		collapse (mean) ma_lesson_num ma_lesson_min , by(ID_e) 
		
		replace ma_lesson_num = round(ma_lesson_num, 1.0)
		replace ma_lesson_min = round(ma_lesson_min, 1.0)
		
		rename (ma_lesson_num ma_lesson_min) (ma_lesson_num_imp ma_lesson_min_imp )
		
		tempfile ma1
		save `ma1'
		
	restore
	
	merge m:1 ID_e using `ma1', assert(3) nogen

	label define min 1 "45 mins" 2 "other"
	label values ma_lesson_min_imp mins
	
	label define num_ma 1 "Up to 4" 2 "5" 3 "6 or more"
	label values ma_lesson_num_imp num_ma

	***impute homework duration
	

	bysort ID_t: egen mean_hw = mean(t_homework_dur)
	
	gen t_homework_dur_imp = t_homework_dur
	replace t_homework_dur_imp = round(mean_hw,1.0) if missing(t_homework_dur)
	
	drop mean_hw
	
	
	
	***reorder variables
	
	order ID_t wave ID_i ID_cc ID_cg ID_cm ID_e std_score class_size class_size_imp
	
	
	//drop some more unneeded variables
	
	
	drop ma_lesson_rem ma_lesson_canc t_country_birth t_sc1 t_sc2 t_sc3 t_gender1 ///
	room_size_e cc_sen_perc1 cc_sen_perc

	

	***AT THE END, TRY TO DROP ALL THE OBS THAT ARE MISSING VALUES FOR MY CONTROL VARIABLES AND SEE WHAT THE PANEL LOOKS LIKE!!!!!!!
	***THE NUMBER OF OBS WAS VERY VERY UNSTABLE WHEN I TRIED THE REGRESSIONS, DATA IS NOWHERE NEAR CLEAN YET!!!!
	
	***THIS OUTCOME IS VERY VERY VERY ODD...
	
	***define dummy for complete observation
	
	gen incomplete = 0
	
	local incomplete_v1 e_gender e_migrant e_mt e_degree e_degree_subj1 e_selective ///
	e_grade residence_ew t_german_speaker ever_tut_math ///
	repeat_grade t_native_born t_migrant_gen t_mt t_repeated t_sen room_quality ///
	t_satisfaction t_homework_dur t_gender school_type ///
	room_size_cat cc_migrant_perc cc_male_perc cc_class3_perc ///
	cc_class2_perc cc_class1_perc cc_migrant_cat ma_lesson_min ma_lesson_num ///
	e_experience class_size std_score
	
	foreach x of local incomplete_v1{
		
		replace incomplete = 1 if `x'==.
		
	}
	
	local incomplete_v2 e_migrant e_mt math_degree_comp ///
	room_quality room_size_cat ma_lesson_min  ///
	e_experience class_size std_score ma_lesson_num //include only variables I know are largely non-missing or cannot be absorbed by FEs 
	//this implies that I need cc, institution, student, and wave FEs
	
	gen incomplete_important = 0
	
	foreach x of local incomplete_v2 {
		
		replace incomplete_important = 1 if `x'==.
		
	}
	
	tab incomplete
	tab incomplete_important
	
	//hh_income, hh_size are missing an enormous number of obs!!
	
	
	save "$DATA/neps_clean.dta", replace
	
}


