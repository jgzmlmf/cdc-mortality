#!/bin/bash

# unzip all mortality multiple cause of death archives
for i in archives/mort*.zip
do
    unzip -ju $i -d ./
done

