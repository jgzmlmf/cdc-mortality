* Collect records related to firearms for all years

capture conren style 5
set more off

// config.do must define data_dir and fprefix locals that point to data files
// (see below for usage example). Not in source control because settings may
// differ on different workstations.
include config.do
include _dictlocs.do
include _icdlab.do

clear
tempfile gundeath
save `gundeath', emptyok replace

// 1968-2002 use similar coding schemes for age, race, sex; these rows can be
// processed together. 1968-1978 use ICD-8, 1979-1998 use ICD-9, and 1999-2002
// use ICD-10 to code cause of death.
clear
tempfile dat_68_02
save `dat_68_02', emptyok replace

forvalues y=1968/2002 {
    di as result "Reading data for `y'"
    infile using dicts/`dct`y'', using("`datadir'/`fprefix'`y'.1.dat") clear
    
    // find firearm related deaths and murders, suicides generally
    if inrange(`y', 1968, 1978) {
        run _mark_icd8.do
    }
    else if inrange(`y', 1979, 1998) {
        run _mark_icd9.do
    }
    else if inrange(`y', 1999, 2002) {
        run _mark_icd10.do
        // some years between 1998-2013 have a manner of death variable called
        // death_manner with codes for suicide, homicide, etc. These codes do
        // not always agree with scheme of _mark_10icd10.do.
        // TODO: how to treat death_manner in conjunction with ICD-10 codes.
    }
    else {
        di as error "Invalid year: `y'"
        exit 198
    }

    keep if firearm == 1 | homicide == 1 | suicide == 1
    capture drop year
    gen int year = `y'
    
    quietly {  // calculate age from unit code and value
        gen int age = (age_unit * 100) + age_val if inlist(age_unit, 0, 1)
        replace age = 0 if inrange(age_unit, 2, 6)  // infants
        replace age = . if age_unit == 9  // age not stated
    }

    recode race (1 = 1 white) (2 = 2 black) (3 = 3 native) /*
        */ (0 4/98 = 99 other), gen(raza) label(raza) 
    drop race
    rename raza race
    
    recode sex (1 = 0 male) (2 = 1 female), gen(female) label(sex)

    assert inrange(age, 0, 150) | mi(age)
    assert inrange(race, 1, 3) | race == 99 if !mi(race)
    assert inlist(female, 0, 1) if !mi(female)

    loc keepers ""
    capture confirm variable edu
    if !_rc {  // year has education codes
        qui replace edu = .a if edu == 99
        loc keepers "`keepers' edu"
    }
    capture confirm variable death_manner
    if !_rc {  // year has manner of death
        loc keepers "`keepers' death_manner"
    }
    
    // convert alphabetic rank of state to USPS code
    statez occ_state, from(anum) to(usps)
    capture rename _USPS_ occ_usps

    keeporder res_stat occ_usps occ_cnty year month age female race firearm /*
        */ homicide suicide cause underlying `keepers'
    qui append using `dat_68_02'
    qui save `dat_68_02', replace
}
erase `dat_68_02'
qui append using `gundeath'
save `gundeath', replace


// 2003-2013 use ICD-10 to code cause of death
clear
tempfile dat_03_13
save `dat_03_13', emptyok replace

forvalues y=2003/2013 {
    di as result "Reading data for `y'"
    infile using dicts/`dct`y'', using("`datadir'/`fprefix'`y'.1.dat") clear
    
    // find firearm related deaths and murders, suicides generally
    run _mark_icd10.do
    // some years between 2003-2013 have a manner of death variable called
    // death_manner with codes for suicide, homicide, etc. These codes do
    // not always agree with scheme of _mark_10icd10.do.
    // TODO: how to treat death_manner in conjunction with ICD-10 codes.

    keep if firearm == 1 | homicide == 1 | suicide == 1
    capture drop year
    gen int year = `y'
    
    quietly {  // calculate age from unit code and value
        gen int age = age_val if age_unit == 1  // measured in years
        replace age = 0 if inrange(age_unit, 2, 6)  // infant death
        replace age = . if age_unit == 9 | age_val == 999
    }

    recode race (1 = 1 white) (2 = 2 black) (3 = 3 native) /*
        */ (0 4/98 = 99 other), gen(raza) label(raza) 
    drop race
    rename raza race
    
    gen int female = sex == "F" if !mi(sex)
    la val female sex

    assert inrange(age, 0, 150) | mi(age)
    assert inrange(race, 1, 3) | race == 99 if !mi(race)
    assert inlist(female, 0, 1) if !mi(female)

    capture confirm variable edu
    if !_rc {  // year has education codes
        qui replace edu = .a if edu == 99
        loc keepers "edu"
    }
    capture confirm variable death_manner
    if !_rc {  // year has manner of death
        loc keepers "`keepers' death_manner"
    }

    // geographic codes are supressed 2005-2013
    if inrange(`y', 2005, 2013) {
        qui gen occ_usps = ""
        qui gen occ_cnty = .b
    }

    keeporder res_stat occ_usps occ_cnty year month age female race firearm /*
        */ homicide suicide cause underlying `keepers'
    qui append using `dat_03_13'
    qui save `dat_03_13', replace
}
erase `dat_03_13'
gen str4 cause_icd8 = cause if inrange(year, 1968, 1978)
gen str4 cause_icd9 = cause if inrange(year, 1979, 1998)
gen str4 cause_icd10 = cause if inrange(year, 1999, 2013)
drop cause
qui append using `gundeath'
save `gundeath', replace

// finalize dataset
use `gundeath', clear

gen int time = ym(year, month)
format time %tm

keeporder res_stat occ_usps occ_cnty time year month age female race edu /*
    */ firearm suicide homicide underlying cause_icd* death_manner

capture la drop res
la def res 1 "Resident" 2 "Intra-state nonresident" /*
    */ 3 "Inter-state nonresident" 4 "Foreign resident"
la val res_stat res

la var res_stat "Resident status"
la var occ_usps "State of death, USPS abbreviation"
la var occ_cnty "County of death"
la var time "Calendar year and month of death"
la var year "Calendar year of death"
la var month "Month of death"
la var age "Age of decedent"
la var female "Dummy marker for female decedent"
la var race "Race of decedent"
la var edu "Years of education of decedent"
la var firearm "Dummy for firearm-related death"
la var suicide "Dummy for suicide"
la var homicide "Dummy for homicide"
la var underlying "Underlying cause of death is homicide/suicide/firearm"
la var cause_icd8 "Cause of death, ICD-8"
la var cause_icd9 "Cause of death, ICD-9"
la var cause_icd10 "Cause of death, ICD-10"
la var death_manner "Manner of death"

qui compress
la data "Homicide, suicide, and firearm deaths"
save "output/gundeath.dta", replace
capture erase `gundeath'

exit
