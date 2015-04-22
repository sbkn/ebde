#!/bin/bash

filename=$"ebde_item"
extension=$".html"


for a in ebde_item*.html;
do
	echo -e "\t\tPROCESSING $a .."
	
	echo "Grabbing the price .."

	#Grab the price of the item (e.g.: xxx,xx):	
	grep -o '<b>EUR</b> [^</span>]*' $a | sed 's/<b>EUR<\/b> *//g' >> test_R.txt 


done



