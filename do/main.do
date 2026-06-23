/* Do file to run all project do files in order */

/* 
do /home/research/ca_ed_lab/projects/csac_survey2025/do/main.do
 */

*********** temp project folder
cd "/home/research/ca_ed_lab/projects/csac_survey2025"
do do/settings.do

local installssc = 0
if `installssc' == 1 {
    ssc install randomtag, replace
    ssc install spmap, replace 
    ssc install shp2dta, replace 
    ssc install geo2xy, replace 
}
*------------------- DATA CLEANING
* clean data from qualtrics survey download
do $projdir/do/clean/clean_qualtrics_download.do

*------------------- DATA EXPLORATION
* explore sample characteristics 
do $projdir/do/explore/sample_char.do
* tabulate main questions 
do $projdir/do/explore/tab_questions.do
* check people who answered "not required for my college" for why no a-g
do $projdir/do/explore/atog_check.do

*------------------- CREATE RESEARCH PRODUCTS

* generate 150 random emails for interviews
do $projdir/do/share/random_emails.do
* export all questions that have open text response
do $projdir/do/share/text_qs.do
* make stata maps
do $projdir/do/share/maps.do
* get demographics for interviewees
do $projdir/do/share/interview_demo.do
* create appendix tables
do $projdir/do/share/appendix.do
