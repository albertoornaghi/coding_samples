
if "`table'"=="sample"{

collect style cell, border( all, width(0.5) pattern(single))
collect label levels result total "Sample Size" mean "Sample Proportion (%)", modify
collect style cell, halign(left) valign(center)

}

if "`table'"=="mean_sd"{
	
	collect style cell, border( all, width(0.5) pattern(single))
	collect label levels result mean "Mean" sd "Standard Deviation", modify
	collect style cell, halign(left) valign(center)
	
}

if "`table'"=="proportion_sd"{

	collect style cell, border( all, width(0.5) pattern(single))
	collect label levels result mean "Proportion" sd "Standard Deviation", modify
	collect style cell, halign(left) valign(center)
	
}

if "`table'"=="diff_pairwise"{
	
collect style title, font(, bold)
collect style cell, border( all, width(0.5) pattern(single) )
collect style cell, halign(left) valign(center)
collect stars p .01 `"***"' .05 `"**"' .1 `"*"', attach(diff) shownote
collect style cell, nformat(%7.2f)

}
