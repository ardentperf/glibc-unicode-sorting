UNICODE_VERS=14
curl -kO https://www.unicode.org/Public/${UNICODE_VERS}.0.0/ucd/Blocks.txt
CHANGE_COUNT=""
grep GLIBC_VERS */run.out|sed 's.[/=]. .g'|sort -k4 -V|awk '{print$1}' | while read AMI
do
  GLIBC_VERS=$(grep GLIBC_VERS $AMI/run.out|tr -d '\r'|cut -d= -f2)
  OS_VERS=$(grep OS_VERS $AMI/run.out|tr -d '\r'|cut -d= -f2|cut -d'\' -f1)
  if [ -n "$PREV_AMI" ]; then
    CHANGELIST="$AMI/changelist_from-${PREV_GLIBC_VERS}_to-${GLIBC_VERS}.txt"
    echo "CodePoint Character PositionChange" >"${CHANGELIST}"
    diff $PREV_AMI/unicode-${UNICODE_VERS}-chars-sorted-glibc-${PREV_GLIBC_VERS}.txt $AMI/unicode-${UNICODE_VERS}-chars-sorted-glibc-${GLIBC_VERS}.txt |awk '/^[<>]/{print$3" "$2" "$1 pos;next}{pos=$1}'|sort >>"${CHANGELIST}"
    awk '/^CodePoint/{next}{print$1}' $CHANGELIST|uniq > changes.tmp
    CHANGECOUNT=$(cat changes.tmp|wc -l)
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
        for(@bl){if($_->[0] <= $l[0] and $l[0] <= $_->[1]){print($_->[2]."\n")}};
      }
    ' changes.tmp | uniq -c | paste -sd, - > blocks.tmp
  fi
  echo "| $GLIBC_VERS | $CHANGECOUNT | $(<blocks.tmp) | $OS_VERS | $AMI |"
  PREV_AMI="$AMI"
  PREV_GLIBC_VERS="$GLIBC_VERS"
done 
rm changes.tmp
rm blocks.tmp

