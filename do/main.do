/* Do file to run all project do files in order */

/* 
do /home/research/ca_ed_lab/projects/csac_survey2025/do/main.do
 */

*********** temp project folder
cd "/home/research/ca_ed_lab/projects/csac_survey2024/temp2025"
do do/settings.do



// clean data
do $projdir/do/clean/clean_qualtrics_download.do


do $projdir/do/explore/sample_char.do
