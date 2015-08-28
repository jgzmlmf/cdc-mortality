* Flag homicides, suicides, and firearm related deaths using ICD-10 codes
* ICD-10 codes have leading zeros; keep as strings

set more off

capture drop homicide
capture drop suicide
capture drop firearm
capture drop underlying

foreach v in firearm suicide homicide underlying {
    gen byte `v' = 0
}

// underlying cause of death uses 4-digit ICD-10 codes
replace firearm = 1 if regexm(cause, "W3[234][0-9]?$")  // accident
replace firearm = 1 if regexm(cause, "X7[234][0-9]?$")  // suicide
replace firearm = 1 if regexm(cause, "X9[345][0-9]?$")  // homicide
replace firearm = 1 if regexm(cause, "Y2[234][0-9]?$")  // undetermined
replace firearm = 1 if cause == "Y350"  // legal action, excluding war

replace suicide = 1 if regexm(cause, "^X([67][0-9]|8[0-4])[0-9]?$")
replace homicid = 1 if regexm(cause, "^X(8[5-9]|9[0-9])[0-9]?$")
replace homicid = 1 if regexm(cause, "^Y0[0-9][0-9]?$")

replace underlying = 1 if firearm == 1 | suicide == 1 | homicide == 1

// record-axis codes are 4-digits with blank in position 5 that gets
// stripped when data are read
foreach v of varlist rec_cond* {
    replace firearm = 1 if regexm(`v', "W3[234][0-9]?$")  // accident
    replace firearm = 1 if regexm(`v', "X7[234][0-9]?$")  // suicide
    replace firearm = 1 if regexm(`v', "X9[345][0-9]?$")  // homicide
    replace firearm = 1 if regexm(`v', "Y2[234][0-9]?$")  // undetermined
    replace firearm = 1 if `v' == "Y350"  // legal action, excluding war
    
    replace suicide = 1 if regexm(`v', "^X([67][0-9]|8[0-4])[0-9]?$")
    replace homicid = 1 if regexm(`v', "^X(8[5-9]|9[0-9])[0-9]?$")
    replace homicid = 1 if regexm(`v', "^Y0[0-9][0-9]?$")
}

