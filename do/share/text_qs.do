/* export all questions that have open text response */

/* 
do $projdir/do/share/text_qs.do

 */


use $projdir/dta/csac_2025_initial_clean.dta, clear 

include $projdir/do/macros_csac.doh 

foreach v of local text_qs {
    replace `v' =  strupper(stritrim(strtrim(`v')))

    export excel responseid `v' using $projdir/out/text_qs if !mi(`v') ///
        , sheet("`v'") firstrow(varlabels) sheetreplace

}

// emails
replace interview_email = strlower(stritrim(strtrim(interview_email)))
export delimited responseid interview_email using $projdir/out/interview_email.csv if !mi(interview_email), replace 

