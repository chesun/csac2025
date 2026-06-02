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

** heard about fafsa juinor or prior
gen heard_fafsa_early = .
replace heard_fafsa_early = 1 if inlist(when_heard_fafsa, 2, 3)
replace heard_fafsa_early = 0 if when_heard_fafsa==1
lab var heard_fafsa_early "Heard FAFSA Junior Year or Prior"

local mapvars plan_transfer_yes transfer_factor_proximity de_yes heard_fafsa_early
keep schoolcountyfips schoolregion `mapvars'
keep if !mi(plan_transfer_yes) | !mi(transfer_factor_proximity) | !mi(de_yes)
keep if !mi(schoolcountyfips)

rename schoolcountyfips geoid 

collapse `mapvars', by(schoolregion)
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
* San Joaquin county is missing the region
replace schoolregion = 4 if geoid == "06077"

merge m:1 schoolregion using `byregion', nogen keep(3)



save $projdir/dta/char_by_county.dta, replace 
export delimited geoid transfer_factor_proximity using $projdir/out/proximity_by_county.csv, replace 

export delimited geoid `mapvars' using $projdir/out/map_data_by_county.csv, replace
** merge to shapefile 
merge 1:1 geoid using counties.dta

spmap plan_transfer_yes using coord, id(id) fcolor(Blues) clmethod(custom) clbreaks(0.66 0.68 0.7 0.72 0.74 0.76 0.8 0.86)
graph export  plan_transfer_yes.png, replace 

spmap transfer_factor_proximity using coord, id(id) fcolor(Blues) clmethod(custom) clbreaks(0.4 0.44 0.48 0.52 0.56 0.6 0.65)
graph export  transfer_factor_proximity.png, replace 

spmap de_yes using coord, id(id) fcolor(Blues) clmethod(custom) clbreaks(0.32 0.35 0.38 0.41 0.44 0.47 0.51)
graph export  de_yes.png, replace 

spmap heard_fafsa_early using coord, id(id) fcolor(Blues) 
graph export  heard_fafsa_early.png, replace 


* export county region xwalk 
export delimited geoid countyname schoolregion using $projdir/out/county_region_xwalk.csv, replace 

export delimited countyname schoolregion heard_fafsa_early using $projdir/out/fig3_county_region_rate.csv, replace