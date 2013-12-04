#!/bin/sh
## Adblock script [Version 2.1.1 | 04 Dec 2013 | 3778+ bytes]
##
## Created by Adrian Jon Kriel: root-AT-extremecooling-DOT-org
## Modified by Eitan Miller
##
## tomato WAN Up script
##
## 0 = disable
## 1 = enable
## (1) = default value
## optimising of dnsmasq, (1)
eval OPTDNSMASQ="1"
## automatic updating, (1)
eval AUTOUPDATE="1"
## MVPS HOSTS ~18,500 lines, 680 Kbyte, (1)
eval MVPSSOURCE="1"
## pgl.yoyo.org ~2,200 lines, 68 Kbyte, (1)
eval PGLSOURCE="1"
## hosts-file.net ~53,000 lines, 1.5 Mbyte, (0)
eval HSFSOURCE="0"
## Hosts File Project ~102,000 lines, 3.0 Mbyte ***6+mb free memory***, (0)
eval HFPSOURCE="0"
## Someone Who Cares, 287 Kbyte
eval SMWCSOURCE="1"
##
## varibles
## location of temp file, (/tmp/hosts)
eval GENFILE="/tmp/hosts"
## redirect ip, (0.0.0.0)
eval REDIRECTIP="0.0.0.0"
## sources
eval MVPSOURCEFILE="http://winhelp2002.mvps.org/hosts.txt"
eval PGLSOURCEFILE="http://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts"
eval HSFSOURCEFILE="http://www.it-mate.co.uk/downloads/hosts.txt"
eval HFPSOURCEFILE="http://hostsfile.mine.nu/Hosts"
eval SMWCSOURCEFILE="http://someonewhocares.org/hosts/zero/hosts"

if ping -c 1 yahoo.com ; then

eval GOTSOURCE="0"
echo "" > $GENFILE
## download 
if [ "$MVPSSOURCE" = "1" ]  ; then
if wget $MVPSOURCEFILE -O - >> $GENFILE ; then
logger ADBLOCK Downloaded $MVPSOURCEFILE
eval GOTSOURCE="1"
else
logger ADBLOCK Failed $MVPSOURCEFILE
fi
fi
if [ "$PGLSOURCE" = "1" ]  ; then
if wget $PGLSOURCEFILE -O - >> $GENFILE ; then
logger ADBLOCK Load $PGLSOURCEFILE
eval GOTSOURCE="1"
else
logger ADBLOCK Fail $PGLSOURCEFILE
fi
fi
if [ "$HSFSOURCE" = "1" ]  ; then
if wget $HSFSOURCEFILE -O - >> $GENFILE ; then
logger ADBLOCK load $HSFSOURCEFILE
eval GOTSOURCE="1"
else
logger ADBLOCK Fail $HSFSOURCEFILE
fi
fi
if [ "$HFPSOURCE" = "1" ]  ; then
if wget $HFPSOURCEFILE -O - >> $GENFILE ; then
logger ADBLOCK Load $HFPSOURCEFILE
eval GOTSOURCE="1"
else
logger ADBLOCK Fail $HFPSOURCEFILE
fi
fi

if [ "$SMWCSOURCE" = "1" ]  ; then
if wget $SMWCSOURCEFILE-O - >> $GENFILE ; then
logger ADBLOCK Load $SMWCSOURCEFILE
eval GOTSOURCE="1"
else
logger ADBLOCK Fail $SMWCSOURCEFILE
fi
fi

if [ "$GOTSOURCE" = "1" ]; then
logger ADBLOCK Got Source Files
#FREE MEMORY!
service dnsmasq stop
killall -9 dnsmasq
logger ADBLOCK Ignor Fail Safe
##strip source file
sed -i -e '/^[0-9A-Za-z]/!d' $GENFILE
sed -i -e '/%/d' $GENFILE
sed -i -e 's/[[:cntrl:][:blank:]]//g' $GENFILE
sed -i -e 's/^[ \t]*//;s/[ \t]*$//' $GENFILE

## dnsmasq, sanitize, optimised
sed -i -e 's/[[:space:]]*\[.*$//'  $GENFILE
sed -i -e 's/[[:space:]]*\].*$//'  $GENFILE
sed -i -e '/[[:space:]]*#.*$/ s/[[:space:]]*#.*$//'  $GENFILE		
sed -i -e '/^$/d' $GENFILE
sed -i -e '/127.0.0.1/ s/127.0.0.1//'  $GENFILE		
sed -i -e '/^www[0-9]./ s/^www[0-9].//'  $GENFILE		
sed -i -e '/^www./ s/^www.//' $GENFILE
## remove duplicates (resource friendly)	
cat $GENFILE | sort -u > $GENFILE.new
mv $GENFILE.new $GENFILE
## format
sed -i -e 's|$|/'$REDIRECTIP'|' $GENFILE
sed -i -e 's|^|address=/|' $GENFILE
## load values from dnsmasq config
cat /etc/dnsmasq.conf >> $GENFILE
## optimise dnsmasq
if [ "$OPTDNSMASQ" = "1" ] ; then
cat >> $GENFILE <<EOF
cache-size=2048
log-async=5
EOF
fi

## remove/whitelist websites
## removes 3 websites (aa.com, bb.com, cc.com) 
## remove the # and edit the website urls.
#sed -i -e '/aa.com/d' $GENFILE
#sed -i -e '/bb.com/d' $GENFILE
#sed -i -e '/cc.com/d' $GENFILE

## apply blacklist
dnsmasq --conf-file=$GENFILE

## failsafe added
dnsmasq
logger ADBLOCK Ignor Fail Safe

## dev info
logger ADBLOCK Unique Hosts Blocked $(awk 'END { print NR }' $GENFILE)
else
logger ADBLOCK Error Not Downloaded
fi
else
logger ADBLOCK Error No Internet
fi
## remove the generated files
rm $GENFILE*
## automatic update
if [ "$AUTOUPDATE" = "1" ] ; then
## script exists
if [ -x /tmp/script_wanup.sh ] ; then
cru a UpdateAdlist "45 23 * * 5 /tmp/script_wanup.sh >/dev/null 2>&1"
fi
fi
## the end
