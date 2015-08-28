* Flag homicides, suicides, and firearm related deaths using ICD-9 codes
* ICD-9 codes have leading zeros; keep as strings

set more off

capture drop homicide
capture drop suicide
capture drop firearm
capture drop underlying

foreach v in firearm suicide homicide underlying {
    gen byte `v' = 0
}

// underlying cause of death uses 4-digit ICD-9 codes
replace firearm = 1 if regexm(cause, "^922[ 012389]?$")   // accident
replace firearm = 1 if regexm(cause, "^955[ 0123459]?$")  // suicide
replace firearm = 1 if regexm(cause, "^965[ 0-9]?$")      // homicide
replace firearm = 1 if regexm(cause, "^985[ 0-5]?$")      // undetermined
replace firearm = 1 if cause == "970"                     // legal action

replace suicide = 1 if regexm(cause, "^95([0123578][0-9]?|[469])$")
replace homicid = 1 if regexm(cause, "^96([02578][0-9]?|[13469])$")

replace underlying = 1 if firearm == 1 | suicide == 1 | homicide == 1

// record-axis codes are 4-digits plus an injury code flag in position 5
// injury flag codes are not related to firearms
foreach v of varlist rec_cond* {
    replace firearm = 1 if regexm(cause, "^922[ 012389]0$")   // accident
    replace firearm = 1 if regexm(cause, "^955[ 0123459]0$")  // suicide
    replace firearm = 1 if regexm(cause, "^965[ 0-9]0$")      // homicide
    replace firearm = 1 if regexm(cause, "^985[ 0-5]0$")      // undetermined
    replace firearm = 1 if cause == "970 0"                   // legal action 
    
    replace suicide = 1 if regexm(cause, "^95([0123578][ 0-9]?|[469] )0$")
    replace homicid = 1 if regexm(cause, "^96([02578][ 0-9]?|[13469] )0$")
}

