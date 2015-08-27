* Make sure dictionaries are working, test on yearly random samples

capture conren style 5
set more off

loc datadir "mort-files/samples"
include _dictlocs.do

forvalues y=1968/2013 {
    di as result "Testing dictionary for `y'"
    infile using dicts/`dct`y'', using("`datadir'/samp.`y'.1.dat") clear
}

exit
