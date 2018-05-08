#!/bin/bash

#page=curl "https://www.baloto.com/historicomes/2017/11" | grep -A 20 ganadores

yr="2017"
for month in {5..12}  ### In April Baloto changed to a superball - previously it was 6 numbers with no extraball
do
curl -s "https://www.baloto.com/historicomes/2017/$month" | grep -A 21 '[0-3][0-9]\/[0-9][0-9]\/[0-9][0-9][0-9][0-9] \- [0-9][0-9][0-9][0-9]'| sed 's/<[^>]*>//g' | sed '/^\s*$/d' | while read ans
do
    #echo "....>>>> $ans <<<<...."
    if [[ $ans =~ [0-9][0-9][0-9][0-9] ]]; then
        echo ""
        echo -n "$ans,"
    elif [[ $ans =~ ^-?[0-9]+$ ]]; then
            echo -n "$ans,"
    elif [[ $ans == "" ]]; then
        ans=""
    fi
done
done
echo ""
yr="2018"
for month in {1..12}  ### In April Baloto changed to a superball - previously it was 6 numbers with no extraball
do
curl -s "https://www.baloto.com/historicomes/2018/$month" | grep -A 21 '[0-3][0-9]\/[0-9][0-9]\/[0-9][0-9][0-9][0-9] \- [0-9][0-9][0-9][0-9]'| sed 's/<[^>]*>//g' | sed '/^\s*$/d' | while read ans
do
    #echo "....>>>> $ans <<<<...."
    if [[ $ans =~ [0-9][0-9][0-9][0-9] ]]; then
        echo ""
        echo -n "$ans,"
    elif [[ $ans =~ ^-?[0-9]+$ ]]; then
            echo -n "$ans,"
    elif [[ $ans == "" ]]; then
        ans=""
    fi
done
done
echo ""

