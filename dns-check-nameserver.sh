#!/bin/bash

# DESCRIPTION: check if a domain name's dns resolution is pointing to valid records
# INPUT: string. domain name
# OUTPUT: multi-row string
# USAGE: ./this.sh [domain_name]
# EXAMPLE: ./test.sh dev-ws-mxv.mxvirtual.com
# AUTHOR: Jesse Gersenson
#
# we'll loop over output, and look for the 'Authority Section', when we find it,
# we set FOUND=1
FOUND=0
domain="$1"
#### pass output of dig [domain name] to a loop, each line is available as "$line"
dig "$domain" | while read line; do 
	#### if line "Query time", we're done. break out of loop ####
	if [[ "$line" =~ "Query time" ]]
	then
		break
	fi

	#### if FOUND is greater than 0 ####
	if [[ $FOUND -gt 0 ]]
	then
		#### parse the line using a space character delimeter, save the 5th field to variable $ns ####
		ns=$(echo $line | cut -f5 -d" "| sed "s/\.$//g")
		#### if $ns is not empty... ####
		if [[ $ns != "" ]]
		then
			#### specify the nameserver to use, and dig the domain, grab its status. save output to variable $result"
			result=$(dig @${ns} "$domain" | grep -o "status: .*,")
			#### print the nameserver and result ####
			echo "$ns $result"
		fi
	fi
	#### if the line is "AUTHORITY SECTION", set FOUND to 1 ####
	if [[ "$line" =~ "AUTHORITY SECTION" ]]
			then
			FOUND=1
	fi

done
