/* check people who answered "not required for my college" for why no a-g */

/* to run this do file, type
do $projdir/do/explore/atog_check.do
 */

log close _all

set linesize 200

graph drop _all
set more off
set varabbrev off
set graphics off
set scheme s1color
set seed 1984

include $projdir/do/macros_csac.doh 


use $projdir/dta/csac_2025_initial_clean_aug.dta, clear 

tab where_attend_coll if why_no_atog_notrequired==1