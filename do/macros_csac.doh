/* macros for the project */

#delimit ;

// question macros ;
local all_qnums 
    8 
    11 12 13 14 15 16 
    18 19 
    22 23 24 
    26 27 
    29 
    31 33 34 35 
    36 37 38 39 40 
    42 43
    46 47 48 50 
    53 54 55 56 57 59 
    60 61 62 
    63 64 65 66 67 68 
    77 78
    ;

local q8_subqs
    hs_senior
    ;
local q11_subqs
    why_fafsa_requirement why_fafsa_assignment why_fafsa_eligible
    why_fafsa_expected why_fafsa_other
    ;
local q12_subqs
    when_heard_fafsa
    ;
local q13_subqs
    difficulty_apply_finaid
    ;
local q14_subqs
    finaid_challenge_tech finaid_challenge_doc finaid_challenge_invite 
    finaid_challenge_multi finaid_challenge_confusing finaid_challenge_nohelp
    finaid_challenge_info finaid_challenge_whichapp
    finaid_challenge_none finaid_challenge_other
    ;
local q15_subqs 
    support_received_counselor support_received_teacher 
    support_received_hsworkshop support_received_cmworkshop
    support_received_parent support_received_family
    support_received_friend support_received_online
    support_received_nobody
    ;
local q16_subqs
    prefer_state_only
    ;

local q18_subqs
    coll_att_3pt_important coll_att_3pt_worth coll_att_3pt_ready
    ;
local q19_subqs 
    coll_factor_gpa coll_factor_score coll_factor_service 
    coll_factor_firstgen coll_factor_extra
    ;

local q22_subqs
    coll_applied_ccc coll_applied_csu coll_applied_uc
    coll_applied_priv4yr coll_applied_vocation coll_applied_outside
    coll_applied_notsure coll_applied_none
    ;
local q23_subqs
    collapp_chall_dna collapp_chall_none collapp_chall_noinfo
    collapp_chall_dnu collapp_chall_course collapp_chall_miss
    collapp_chall_fee collapp_chall_deadline collapp_chall_notready
    collapp_chall_submit collapp_chall_other
    ;
local q24_subqs
    attend_coll
    ;

local q26_subqs
    fall_plan_workpt fall_plan_workft fall_plan_family
    fall_plan_military fall_plan_other
    ;
local q27_subqs
    why_no_coll_notforme why_no_coll_expensive why_no_coll_notworth
    why_no_coll_gapyear why_no_coll_military why_no_coll_health
    why_no_coll_work why_no_coll_training why_no_coll_other
    ;
local q29_subqs
    coll_decision_financial coll_decision_academic coll_decision_family
    ;
local q31_subqs
    where_attend_coll
    ;
local q33_subqs
    which_uc_campus
    ;
local q34_subqs
    which_csu_campus
    ;
local q35_subqs
    how_sure_attend
    ;
local q36_subqs
    plan_transfer
    ;
local q37_subqs
    transfer_factor_afford transfer_factor_proximity
    transfer_factor_path transfer_factor_work
    transfer_factor_partnership transfer_factor_comfort
    transfer_factor_rejected transfer_factor_ready
    transfer_factor_other
    ;
local q38_subqs 
    where_transfer
    ;
local q39_subqs
    heard_pathway_tag heard_pathway_adt
    heard_pathway_igetc heard_pathway_cgetc
    heard_pathway_tsp heard_pathway_none
    heard_pathway_notsure
    ;
local q40_subqs
    cc_goal_degree cc_goal_gened
    cc_goal_path cc_goal_other
    ;
local q42_subqs 
    coll_contact
    ;
local q43_subqs 
    coll_contact_subject_doc coll_contact_subject_work 
    coll_contact_subject_grant coll_contact_subject_loan
    ;

local q46_subqs
    pay_plan_scholarship pay_plan_grant 
    pay_plan_saving pay_plan_work
    pay_plan_otherppl pay_plan_loan
    pay_plan_va pay_plan_credit
    ;
