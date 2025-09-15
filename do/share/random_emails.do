/* generate 150 random emails for interviews */

/* to run this do file, type
do $projdir/do/share/random_emails.do
 */

log close _all

graph drop _all
set more off
set varabbrev off
set graphics off
set scheme s1color
set seed 1984

use $projdir/dta/csac_2025_initial_clean_aug.dta, clear 

include $projdir/do/macros_csac.doh 


keep responseid interview_email `demo_qs' `other_tab_qs'

keep if !mi(interview_email)

randomtag, count(150)

export delimited responseid interview_email if _randomtag==1 using $projdir/out/interview_email_random150.csv, replace 

randomtag if _randomtag!=1, count(150) generate(_randomtag2)

export delimited if _randomtag2==1 using $projdir/out/interview_email_random150_batch2_withdemo.csv, replace 


save $projdir/dta/email_list_withdemo.dta, replace 
