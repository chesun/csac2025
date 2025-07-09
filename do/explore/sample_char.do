/* explore sample chacracteristics */

/* to run this do file, type
do $projdir/do/explore/sample_char.do
 */

log close _all

log using $projdir/log/explore/explore_sample_char.txt, text replace 

graph drop _all
set more off
set varabbrev off
set graphics off
set scheme s1color
set seed 1984

use $projdir/dta/csac_2025_initial_clean, clear

//------------------------------------------------
// HS Senior status and college going
//------------------------------------------------

tab hs_senior 

tab attend_coll if hs_senior == 1



//------------------------------------------------
// demographics
//------------------------------------------------

di "race for all respondents"
tab race_simple_23
tab race_simple_24
tab race_hrchy

di "race for high school seniors"
tab race_simple_23 if hs_senior==1 
tab race_simple_23 if hs_senior==1 
tab race_hrchy if hs_senior == 1


di "parent education"

tab parent_edu if hs_senior==1


di "First-gen status, defined by college degree"
tab firstgen_bydegree if hs_senior==1


di "First-gen status, defined by attending college"
tab firstgen_byattend if hs_senior==1


di "home language is english"

tab home_lang_eng if hs_senior == 1

di "has a job"

tab has_job if hs_senior == 1

di "gender"

tab gender if hs_senior == 1



log close 
