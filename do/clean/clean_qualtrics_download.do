/* First pass clean of qualtrics downloaded data */

/* to run this do file, type
do $projdir/do/clean/clean_qualtrics_download.do
 */

log close _all

log using $projdir/log/clean/clean_qualtrics_download.txt, text replace  

graph drop _all
set more off
set varabbrev off
set graphics off
set scheme s1color
set seed 1984

// this is the correct file, the older file has line breaks in text response which results in incorrect import

// clean both july and august data versions to see how many additional responses we have
foreach version in jul aug {
    import delimited "$rawdtadir/csac_2025_label_`version'.csv", varnames(1) rowrange(4) clear 


    /* Importing jake's newest data */
    /* import delimited "/home/research/ca_ed_lab/data/restricted_access/raw/csac_survey/2024/csac_2025_label_aug.csv", varnames(1) rowange(4) clear */


    // Q33: Which campus are you most likely to attend? (if UC selected)
    encode q33, generate(which_uc_campus) label(which_uc_campus_lab)
    label var which_uc_campus "Q33: which campus are you most likely to attend (if UC)"
    drop q33 

    // Q34: Which campus are you most likely to attend? (if CSU selected)
    encode q34, generate(which_csu_campus) label(which_csu_campus_lab)
    label var which_csu_campus "Q34: which campus are you mostly likely to attend (if CSU)"
    drop q34 

    keep responseid which_uc_campus which_csu_campus
    tempfile campus 
    save `campus', replace 

    import delimited "$rawdtadir/csac_2025_value_`version'.csv", varnames(1) rowrange(4) clear 

    // drop empty system variables
    drop recipient*name recipientemail externalreference

    drop distributionchannel  
    drop *click* *pagesubmit

        // code the date time variables as stata datetime format
        foreach var of varlist startdate enddate recordeddate {
            gen num`var' = clock(`var', "YMD hms")
            format num`var' %tc
        }

        //create a month variable
        gen month =  month(dofc(numenddate))
        lab var month "Month of response"


    //------------ cleaning questions
    label define hs_senior_lab 0 "No" 1 "Yes"
    gen hs_senior =.
    replace hs_senior = 0 if q8=="2"
    replace hs_senior = 1 if q8=="1"
    label var hs_senior "Q8: Graduated HS in spring or summer 2025"
    drop q8


    ************* FAFSA questions 

    // Q11: wy did you complete FAFSA or CADAA? select all that apply
    rename q11 why_fafsa_raw
    label var why_fafsa_raw "Q11: Why did you complete FAFSA/CADAA"

    gen why_fafsa_requirement = (strpos(why_fafsa_raw, "1")!=0)
    replace why_fafsa_requirement = . if mi(why_fafsa_raw)
    gen why_fafsa_assignment = (strpos(why_fafsa_raw, "2")!=0)
    replace why_fafsa_assignment = . if mi(why_fafsa_raw)
    gen why_fafsa_eligible = (strpos(why_fafsa_raw, "3")!=0)
    replace why_fafsa_eligible = . if mi(why_fafsa_raw)
    gen why_fafsa_expected = (strpos(why_fafsa_raw, "4")!=0)
    replace why_fafsa_expected = . if mi(why_fafsa_raw)
    gen why_fafsa_other = (strpos(why_fafsa_raw, "5")!=0)
    replace why_fafsa_other = . if mi(why_fafsa_raw)


    label var why_fafsa_requirement "Q11: Requirement for Graduation"
    label var why_fafsa_assignment "Q11: Assignment for Class"
    label var why_fafsa_eligible "Q11: Check Eligibility for Financial Aid"
    label var why_fafsa_expected "Q11: Expected at School"
    label var why_fafsa_other "Q11: Other"


    rename q11_5_text why_fafsa_other_text
    replace why_fafsa_other_text = strlower(strtrim(why_fafsa_other_text))
    label var why_fafsa_other_text "Q11: Free response for why completed FAFSA or CADAA"

    // Q12: when did you first hear about FAFSA
    lab define when_heard_fafsa_lab 1 "Senior Year" 2 "Junior Year" 3 "Before Junior Year"
    destring q12, generate(when_heard_fafsa) 
    lab val when_heard_fafsa when_heard_fafsa_lab
    label var when_heard_fafsa "Q12: When did you first hear about FAFSA or CADAA"
    drop q12 

    // Q13: how difficult was applying for financial aid
    lab define difficulty_apply_finaid_lab 1 "Very easy" 2 "Somewhat easy" 3 "Somewhat difficult" 4 "Very difficult"
    destring q13, generate(difficulty_apply_finaid) 
    lab val difficulty_apply_finaid difficulty_apply_finaid_lab
    label var difficulty_apply_finaid "Q14: How difficult was applying for financial aid"
    drop q13

    // Q14: What challenges did you face in applying for financial aid via the FAFSA or CADAA? (Select all that apply)
    rename q14 finaid_challenge_raw
    label var finaid_challenge_raw "Q15: challenges you faced applying to FAFSA/CADAA"

    gen finaid_challenge_tech = (strpos(finaid_challenge_raw, "1")!=0)
    gen finaid_challenge_none = (strpos(finaid_challenge_raw, "10") !=0)
    gen finaid_challenge_doc = (strpos(finaid_challenge_raw, "2") !=0)
    gen finaid_challenge_invite = (strpos(finaid_challenge_raw, "3") !=0)
    gen finaid_challenge_multi = (strpos(finaid_challenge_raw, "4") !=0)
    gen finaid_challenge_confusing = (strpos(finaid_challenge_raw, "5") !=0)
    gen finaid_challenge_nohelp = (strpos(finaid_challenge_raw, "6") !=0)
    gen finaid_challenge_info = (strpos(finaid_challenge_raw, "7") !=0)
    gen finaid_challenge_whichapp = (strpos(finaid_challenge_raw, "8") !=0)
    gen finaid_challenge_other = (strpos(finaid_challenge_raw, "9") !=0)


    replace finaid_challenge_tech =. if mi(finaid_challenge_raw)
    replace finaid_challenge_none =. if mi(finaid_challenge_raw)
    replace finaid_challenge_doc =. if mi(finaid_challenge_raw)
    replace finaid_challenge_invite =. if mi(finaid_challenge_raw)
    replace finaid_challenge_multi =. if mi(finaid_challenge_raw)
    replace finaid_challenge_confusing =. if mi(finaid_challenge_raw)
    replace finaid_challenge_nohelp =. if mi(finaid_challenge_raw)
    replace finaid_challenge_info =. if mi(finaid_challenge_raw)
    replace finaid_challenge_whichapp =. if mi(finaid_challenge_raw)
    replace finaid_challenge_other =. if mi(finaid_challenge_raw)

    label var finaid_challenge_tech "FAFSA challenges: technical difficulties"
    label var finaid_challenge_none "FAFSA challenges: no difficulties"
    label var finaid_challenge_doc "FAFSA challenges: issues with required documents"
    label var finaid_challenge_invite "FAFSA challenges: issues inviting financial contributors"
    label var finaid_challenge_multi "FAFSA challenges: took multiple attempts to submit"
    label var finaid_challenge_confusing "FAFSA challenges: application was confusing"
    label var finaid_challenge_nohelp "FAFSA challenges: could not find someone to help"
    label var finaid_challenge_info "FAFSA challenges: concerned about sharing family information"
    label var finaid_challenge_whichapp "FAFSA challenges: didn't know which applicationt o complete"
    label var finaid_challenge_other "FAFSA challenges: other/eplain"


    rename q14_9_text finaid_challenge_other_text 
    replace finaid_challenge_other_text  = strlower(strtrim(finaid_challenge_other_text ))
    label var finaid_challenge_other_text  "Q14: Free response for challenges faced applying to FAFSA/CADAA"

    // Q15: Please tell us about the support you received in completing your FAFSA/CADAA. (Select all that apply)
    rename q15 support_received_raw
    label var support_received_raw "Q16: Support received when applying for FAFSA/CADAA"

    gen support_received_counselor = (strpos(support_received_raw, "1") !=0)
    gen support_received_teacher = (strpos(support_received_raw, "2") !=0)
    gen support_received_hsworkshop = (strpos(support_received_raw, "3") !=0)
    gen support_received_cmworkshop = (strpos(support_received_raw, "4") !=0)
    gen support_received_parent = (strpos(support_received_raw, "5") !=0)
    gen support_received_family = (strpos(support_received_raw, "6") !=0)
    gen support_received_friend = (strpos(support_received_raw, "7") !=0)
    gen support_received_online = (strpos(support_received_raw, "8") !=0)
    gen support_received_nobody = (strpos(support_received_raw, "9") !=0)

    replace support_received_counselor =. if mi(support_received_raw)
    replace support_received_teacher =. if mi(support_received_raw)
    replace support_received_hsworkshop =. if mi(support_received_raw)
    replace support_received_cmworkshop =. if mi(support_received_raw)
    replace support_received_parent =. if mi(support_received_raw)
    replace support_received_family =. if mi(support_received_raw)
    replace support_received_friend =. if mi(support_received_raw)
    replace support_received_online =. if mi(support_received_raw)
    replace support_received_nobody =. if mi(support_received_raw)

    lab var support_received_counselor "Q15 FAFSA support: HS counselor"
    lab var support_received_teacher "Q15 FAFSA support: teacher"
    lab var support_received_hsworkshop "Q15 FAFSA support: HS workshop"
    lab var support_received_cmworkshop "Q15 FAFSA support: community workshop"
    lab var support_received_parent "Q15 FAFSA support: parent"
    lab var support_received_family "Q15 FAFSA support: family other than parent"
    lab var support_received_friend "Q15 FAFSA support: friend"
    lab var support_received_online "Q15 FAFSA support: Online resources"
    lab var support_received_nobody "Q15 FAFSA support: Nobody, completed on my own"

    order why_fafsa_* when_heard_fafsa difficulty_apply_finaid finaid_challenge_* support_received_*, after(hs_senior)

    // Q16 *NEW*: Would you prefer an option to apply for state-based aid only, in order to keep your data from being shared with the federal government - even if it meant not receiving federal aid?
    lab define prefer_state_only_lab 1 "Yes" 2 "No" 3 "I'm not sure" 4 "Prefer not to answer" 
    destring q16, gen(prefer_state_only)
    lab val prefer_state_only prefer_state_only_lab
    lab var prefer_state_only "Prefer option to apply for state aid only"
    drop q16 

    ***************** College applications questions 

    // Q18: How much do you agree with the statements about college below?

    label define coll_att_3pt_lab -1 "Disagree" 0 "Somewhat agree" 1 "Strongly agree"
    destring q18_1, generate(coll_att_3pt_important) 
    destring q18_2, generate(coll_att_3pt_worth) 
    destring q18_3, generate(coll_att_3pt_ready) 
    // the question is currently 1,2,3
    order coll_att_3pt_important coll_att_3pt_worth coll_att_3pt_ready, after(prefer_state_only)
    foreach var of varlist coll_att_3pt_important - coll_att_3pt_ready {
        di "variable: `var'"
        replace `var' = `var' - 2
    }
    lab val coll_att_3pt_important coll_att_3pt_worth coll_att_3pt_ready coll_att_3pt_lab

        label var coll_att_3pt_important "College is important for my future plans"
        label var coll_att_3pt_worth "College is worth the cost"
        label var coll_att_3pt_ready "I am academically ready for college"

    drop q18_?
    order coll_att*, after(support_received_nobody)

    // Q19: To what extent do you think each of these should be considered as factor in college admissions
    label define coll_factor_lab 0 "Not a factor" 1 "Minor Factor" 2 "Major Factor"

    destring q19_1, generate(coll_factor_gpa) 
    destring q19_2, generate(coll_factor_score) 
    destring q19_3, generate(coll_factor_service)
    destring q19_4, generate(coll_factor_firstgen)
    destring q19_5, generate(coll_factor_extra)
    drop q19_?



    // the questions are currently 1,2,3
    foreach var of varlist coll_factor_gpa - coll_factor_extra {
        replace `var' = `var' - 1
    }

    lab val coll_factor_gpa - coll_factor_extra coll_factor_lab

    label var coll_factor_gpa "Q19: how should High School GPA factor in college applications"
    label var coll_factor_score "Q19: how should std test score factor in coll app"
    label var coll_factor_service "Q19: how should community service factor in coll app"
    label var coll_factor_firstgen "Q19: how should being firstgen factor in coll app"
    label var coll_factor_extra "Q19: how should extracurricular activites factor in coll app"


    rename q20 coll_factor_other_text 
    label var coll_factor_other_text "Q20: what other factors should be considered in coll app"


    //------- plans after high school graduation 

    // Q22: Did you apply to any colleges and universities? (Select all that apply)
    rename q22 coll_applied_raw
    label var coll_applied_raw "Q25: What colleges or universities did you apply to"

    gen coll_applied_ccc = (strpos(coll_applied_raw, "1") !=0)
    gen coll_applied_csu = (strpos(coll_applied_raw, "2") !=0)
    gen coll_applied_uc = (strpos(coll_applied_raw, "3") !=0)
    gen coll_applied_priv4yr = (strpos(coll_applied_raw, "4") !=0)
    gen coll_applied_vocation = (strpos(coll_applied_raw, "5") !=0)
    gen coll_applied_outside = (strpos(coll_applied_raw, "6") !=0)
    gen coll_applied_notsure = (strpos(coll_applied_raw, "7") !=0)
    gen coll_applied_none = (strpos(coll_applied_raw, "9") !=0)

    replace coll_applied_ccc =. if mi(coll_applied_raw)
    replace coll_applied_csu =. if mi(coll_applied_raw)
    replace coll_applied_uc =. if mi(coll_applied_raw)
    replace coll_applied_priv4yr =. if mi(coll_applied_raw)
    replace coll_applied_vocation =. if mi(coll_applied_raw)
    replace coll_applied_outside =. if mi(coll_applied_raw)
    replace coll_applied_notsure =. if mi(coll_applied_raw)
    replace coll_applied_none =. if mi(coll_applied_raw)

    label var coll_applied_ccc "Q22: applied to CCC"
    label var coll_applied_csu "Q22: applied to CSU"
    label var coll_applied_uc "Q22: applied to UC"
    label var coll_applied_priv4yr "Q22: applied to private 4 year in CA"
    label var coll_applied_vocation "Q22: applied to vocational college in CA"
    label var coll_applied_outside "Q22: applied to college outside CA"
    label var coll_applied_notsure "Q22: not sure"
    label var coll_applied_none "Q22: did not apply to college"


    // a shortened variable for encoding different combos
        gen coll_applied_short = coll_applied_raw
        replace coll_applied_short = subinstr(coll_applied_short, "1", "CCC", .)
        replace coll_applied_short = subinstr(coll_applied_short, "2", "CSU", .)
        replace coll_applied_short = subinstr(coll_applied_short, "3", "UC", .)
        replace coll_applied_short = subinstr(coll_applied_short, "4", "PRIVATE", .)
        replace coll_applied_short = subinstr(coll_applied_short, "5", "VOCATIONAL", .)
        replace coll_applied_short = subinstr(coll_applied_short, "6", "OUTSIDE", .)
        replace coll_applied_short = subinstr(coll_applied_short, "7", "NOTSURE", .)
        replace coll_applied_short = subinstr(coll_applied_short, "9", "DIDNOTAPPLY", .)

        // encode 
        lab define coll_applied_coded 1 "CCC" 2 "CSU" 3 "UC" ///
            4 "CCC,UC" 5 "CCC,CSU" 6 "CSU,UC" 7 "CCC,CSU,UC" ///
            8 "CCC,UC,PRIVATE" 9 "CCC,CSU,PRIVATE" 10 "CSU,UC,PRIVATE" 11 "CCC,CSU,UC,PRIVATE" ///
            12 "CCC,UC,VOCATIONAL" 13 "CCC,CSU,VOCATIONAL" 14 "CSU,UC,VOCATIONAL" 15 "CCC,CSU,UC,VOCATIONAL" ///
            16 "CCC,UC,OUTSIDE" 17 "CCC,CSU,OUTSIDE" 18 "CSU,UC,OUTSIDE" 19 "CCC,CSU,UC,OUTSIDE" 

        encode coll_applied_short, gen(coll_applied_coded) lab(coll_applied_coded)
        lab var coll_applied_coded "College applied coded with all categories"

        gen coll_applied_coded_trunc = coll_applied_coded
        replace coll_applied_coded_trunc = 20 if coll_applied_coded_trunc >= 20 & !mi(coll_applied_coded_trunc)
        lab define coll_applied_coded_trunc ///
            1 "CCC" 2 "CSU" 3 "UC" ///
            4 "CCC,UC" 5 "CCC,CSU" 6 "CSU,UC" 7 "CCC,CSU,UC" ///
            8 "CCC,UC,PRIVATE" 9 "CCC,CSU,PRIVATE" 10 "CSU,UC,PRIVATE" 11 "CCC,CSU,UC,PRIVATE" ///
            12 "CCC,UC,VOCATIONAL" 13 "CCC,CSU,VOCATIONAL" 14 "CSU,UC,VOCATIONAL" 15 "CCC,CSU,UC,VOCATIONAL" ///
            16 "CCC,UC,OUTSIDE" 17 "CCC,CSU,OUTSIDE" 18 "CSU,UC,OUTSIDE" 19 "CCC,CSU,UC,OUTSIDE"  ///
            20 "OTHERCOMBINATIONS"

        lab values coll_applied_coded_trunc coll_applied_coded_trunc
        lab var coll_applied_coded_trunc "Colleges applied with truncated categories"

        //dummies
        gen coll_applied_only_ccc = 1 if coll_applied_coded == 1
        gen coll_applied_only_csu = 1 if coll_applied_coded == 2
        gen coll_applied_only_uc = 1 if coll_applied_coded == 3 
        gen coll_applied_only_ccc_uc = 1 if coll_applied_coded == 4
        gen coll_applied_only_ccc_csu = 1 if coll_applied_coded == 5 
        gen coll_applied_only_csu_uc = 1 if coll_applied_coded == 6 
        gen coll_applied_only_ccc_csu_uc = 1 if coll_applied_coded == 7

    // Q23: What challenges did you face when applying to college or trade school? (Select all that apply)
    rename q23 collapp_chall_raw
    label var collapp_chall_raw "Q26: challenges applying to college/trade school"

    gen collapp_chall_dna = (strpos(collapp_chall_raw, "1") !=0)
    gen collapp_chall_none = (strpos(collapp_chall_raw, "2") !=0)
    gen collapp_chall_noinfo = (strpos(collapp_chall_raw, "3") !=0)
    gen collapp_chall_dnu = (strpos(collapp_chall_raw, "4") !=0)
    gen collapp_chall_course = (strpos(collapp_chall_raw, "5") !=0)
    gen collapp_chall_miss = (strpos(collapp_chall_raw, "6") !=0)
    gen collapp_chall_fee = (strpos(collapp_chall_raw, "7") !=0)
    gen collapp_chall_deadline = (strpos(collapp_chall_raw, "8") !=0)
    gen collapp_chall_notready = (strpos(collapp_chall_raw, "11") !=0)
    gen collapp_chall_submit = (strpos(collapp_chall_raw, "9") !=0)
    gen collapp_chall_other = (strpos(collapp_chall_raw, "10") !=0)

    replace collapp_chall_dna =. if mi(collapp_chall_raw)
    replace collapp_chall_none =. if mi(collapp_chall_raw)
    replace collapp_chall_noinfo =. if mi(collapp_chall_raw)
    replace collapp_chall_dnu =. if mi(collapp_chall_raw)
    replace collapp_chall_course =. if mi(collapp_chall_raw)
    replace collapp_chall_miss =. if mi(collapp_chall_raw)
    replace collapp_chall_fee =. if mi(collapp_chall_raw)
    replace collapp_chall_deadline =. if mi(collapp_chall_raw)
    replace collapp_chall_notready =. if mi(collapp_chall_raw)
    replace collapp_chall_submit =. if mi(collapp_chall_raw)
    replace collapp_chall_other =. if mi(collapp_chall_raw)

    lab var collapp_chall_dna "Q23: did not apply to college"
    lab var collapp_chall_none "Q23: did not face challenges"
    lab var collapp_chall_noinfo "Q23: did nothave enough info"
    lab var collapp_chall_dnu "Q23: did not understand questions on application"
    lab var collapp_chall_course "Q23: trouble entering HS coursework"
    lab var collapp_chall_miss "Q23: missing necessary coursework for eligibility"
    lab var collapp_chall_fee "Q23: could not afford application fees"
    lab var collapp_chall_deadline "Q23: missed application deadline"
    lab var collapp_chall_notready "Q23: not academically ready for college"
    lab var collapp_chall_submit "Q23: difficulty submitting other required items"
    lab var collapp_chall_other "Q23: other (please specify)"

    rename q23_10_text collapp_chall_other_text
    label var collapp_chall_other_text "Q23: Free response for Other in college application challenges"

    // Q24: Do you plan to attend college in the fall?
    label define attend_coll_lab 0 "No" 1 "Yes" -1 "I don't know"
    destring q24, generate(attend_coll) 
    // currently coded as 1 yes,2 no,3 idk
    replace attend_coll = (attend_coll - 2)*(-1)
    lab val attend_coll attend_coll_lab
    label var attend_coll "Q27: plan to attend college in the fall"
    drop q24

    order coll_applied* collapp_chall* attend_coll, after(coll_factor_extra)


    ************** If not attending college 

    // Q26: What do you think you will be doing this coming Fall? (Select all that apply)
    rename q26 fall_plan_raw
    label var fall_plan_raw "Q26: plans for coming fall"

    gen fall_plan_workpt = (strpos(fall_plan_raw, "1") !=0)
    gen fall_plan_workft = (strpos(fall_plan_raw, "2") !=0)
    gen fall_plan_family = (strpos(fall_plan_raw, "3") !=0)
    gen fall_plan_military = (strpos(fall_plan_raw, "4") !=0)
    gen fall_plan_other = (strpos(fall_plan_raw, "5") !=0)

    replace fall_plan_workpt =. if mi(fall_plan_raw)
    replace fall_plan_workft =. if mi(fall_plan_raw)
    replace fall_plan_family =. if mi(fall_plan_raw)
    replace fall_plan_military =. if mi(fall_plan_raw)
    replace fall_plan_other =. if mi(fall_plan_raw)

    lab var fall_plan_workpt "Q26: work part time"
    lab var fall_plan_workft "Q26: work full time"
    lab var fall_plan_family "Q26: family obligations"
    lab var fall_plan_military "Q26: military"
    lab var fall_plan_other "Q26: other"

    rename q26_5_text fall_plan_other_text
    label var fall_plan_other_text "Q26: free response for fall plans: other"

    // Q27: Why won't you be attending college this fall? (Select all that apply)
    rename q27 why_no_coll_raw
    label var why_no_coll_raw "Q27: why won't you attend college this fall"

    gen why_no_coll_notforme = (strpos(why_no_coll_raw, "1") !=0)
    gen why_no_coll_expensive = (strpos(why_no_coll_raw, "2") !=0)
    gen why_no_coll_notworth = (strpos(why_no_coll_raw, "3") !=0)
    gen why_no_coll_gapyear = (strpos(why_no_coll_raw, "4") !=0)
    gen why_no_coll_military = (strpos(why_no_coll_raw, "5") !=0)
    gen why_no_coll_health = (strpos(why_no_coll_raw, "6") !=0)
    gen why_no_coll_work = (strpos(why_no_coll_raw, "7") !=0)
    gen why_no_coll_training = (strpos(why_no_coll_raw, "8") !=0)
    gen why_no_coll_other = (strpos(why_no_coll_raw, "9") !=0)

    replace why_no_coll_notforme =. if mi(why_no_coll_raw)
    replace why_no_coll_expensive =. if mi(why_no_coll_raw)
    replace why_no_coll_notworth =. if mi(why_no_coll_raw)
    replace why_no_coll_gapyear =. if mi(why_no_coll_raw)
    replace why_no_coll_military =. if mi(why_no_coll_raw)
    replace why_no_coll_health =. if mi(why_no_coll_raw)
    replace why_no_coll_work =. if mi(why_no_coll_raw)
    replace why_no_coll_training =. if mi(why_no_coll_raw)
    replace why_no_coll_other =. if mi(why_no_coll_raw)

    lab var why_no_coll_notforme "Q27: not for me"
    lab var why_no_coll_expensive "Q27: too expensive"
    lab var why_no_coll_notworth "Q27: Not worth the cost"
    lab var why_no_coll_gapyear "Q27: gap year"
    lab var why_no_coll_military "Q27: military"
    lab var why_no_coll_health "Q27: health reasons"
    lab var why_no_coll_work "Q27: need to work"
    lab var why_no_coll_training "Q27: in another education/training program"
    lab var why_no_coll_other "Q27: other"

    rename q27_9_text why_no_coll_other_text
    label var why_no_coll_other_text "Q27: why won't attend college this fall: other"

    *************** if idk attending college 

    //Q29: Which of the following might influence your decision of whether or not to attend college? (Select all that apply)
    rename q29 coll_decision_raw
    label var coll_decision_raw "Q29: which might influence decision to attend college"

    gen coll_decision_financial = (strpos(coll_decision_raw, "1") !=0)
    lab var coll_decision_financial "Q29: financial support"
    gen coll_decision_academic = (strpos(coll_decision_raw, "2") !=0)
    lab var coll_decision_academic "Q29: academic support"
    gen coll_decision_family = (strpos(coll_decision_raw, "3") !=0)
    lab var coll_decision_family "Q29: family or other support"

    replace coll_decision_financial =. if mi(coll_decision_raw)
    replace coll_decision_academic =. if mi(coll_decision_raw)
    replace coll_decision_family =. if mi(coll_decision_raw)

    order fall_plan_raw fall_plan_workpt - fall_plan_other fall_plan_other_text ///
        why_no_coll_raw why_no_coll_notforme - why_no_coll_other why_no_coll_other_text ///
        coll_decision_raw coll_decision_financial - coll_decision_family, after(attend_coll)


    ************* If yes to attending college 

    // Q31: Where are you most likely to attend college this fall?
    encode q31, generate(where_attend_coll) label(where_attend_coll_lab)
    label var where_attend_coll "Q31: where are you mostly likely to attend college this fall"
    drop q31
    label def where_attend_coll_lab 1 "CCC" 2 "CSU" 3 "UC" 4 "Priv 4yr" 5 "Vocational" 6 "Outside CA" 7 "None of these" 8 "Not sure", modify
    lab val where_attend_coll where_attend_coll_lab

    // Q32: text response. Which specific college or university are you most likely to attend?
    rename q32 which_coll
    label var which_coll "Q32: Which specific college are you mostly likely to attend"

    order which_coll, after(where_attend_coll)

    // which UC/CSU campus: Q33 and Q34
    merge 1:1 responseid using `campus', keep (3) nogen


    // Q35: How sure are you that you will attend this school in the fall?
    label define how_sure_attend_lab 0 "unsure" 1 "Somewhat sure" 2 "Absolutely sure"
    destring q35, generate(how_sure_attend) 
    // currently coded as 1,2,3
    replace how_sure_attend = how_sure_attend - 1
    lab val how_sure_attend how_sure_attend_lab
    label var how_sure_attend "Q35: how sure are you that you will attend this school in the fall"
    drop q35

    order where_attend_coll which_coll which_uc_campus which_csu_campus how_sure_attend, after(coll_decision_family)

    //--------------- new questions about transfer intentions 
    // Q36 *NEW*: Do you plan to eventually transfer from your community college to a four-year college or university? (if CCC selected)
    // currently 1,2,3 for yes, no,notsure
    gen plan_transfer=.
    replace plan_transfer = -1 if q36 == "2"
    replace plan_transfer = 0 if q36 == "3"
    replace plan_transfer = 1 if q36 == "1"
    lab def plan_transfer -1 "No" 0 "Not sure" 1 "yes"
    lab val plan_transfer plan_transfer
    lab var plan_transfer "Q36: Do you plan to transfer to 4-year college (if CCC)"

    gen plan_transfer_cat = .
    replace plan_transfer_cat = 1 if plan_transfer==1
    replace plan_transfer_cat = 2 if inlist(plan_transfer,-1,0)
    replace plan_transfer_cat = 3 if inlist(where_attend_coll, 2,3,4,6)
    lab define plan_transfer_cat 1 "plan to transfer" 2 "Unsure or no transfer" 3 "4 year"
    lab val plan_transfer_cat plan_transfer_cat
    lab var plan_transfer_cat "categories for crosstab, by plan to transfer"

    // Q37 *NEW*: What factors influenced your decision to start at a community college and transfer? (Select all that apply)
    rename q37 transfer_factor_raw 
    lab var transfer_factor_raw "Q37: What factors influenced decision to star at CC and transfer"

    gen transfer_factor_afford = (strpos(transfer_factor_raw, "1")!=0)
    lab var transfer_factor_afford "Q37 Transfer factor: affordability"
    gen transfer_factor_proximity = (strpos(transfer_factor_raw, "2")!=0)
    lab var transfer_factor_proximity "Q37 transfer factor: proximity to home"
    gen transfer_factor_path = (strpos(transfer_factor_raw, "3")!=0)
    lab var transfer_factor_path "Q37 transfer factor: unsure about major or career path"
    gen transfer_factor_work = (strpos(transfer_factor_raw, "4")!=0)
    lab var transfer_factor_work "Q37 transfer factor: need to work"
    gen transfer_factor_partnership = (strpos(transfer_factor_raw, "5")!=0)
    lab var transfer_factor_partnership "Q37 transfer factor: availability of transfer agreement/partnership"
    gen transfer_factor_comfort = (strpos(transfer_factor_raw, "6")!=0)
    lab var transfer_factor_comfort "Q37 transfer factor: feel more comfortable at CCC"
    gen transfer_factor_rejected = (strpos(transfer_factor_raw, "7")!=0)
    lab var transfer_factor_rejected "Q37 transfer factor: didn't get into 4 year university of choice"
    gen transfer_factor_ready = (strpos(transfer_factor_raw, "8")!=0)
    lab var transfer_factor_ready "Q37 transfer factor: wasn't academically ready for 4-year university"
    gen transfer_factor_other = (strpos(transfer_factor_raw, "9")!=0)
    lab var transfer_factor_other "Q37 transfer factor: other (please explain)"

    foreach v of varlist transfer_factor_afford - transfer_factor_other {
        replace `v' = . if mi(transfer_factor_raw)
    }

    rename q37_9_text transfer_factor_other_text 
    lab var transfer_factor_other_text "Text response to Q37 transfer factor: other"

    order plan_transfer transfer_factor*, after(how_sure_attend)

    // Q38 *NEW*: Where do you intend to transfer? 
    // the values are messed up
    /* original question coding: 1 "UC" 4 "CSU" 2 "Private in CA" 5 "Public Outside CA" 6 "Private Outside CA" 3 "Not Sure" */
    destring q38, replace 
    gen where_transfer = 1 if q38==1
    replace where_transfer = 2 if q38==4
    replace where_transfer = 3 if q38==2
    replace where_transfer=4 if q38==5
    replace where_transfer=5 if q38==6
    replace where_transfer=6 if q38==3
    drop q38
    lab define where_transfer 1 "UC" 2 "CSU" 3 "Private in CA" 4 "Public Outside CA" 5 "Private Outside CA" 6 "Not Sure"
    lab val where_transfer where_transfer
    lab var where_transfer "Q38: where do you intend to transfer"

    // Q39 *NEW*: Have you heard of the these transfer programs and pathways? (Select all that apply)
    rename q39 heard_pathway_raw 
    lab var heard_pathway_raw "Q39: have you heard of these transfer programs and pathways"

    gen heard_pathway_tag = (strpos(heard_pathway_raw, "1")!=0)
    lab var heard_pathway_tag "Q39 heard TAG"
    gen heard_pathway_adt = (strpos(heard_pathway_raw, "2")!=0)
    lab var heard_pathway_adt "Q39: heard ADT"
    gen heard_pathway_igetc = (strpos(heard_pathway_raw, "3")!=0)
    lab var heard_pathway_igetc "Q39: heard IGETC"
    gen heard_pathway_cgetc = (strpos(heard_pathway_raw, "4")!=0)
    lab var heard_pathway_cgetc "Q39: heard Cal-GETC"
    gen heard_pathway_tsp = (strpos(heard_pathway_raw, "5")!=0)
    lab var heard_pathway_tsp "Q39: heard TSP"
    gen heard_pathway_none = (strpos(heard_pathway_raw, "6")!=0)
    lab var heard_pathway_none "Q39: heard none"
    gen heard_pathway_notsure = (strpos(heard_pathway_raw, "7")!=0)
    lab var heard_pathway_notsure "Q39: heard not sure"

    foreach v of varlist heard_pathway_tag - heard_pathway_notsure {
        replace `v' = . if mi(heard_pathway_raw)
    }

    order where_transfer heard_pathway*, after(transfer_factor_other_text)

    // Q40 *NEW*: What are you primary goals for attending a community college before transferring? (Select all that apply)
    rename q40 cc_goal_raw 
    lab var cc_goal_raw "Q40: primary goals for attending CC before transferring"

    gen cc_goal_degree = (strpos(cc_goal_raw, "1")!=0)
    lab var cc_goal_degree "Q40: earn associate degree"
    gen cc_goal_gened = (strpos(cc_goal_raw, "2")!=0)
    lab var cc_goal_gened "Q40: complete gen ed requirements"
    gen cc_goal_path = (strpos(cc_goal_raw, "3")!=0)
    lab var cc_goal_path "Q40: explore major and career paths"
    gen cc_goal_other = (strpos(cc_goal_raw, "4")!=0)
    lab var cc_goal_other "Q40: other"

    foreach v of varlist cc_goal_degree - cc_goal_other {
        replace `v' = . if mi(cc_goal_raw)
    }

    rename q40_4_text cc_goal_other_text 
    lab var cc_goal_other_text "Q40: open response for other"

    order cc_goal*, after(heard_pathway_notsure)

    // Q41 *NEW* open text box: Do you have any concerns about your plans to transfer? 
    rename q41 transfer_concern_text
    lab var transfer_concern_text "Q41: any concern about plan to transfer"

    // Q42: Have any of the colleges that you have been accepted to contacted you about your financial aid offer (e.g. email, letter, phone call) ?
    destring q42, replace 
    rename q42 coll_contact 
    replace coll_contact = coll_contact - 1
    lab define coll_contact 0 "None" 1 "Some" 2 "All"
    lab val coll_contact coll_contact
    lab var coll_contact "Q42: any college contacted you about finaid"

    // Q43: What did the colleges contact you about regarding your financial aid offer? (Select all that apply) 
    rename q43 coll_contact_subject_raw
    label var coll_contact_subject_raw "Q43: what did the colleges contact you about regarding your finaid"

    gen coll_contact_subject_doc = (strpos(coll_contact_subject_raw, "1") !=0)
    gen coll_contact_subject_work = (strpos(coll_contact_subject_raw, "2") !=0)
    gen coll_contact_subject_grant = (strpos(coll_contact_subject_raw, "3") !=0)
    gen coll_contact_subject_loan = (strpos(coll_contact_subject_raw, "4") !=0)

    replace coll_contact_subject_doc =. if mi(coll_contact_subject_raw)
    replace coll_contact_subject_work =. if mi(coll_contact_subject_raw)
    replace coll_contact_subject_grant =. if mi(coll_contact_subject_raw)
    replace coll_contact_subject_loan =. if mi(coll_contact_subject_raw)

    lab var coll_contact_subject_doc "Q43: FAFSA/CADAA verification or additional documentation"
    lab var coll_contact_subject_work "Q43: eligibility for work study"
    lab var coll_contact_subject_grant "Q43: grants or scholarships"
    lab var coll_contact_subject_loan "Q43: information about loans"

    order transfer_concern_text coll_contact coll_contact_subject*, after(cc_goal_other_text)

    *************** college experience expectations
    // Q46: How do you plan to pay college tuition and fees? (Select all that apply)

    rename q46 pay_plan_raw
    label var pay_plan_raw "Q54: how do you plan to pay college tuition and fees"

    order pay_plan_raw, after(coll_contact_subject_loan)

    gen pay_plan_scholarship = (strpos(pay_plan_raw, "1") !=0) if !mi(pay_plan_raw)
    gen pay_plan_grant = (strpos(pay_plan_raw, "2") !=0) if !mi(pay_plan_raw)
    gen pay_plan_saving = (strpos(pay_plan_raw, "3") !=0) if !mi(pay_plan_raw)
    gen pay_plan_work = (strpos(pay_plan_raw, "4") !=0) if !mi(pay_plan_raw)
    gen pay_plan_otherppl = (strpos(pay_plan_raw, "5") !=0) if !mi(pay_plan_raw)
    gen pay_plan_loan = (strpos(pay_plan_raw, "6") !=0) if !mi(pay_plan_raw)
    gen pay_plan_va = (strpos(pay_plan_raw, "7") !=0) if !mi(pay_plan_raw)
    gen pay_plan_credit = (strpos(pay_plan_raw, "8") !=0) if !mi(pay_plan_raw)

    lab var pay_plan_scholarship "Q46: scholarships"
    lab var pay_plan_grant "Q46: grants"
    lab var pay_plan_saving "Q46: my own savings"
    lab var pay_plan_work "Q46: working while enrolled"
    lab var pay_plan_otherppl "Q46: money from other people"
    lab var pay_plan_loan "Q46: student loans"
    lab var pay_plan_va "Q46: military/VA benefits"
    lab var pay_plan_credit "Q46: credit cards"

    order pay_plan_raw, before(pay_plan_scholarship)

    // Q47: What are you most likely to study in college?
    rename q47 major_raw 
    lab var major_raw "Q47: what are you most likely to study in college"

    gen major_business = (strpos(major_raw, "1") !=0) if !mi(major_raw)
    gen major_engineering = (strpos(major_raw, "2") !=0) if !mi(major_raw)
    gen major_science = (strpos(major_raw, "3") !=0) if !mi(major_raw)
    gen major_social = (strpos(major_raw, "4") !=0) if !mi(major_raw)
    gen major_humanity = (strpos(major_raw, "5") !=0) if !mi(major_raw)
    gen major_health = (strpos(major_raw, "6") !=0) if !mi(major_raw)
    gen major_education = (strpos(major_raw, "7") !=0) if !mi(major_raw)
    gen major_applied = (strpos(major_raw, "8") !=0) if !mi(major_raw)
    gen major_service = (strpos(major_raw, "9") !=0) if !mi(major_raw)
    gen major_undecided = (strpos(major_raw, "10") !=0) if !mi(major_raw)


    lab var major_business "Q47: Business"
    lab var major_engineering "Q47: Engineering"
    lab var major_science "Q47: Natural Scinces"
    lab var major_social "Q47: Social Sciences"
    lab var major_humanity "Q47: Humanities and Arts"
    lab var major_health "Q47: Health Sciences"
    lab var major_education "Q47: Education"
    lab var major_applied "Q47: Applied Sciences"
    lab var major_service "Q47: Public Service"
    lab var major_undecided "Q47: Undecided"

    order major_raw, before(major_business)

    // Q48: What is the highest degree you hope to earn after you have completed all of your schooling?
    lab define highest_degree_lab 1 "Get a certificate in a vocational or technical field" ///
        2 "Associate degree  (AA/AS/ADT)" 3 "Bachelor’s Degree (BA/BS)" ///
        4 "Master’s Degree (MA/MS)" 5 "Doctoral Degree (Ph.D., M.D., J.D., etc.)" ///
        6 "I'm unsure"
    destring q48, replace 
    rename q48 highest_degree
    label var highest_degree "Q48: highest degree you hope to earn"
    lab val highest_degree highest_degree_lab

    // Q50: When you think about college, how worried are you about the following?
    label define coll_worry_lab 0 "Not at all worried" 1 "Somewhat worried" 2 "Very worried"
    foreach var of varlist tuition-support {
        destring `var', generate(coll_worry_`var')
        // currently coded 1,2,3
        replace coll_worry_`var' = coll_worry_`var' - 1
        lab val coll_worry_`var' coll_worry_lab
        label var coll_worry_`var' "Q50: worry about college"
        drop `var'
    }

    order coll_worry_tuition-coll_worry_support, after(highest_degree)


    **************** high school experience

    // Q53: Please tell us what type of high school you are graduating from:
    destring q53, replace 
    rename q53 hs_type
    lab define hs_type 1 "Public" 2 "Private" 3 "Home School"
    label var hs_type "Q53: type of HS you are graduating from"
    lab val hs_type hs_type

    // Q54 *NEW*: What were your high school grades?
    destring q54, replace 
    rename q54 hs_grade
    lab define hs_grade 1 "Mostly A" 2 "Mostly A/B" 3 "Mostly B" 4 "Mostly B/C" 5 "Mostly C" 6 "Mostly C/D"
    lab val hs_grade hs_grade
    lab var hs_grade "Q54: high school grades"

    // create a coarse category of hs grades
    gen hs_grade_coarse = hs_grade if inlist(hs_grade,1,2)
    replace hs_grade_coarse = 3 if inlist(hs_grade,3,4)
    replace hs_grade_coarse = 4 if inlist(hs_grade,5,6)
    lab define hs_grade_coarse 1 "Mostly A" 2 "Mostly A/B" 3 "Mostly B or B/C" 4 "Mostly C or C/D"
    lab val hs_grade_coarse hs_grade_coarse
    lab var hs_grade_coarse "HS grade (coarse)"

    // Q55: Are you on track to complete the "a-g" course requirements - the group of courses necessary for admission to UC and CSU?
    destring q55, replace 
    rename q55 complete_atog
    replace complete_atog = -1 if complete_atog==2
    replace complete_atog = 0 if complete_atog == 3
    label define complete_atog_lab -1 "No" 0 "Not Sure" 1 "Yes"
    lab val complete_atog complete_atog_lab
    label var complete_atog "Q55: are you on track to complete a-g"

    // Q56: How difficult was it to keep track of your "a-g" course progress?
    destring q56, replace 
    rename q56 track_atog
    replace track_atog = 0 if track_atog == 4
    lab define track_atog 0 "Not Sure" 1 "Easy" 2 "Difficult" 3 "Very Difficult" 
    lab val track_atog track_atog
    lab var track_atog "Q56: How difficult to track a-g course progress"

    // Q57: Why are you not on track to complete the "a-g" course requirements? (Select all that apply)
    rename q57 why_no_atog_raw
    label var why_no_atog_raw "Q57: why not on track to complete a-g"

    gen why_no_atog_notrequired = (strpos(why_no_atog_raw, "1") !=0) if !mi(why_no_atog_raw)
    gen why_no_atog_unknown = (strpos(why_no_atog_raw, "2") !=0) if !mi(why_no_atog_raw)
    gen why_no_atog_nocourse = (strpos(why_no_atog_raw, "3") !=0) if !mi(why_no_atog_raw)
    gen why_no_atog_lowgrade = (strpos(why_no_atog_raw, "4") !=0) if !mi(why_no_atog_raw)
    gen why_no_atog_nocollege = (strpos(why_no_atog_raw, "5") !=0) if !mi(why_no_atog_raw)
    gen why_no_atog_other = (strpos(why_no_atog_raw, "6") !=0) if !mi(why_no_atog_raw)

    lab var why_no_atog_notrequired "Q57: not required for the college I plan to attend"
    lab var why_no_atog_unknown "Q57: didn't know about the requirements"
    lab var why_no_atog_nocourse "Q57: my HS didn't offer necessary courses"
    lab var why_no_atog_lowgrade "Q57: My grades were too low in some required courses"
    lab var why_no_atog_nocollege "Q57: I am not planning to attend college"
    lab var why_no_atog_other "Q57: Other"

    rename q57_6_text why_no_atog_other_text
    lab var why_no_atog_other_text "Q57: why not on track to complete a-g: other (text)"

    order why_no_atog_raw why_no_atog_other_text, after(why_no_atog_other)

    // Q59: Did you take any community college or CSU courses while in high school - sometimes referred to as dual enrollment? 
    destring q59, replace 
    rename q59 de 
    replace de = -1 if de==2
    replace de = 0 if de==3 
    lab define de -1 "No" 0 "Not Sure" 1 "Yes"
    lab val de de 
    lab var de "Q59: Did you take DE courses"

    // Q60: Why did you take these dual enrollment courses? (Select all that apply)
    rename q60 why_de_raw
    label var why_de_raw "Q60: why did you take dual enrollment courses"

    gen why_de_class = (strpos(why_de_raw, "1") !=0) if !mi(why_de_raw)
    gen why_de_college = (strpos(why_de_raw, "2") !=0) if !mi(why_de_raw)
    gen why_de_reduce = (strpos(why_de_raw, "3") !=0) if !mi(why_de_raw)
    gen why_de_trade = (strpos(why_de_raw, "4") !=0) if !mi(why_de_raw)
    gen why_de_admission = (strpos(why_de_raw, "6") !=0) if !mi(why_de_raw)
    gen why_de_other = (strpos(why_de_raw, "5") !=0) if !mi(why_de_raw)

    lab var why_de_class "Q60: take classes not offered by my school"
    lab var why_de_college "Q60: improve chance of getting into selective college"
    lab var why_de_reduce "Q60: reduce number of courses needed in college"
    lab var why_de_trade "Q60: to be ready for a trade or job after HS"
    lab var why_de_admission "Q60: satisfy requirements for UC/CSU admission"
    lab var why_de_other "Q60: other"

    rename q60_5_text why_de_other_text
    label var why_de_other_text "Q60: why did you take dual enrollment: other"

    order why_de_raw why_de_other_text, after(why_de_other)

    // Q61 *NEW*: What was the location of the dual enrollment (or college classes) that you took? (Select all that apply)
    rename q61 de_loc_raw
    lab var de_loc_raw "Q61: DE course location"

    gen de_loc_hs = (strpos(de_loc_raw, "1")!=0)
    lab var de_loc_hs "Q61: hs campus"
    gen de_loc_cc = (strpos(de_loc_raw, "2")!=0)
    lab var de_loc_cc "Q61: CC campus"
    gen de_loc_virtual = (strpos(de_loc_raw, "3")!=0)
    lab var de_loc_virtual "Q61: virtually"

    foreach v of varlist de_loc_hs - de_loc_virtual {
        replace `v' = . if mi(de_loc_raw)
    }

    // Q62 *NEW*: What kind of dual enrollment courses did you take?
    rename q62 de_type_raw
    lab var de_type_raw "Q62: type of DE course"

    gen de_type_math = (strpos(de_type_raw, "1")!=0)
    lab var de_type_math "Q62: DE math"
    gen de_type_hist = (strpos(de_type_raw, "2")!=0)
    lab var de_type_hist "Q62: DE history"
    gen de_type_eng = (strpos(de_type_raw, "3")!=0)
    lab var de_type_eng "Q62: DE English"
    gen de_type_sci = (strpos(de_type_raw, "4")!=0)
    lab var de_type_sci "Q62: DE Science"
    gen de_type_fl = (strpos(de_type_raw, "5")!=0)
    lab var de_type_fl "Q62: DE foreign language"
    gen de_type_oth = (strpos(de_type_raw, "6")!=0)
    lab var de_type_oth "Q62: Other"

    foreach v of varlist de_type_math - de_type_oth {
        replace `v' = . if mi(de_type_raw)
    }

    rename q62_6_text de_type_oth_text
    lab var de_type_oth_text "Q62 type of DE course, open response for other"



    **************** Career plannning *NEW*

    // Q63: DO you have a future career in mind?
    destring q63, replace 
    rename q63 have_career 
    replace have_career = -1 if have_career==2
    replace have_career = 0 if have_career==3

    lab define have_career -1 "No" 0 "Not Sure" 1 "Yes"
    lab val have_career have_career
    lab var have_career "Q63: Do you have a future career in mind"

    rename q63_1_text have_career_yes_text
    lab var have_career_yes_text "Q63 open text for Yes to have future career in mind"

    // Q64: Where did you learn about this career? select all that apply
    rename q64 where_learn_career_raw
    lab var where_learn_career_raw "Q64: Where did you learn about this career"

    gen where_learn_career_hs = (strpos(where_learn_career_raw, "1")!=0)
    lab var where_learn_career_hs "Q64: HS"
    gen where_learn_career_parent = (strpos(where_learn_career_raw, "2")!=0)
    lab var where_learn_career_parent "Q64: Parents"
    gen where_learn_career_friend = (strpos(where_learn_career_raw, "3")!=0)
    lab var where_learn_career_friend "Q64: friends"
    gen where_learn_career_sm = (strpos(where_learn_career_raw, "4")!=0)
    lab var where_learn_career_sm "Q64: social media"
    gen where_learn_career_college = (strpos(where_learn_career_raw, "5")!=0)
    lab var where_learn_career_college "Q64: College"
    gen where_learn_career_other = (strpos(where_learn_career_raw, "6")!=0)
    lab var where_learn_career_other "Q64: Other"

    foreach v of varlist where_learn_career_hs - where_learn_career_other {
        replace `v' = . if mi(where_learn_career_raw)
    }

    rename q64_6_text where_learn_career_other_text
    lab var where_learn_career_other_text "Q64: open text for Other to where learn about this career"

    // Q65: Have you done any career planning through school? If so, describe it below:
    destring q65, replace
    rename q65 careerplan_hs
    replace careerplan_hs = -1 if careerplan_hs == 2
    replace careerplan_hs = 0 if careerplan_hs == 3

    lab define careerplan_hs -1 "No" 0 "Not Sure" 1 "Yes"
    lab val careerplan_hs careerplan_hs
    lab var careerplan_hs "Q65: Have you done career planning in school"

    rename q65_1_text careerplan_hs_yes_text
    lab var careerplan_hs_yes_text "Q65: open text for Yes to done career planning in school"

    // Q66: Have you taken coursework related to your future career
    destring q66, replace
    rename q66 career_course
    replace career_course = -1 if career_course == 2
    replace career_course = 0 if career_course == 3

    lab define career_course -1 "No" 0 "Not Sure" 1 "Yes"
    lab val career_course career_course
    lab var career_course "Q66: Have you taken course related to career"

    rename q66_1_text career_course_yes_text
    lab var career_course_yes_text "Q66: open text for Yes to taken course related to career"

    // Q67: How important do you think it is that high schools do the following? Matrix question
    lab define important_3pt 1 "Not very important" 2 "Somewhat important" 3 "Very important"

    rename q67_1 hs_important_rwm
    rename q67_2 hs_important_civic
    rename q67_3 hs_important_col
    rename q67_4 hs_important_citizen
    rename q67_5 hs_important_career

    foreach v of varlist hs_important_rwm - hs_important_career {
        destring `v', replace 
        lab val `v' important_3pt
    }

    lab var hs_important_rwm "Q67: important for HS to teach reading writing math"
    lab var hs_important_civic "Q67: important to teach civic"
    lab var hs_important_col "Q67: important to prep for college"
    lab var hs_important_citizen "Q67: important to encourage active citizens"
    lab var hs_important_career "Q67: important to prep for career"

    // Q68: How important is it to you that you vote in the next election?
    destring q68, generate(vote_important)
    replace vote_important = 1 if q68 == "3"
    replace vote_important = 3 if q68 == "1"
    lab val vote_important important_3pt
    lab var vote_important "Q68: how important to vote in next election"

    **************** Demographics 

    //------------------------------
    // race
    //------------------------------
    rename q71 race_raw
    gen black = 1 if strpos(race_raw, "1") !=0
    replace black = 0 if strpos(race_raw, "1") ==0 & !mi(race_raw)
    label var black "selected Black"

    gen native = 1 if strpos(race_raw, "2") != 0
    replace native = 0 if strpos(race_raw, "2") == 0 & !mi(race_raw)
    label var native "selected American Indian/Alaskan Native"

    gen asian = 1 if strpos(race_raw, "3") != 0
    replace asian = 0 if strpos(race_raw, "3") ==0 & !mi(race_raw)
    label var asian "selected Asian"

    gen filipino = 1 if strpos(race_raw, "4") !=0
    replace filipino = 0 if strpos(race_raw, "4") == 0 & !mi(race_raw)
    label var filipino "selected Filipino"

    gen hispanic = 1 if strpos(race_raw, "5") != 0
    replace hispanic = 0 if strpos(race_raw, "5") == 0 & !mi(race_raw)
    label var hispanic "selected Hispanic"

    gen islander = 1 if strpos(race_raw, "6") !=0
    replace islander = 0 if strpos(race_raw, "6") ==0 & !mi(race_raw)
    label var islander "selected Pacific Islander"

    gen white = 1 if strpos(race_raw, "7") !=0
    replace white = 0 if strpos(race_raw, "7") ==0 & !mi(race_raw)
    label var white "selected White/Non-Hispanic"

    // if other race was selected 
    gen other_race = 1 if strpos(race_raw, "8") !=0 
    replace other_race = 0 if strpos(race_raw, "8") ==0 & !mi(race_raw)
        /* & (black == 0) & (native == 0) & (asian == 0) & (filipino == 0) ///
        & (hispanic == 0) & (islander == 0) & (white == 0)) */
    label var other_race "selected Other race"

    rename q71_8_text other_race_text
    label var other_race_text "Q72: free response for race/ethnicity: other"

    // limit mutlirace to people who chose two or more from predefined options 
    gen numrace = 0
    foreach v of varlist black-other_race {
        replace numrace = numrace + `v'
    }

    ************** simple mutually exclusive race, 2024 version
    // differs from 2023 version in how multirace is defined
    label define race_simple_lab 1 "Black" 2 "Native" 3 "Asian" 4 "Filipino" ///
        5 "Hispanic" 6 "Pacific Islander" 7 "White" 8 "Other Race" ///
        9 "Multiracial" 
    gen race_simple_24 = .

    // select only black, native, etc. 
    replace race_simple_24 = 1 if black == 1 & numrace == 1
    replace race_simple_24 = 2 if native == 1 & numrace == 1
    replace race_simple_24 = 3 if asian == 1 & numrace == 1
    replace race_simple_24 = 4 if filipino == 1 & numrace == 1
    replace race_simple_24 = 5 if hispanic == 1 & numrace == 1
    replace race_simple_24 = 6 if islander == 1 & numrace == 1
    replace race_simple_24 = 7 if white == 1 & numrace == 1
    replace race_simple_24 = 8 if other_race == 1 & numrace == 1
    // select 1 predefined and other race
    replace race_simple_24 = 1 if black == 1 & other_race == 1 & numrace == 2 
    replace race_simple_24 = 2 if native == 1 & other_race == 1 & numrace == 2 
    replace race_simple_24 = 3 if asian == 1 & other_race == 1 & numrace == 2 
    replace race_simple_24 = 4 if filipino == 1 & other_race == 1 & numrace == 2 
    replace race_simple_24 = 5 if hispanic == 1 & other_race == 1 & numrace == 2 
    replace race_simple_24 = 6 if islander == 1 & other_race == 1 & numrace == 2 
    replace race_simple_24 = 7 if white == 1 & other_race == 1 & numrace == 2 
    // multiracial
    // select 2 or more predefined options 
    replace race_simple_24 = 9 if (inrange(numrace, 2, 8) & other_race == 0) ///
        | (inrange(numrace, 3, 8) & other_race == 1)
    label values race_simple_24 race_simple_lab
    label var race_simple_24 "race narrowly defined (mutually exclusive), 2024 version"

    ************** simple mutually exclusive race, 2023 version
    gen race_simple_23 = .
    label var race_simple_23 "mutually exclusive race, 2023 version"
    replace race_simple_23 = race_simple_24 if numrace == 1
    replace race_simple_23 = 9 if inrange(numrace, 2, 8)
    lab val race_simple_23 race_simple_lab


    ************** mututally exclusive race based on URM hierarchy, same as 2023 version
    gen race_hrchy = .
    lab var race_hrchy "mutually exclusive race based on URM hierarchy"
    // initiate numerical value for category
    local j = 8
    foreach cat in white other_race asian filipino islander hispanic black native {
        replace race_hrchy = `j' if `cat' == 1
        // copy the value label from the dummies
        local varlab: var lab `cat'
        // remove unused part of string, keep only the race
        local varlab = subinstr("`varlab'", "selected ", "", 1)
        // update value label
        lab define race_hrchy_lab `j' "`varlab'", add 
        // update numerical category
        local j = `j' - 1
    }
    label values race_hrchy race_hrchy_lab


    order race_raw other_race_text black-other_race numrace race_simple_24, after(vote_important)








    // Q72: What is the highest level of education completed among either of your parents (or those who raised you)?
    /* updated 8-6-2025 don't know is coded 7, everything else loses a rank */
    display "jake update here"
    label define parent_edu_lab 1 "Did not complete high school" ///
        2 "High school diploma" 3 "Some college, no college degree" ///
        4 "Associate degree" 5 "Bachelor's degree" ///
        6 "Graduate/Professional degree" 7 "Don't know"
    destring q72, replace 
    rename q72 parent_edu
    lab val parent_edu parent_edu_lab
    label var parent_edu "Q72: highest parent education"

    // first gen status, two ways 
    lab define firstgen 0 "Not firstgen" 1 "Firstgen"
    gen firstgen_bydegree = inrange(parent_edu, 1,3)
    replace firstgen_bydegree = . if mi(parent_edu)

    gen firstgen_byattend = inrange(parent_edu, 1, 2)
    replace firstgen_byattend = . if mi(parent_edu)
    /* added  8-6-2025*/
    replace firstgen_byattend = . if parent_edu==7
    replace firstgen_bydegree = . if parent_edu==7


    lab val firstgen_byattend firstgen_bydegree firstgen

    // Q73: primary language at home
    destring q73, replace 
    gen home_lang_eng = 2-q73 
    lab define home_lang_eng 0 "No" 1 "Yes"
    lab val home_lang_eng home_lang_eng
    lab var home_lang_eng "Primary home language English"

    rename q75 home_lang_other
    label var home_lang_other "Q75: what language was primarily spoken at home"

    // Q77: do you currently have a job
    destring q77, replace 
    gen has_job = 2- q77 
    lab define has_job 0 "No" 1 "Yes"
    lab val has_job has_job
    lab var has_job "Q77: currently has a job"

    // Q78: How many hours a week do you work at your job?
    lab define hours_perweek 1 "Less than 10" 2 "10-19" 3 "20-30" 4 "More than 30"
    destring q78, gen (hours_perweek)
    lab val hours_perweek hours_perweek
    lab var hours_perweek "Q78: how many hours work a week"

    // Q80: gender identity 
    rename q80 gender_raw

    label define gender_lab 1 "Woman" 2 "Man" 3 "Non-binary" 4 "Prefer not to say" 5 "Other"
    destring gender_raw, gen(gender)
    lab val gender gender_lab

    rename q80_5_text gender_other_text
    lab var gender_other_text "Free response for gender: other"

    destring q81, gen(interview) 
    lab def interview 1 "Yes" 2 "No"
    lab val interview interview

    rename q83 interview_email 
    replace interview_email = strlower(stritrim(strtrim(interview_email)))


    rename q86 coll_excite
    label var coll_excite "Q90: what excites you most about college"

    rename q88 coll_challenge 
    label var coll_challenge "Q92: biggest challenge you will face in college"

    order coll_excite coll_challenge, after(interview_email)




    //------------------ clear text variables
    include $projdir/do/macros_csac.doh 

    foreach v of local text_qs {
        replace `v' =  strupper(stritrim(strtrim(`v')))


    }

    //------------ consolidate people who responded other to race and wrote in

    /* labelbook: 
    Definition
            1   American Indian/Alaskan Native
            2   Black
            3   Hispanic
            4   Pacific Islander
            5   Filipino
            6   Asian
            7   Other race
            8   White/Non-Hispanic

    */
    // if only white, then white
    replace race_hrchy = 8 if other_race_text=="WHITE" & race_hrchy==7
    replace race_hrchy = 6 if strpos(other_race_text, "ASIAN")!=0 & race_hrchy==7
    replace race_hrchy = 3 if (strpos(other_race_text, "MEXICAN")!=0 ///
        | strpos(other_race_text, "LATINO")!=0 ///
        | strpos(other_race_text, "LATINA")!=0 ///
        | strpos(other_race_text, "LATINX")!=0 ///
        | strpos(other_race_text, "HISPANIC")!=0) ///
        & race_hrchy==7
    replace race_hrchy = 2 if strpos(other_race_text, "AFRICAN") !=0 ///
        | strpos(other_race_text, "BLACK") !=0 ///
        & race_hrchy==7



    //------ merge in NCES codes
    preserve 
    import delimited  $projdir/dta/survey_25_nces.csv, varnames(1) clear
    tempfile nces 
    save `nces', replace 
    restore 

    merge 1:1 responseid using `nces', keep(1 3) noupdate nogen  

    // the email variable seems different from what they provided in the survey
    lab var email "Email from merging on NCES codes"
    rename stdt_hs_code nces_code 
    lab var nces_code "NCES code for high school"



    /* jake add - geographic info from NCES code 
    modified by CS aug 28 2025 */
    merge m:1 nces_code using "$projdir/dta/nces_to_merge.dta", keep(1 3) noupdate nogen
    rename locale schoollocale
    rename region schoolregion

    gen schoollocale_comb= .
    replace schoollocale_comb = 1 if inlist(schoollocale, 11,12,13)
    replace schoollocale_comb = 2 if inlist(schoollocale, 21,22,23)
    replace schoollocale_comb = 3 if inlist(schoollocale, 31,32,33)
    replace schoollocale_comb = 4 if inlist(schoollocale, 41,42,43)

    gen schoollocale_comb2 =.
    replace schoollocale_comb2 = 1 if inlist(schoollocale, 11,12,13)
    replace schoollocale_comb2 = 2 if inlist(schoollocale, 21,22,23)
    replace schoollocale_comb2 = 3 if inlist(schoollocale, 31,32,33, 41,42,43)

    label def schoollocale_comb 1 "City" 2 "Suburb" 3 "Town" 4 "Rural"
    label def schoollocale_comb2 1 "City" 2 "Suburb" 3 "Town/Rural"

    label val schoollocale_comb schoollocale_comb
    label val schoollocale_comb2 schoollocale_comb2

    /* end jake add */


    foreach num in `all_qnums' {
        foreach q in `q`num'_subqs' {
            local `q'_str: variable label `q'
        }
    }


    compress 
    save $projdir/dta/csac_2025_initial_clean_`version'.dta, replace 
}





log close 
