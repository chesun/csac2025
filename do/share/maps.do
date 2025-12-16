/* make stata maps */

/* to run this do file, type
do $projdir/do/share/maps.do
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


// convert shape file to dta format 
shp2dta using $projdir/dta/ca_counties/CA_Counties.shp, database(counties) coordinates(coord) genid(id) replace 
use counties, clear 
rename GEOID geoid 
rename NAME countyname
save, replace 

*** create question response rates data by region
use $projdir/dta/csac_2025_initial_clean_aug.dta, clear 

gen plan_transfer_yes = (plan_transfer==1)
replace plan_transfer_yes = . if mi(plan_transfer)

gen de_yes = (de==1)
replace de_yes=. if mi(de)

keep schoolcountyfips schoolregion plan_transfer_yes transfer_factor_proximity de_yes
keep if !mi(plan_transfer_yes) | !mi(transfer_factor_proximity) | !mi(de_yes)
keep if !mi(schoolcountyfips)

rename schoolcountyfips geoid 

collapse plan_transfer_yes transfer_factor_proximity de_yes, by(schoolregion)
tempfile byregion 
save `byregion', replace 

** list of county fips codes
use $projdir/dta/nces_to_merge, clear
keep schoolcountyfips region 
rename region schoolregion 
rename schoolcountyfips geoid 
duplicates drop geoid, force 
* keep only california counties
keep if strpos(geoid, "06")==1

merge m:1 schoolregion using `byregion', nogen keep(3)
* San Joaquin county is missing the region
replace schoolregion = 4 if geoid == "06077"


save $projdir/dta/char_by_county.dta, replace 
export delimited geoid transfer_factor_proximity using $projdir/out/proximity_by_county.csv, replace 

export delimited geoid plan_transfer_yes transfer_factor_proximity de_yes using $projdir/out/map_data_by_county.csv, replace
** merge to shapefile 
merge 1:1 geoid using counties.dta

spmap plan_transfer_yes using coord, id(id) fcolor(Blues) clnumber(6)
graph export  plan_transfer_yes.png, replace 

spmap transfer_factor_proximity using coord, id(id) fcolor(Blues) clnumber(6)
graph export  transfer_factor_proximity.png, replace 

spmap de_yes using coord, id(id) fcolor(Blues) clnumber(6)
graph export  de_yes.png, replace 


* export county region xwalk 
export delimited geoid countyname schoolregion using $projdir/out/county_region_xwalk.csv, replace 