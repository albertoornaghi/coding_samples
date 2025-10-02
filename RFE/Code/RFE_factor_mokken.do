clear

***set pathnames

local project "RFE"
include "/Users/albertoornaghi/Documents/GitHub/coding_samples/Helper/pathnames.do"


***set locals for running code

local factor					1
local mokken					0
local irt						0

use "$RFEDATA/RFE_data_clean.dta", clear

***set locals for varlists

local radical post_activism_radical_1 post_activism_radical_2 post_activism_radical_3 post_activism_radical_4
local policy post_policy_1-post_policy_8
local moderate post_activism_moderate_1 post_activism_moderate_2 post_activism_moderate_3 post_activism_moderate_4

if `factor'==1{

	***Run factor analysis below to build alternate indices for dependent variables

	
	foreach x in policy radical moderate{ //careful - double quotes indicate varlist interpretation, single quotes indicates name of local interpretation

		corr ``x'', covariance //calculates and displays variance-covariance matrix for relevant variables
		matrix `x' = r(C) //saves variance-covariance matrix
		matlist `x'
	
		local N1 = r(N) //saves sample size
	
		mean ``x'' //calculate means of variables
		matrix means_`x' = e(b) //save means in a vector

		factormat `x', n(`N1') means(means_`x') //runs factor analysis
		
		matrix `x'_factor=e(L)
		mat2txt, matrix(`x'_factor) saving("$RFETAB/`x'_factor") replace
	
		screeplot, title("") xtitle(Factors) xlabel(,nogrid) ylabel(,nogrid) yline(1) //plots eigenvalues
		graph export "$RFEFIG/screeplot``x''.jpg", as(jpg) name("Graph") quality(100) replace
		
		predict post_`x'_factor //predics factor
	
	}
	

	
}

if `mokken'==1{

***I test below whether my question items form Mokken scales


	preserve

		file open tbl using "$RFETAB/loevingers_h", write replace

		foreach x in policy radical moderate{ //careful - double quotes indicate varlist interpretation, single quotes indicates name of local interpretation

			msp ``x'', c(0.3) // test for mokken scales

			file write tbl "Loevinger's H `x' = " "`r(H1)'" ", second scale = " "`r(H2)'" _n //save Loevnger's H values in text file
	
			traces ``x'', restscore cumulative //plot traces
	
			graph export "$RFEFIG/monotonicity_graph_`x'.jpg", as(jpg) name("restscore") quality(100) replace
	
			if "`x'"=="radical"{

				graph export "$RFEFIG/.jpg", as(jpg) name("restscore4") quality(100) replace //save one graph as an example
			}
		}

		file close tbl
	
	restore

}

if `irt'==1{

///run tests for difficulty

irt grm post_activism_radical_1 post_activism_radical_2 post_activism_radical_3 post_activism_radical_4, nolog //fit graded response model to test for difficulty of items and discrimination parameters

irtgraph icc 1.post_activism_radical_* 4.post_activism_radical_*, bcc xlabel(,nogrid) ylabel(,nogrid) legend(size(vsmall)) title("") //plot out item response functions to check (visually) the difficult and dscrimination parameters of the various items



}

save "$RFEDATA/RFE_data_clean", replace

