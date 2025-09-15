/* get demographics for interviewees */

/* to run this do file, type
do $projdir/do/share/interview_demo.do
 */

log close _all

graph drop _all
set more off
set varabbrev off
set graphics off
set scheme s1color
set seed 1984


include $projdir/do/macros_csac.doh 


import delimited $projdir/dta/interview_email_random150_batch1_flag.csv, varnames(1) clear 


merge 1:1 responseid using $projdir/dta/csac_2025_initial_clean.dta, keepusing(`demo_qs' `other_tab_qs') keep(3) 

export delimited $projdir/out/interview_email_random150_batch1_withdemo.csv