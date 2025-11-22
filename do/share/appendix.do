/* create appendix tables */

/* 
to run this do file:

do $projdir/do/share/appendix.do

 */

log close _all

set linesize 200

graph drop _all
set more off
set varabbrev off
set graphics off
set scheme s1color
set seed 1984


local check_tab_dir "$projdir/out/check"

use $projdir/dta/csac_2025_initial_clean_aug.dta, replace 

include $projdir/do/macros_csac.doh 

local c2c_qnums 12 14 16 22 23 31 36 37 38 39 40 48 50 ///
    55 56 57 59 60 61 62 63 64 65 66

lab var race_hrchy "Race/Ethnicity"
lab var gender "Gender"
lab var firstgen_byattend "First-Gen"
lab var schoolregion "Region"
lab var schoollocale_comb "Locale"
lab var hs_grade_coarse "High School Grades"

local appendix_tab_qs race_hrchy gender firstgen_byattend schoolregion schoollocale_comb hs_grade_coarse

//--------------------------------------------------------------------
// C2C appendix
//--------------------------------------------------------------------

foreach report_type in c2c {
    asdoc, save(`check_tab_dir'/appendix_`report_type'.doc) replace text( Appendix: Tabulations of Referenced Survey Questions)
    asdoc, save(`check_tab_dir'/appendix_`report_type'.doc) append text(\) 

    local secnum 1
    foreach qnum in ``report_type'_qnums' {
        // write heading 
        asdoc, save(`check_tab_dir'/appendix_`report_type'.doc) append text(\b `secnum'. Tabulations of Question `qnum': `q`qnum'_str')  fs(16)
        asdoc, save(`check_tab_dir'/appendix_`report_type'.doc) append text(\)

        local subsecnum 1


        foreach var of varlist `q`qnum'_subqs' {
            // write subheading for sub question
            asdoc, save(`check_tab_dir'/appendix_`report_type'.doc) append text(\b `secnum'.`subsecnum'. ``var'_str') fs(14)
            asdoc, save(`check_tab_dir'/appendix_`report_type'.doc) append text(\)

            // one way tabulation, rtf font size are half of the number 
            local subsubsecnum 1
            asdoc, save(`check_tab_dir'/appendix_`report_type'.doc) append text(\b `secnum'.`subsecnum'.`subsubsecnum'. One-Way Tabulation) fs(12)
            asdoc tab `var', save(`check_tab_dir'/appendix_`report_type'.doc) append title(\) label fs(12) 

            // twoway tabulation
            local subsubsecnum 2

            foreach demo of varlist `appendix_tab_qs' {

                asdoc, save(`check_tab_dir'/appendix_`report_type'.doc) append text(\b `secnum'.`subsecnum'.`subsubsecnum'. Two-Way Tabulation by ``demo'_str') fs(12)

                asdoc tab2 `demo' `var', save(`check_tab_dir'/appendix_`report_type'.doc) append title(\) label row fs(12) nokey

                local subsubsecnum `= `subsubsecnum' + 1'


            }

            local subsecnum `= `subsecnum' + 1'

        }



        local secnum `=`secnum'+ 1'

    }
}

