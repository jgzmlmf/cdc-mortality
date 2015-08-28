* Flag homicides, suicides, and firearm related deaths using ICD-8 codes
* ICD-8 codes have leading zeros; keep as strings

set more off

capture drop homicide
capture drop suicide
capture drop firearm
capture drop underlying

foreach v in firearm suicide homicide underlying {
    gen byte `v' = 0
}

// underlying cause of death uses 4-digit ICD-8 codes
replace firearm = 1 if regexm(cause, "^922[ 09]?$")
replace firearm = 1 if inlist(cause, "955", "965", "970", "985")
replace suicide = 1 if regexm(cause, "^95(0[0-9]?|2[019]?|[13456789])$")
replace homicid = 1 if regexm(cause, "^96[0-9]$")
replace underlying = 1 if firearm == 1 | suicide == 1 | homicide == 1

// record-axis codes are 4-digits plus an injury code flag in position 5
// injury flag codes are not related to firearms
foreach v of varlist rec_cond* {
    replace firearm = 1 if regexm(`v', "^922[ 09]?0$")
    replace firearm = 1 if inlist(`v', "955 0", "965 0", "970 0", "985 0")
    replace suicide = 1 if regexm(`v', "^95(0[0-9]?|2[019]?|[13456789]) ?0$")
    replace homicid = 1 if regexm(`v', "^96[0-9] 0$")
}
 