local q47_subqs 
    major_business major_engineering major_science
    major_social major_humanity major_health
    major_education major_applied major_service 
    major_undecided
    ;
local q48_subqs
    highest_degree
    ;
local q50_subqs
    coll_worry_tuition coll_worry_living coll_worry_academic
    coll_worry_work coll_worry_family coll_worry_community
    coll_worry_living_away coll_worry_support
    ;
local q53_subqs 
    hs_type
    ;
local q54_subqs
    hs_grade
    ;
local q55_subqs
    complete_atog
    ;
local q56_subqs
    track_atog
    ;
local q57_subqs
    why_no_atog_notrequired why_no_atog_unknown
    why_no_atog_nocourse why_no_atog_lowgrade
    why_no_atog_nocollege why_no_atog_other
    ;
local q59_subqs 
    de
    ;
local q60_subqs
    why_de_class why_de_college
    why_de_reduce why_de_trade
    why_de_other
    ;
local q61_subqs 
    de_loc_hs de_loc_cc de_loc_virtual
    ;
local q62_subqs 
    de_type_math de_type_hist
    de_type_eng de_type_sci
    de_type_fl de_type_oth
    ;
local q63_subqs 
    have_career
    ;
local q64_subqs 
    where_learn_career_hs where_learn_career_parent
    where_learn_career_friend where_learn_career_sm
    where_learn_career_college where_learn_career_other
    ;
local q65_subqs 
    careerplan_hs 
    ;
local q66_subqs
    career_course
    ;
local q67_subqs 
    hs_important_rwm hs_important_civic
    hs_important_col hs_important_citizen
    hs_important_career
    ;
local q68_subqs
    vote_important
    ;

local q37_subqs
    home_lang_eng
    ;
local q77_subqs
    has_job
    ;
local q78_subqs 
    hours_perweek
    ;



local q8_str
    "Will you (or did you) graduate from high school in spring or summer of 2025?"
    ;
local q11_str
    "Why did you complete the FAFSA or CADAA? (Select all that apply)"
    ;
local q12_str  
    "When did you first hear of the FAFSA or CADAA?"
    ;
local q13_str 
    "How difficult was the experience applying for financial aid?"
    ;
local q14_str 
    "What challenges did you face in applying for financial aid via the FAFSA or CADAA? (Select all that apply)"
    ;
local q15_str
    "Please tell us about the support you received in completing your FAFSA/CADAA. (Select all that apply)"
    ;
local q16_str 
    "Would you prefer an option to apply for state-based aid only, in order to keep your data from being shared with the federal government - even if it meant not receiving federal aid?"
    ;
local q18_str 
    "How much do you agree with the statements about college below?"
    ;
local q19_str
    "To what extent do you think each of these should be considered as factor in college admissions"
    ;
local q22_str
    "Did you apply to any colleges and universities? (Select all that apply)"
    ;
local q23_str
    "What challenges did you face when applying to college or trade school? (Select all that apply)"
    ;
local q24_str 
    "Do you plan to attend college in the fall?"
    ;

local q26_str
    "What do you think you will be doing this coming Fall? (Select all that apply)"
    ;
local q27_str
    "Why won't you be attending college this fall? (Select all that apply)"
    ;

local q29_str
    "Which of the following might influence your decision of whether or not to attend college? (Select all that apply)"
    ;

local q31_str
    "Where are you most likely to attend college this fall?"
    ;
local q33_str
    "Which (UC) campus are you most likely to attend?"
    ;
local q34_str 
    "Which (CSU) campus are you most likely to attend?"
    ;
local q35_str 
    "How sure are you that you will attend this school in the fall?"
    ;

local q36_str 
    "Do you plan to eventually transfer from your community college to a four-year college or university?"
    ;
local q37_str 
    "What factors influenced your decision to start at a community college and transfer? (Select all that apply)"
    ;
local q38_str 
    "Where do you intend to transfer?"
    ;
local q39_str 
    "Have you heard of the these transfer programs and pathways? (Select all that apply)"
    ;
