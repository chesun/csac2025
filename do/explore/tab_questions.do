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

