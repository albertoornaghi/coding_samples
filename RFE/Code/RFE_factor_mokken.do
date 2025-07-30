
***I run a factor analysis below to build alternate indices for my dependent variables

///policy support dv, using principal factors with variance-covariance matrix

corr post_policy_1 post_policy_2 post_policy_3 post_policy_4 post_policy_5 post_policy_6 post_policy_7 post_policy_8, covariance /// calculates and displays variance-covariance matrix for relevant variables
matrix cov1 = r(C) /// saves variance-covariance matrix
matlist cov1

global N1 = r(N) /// saves sample size

mean post_policy_1 post_policy_2 post_policy_3 post_policy_4 post_policy_5 post_policy_6 post_policy_7 post_policy_8 /// calculate means of variables
matrix means_policy = e(b) /// save means in a vector

factormat cov1, n($N1) means(means_policy) /// runs factor analysis

screeplot, title("") xtitle(Factors) xlabel(,nogrid) ylabel(,nogrid) yline(1) /// plots eigenvalues
graph save "Graph" "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV398/Dissertation/Graphs/screeplotpolicy.gph"
graph export "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV398/Dissertation/Graphs/screeplotpolicy.jpg", as(jpg) name("Graph") quality(100)

predict post_policy_factor /// predics factor

///radical support

corr post_activism_radical_1 post_activism_radical_2 post_activism_radical_3 post_activism_radical_4, covariance 
matrix cov1 = r(C) 
matlist cov1

global N1 = r(N) 

mean post_activism_radical_1 post_activism_radical_2 post_activism_radical_3 post_activism_radical_4 
matrix means_radical = e(b) 

factormat cov1, n($N1) means(means_radical) 

screeplot, title("") xtitle(Factors) xlabel(,nogrid) ylabel(,nogrid) yline(1)
graph save "Graph" "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV398/Dissertation/Graphs/screeplotradical.gph"
graph export "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV398/Dissertation/Graphs/screeplotradical.jpg", as(jpg) name("Graph") quality(100) 

predict post_radical_factor 
label var post_radical_factor "Post-treatment radical activism support (factor)"

///moderates support


corr post_activism_moderate_1 post_activism_moderate_2 post_activism_moderate_3 post_activism_moderate_4, covariance 
matrix cov1 = r(C) 
matlist cov1

global N1 = r(N) 

mean post_activism_moderate_1 post_activism_moderate_2 post_activism_moderate_3 post_activism_moderate_4
matrix means_moderate = e(b) 

factormat cov1, n($N1) means(means_moderate) 

screeplot, title("") xtitle(Factors) xlabel(,nogrid) ylabel(,nogrid) yline(1)
graph save "Graph" "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV398/Dissertation/Graphs/screeplotmoderate.gph"
graph export "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV398/Dissertation/Graphs/screeplotmoderate.jpg", as(jpg) name("Graph") quality(100) 


predict post_moderate_factor
label var post_moderate_factor "Post-treatment moderate activism support (factor)" 

***I test below whether my question items form Mokken scales

******SAVE FILE BEFORE RUNNING MOKKEN SCALE TESTS******

ssc install msp
ssc install traces

msp post_activism_radical_1 post_activism_radical_2 post_activism_radical_3 post_activism_radical_4, c(0.3) /// this first command tests for the scalability of the items, c(x) specificies the minimum Loevinger's H required to keep the item in the scale - 0.3 is generally considered the minimum for scalability 

traces post_activism_radical_1 post_activism_radical_2 post_activism_radical_3 post_activism_radical_4, restscore cumulative nodrawcomb /// plots item response graph - shows the prob of responding some value to a given item against the sum score for an individual on all the other items - monotonicity requires that these plots never decrease - clearly bot fully monotnoic - this could be because of small sample size: sometimes the probability of politive response drops to zero because there are no observations ... - seems like they respect invariant item ordering (non-interesecting IRFs) 

graph save "restscore4" "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV398/Dissertation/Graphs/monotonicitygraphradical.gph", replace
graph export "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV398/Dissertation/Graphs/monotonicitygraphradical.jpg", as(jpg) name("restscore4") quality(100) ///save one graph as an example

///it seems very clear that the problem is sample size: probabilities drop to zero sometimes because there are simply no observations with those values ... unlikely to be because they actually dont exist but rather because I dont observe them - this is clear because none of the traces are trending down or reversing, they spike up and down but broadly trend upwards 

///run tests for difficulty

summarize post_activism_radical_*

irt grm post_activism_radical_1 post_activism_radical_2 post_activism_radical_3 post_activism_radical_4, nolog /// fit graded response model to test for difficulty of items and discrimination parameters

irtgraph icc 1.post_activism_radical_* 4.post_activism_radical_*, bcc xlabel(,nogrid) ylabel(,nogrid) legend(size(vsmall)) title("") ///plot out item response functions to check (visually) the difficult and dscrimination parameters of the various items

///policy mokken scaling

msp post_policy_1-post_policy_8, c(0.3)

traces post_policy_1-post_policy_8, restscore cumulative nodrawcomb

///moderate mokken scaling

msp post_activism_moderate_1 post_activism_moderate_2 post_activism_moderate_3 post_activism_moderate_4, c(0.3)

traces post_activism_moderate_1 post_activism_moderate_2 post_activism_moderate_3 post_activism_moderate_4, restscore cumulative nodrawcomb

***test factoring on overall activism scale??

corr post_activism_moderate_1-post_activism_radical_4, covariance 
matrix cov1 = r(C) 
matlist cov1

global N1 = r(N) 

mean post_activism_moderate_1-post_activism_radical_4 
matrix means_radical = e(b) 

factormat cov1, n($N1) means(means_radical) 

screeplot, title("") xtitle(Factors) xlabel(,nogrid) ylabel(,nogrid) yline(1)
graph save "Graph" "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV398/Dissertation/Graphs/screeplotradical.gph"
graph export "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV398/Dissertation/Graphs/screeplotradical.jpg", as(jpg) name("Graph") quality(100) 

///run tests for difficulty

irt grm post_activism_moderate_1 post_activism_moderate_2 post_activism_moderate_3 post_activism_moderate_4, nolog /// fit graded response model to test for difficulty of items and discrimination parameters

irtgraph icc 1.post_activism_moderate_* 4.post_activism_moderate_*, bcc xlabel(,nogrid) ylabel(,nogrid) legend(size(vsmall)) title("") ///plot out item response functions to check (visually) the difficult and dscrimination parameters of the various items

