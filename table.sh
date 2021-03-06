# usage: sh table.sh [ubuntu|rhel]
#
set -e

UNICODE_VERS=14
curl -kO https://www.unicode.org/Public/${UNICODE_VERS}.0.0/ucd/Blocks.txt

for PREFIX in _ubuntu _rhel; do
[ -n "$1" ] && [ "_$1" != "$PREFIX" ] && continue
echo ""
echo "===== Table for $PREFIX ====="

echo "" >blocks.tmp
CHANGECOUNT=""
CHANGECOUNT_STR=""
echo "" >langs.tmp
LC_CHANGECOUNT=""
LC_CHANGECOUNT_STR=""
case $PREFIX in
  _ubuntu)
    SORTED_AMI_LIST="$(grep -E '(GLIBC_VERS|OS_VERS)' $PREFIX/*/run.out|sed 's.[/=].  .g;s.[\r\]..g;s.LTS..'|paste -d" " - -|sort -k13 -k6 -V|awk '{print$2}')"
    ;;
  _rhel)
    SORTED_AMI_LIST="$(grep GLIBC_VERS $PREFIX/*/run.out|sed 's.[/=].  .g'|sort -k5 -V|awk '{print$2}')"
    ;;
esac
echo "$SORTED_AMI_LIST" | while read AMI
do
  GLIBC_VERS=$(grep GLIBC_VERS $PREFIX/$AMI/run.out|tr -d '\r'|cut -d= -f2)
  case $PREFIX in
    _ubuntu)
      OS_VERS=$(grep OS_VERS $PREFIX/$AMI/run.out|tr -d '\r'|cut -d= -f2|cut -d\\ -f1)
      ;;
    _rhel)
      OS_VERS=$(grep -A1 "cat /etc/system-release$" $PREFIX/$AMI/run.out|grep -v "system-release" || grep OS_VERS $PREFIX/$AMI/run.out|tr -d '\r'\'|cut -d= -f2)
      ;;
  esac
  rm -f $PREFIX/$AMI/changelist_*
  [ -d $PREFIX/$AMI/LC_COLLATE ] && rm -rf $PREFIX/$AMI/LC_COLLATE
  mkdir $PREFIX/$AMI/LC_COLLATE
  for F in $PREFIX/$AMI/locales/*; do 
    awk '/^LC_COLLATE/{pr=1}!NF{next}!/^[%#]/{if(pr){print}}/^END LC_COLLATE/{pr=0}' $F >$PREFIX/$AMI/LC_COLLATE/$(basename $F)
    [ -s $PREFIX/$AMI/LC_COLLATE/$(basename $F) ] || rm $PREFIX/$AMI/LC_COLLATE/$(basename $F)
  done
  LOCALE_COUNT=$(ls $PREFIX/$AMI/LC_COLLATE|wc -l)
  if [ -n "$PREV_AMI" ]; then
    CHANGELIST="$PREFIX/$AMI/changelist_en-US_from-${PREV_GLIBC_VERS}_to-${GLIBC_VERS}.txt"
    echo "CodePoint String PositionChange" >"${CHANGELIST}"
    diff $PREFIX/$PREV_AMI/unicode-${UNICODE_VERS}-chars-sorted-glibc-${PREV_GLIBC_VERS}.txt $PREFIX/$AMI/unicode-${UNICODE_VERS}-chars-sorted-glibc-${GLIBC_VERS}.txt |awk '/^[<>]/{print substr($2,1+length($2)-8)" "substr($2,1,length($2)-8)" "$1 pos;next}!/^---/{pos=$1}'|sort >>"${CHANGELIST}" || true
    awk '/^CodePoint/{next}{print$1}' $CHANGELIST|uniq > changes.tmp
    CHANGECOUNT=$(cat changes.tmp|wc -l)
    if (( CHANGECOUNT <= 25000)); then
    perl -e'
      my @bl;
      open(BLOCKS,"Blocks.txt");
      while(<BLOCKS>){
        if(/^([0-9A-Z]*)[.][.]([0-9A-Z]*); (.*)/){
          my @b=(hex("0x".$1),hex("0x".$2),$3);
          push(@bl,\@b)
        }
      }
      while(<>){
        if(/^CodePoint/){next};
        my @l = split;
        for(@bl){if($_->[0] <= hex("0x".$l[0]) and hex("0x".$l[0]) <= $_->[1]){print($_->[2]."\n")}};
      }
    ' changes.tmp | uniq -c | paste -sd, - > blocks.tmp
    else
      echo "(Blocks not listed for this many en_US sort order changes)" > blocks.tmp
    fi
    LC_CHANGELIST="$PREFIX/$AMI/changelist_locales_from-${PREV_GLIBC_VERS}_to-${GLIBC_VERS}.txt"
    diff -byt --suppress-common-lines $PREFIX/$PREV_AMI/LC_COLLATE $PREFIX/$AMI/LC_COLLATE >"${LC_CHANGELIST}" || true
    LC_CHANGECOUNT=$(grep -vE '^(diff|Only)' $LC_CHANGELIST|wc -l)
    grep -E '^diff' $LC_CHANGELIST|tr / ' '|awk '{print" "$7}' >langs.tmp
    grep -E "^Only in $PREFIX/$PREV_AMI" $LC_CHANGELIST|awk '{print" "$4" (removed)"}' >>langs.tmp
    (( `cat langs.tmp|wc -l` > 20 )) && echo "(More than 20 languages)" >langs.tmp
    CHANGECOUNT_STR="0"; (( CHANGECOUNT > 0 )) && CHANGECOUNT_STR="[$CHANGECOUNT]($CHANGELIST)"
    LC_CHANGECOUNT_STR="0"; (( LC_CHANGECOUNT > 0 )) && LC_CHANGECOUNT_STR="[$LC_CHANGECOUNT]($LC_CHANGELIST)"
    (( `stat --printf="%s" $CHANGELIST` > 50000000 )) && echo "File too large (over 50 GB) - removed to preserve version control sanity" >$CHANGELIST
  fi
  echo "| $GLIBC_VERS | $CHANGECOUNT_STR | $(<blocks.tmp) | $LC_CHANGECOUNT_STR | $(paste -sd, langs.tmp) | $LOCALE_COUNT | $OS_VERS | [$AMI]($PREFIX/$AMI) |"
  PREV_AMI="$AMI"
  PREV_GLIBC_VERS="$GLIBC_VERS"
done 
rm langs.tmp
rm changes.tmp
rm blocks.tmp
rm Blocks.txt

done
