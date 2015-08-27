#!/bin/bash

# randomly sample data by year for use during development

mkdir -p samples
for i in *.dat
do
    echo "Sampling from ${i}"
    shuf -n 50 $i > samples/samp.${i}
done;

