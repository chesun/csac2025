/* tabulate main questions */

/* to run this do file, type
do $projdir/do/explore/tab_questions.do
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

foreach version in jul aug {

    use $projdir/dta/csac_2025_initial_clean_`version'.dta, clear 


    *********** simple tab
    log using $projdir/log/explore/tab_questions_simple_`version'.txt, text replace 
    foreach var of local all_qs {
        di "tabulation of `var'"
        
        tab `var' if hs_senior==1

    }

    log close 


    *********** tab by demographics and other characteristics

    foreach c in `demo_qs' `other_tab_qs' {
        di "tabulation by `c'"
        log using $projdir/log/explore/tab_questions_`c'_`version'.txt, text replace 

            foreach var of local all_qs {
            di "`var' by `c'"


            tabulate `c' `var'  if hs_senior==1, row 

        }

        log close 
    }

}

*** demographics by region and locale 
use $projdir/dta/csac_2025_initial_clean_aug.dta, clear 

foreach c of local location_qs {
        di "tabulation by `c'"
        log using $projdir/log/explore/tab_demo_`c'_aug.txt, text replace 

            foreach var of local demo_qs {
            di "`var' by `c'"


            tabulate `c' `var'  if hs_senior==1, row 

        }

        log close 
    }

*** Tab by college applied
log using $projdir/log/explore/tab_contact_coll_applied.txt, text replace 

foreach q in coll_contact coll_contact_subject_doc coll_contact_subject_work ///
    coll_contact_subject_grant coll_contact_subject_loan {

        di "`q' by coll_applied_coded_single"
        tab coll_applied_coded_single `q' , row 

    }

        log close 

*** tabulate the corrected fafsa challenges
log using $projdir/log/explore/tab_fafsa_challenge.txt, text replace 

foreach q of local q14_subqs {
    di "simple tab"
    tab `q'


}

foreach c in `demo_qs' `other_tab_qs' {

    foreach q of local q14_subqs {
        di "tabulation of `q' by `c'"

    tab `c' `q', row


    }


}

log close 