local q40_str 
    "What are you primary goals for attending a community college before transferring? (Select all that apply)"
    ;

local q42_str
    "Have any of the colleges that you have been accepted to contacted you about your financial aid offer (e.g. email, letter, phone call) ?"
    ;
local q43_str
    "What did the colleges contact you about regarding your financial aid offer? (Select all that apply) "
    ;



local q46_str 
    "How do you plan to pay college tuition and fees? (Select all that apply)"
    ;
local q47_str
    "What are you most likely to study in college?"
    ;
local q48_str
    "What is the highest degree you hope to earn after you have completed all of your schooling?"
    ;
local q50_str
    "When you think about college, how worried are you about the following?"
    ;

local q53_str
    "Please tell us what type of high school you are graduating from:"
    ;
local q54_str 
    "What were your high school grades?"
    ;
local q55_str 
    "Are you on track to complete the 'a-g' course requirements - the group of courses necessary for admission to UC and CSU?"
    ;
local q56_str 
    "How difficult was it to keep track of your 'a-g' course progress?"
    ;
local q57_str
    "Why are you not on track to complete the 'a-g' course requirements? (Select all that apply)"
    ;
local q59_str
    "Did you take college courses while in high school (sometimes referred to as dual enrollment)?"
    ;
local q60_str 
    "Why did you take these dual enrollment courses? (Select all that apply)"
    ;
local q61_str 
    "What was the location of the dual enrollment (or college classes) that you took? (Select all that apply)"
    ;
local q62_str 
    "What kind of dual enrollment courses did you take?"
    ;

local q63_str 
    "Do you have a future career in mind?"
    ;
local q64_str 
    "Where did you learn about this career?"
    ;
local q65_str 
    "Have you done any career planning through school? If so, describe it below:"
    ;
local q66_str 
    "Have you taken any coursework related to your future career?"
    ;
local q67_str 
    "How important do you think it is that high schools do the following?"
local q68_str 
    "How important is it to you that you vote in the next election?"
    ;

local q73_str 
    "When you were growing up, was English the primary language spoken in your home?"
    ;
local q77_str 
    "Do you currently have a job?"
    ;
local q78_str 
    "How many hours a week do you work at your job?"
    ;


foreach num in `all_qnums' {;
    foreach q in `q`num'_subqs' {;
        local `q'_str: variable label `q';
    };
}
;


local fafsa_qs 
    why_fafsa_requirement why_fafsa_assignment why_fafsa_eligible
    why_fafsa_expected why_fafsa_other

    when_heard_fafsa difficulty_apply_finaid

    finaid_challenge_tech finaid_challenge_none finaid_challenge_doc
    finaid_challenge_invite finaid_challenge_multi finaid_challenge_confusing
    finaid_challenge_nohelp finaid_challenge_info finaid_challenge_whichapp
    finaid_challenge_other

    support_received_counselor support_received_teacher support_received_hsworkshop
    support_received_cmworkshop support_received_parent support_received_family
    support_received_friend support_received_online support_received_nobody

    prefer_state_only
    ;

local coll_app_qs
    coll_att_3pt_important coll_att_3pt_worth coll_att_3pt_ready

    coll_factor_gpa coll_factor_score coll_factor_service 
    coll_factor_firstgen coll_factor_extra

    coll_applied_ccc coll_applied_csu coll_applied_uc
    coll_applied_priv4yr coll_applied_vocation coll_applied_outside
    coll_applied_notsure coll_applied_none

    collapp_chall_dna collapp_chall_none collapp_chall_noinfo
    collapp_chall_dnu collapp_chall_course collapp_chall_miss
    collapp_chall_fee collapp_chall_deadline collapp_chall_notready
    collapp_chall_submit collapp_chall_other

    attend_coll
    ;

local not_coll_qs
    fall_plan_workpt fall_plan_workft fall_plan_family
    fall_plan_military fall_plan_other

    why_no_coll_notforme why_no_coll_expensive why_no_coll_notworth
    why_no_coll_gapyear why_no_coll_military why_no_coll_health
    why_no_coll_work why_no_coll_training why_no_coll_other
    ;

