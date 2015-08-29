* Tabulate homicides by state, year, and age group

capture conren style 5
set more off

use "output/gundeath.dta", clear
keep if inrange(res_stat, 1, 3)  // U.S. residents only
keep if !mi(occ_usps)

// create age groups
gen str age_grp = "adult_" if inrange(age, 21, 150)
replace age_grp = "juv_" if inrange(age, 12, 17)
replace age_grp = "youth_" if inrange(age, 18, 20)
replace age_grp = "child_" if inrange(age, 0, 11)
replace age_grp = "norep_" if mi(age)
assert !mi(age_grp)

gen byte firearm_hom = firearm == 1 & homicide == 1
gen byte firearm_sui = firearm == 1 & suicide == 1

collapse (sum) firearm* homicide suicide, by(occ_usps year age_grp) fast
reshape wide @firearm_hom @firearm_sui @firearm @homicide @suicide /*
    */ , i(occ_usps year) j(age_grp) string

foreach v of varlist *firearm* *homicide *suicide {
    qui replace `v' = 0 if mi(`v')
}

egen long all_homicide = rowtotal(*_homicide)
gen long anyage_homicide = all_homicide - norep_homicide
gen long nonjuv_homicide = all_homicide - juv_homicide

statez occ_usps, from(usps) to(fips)
capture rename (occ_usps _FIPS_) (usps fips)
destring fips, replace

keeporder fips usps year all_* adult_hom juv_hom nonjuv_* anyage_*

la var all_hom "Number of total homicides"
la var adult_hom "Number of adult (21+) homicides"
la var juv_hom "Number of juvenile (12-17) homicides"
la var nonjuv_hom "Number of non-juvenile (age not 12-17) homicides"
la var anyage_hom "Number of homicides for any reported age"

qui compress
qui sum year
la data "Homicides by state, `r(min)'-`r(max)'"
save "output/mort_homicide.dta", replace
exit
