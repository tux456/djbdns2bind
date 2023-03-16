#!/bin/bash

if [ -z "$MASTER" ];then MASTER="INSERT_MASTER_DNS.HERE.COM";fi
if [ -z "$ORIGIN" ];then ORIGIN="null";fi

cat <<fin667
@     IN     SOA    $MASTER.     hostmaster.$ORIGIN. (
                    2001062501 ; serial
                    21600      ; refresh after 6 hours
                    3600       ; retry after 1 hour
                    604800     ; expire after 1 week
                    86400 )    ; minimum TTL of 1 day
fin667

# echo "\$ORIGIN $ORIGIN"
if [ -z "$DEFAULT_TTL" ];then DEFAULT_TTL="1h";fi
echo "\$TTL $DEFAULT_TTL"

if [[ "$ORIGIN" =~ .*".arpa" ]];then
  ZONETYPE=PTR
  PTR_ORIGIN=$(echo $(echo $ORIGIN | tr '.' '\n' | tac | xargs |sed 's|[^0-9 ]||g') |tr \  .)
#  echo PTR_ORIGIN=$PTR_ORIGIN
else
  ZONETYPE=DIRECT
fi


# Read each line of the file
while read line; do
#  echo "DJB LINE: $line"
  # Put the first character in the DNS_TYPE variable
  DNS_TYPE=${line:0:1}
  LINE=$(echo "$line" | cut -c2-)
  # Separate each field with : delimiter
  IFS=':' read -ra FIELDS <<< $(echo $LINE)

  # Put the fields in f1, f2, f3, f4 variables
  f1=${FIELDS[0]}
  f2=${FIELDS[1]}
  f3=${FIELDS[2]}
  f4=${FIELDS[3]}

  if [ $ZONETYPE == "PTR" ];then
    f2_short=$(echo $f2 |sed "s/$PTR_ORIGIN.//" )
  elif [ "$ZONETYPE" == "DIRECT" ];then
    f1_short=$(echo $f1 |sed "s/.$ORIGIN//" )  
    if [ "$ORIGIN" != "null" ];then AREC="$f1_short IN A $f2" ;else AREC="$f1 IN A $f2";fi
  fi
 
 if [ "$DNS_TYPE" == "#" ];then echo ";  $LINE"
 elif [ "$DNS_TYPE" == "." ];then echo -e "$(echo $f1 |sed "s/$ORIGIN//" )\tIN NS $(echo $f3.|sed 's/[.][.]/./g')"
   elif [ "$DNS_TYPE" == "+" -a "$ZONETYPE" != "PTR" ];then echo -e "$f1_short\tIN A $f2"
   elif [ "$DNS_TYPE" == "+" -a "$ZONETYPE" == "PTR" ];then echo ";"
   elif [ "$DNS_TYPE" == "=" -a "$ZONETYPE" != "PTR" ];then echo -e "$f1_short\tIN A $f2"
   elif [ "$DNS_TYPE" == "=" -a "$ZONETYPE" == "PTR" ];then echo -e "$f2_short\tIN PTR $f1"
   elif [ "$DNS_TYPE" == "C" ];then echo -e "$f1_short\tIN CNAME $f2"
   elif [ "$DNS_TYPE" == "'" ];then echo -e "$f1_short\tIN TXT \"$f2\" "
   elif [ "$line" == "" ];then echo ""
   else echo ";  CONVERSION NOT FOUND:  $line"
  fi
done < $1