local idk_coll_qs 
    coll_decision_financial coll_decision_academic coll_decision_family
    ;

local yes_coll_qs
    where_attend_coll
    which_uc_campus
    how_sure_attend
    plan_transfer

    transfer_factor_afford transfer_factor_proximity
    transfer_factor_path transfer_factor_work
    transfer_factor_partnership transfer_factor_comfort
    transfer_factor_rejected transfer_factor_ready
    transfer_factor_other

    where_transfer

    heard_pathway_tag heard_pathway_adt
    heard_pathway_igetc heard_pathway_cgetc
    heard_pathway_tsp heard_pathway_none
    heard_pathway_notsure

    cc_goal_degree cc_goal_gened
    cc_goal_path cc_goal_other

    coll_contact

    coll_contact_subject_doc coll_contact_subject_work 
    coll_contact_subject_grant coll_contact_subject_loan
    ;

local coll_exp_qs
    pay_plan_scholarship pay_plan_grant 
    pay_plan_saving pay_plan_work
    pay_plan_otherppl pay_plan_loan
    pay_plan_va pay_plan_credit

    major_business major_engineering major_science
    major_social major_humanity major_health
    major_education major_applied major_service 
    major_undecided

    highest_degree

    coll_worry_tuition coll_worry_living coll_worry_academic
    coll_worry_work coll_worry_family coll_worry_community
    coll_worry_living_away coll_worry_support
    ;

local hs_exp_qs
    hs_type
    hs_grade
    complete_atog
    track_atog

    why_no_atog_notrequired why_no_atog_unknown
    why_no_atog_nocourse why_no_atog_lowgrade
    why_no_atog_nocollege why_no_atog_other

    de

    why_de_class why_de_college why_de_reduce
    why_de_trade why_de_other

    de_loc_hs de_loc_cc de_loc_virtual

    de_type_math de_type_hist
    de_type_eng de_type_sci
    de_type_fl de_type_oth
    ;

local career_qs
    have_career

    where_learn_career_hs where_learn_career_parent
    where_learn_career_friend where_learn_career_sm
    where_learn_career_college where_learn_career_other

    careerplan_hs

    career_course

    hs_important_rwm hs_important_civic
    hs_important_col hs_important_citizen
    hs_important_career

    vote_important
    ;    

local lang_work_qs
    home_lang_eng
    has_job
    hours_perweek
    ;

local all_qs 
    hs_senior
    `fafsa_qs' 
    `coll_app_qs'
    `not_coll_qs'
    `idk_coll_qs'
    `yes_coll_qs'
    `coll_exp_qs'
    `hs_exp_qs'
    `career_qs'
    `lang_work_qs'
    ;

local demo_qs 
    race_hrchy
    gender 
    parent_edu
    firstgen_byattend
    firstgen_bydegree
    ;

local other_tab_qs
    plan_transfer_cat
    hs_grade
    hs_grade_coarse
    where_attend_coll
    ;

local text_qs 
    why_fafsa_other_text
    finaid_challenge_other_text
    coll_factor_other_text
    collapp_chall_other_text
    fall_plan_other_text
    why_no_coll_other_text
    transfer_factor_other_text
    cc_goal_other_text
    transfer_concern_text
    why_no_atog_other_text
    why_de_other_text
    de_type_oth_text
    have_career_yes_text
    where_learn_career_other_text
    careerplan_hs_yes_text
    career_course_yes_text
    other_race_text
    gender_other_text
    coll_excite
    coll_challenge
    ;



    


    

local race_hrchy_str "Race";
local gender_str "Gender";
local parent_edu_str "Parent Education";
local firstgen_byattend_str "First-Gen (Attend)";
local firstgen_bydegree_str "First-Gen (Degree)";

local plan_transfer_cat_str "Transfer Intention Categories";
local hs_grade "High School Grades";

#delimit cr 