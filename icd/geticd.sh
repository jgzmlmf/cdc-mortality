#!/bin/bash

# Download HTML pages with ICD codes to parse with icdtab.py

wget -N http://www.wolfbane.com/icd/icd8h.htm
wget -N http://www.wolfbane.com/icd/icd9h.htm
wget -N http://www.wolfbane.com/icd/icd10h.htm

