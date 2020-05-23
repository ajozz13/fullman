#!/bin/sh -eu

#  Use the prefix of your target email as the name of your input file 
#  For example: if your IBC assigned email is: aams-data-your_co-eccf@pactrak.com
#               your input file will need to be: aams-data-your_co-eccf.txt or .csv
 curl -F 'data=@/path/to/your/aams-data-file.csv' https://api.pactrak.com/manifests/upload
