#!/bin/bash

# Download data manuals for CDC public use mortality multiple case of death
# from http://www.cdc.gov/nchs/nvss/mortality_public_use_data.htm

opts="-q -N"

# 1968-1978 is a single manual
echo "Downloading 1968-1978 documentation"
wget $opts http://www.cdc.gov/nchs/data/dvs/dt78icd8.pdf

# 1979-1995 use ICD9 codes and have similar file names
for yr in {79..95}
do
    echo "Downloading 19${yr} documentation"
    wget $opts http://www.cdc.gov/nchs/data/dvs/dt${yr}icd9.pdf
done

# 1996 appears have a typo in file name (idc -> icd)
echo "Downloading 1996 documentation"
wget $opts http://www.cdc.gov/nchs/data/dvs/dt96idc9.pdf

# 1997 and 1998 do not have single PDFs, get the record layout
echo "Downloading 1997-1998 documentation"
wget $opts http://www.cdc.gov/nchs/data/dvs/mort97det.pdf
wget $opts http://www.cdc.gov/nchs/data/dvs/mort98det.pdf

# 1999 has a unique file name
echo "Downloading 1999 documentation"
wget $opts http://www.cdc.gov/nchs/data/dvs/Mort99doc.pdf

# 2000-2002 follow a similar pattern
echo "Downloading 2000-2002 documentation"
wget $opts http://www.cdc.gov/nchs/data/dvs/interim2000p1.pdf
wget $opts http://www.cdc.gov/nchs/data/dvs/interim2001p1.pdf
wget $opts http://www.cdc.gov/nchs/data/dvs/interim2002p1.pdf

# 2003 onwards have a similar pattern, but post 2005 data are not so
# useful before geographic identifiers were removed
for yr in {2003..2013}
do
    echo "Downloading ${yr} documentation"
    wget $opts http://www.cdc.gov/nchs/data/dvs/Record_Layout_${yr}.pdf
done

