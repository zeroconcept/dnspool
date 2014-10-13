#!/bin/bash

TEMP="/tmp/adblock.lst"
ADDN_HOSTS="/etc/dnsmasq/adblock.uniq"
PREFIX="0.0.0.0"
URL_LIST="http://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&mimetype=plaintext http://winhelp2002.mvps.org/hosts.txt http://adaway.org/hosts.txt http://hosts-file.net/ad_servers.txt http://www.malwaredomainlist.com/hostslist/hosts.txt http://adblock.gjtech.net/?format=unix-hosts http://hphosts.gt500.org/hosts.zip http://www.securemecca.com/Downloads/hosts.txt http://someonewhocares.org/hosts/hosts"


  # remove if file exist
  [ -e $TEMP ] && rm -rf $TEMP

  # re-creating file
  touch $TEMP

  echo -e "\nDownloading and processing URLs..."
  for url in ${URL_LIST[@]}; do
    echo $url
    if test ${url##*.} = "zip"
    then
      echo -e "Processing ${url##*/}..."
      curl -s -o /tmp/${url##*/} $url
      # Hard-coded filename -- will figure out the way to handle it in flexible way
      unzip -p /tmp/${url##*/} hosts.txt | grep "^127.0.0.1\|^0.0.0.0" | awk '{ print $2 }' >> $TEMP
    else
      curl -s $url | grep "^127.0.0.1\|^0.0.0.0" | awk '{ print $2 }' >> $TEMP
    fi
  done

  echo -e "\nTrimming, sorting the aggregated results and remove any duplicates..."
  cat $TEMP | grep -v "localhost" | sed -e 's/^[ \t]*//' | awk '{ print pre "\t" $0 }' pre=$PREFIX | tr -d '\r' | sort -f --buffer-size=16M | uniq > $ADDN_HOSTS
  echo -e "Total lines:" `wc -l $ADDN_HOSTS`

  # Restart DNS
  service dnsmasq restart

