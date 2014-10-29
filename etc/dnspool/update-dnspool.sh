#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORKING_DIR="/run/dnspool"
TEMP="$WORKING_DIR/blacklist.lst"
ADDN_HOSTS="/etc/dnspool/blacklist.uniq"
HOSTS_PREFIX="0.0.0.0"
FILE_URL_LIST="$DIR/ads.url"

  # remove if file/folder exist
  [ -d $WORKING_DIR ] && rm -rf $WORKING_DIR

  # re-creating folder and file
  mkdir -p $WORKING_DIR
  touch $TEMP

  echo -e "\nDownloading and processing URLs..."
  while read -r url_list; do
    [[ "$url_list" =~ ^#.*$ ]] && continue #Skipping commented lines
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

  #There might be a situtation where it's hard to standardize the hostname with scripts, thus custom job goes here
  #---------------------------------------------------------------------------------------------------------------
  ADULT_LIST="ftp://ftp.ut-capitole.fr/pub/reseau/cache/squidguard_contrib/adult.tar.gz"
  echo -e $ADULT_LIST
  curl -s -o $WORKING_DIR\/${ADULT_LIST[0]##*/} $ADULT_LIST 
  tar zxf ${ADULT_LIST[0]##*/} -C $WORKING_DIR
  cat $WORKING_DIR\/"adult/domains" >> $TEMP

  #Custom end here.
  #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  echo -e "\nTrimming, sorting the aggregated results and remove any duplicates..."
  cat $TEMP | grep -v "localhost" | sed -e 's/^[ \t]*//' | awk '{ print pre "\t" $0 }' pre=$HOSTS_PREFIX | tr -d '\r' | sort -f --buffer-size=16M | uniq > $ADDN_HOSTS
  echo -e "Total lines:" `wc -l $ADDN_HOSTS`

  # Restart DNS
  service dnsmasq restart

