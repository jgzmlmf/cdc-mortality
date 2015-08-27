#!/bin/bash

# Download public use mortality multiple cause files, 1968-2013

server="ftp://ftp.cdc.gov/pub/Health_Statistics/NCHS/Datasets/DVS"

for yr in {1968..2013}
do
    echo "Downloading mortality file for ${yr}"
    wget -N ${server}/mortality/mort${yr}us.zip
done

