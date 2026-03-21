
global HELPER "$MAIN/Helper"

if "`project'"=="RFE"{
	global RFEMAIN "/Users/albertoornaghi/Documents/GitHub/coding_samples/RFE"
	global MAIN "/Users/albertoornaghi/Documents/GitHub/coding_samples"
	
	global RFECODE "$RFEMAIN/Code"
	
	global RFEDATA "$RFEMAIN/Datasets"
	
	global RFEFIG "$RFEMAIN/Graphs"
	global RFETAB "$RFEMAIN/Tables"
	
	
}

if "`project'"=="MN"{
	global MNMAIN "/Users/albertoornaghi/Documents/GitHub/coding_samples/MN"
	global MAIN "/Users/albertoornaghi/Documents/GitHub/coding_samples"
	
	global MNCODE "$MNMAIN/Code"
	
	global MNDATA "/Users/albertoornaghi/Desktop/LSE Files/Year 4/GV343/Methods Note"
	
	global MNFIG "$MNMAIN/Graphs"
	global MNTAB "$MNMAIN/Tables"
	
	
}


if "`project'"=="NEPS"{
	
	global NEPSMAIN "/Users/albertoornaghi/Documents/GitHub/coding_samples/NEPS"

	global NEPSDATA "/Users/albertoornaghi/Desktop/PSE Files/Advanced Microeconometrics/NEPS Data" //data too big to store in GitHub

	global NEPSCODE "$MAIN/Code"

	global NEPSFIG "$MAIN/Fig"
	global NEPSTAB "$MAIN/Tables"
	
}
