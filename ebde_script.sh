#!/bin/bash

#To download the source of the page use:
#	wget -q -O foo.html "url"

#if [ -z ${1}  ]
#then
#	echo -e "\tNO URL AS ARGUMENT GIVEN .. exiting"
#	exit 1
#fi

#The html file for the search:
input=$"ebout2.html"


#wget -q -O ${input} $1


if [ ! -f "${input}"  ]
then
	echo -e "\n\tINPUT FILE DOES NOT EXIST\n\tWGET PROBABLY FAILED .., exiting ..\n"
	exit 1
fi

#The separated items will be saved in these files (e.g. "filename1.extension"):
filename=$"ebde_item"
extension=$".html"

echo -e "\tThe files will be named:\n\t\t$filename$extension"

echo "Starting .."

echo "Searching for items .."

#Count the items:
itm_cnt="$(grep -oci 'listingId=' $input)"

echo -e "\tFound $itm_cnt items"

echo "Splitting the file .."

#Split into files according to items:
#	- split file into separate files based on RS
#	- </ul></li> is the delimiter (first occurence in awk => puts  the delimiter back in place, at the end of each file), (second occurence defines the delimiter)
#	- YOU NEED TO EITHER DELETE THE LAST FILE (its just garbage) or JUST USE THE NEXT COMMAND OUTRIGHT !
#	- Thus: #files - 1 = #itms.
awk -v "FILE=$filename" '{print $0 "</ul></li>"> FILE NR ".html"}' RS='</ul></li>' ${input}
#^^THE ITEM NAME IS HARDCODED !!!!!!!!!!!!!!!!!!!!!!!!^^

echo "Trimming the first file .."

#Trim the first file (delete the bloat) AND copy it into the last one as it is only bloat too:
awk '/^<ul id="ListViewInner">/{p=1}p' ${filename}1${extension} > ${filename}$((itm_cnt+1))${extension}

echo "Renaming last file .."

#Rename last file to first file:
mv ${filename}$((itm_cnt+1))${extension} ${filename}1${extension}


for a in ebde_item*.html;
do
	#If file not found:
	if [ ! -f "${a}" ]
	then
		echo -e "\n\t\tFILE NOT FOUND ($a)"
		echo -e "\n\t\t\tEXITING."
		break
	fi
	
	echo -e "\t\tPROCESSING $a .."
	
	#THIS NEEDS: [ -f $a ] && ..
	echo "Grabbing the id .."

	#Grab the id of the item:
	grep -ow 'id=\"item[^"]*' $a | sed 's/id="*//g' >> test.txt

	echo "Grabbing the listingId .."

	#Grab the listingId of the item:
	grep -ow 'listingId=\"[^"]*' $a | sed 's/listingId="*//g' >> test.txt

	echo "Grabbing the price .."

	#Grab the price of the item (e.g.: xxx,xx):	
	grep -o '<b>EUR</b> [^</span>]*' $a | sed 's/<b>EUR<\/b> *//g' >> test.txt 

	echo "Grabbing format of item .."

	#Grab "Gebote":
	#	- IF this returns NIL -> indicator value ? e.g. -1 ?
	grep 'Gebot' $a | sed 's/[^0-9]*//g' >> test.txt

	#Grab "Sofort-Kaufen" if the previous command returns nothing:
	grep -o 'Sofort-Kaufen' $a >> test.txt

	echo "Grabbing shipping costs .."

	#Grab the shipping costs:
	#This results to either "+ EUR x,xx Versand" or "Kostenloser Versand"
	#grep -w 'Versand' $a | sed 's/span//g; s/class//g; s/bfsp//g; s/[<>/="\t]//g; s/ *//' >> test.txt
	versand=$(grep -w 'Versand' $a | sed 's/span//g; s/class//g; s/bfsp//g; s/[<>/="\t]//g; s/ *//')
	if [ "$versand" != 'Kostenloser Versand' ];
	then
		versand_new=$(echo "${versand}" | sed 's/[^0-9,]//g')
		versand="${versand_new}"
	else
		versand=0
	fi
	echo "${versand}" >> test.txt

	echo "Grabbing Date .."

	#Grab the date (format: "xx. jan. yy:zz"):
	#grep '[0-9]\{1,2\}\..\{1,\}[0-9]\{2\}:[0-9]\{2\}' $a | sed 's/span//g; s/class//g; s/li//g; s/[<>/="\t]//g; s/ *//' >> test.txt
	date_orig=$(grep '[0-9]\{1,2\}\..\{1,\}[0-9]\{2\}:[0-9]\{2\}' $a | sed 's/span//g; s/class//g; s/li//g; s/[<>/="\t]//g; s/ *//')
	
	#Work with the date:
	#Grab the day:
	date_day=$(echo "${date_orig}" | grep -o '[0-9]\{1,2\}\.' | sed 's/\.//')
	#Grab the month:
	date_month=$(echo "${date_orig}" | sed 's/[0-9:. ]//g; s/ä/ae/')
	#Make the month a numerical value:
	case "$date_month" in
		Jan)
			date_month=1
			;;
		Feb)
			date_month=2
			;;
		Maer)
			date_month=3
			;;
		Apr)
			date_month=4
			;;
		Mai)
			date_month=5
			;;
		Jun)
			date_month=6
			;;
		Jul)
			date_month=7
			;;
		Aug)
			date_month=8
			;;
		Sep)
			date_month=9
			;;
		Okt)
			date_month=10
			;;
		Nov)
			date_month=11
			;;
		Dez)
			date_month=12
			;;

		*)
			echo -e "\n\t\t\tdate_month could not be transformed.\n"
			date_month=0
	esac
	#Grab the hour:
	date_hour=$(echo "${date_orig}" | grep -o '[0-9]\{1,2\}\:' | sed 's/\://')
	#Grab the minute:
	date_minute=$(echo "${date_orig}" | grep -o '\:[0-9]\{1,2\}' | sed 's/\://')
	#Build new date:
	date_new="2015-${date_month}-${date_day} ${date_hour}:${date_minute}:00"
	#CARE - YEAR HARDCODED !!!!!!!!!!!!!!!!!!!!!!!!!!!!
	echo "${date_new}" >> test.txt

	#Add a blank line:
	echo -e "\n" >> test.txt
done



