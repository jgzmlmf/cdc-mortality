* Collect records related to firearms for all years

capture conren style 5
set more off

loc datadir "mort-files/samples"
loc fprefix = "samp."
include _dictlocs.do
include _icdlab.do

clear
tempfile gundeath
save `gundeath', emptyok replace

// 1968-1978 use ICD-8 to code cause of death
clear
tempfile dat_68_78
save `dat_68_78', emptyok replace

forvalues y=1968/1978 {
    infile using dicts/`dct`y'', using("`datadir'/`fprefix'`y'.1.dat") clear
    
    // make cause of death codes numeric
    qui destring cause, replace
    forvalues i=1/14 {
        qui gen str4 rec_cause`i' = substr(rec_cond`i', 1, 4)  // cause code
        qui gen str1 rec_injur`i' = substr(rec_cond`i', 5, 1)  // injury flag
        qui destring rec_cause`i' rec_injur`i', replace
    }

    // find firearm related deaths and murders, suicides generally
    gen byte firearm = 0
    gen byte suicide = 0
    gen byte homicide = 0
    foreach v of varlist cause rec_cause* {
        quietly {
            replace firearm = 1 if inlist(`v', 922, 955, 965, 970, 985)
            replace suicide = 1 if inrange(`v', 950, 959)
            replace homicid = 1 if inrange(`v', 960, 969)
        }
    }
    keep if firearm == 1 | homicide == 1 | suicide == 1
    gen int year = `y'
    
    quietly {  // calculate age from unit code and value
        gen int age = (age_unit * 100) + age_val if inlist(age_unit, 0, 1)
        replace age = 0 if inrange(age_unit, 2, 6)  // infants
        replace age = . if age_unit == 9  // age not stated
    }

    recode race (1 = 1 white) (2 = 2 black) (3 = 3 native) /*
        */ (0 4 5 6 7 8 = 9 other), gen(raza) label(raza) 
    drop race
    rename raza race
    
    recode sex (1 = 0 male) (2 = 1 female), gen(female) label(sex)

    assert age >= 0 & (age < 125 | mi(age))
    assert inrange(race, 1, 9) if !mi(race)
    assert inlist(female, 0, 1) if !mi(female)

    keeporder occ_state occ_cnty year month age female race firearm /*
        */ homicide suicide cause
    qui append using `dat_68_78'
    qui save `dat_68_78', replace
}
erase `dat_68_78'
rename cause cause_icd8
la val cause_icd8 icd8
qui append using `gundeath'
save `gundeath', replace

// 1979-1998 use ICD-9 to code cause of death

// 1999-2013 use ICD-10 to code cause of death



exit
