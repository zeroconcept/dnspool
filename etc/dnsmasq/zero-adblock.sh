#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORKING_DIR="/run/dnsmasq"
TEMP="$WORKING_DIR/adblock.lst"
ADDN_HOSTS="/etc/dnsmasq/adblock.uniq"
HOSTS_PREFIX="0.0.0.0"
FILE_URL_LIST="$DIR/ads.url"

  # remove if file/folder exist
  [ -d $WORKING_DIR ] && rm -rf $WORKING_DIR

  # re-creating folder and file
  mkdir -p $WORKING_DIR
  touch $TEMP

  echo -e "\nDownloading and processing URLs..."
  while read url_list
  do
    # Break read line into array
    hostsfile=($url_list)
    echo -e $hostsfile
    if [ ${hostsfile[0]##*.} == "zip" ] #Download, unzip if the URL ended with ZIP
    then
      curl -s -o $WORKING_DIR\/${hostsfile[$i]##*/} ${hostsfile[0]}
      for (( i=1; i<${#hostsfile[@]}; i++ ));
      do
        echo -e "  Processing ${hostsfile[0]##*/}\\${hostsfile[$i]}"
        unzip -p $WORKING_DIR\/${hostsfile[0]##*/} ${hostsfile[$i]} | grep "^127.0.0.1\|^0.0.0.0" | awk '{ print $2 }' >> $TEMP
      done
    else
      curl -s $hostsfile | grep "^127.0.0.1\|^0.0.0.0" | awk '{ print $2 }' >> $TEMP 
    fi
    
  done < $FILE_URL_LIST

  echo -e "\nTrimming, sorting the aggregated results and remove any duplicates..."
  cat $TEMP | grep -v "localhost" | sed -e 's/^[ \t]*//' | awk '{ print pre "\t" $0 }' pre=$HOSTS_PREFIX | tr -d '\r' | sort -f --buffer-size=16M | uniq > $ADDN_HOSTS
  echo -e "Total lines:" `wc -l $ADDN_HOSTS`

  # Restart DNS
  service dnsmasq restart

