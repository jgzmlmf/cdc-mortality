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

// 1968-1978 use ICD-8 and 1979-1998 use ICD-9 to code cause of death, these
// schemes are similar for suicides, homicides, and firearm-related deaths.
clear
tempfile dat_68_98
save `dat_68_98', emptyok replace

forvalues y=1968/1998 {
    di as result "Reading data for `y'"
    infile using dicts/`dct`y'', using("`datadir'/`fprefix'`y'.1.dat") clear
    
    // find firearm related deaths and murders, suicides generally
    if inrange(`y', 1968, 1978) {
        run _mark_icd8.do
    }
    else if inrange(`y', 1979, 2013) {
        run _mark_icd9.do
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

    assert inrange(age, 0, 125) | mi(age)
    assert inrange(race, 1, 3) | race == 99 if !mi(race)
    assert inlist(female, 0, 1) if !mi(female)

    capture confirm variable edu
    if !_rc {  // year has education codes
        qui replace edu = .a if edu == 99
        loc keepers "edu"
    }

    keeporder occ_state occ_cnty year month age female race firearm /*
        */ homicide suicide cause underlying `keepers'
    qui append using `dat_68_98'
    qui save `dat_68_98', replace
}
erase `dat_68_98'
gen str4 cause_icd8 = cause if inrange(year, 1968, 1978)
gen str4 cause_icd9 = cause if inrange(year, 1979, 1998)
//la val cause_icd8 cause_icd9 icd89
qui append using `gundeath'
save `gundeath', replace


// 1999-2013 use ICD-10 to code cause of death


// finalize dataset
use `gundeath', clear
qui compress
la data "Homicide, suicide, and firearm deaths"
save "output/gundeath.dta", replace
capture erase `gundeath'
exit
