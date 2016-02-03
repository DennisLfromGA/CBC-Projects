#!/bin/sh
## Local folder for current-vers
folder="$HOME/Downloads/CBC/current-vers"

# Output file name
out=current-vers.csv
omaha=omaha-vers.csv

## Local vers file for comparison
local="${omaha}.sav"

## URL of omahaproxy
url='https://cros-omahaproxy.appspot.com/all'

cd $folder || exit 2

##
echo "Downloading current Chrome OS versions..."

## Get current versions from omahaproxy
if ! curl -sL --connect-timeout 60 -m 300 --retry 2 $url -o $omaha 2>/dev/null
then
  echo "Download of '$url' has failed..."
  exit 1
fi

# Check to see if the omaha file has changed.
if diff -q $omaha $local 2>/dev/null; then
  echo "The omaha versions have not changed."
  echo "No need to proceed with generation of '$out'."
  exit 0
else
  echo "The omaha versions have changed!"
  cp $omaha $local 
  echo "Continuing with generation of '$out' ..."
  echo "Be sure to update the github site."
fi

mv $out /tmp 2>/dev/null

## Generate csv file for import
echo -n "Generating new, sorted csv file for import - "
echo "Hardware,Track,Chrome Vers,ChromeOS Vers." > $out 
grep -v timestamp < $omaha |\
  awk -F',' '{printf "%s,%s,%s,%s\n",$6,$5,$3,$2}' |\
  sort -u >> $out 

echo "finished."
echo "Output is in '$out'"
