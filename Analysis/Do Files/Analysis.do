* 2-1-1 Data Analysis


* Set directory path

	global path "S:/CHHS/MYDEPT/PRIVATE/Thomas_CoordinatedEntry/2021-coordinated-entry-analysis"

* Set folder directories
	
	global dos "${path}/Analysis/Do Files"
	global data  "${path}/Data"
	global output "${path}/Analysis/Figures"


* Import CSVs, load and merge the data across the three study years and ///
* save it as a single dataset

local years 19 20 21

	foreach i in `years' {

		import delimited "${data}/Cleaned/CEMonthly_20`i'.csv", clear

		save "${data}/Cleaned/CEMonthly_20`i'.dta", replace

	}

	use "${data}/Cleaned/CEMonthly_2019.dta", clear

	append using "${data}/Cleaned/CEMonthly_2020.dta"

	append using "${data}/Cleaned/CEMonthly_2021.dta"

	save "${data}/Cleaned/CEMonthly_all.dta", replace

* Generate Valid time for Key variables in Seconds

	gen double avg_wait = (clock(averagequeuewaittime, "hms"))/1000

	gen double avg_handle = (clock(averagehandletime, "hms"))/1000

	gen double avg_hold = (clock(averageholdtime, "hms"))/1000

/* Aggregate Inbound and Callback times by date and Calculate Weighted Averages. 

The dataset includes average times for inbound calls and callbacks in separate rows. 
The average for a given indicator, say, average call time is the average of both inbound
and callback times. Since each of these two types is reported as a daily average with
different volume of calls, we calculate the overall average of the two by 
weighting inbound and callback averages by the respective number of calls. 

Formula Wt_calltime = (avg_inbound*inboundcalls + avg_callback*callbackcalls) / total calls

*/

	foreach k in avg_wait avg_handle avg_hold {
		
		gen wt_`k' = calls * `k' 
	}


	collapse (sum) calls agentcount wt_avg_wait wt_avg_handle wt_avg_hold ///
	(mean) avg_wait avg_handle avg_hold, by(date language)

	foreach j in wt_avg_wait wt_avg_handle wt_avg_hold {
	
		gen `j'_1 = ((`j' / 60) / calls)
		
	}
	
	label variable wt_avg_wait_1 "Average Wait Time (Weighted) in minutes"
	
	label variable wt_avg_handle_1 "Average Call Length (Weighted) in minutes"
	
	label variable wt_avg_hold_1 "Average Hold Time (Weighted) in minutes"
	
	label variable calls "Number of Calls"
	
	label variable agentcount "Number of Agents"

* Transform Date Variable and set the dataset as timeseries

	gen date1 = date(date, "YMD")

	label variable date1 "Date of Call"
	
	
	


* Encode Language as a numerical variable and set the timeseries and panel

	encode language, generate(lang)
	
	tsset lang date1
	
	format date1 %td


	save "${data}/Cleaned/timeseries_211.dta", replace
	export delimited using "${data}/Cleaned/timeseries_211.csv", replace
	
	drop if lang==2
	
	export delimited using "${data}/Cleaned/timeseries_211_eng.csv", replace
	
    
	use "${data}/Cleaned/timeseries_211.dta", clear
	
	

* Trend of Average Call length for English and Spanish Calls

		foreach var in wt_avg_handle_1 {
	
			foreach l in 1 2 {
			
				lpoly `var' date1 if lang==`l', bwidth(18) ci mcolor(maroon%70) ///
				msize(vsmall) lineopts(lcolor(maroon)) ciopts(recast(rarea) ///
				color(maroon%50) fintensity(30)) xlabel(#15, labsize(tiny) ///
				angle(forty_five) format(%tdMon_dd,_CCYY)) legend(on nocolfirst ///
				rows(1)	position(6)) scheme(cleanplots)	name(`var'_`l', replace) ///
				xsize(8) ysize(6) 
			
			do "${dos}/graph_format.do"
			
			graph save "`var'_`l'" "${output}/`var'`l'.gph", replace
			
			graph export "${output}/`var'`l'.png", replace
			
				}
		}


foreach var in wt_avg_wait_1  {
	
		foreach l in 1 2 {
			
			lpoly `var' date1 if lang==`l', bwidth(18) ci mcolor(ebblue%70) ///
			msize(vsmall) lineopts(lcolor(ebblue)) ciopts(recast(rarea) ///
			fcolor(ebblue%50) fintensity(30)) xlabel(#15, labsize(tiny) ///
			angle(forty_five) format(%tdMon_dd,_CCYY)) legend(on nocolfirst ///
			rows(1) position(6)) scheme(cleanplots) name(`var'_`l', replace) ///
			xsize(8) ysize(6) 
			
			do "${dos}/graph_format.do"
			
			graph save "`var'_`l'" "${output}/`var'`l'.gph", replace
			
			graph export "${output}/`var'`l'.png", replace
			
		}
}



foreach var in wt_avg_hold_1 {
	
		foreach l in 1 2 {
			
			lpoly `var' date1 if lang==`l', bwidth(18) ci mcolor(purple%70) ///
			msize(vsmall) lineopts(lcolor(purple)) ciopts(recast(rarea) /// 
			fcolor(purple%50) fintensity(30)) xlabel(#15, labsize(tiny) /// 
			angle(forty_five) format(%tdMon_dd,_CCYY)) legend(on nocolfirst ///
			rows(1) position(6)) scheme(cleanplots) name(`var'_`l', replace) ///
			xsize(8) ysize(6) 
			
			do "${dos}/graph_format.do"
			
			graph save "`var'_`l'" "${output}/`var'`l'.gph", replace
			
			graph export "${output}/`var'`l'.png", replace
			
		}
}

foreach var in calls agentcount {
	
		foreach l in 1 2 {
			
			lpoly `var' date1 if lang==`l', bwidth(18) ci mcolor(navy%70) ///
			msize(vsmall) lineopts(lcolor(navy)) ciopts(recast(rarea) ///
			fcolor(navy%50)  fintensity(30)) xlabel(#15, labsize(tiny) ///
			angle(forty_five) format(%tdMon_dd,_CCYY)) legend(on nocolfirst ///
			rows(1) position(6)) scheme(cleanplots) name(`var'_`l', replace) ///
			xsize(8) ysize(6) 
			
			do "${dos}/graph_format.do"
			
			graph save "`var'_`l'" "${output}/`var'`l'.gph", replace
			
			graph export "${output}/`var'`l'.png", replace
			
		}
}


