#!/bin/bash

if [ -z "$ORIGIN" ];then echo "Need to set ORIGIN env";exit 1;fi

#echo "; ***********************************"
#echo "; * $ORIGIN"
#echo "; ***********************************"
#echo "; "
if [ -n "$MASTER" ];then
cat <<fin667
$ORIGIN.  2560   IN     SOA    $MASTER.     hostmaster.$ORIGIN. (
                    $(date +%s) ; serial
                    16384      ; refresh 
                    2048       ; retry
                    1048576     ; expire 
                    2560 )    ; minimum TTL of 1 day
fin667
if [ -n "$DEFAULT_TTL" ];then echo "\$TTL $DEFAULT_TTL";fi

fi


if [[ "$ORIGIN" =~ .*".arpa" ]];then
  PTR_ORIGIN=$(echo $(echo $ORIGIN | tr '.' '\n' | tac | xargs |sed 's|[^0-9 ]||g') |tr \  .)
fi



while read line; do
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

  OUTZONE=false
  if [ $ZONETYPE == "PTR" ];then
    f2_short=$(echo $f2 |sed "s/$PTR_ORIGIN.//" )
    f1_short=$(echo $f1 |sed "s/.$PTR_ORIGIN//" )
  elif [ "$ZONETYPE" == "DIRECT" ];then
    f1_short=$(echo $f1 |sed "s/.$ORIGIN//" )
    [ "$f1_short" == "$ORIGIN" ] && f1_short="@"
  fi

 if [ "$DNS_TYPE" == "#" ];then [ -z "$SILENT" ] && echo ";  $line"
#   elif [ "$DNS_TYPE" == "&" ];then echo -e "$(echo $f1 |sed "s/$ORIGIN//" ) IN MX $f2 $f3"
   elif [ "$DNS_TYPE" == "." -a "$f1_short" == "@" ];then echo -e "@ 259200 IN NS $(echo $f3.|sed 's/[.][.]/./g')"
   elif [ "$DNS_TYPE" == "." -a "$f1_short" == "$f1" ];then echo -e "@ 259200 IN NS $(echo $f3.|sed 's/[.][.]/./g')"
   elif [ "$DNS_TYPE" == "@" -a "$f1_short" == "@" ];then echo -e "@ IN MX $f4 $(echo $f3.|sed 's/[.][.]/./g')"
   elif [ "$DNS_TYPE" == "@" ];then echo -e "@ IN MX $f4 $(echo $f3.|sed 's/[.][.]/./g')"
   elif [ "$DNS_TYPE" == "@" ];then echo -e "$f1 IN MX $f4 $(echo $f3.|sed 's/[.][.]/./g')"
   elif [ "$DNS_TYPE" == "+" -a "$ZONETYPE" == "PTR" ];then echo ";"
   elif [ "$DNS_TYPE" == "C" -a "$ZONETYPE" != "PTR" -a "$f1_short" != "$f1" ];then echo -e "$f1_short IN CNAME $f2."
   elif [ "$DNS_TYPE" == "'" -a "$f1_short" == "@"  -a "$ZONETYPE" != "PTR" ];then echo -e "$f1_short $f3 IN TXT \"$f2\" "
   elif [ "$DNS_TYPE" == "'" -a "$ZONETYPE" != "PTR" ];then echo -e "$f1_short $f3 IN TXT \"$f2\" "
   elif [ "$DNS_TYPE" == "+" -a "$f1_short" != "$f1" ];then echo -e "$f1_short IN A $f2"
   elif [ "$DNS_TYPE" == "=" -a "$ZONETYPE" != "PTR" -a "$f1_short" != "$f1" ];then echo -e "$f1_short IN A $f2"
   elif [ "$DNS_TYPE" == "=" -a "$ZONETYPE" == "PTR" -a "$f2_short" != "$f2" ];then echo -e "$f2_short IN PTR $f1."

   elif [ "$line" == "" ];then echo ""
   else [ -z "$SILENT" ] && echo ";  CONVERSION NOT FOUND:  $line"
  fi
done < $1
