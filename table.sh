# table.sh - utility script to compare sorted lists from many systems and generate a summary
#
# After using the test-host script to generate sorted lists on many remote systems and download
# results from all of those remote systems, this script will iterate through all the downloaded
# lists (ordered by glibc version) and generate a DIFF of the sorted lists. It will then summarize
# the output of DIFF into a table in markdown format, matching the columns of the table in the main 
# README of this package. This script is intended to populate that table for easy viewing of the
# summary.
#
# usage: sh table.sh [ubuntu|rhel]
#
set -e

# make sure the unicode version here matches the "run.sh" script
UNICODE_VERS="14"
curl -kO https://www.unicode.org/Public/${UNICODE_VERS}.0.0/ucd/Blocks.txt

for PREFIX in _ubuntu _rhel; do
[ -n "$1" ] && [ "_$1" != "$PREFIX" ] && continue
echo ""
echo "===== Table for $PREFIX ====="

# some initialization
echo "" >blocks.tmp
CHANGECOUNT=""
CHANGECOUNT_STR=""
echo "" >langs.tmp
LC_CHANGECOUNT=""
LC_CHANGECOUNT_STR=""

# this logic was trickier than expected. we have a directory structure with the output 
# of "run.sh" from a whole bunch of different major versions of an operating system, going 
# back to RHEL 5 and Ubuntu 10. we want to produce a sorted list of those directories so 
# that we can iterate over the list, comparing each directory with the preceding one, and
# outputting a table as we go.
#
# in the case of RHEL, we simply sort by the full glibc version. the unix "sort" utility has
# a built-in "version" sort (-V) which correctly handles delimitors and numbers. my initial 
# approach was to choose two different minors from each RHEL major. so far, I've not yet seen
# two minors where the glibc versions (including patch level) were identical, for the RHEL 
# minors I tested. if this were to happen, the logic here does not guarantee that those two 
# entries in the table would be correctly ordered. that may cause an incorrect and misleading
# table to be generated. but if we need an OS version as a tie-breaker in the future, care must 
# be taken (see further notes below).
#
# the case of Ubuntu was harder. i wanted to include every bi-annual release. of course we sort
# in the glibc version first. rather inconveniently, Ubuntu 15.04 and 15.10 shipped exactly the
# same version of glibc (2.21-0ubuntu4) and we have to make sure they don't land backwards in the 
# table. if they are reversed, then the table would claim that 15.10 had changes (compared with
# the preceding table line 14.10) which would be incorrect and would mislead people. it's actually
# Ubuntu 15.04 that has changes, and 15.10 had no detected changes at all. fortunately, Ubuntu 
# has consistently included the OS version in /etc/issue since 2010 (unlike redhat). we pull 
# that in addition to glibc version, use the unix "paste" utility to concatenate every pair of 
# lines into a single line, then use the unix "sort" utility again to correctly sort by glibc
# version with the OS version as a tie-breaker.
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
      # it's not a simple operation to extract the OS version from the output of run.sh 
      # for RHEL. this is because RHEL 5/6 include the version in /etc/issue however in 
      # RHEL7+ it moved to the file system-release file (which doesn't exist in v5/6). the
      # logic here will use the system-release file if it exists, otherwise use /etc/issue.
      OS_VERS=$(grep -A1 "cat /etc/system-release$" $PREFIX/$AMI/run.out|grep -v "system-release" || grep OS_VERS $PREFIX/$AMI/run.out|tr -d '\r'\'|cut -d= -f2)
      ;;
  esac

  # remove files from any previous run, always start clean for doing comparisons
  rm -f $PREFIX/$AMI/changelist_*
  [ -d $PREFIX/$AMI/LC_COLLATE ] && rm -rf $PREFIX/$AMI/LC_COLLATE

  # we are only interested in the collation data from the locale files; loop through all
  # locale files and extract the LC_COLLATE section to a temporary working directory
  mkdir $PREFIX/$AMI/LC_COLLATE
  for F in $PREFIX/$AMI/locales/*; do 
    awk '/^LC_COLLATE/{pr=1}!NF{next}!/^[%#]/{if(pr){print}}/^END LC_COLLATE/{pr=0}' $F >$PREFIX/$AMI/LC_COLLATE/$(basename $F)
    [ -s $PREFIX/$AMI/LC_COLLATE/$(basename $F) ] || rm $PREFIX/$AMI/LC_COLLATE/$(basename $F)
  done
  
  # capture total number of locales with collations, so that table can show if there were new additions
  LOCALE_COUNT=$(ls $PREFIX/$AMI/LC_COLLATE|wc -l)
  
  # compare with previous AMI & print summary of diff (doesn't apply to the very first directory we process)
  if [ -n "$PREV_AMI" ]; then
    # echo "CodePoint String PositionChange" >"${CHANGELIST}"
    # diff $PREFIX/$PREV_AMI/unicode-${UNICODE_VERS}-chars-sorted-glibc-${PREV_GLIBC_VERS}.txt \
    #      $PREFIX/$AMI/unicode-${UNICODE_VERS}-chars-sorted-glibc-${GLIBC_VERS}.txt |
    #      awk '/^[<>]/{print substr($2,1+length($2)-8)" "substr($2,1,length($2)-8)" "$1 pos;next}!/^---/{pos=$1}' |
    #      sort >>"${CHANGELIST}" || true

    # run unix "diff" to compare sorted word lists from previous system and this system. everything else is based
    # on this. pass through uniq since a few strings can be duplicated and we only need each string once. note
    # that (importantly) uniq doesn't sort and doesn't change ordering of lines in the diff output.
    diff --minimal $PREFIX/$PREV_AMI/unicode-${UNICODE_VERS}-chars-sorted-glibc-${PREV_GLIBC_VERS}.txt \
                   $PREFIX/$AMI/unicode-${UNICODE_VERS}-chars-sorted-glibc-${GLIBC_VERS}.txt           \
        | uniq > diff.tmp

    # most words still appear twice in the diff, as deleted from old position and added to new 
    # position. we'll process the diff in two stages. first, read each word and reverse-engineer
    # which pattern and code point were used to compose the word. create an intermediate file by
    # stream processing the diff and creating a line for each word, with the additional fields.
    #     OUTPUT FIELDS: CodePoint, UnicodeBlock, PatternID, String, PositionChange
    perl -CSDA -e'
      use strict;
      use warnings;
      use utf8;
      my @bl;
      my $hunkposition;

      # read the unicode blocks into a variable for later lookups
      open(BLOCKS,"Blocks.txt");
      while(<BLOCKS>){
        # lines look like this:
        #   102E0..102FF; Coptic Epact Numbers
        # decode range and store as numbers in array, then store 
        # string version of first number (for later lookup)
        if(/^([0-9A-Z]*)[.][.]([0-9A-Z]*); (.*)/){
          my @b=(hex("0x".$1),hex("0x".$2),$1);
          push(@bl,\@b)
        }
      }

      LINE:
      while (<>) {
        chomp;
        
        # match lines of the diff with actual strings
        if(/^[<>]/) {
          # remove first two characters from string (diff prefixes each line eg. "> ")
          substr($_,0,2)="";

          # find the first matching pattern, using length then chars, and determine code point 
          # used for generation. there will be cases of the same string generated by multiple 
          # code points; this approach will take the first matched pattern for all occurrences 
          # of dup strings. this approach is worthwhile in order to keep things simple.
          #
          # IMPORTANT: make sure to keep this block in sync with README and run.sh
          #

          # the initialization values are important, because they will appear in the output
          # data if there are no matches. it should be a value that stands out as clearly
          # not a "normal" value, so its obvious something went wrong.
          my $pattern=999;
          my $codepoint=0xFFFFFF;
          my $unicodeblock="FFFFFF";

          if(length()==1) {
                            $pattern=199; $codepoint=ord($_); goto PR;
          }
          elsif(length()==2) {
            if(/.B/)      { $pattern=200; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/.O/)      { $pattern=201; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/.3/)      { $pattern=202; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/.[.]/)    { $pattern=203; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/. /)      { $pattern=204; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/.様/)      { $pattern=205; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/.ク/)      { $pattern=206; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/B./)      { $pattern=210; $codepoint=ord(substr($_,1,1)); goto PR; };
            if(/O./)      { $pattern=211; $codepoint=ord(substr($_,1,1)); goto PR; };
            if(/3./)      { $pattern=212; $codepoint=ord(substr($_,1,1)); goto PR; };
            if(/[.]./)    { $pattern=213; $codepoint=ord(substr($_,1,1)); goto PR; };
            if(/ ./)      { $pattern=214; $codepoint=ord(substr($_,1,1)); goto PR; };
            if(/様./)      { $pattern=215; $codepoint=ord(substr($_,1,1)); goto PR; };
            if(/ク./)      { $pattern=216; $codepoint=ord(substr($_,1,1)); goto PR; };
                            $pattern=299; $codepoint=ord(substr($_,1,1)); goto PR;
          }
          elsif(length()==3) {
            if(/.BB/)      { $pattern=300; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/.OO/)      { $pattern=301; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/.33/)      { $pattern=302; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/.[.][.]/)  { $pattern=303; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/.  /)      { $pattern=304; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/.様様/)      { $pattern=305; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/.クク/)      { $pattern=306; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/B.B/)      { $pattern=310; $codepoint=ord(substr($_,1,1)); goto PR; };
            if(/O.O/)      { $pattern=311; $codepoint=ord(substr($_,1,1)); goto PR; };
            if(/3.3/)      { $pattern=312; $codepoint=ord(substr($_,1,1)); goto PR; };
            if(/[.].[.]/)  { $pattern=313; $codepoint=ord(substr($_,1,1)); goto PR; };
            if(/ . /)      { $pattern=314; $codepoint=ord(substr($_,1,1)); goto PR; };
            if(/様.様/)      { $pattern=315; $codepoint=ord(substr($_,1,1)); goto PR; };
            if(/ク.ク/)      { $pattern=316; $codepoint=ord(substr($_,1,1)); goto PR; };
            if(/BB./)      { $pattern=320; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/OO./)      { $pattern=321; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/33./)      { $pattern=322; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/[.][.]./)  { $pattern=323; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/  ./)      { $pattern=324; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/様様./)      { $pattern=325; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/クク./)      { $pattern=326; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/..B/)      { $pattern=330; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/..O/)      { $pattern=331; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/..3/)      { $pattern=332; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/..[.]/)    { $pattern=333; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/.. /)     { $pattern=334; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/..様/)     { $pattern=335; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/..ク/)     { $pattern=336; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/.B./)      { $pattern=340; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/.O./)      { $pattern=341; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/.3./)      { $pattern=342; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/.[.]./)    { $pattern=343; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/. ./)      { $pattern=344; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/.様./)      { $pattern=345; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/.ク./)      { $pattern=346; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/B../)      { $pattern=350; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/O../)      { $pattern=351; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/3../)      { $pattern=352; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/[.]../)    { $pattern=353; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/ ../)      { $pattern=354; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/様../)      { $pattern=355; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/ク../)      { $pattern=356; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/3B./)      { $pattern=380; $codepoint=ord(substr($_,2,1)); goto PR; };
                            $pattern=399; $codepoint=ord(substr($_,2,1)); goto PR;
          }
          elsif(length()==4) {
            if(/..BB/)      { $pattern=400; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/..OO/)      { $pattern=401; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/..33/)      { $pattern=402; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/..[.][.]/)  { $pattern=403; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/..  /)      { $pattern=404; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/..様様/)      { $pattern=405; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/..クク/)      { $pattern=406; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/B..B/)      { $pattern=410; $codepoint=ord(substr($_,1,1)); goto PR; };
            if(/O..O/)      { $pattern=411; $codepoint=ord(substr($_,1,1)); goto PR; };
            if(/3..3/)      { $pattern=412; $codepoint=ord(substr($_,1,1)); goto PR; };
            if(/[.]..[.]/)  { $pattern=413; $codepoint=ord(substr($_,1,1)); goto PR; };
            if(/ .. /)      { $pattern=414; $codepoint=ord(substr($_,1,1)); goto PR; };
            if(/様..様/)      { $pattern=415; $codepoint=ord(substr($_,1,1)); goto PR; };
            if(/ク..ク/)      { $pattern=416; $codepoint=ord(substr($_,1,1)); goto PR; };
            if(/BB../)      { $pattern=420; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/OO../)      { $pattern=421; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/33../)      { $pattern=422; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/[.][.]../)  { $pattern=423; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/  ../)      { $pattern=424; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/様様../)      { $pattern=425; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/クク../)      { $pattern=426; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/3B.B/)      { $pattern=480; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/3B-./)      { $pattern=481; $codepoint=ord(substr($_,3,1)); goto PR; };
                            $pattern=499; $codepoint=ord(substr($_,2,1)); goto PR;
          }
          elsif(length()==5) {
            if(/BB..[\t]/)    { $pattern=580; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/[\t]BB../)      { $pattern=581; $codepoint=ord(substr($_,3,1)); goto PR; };
            if(/BB-../)      { $pattern=582; $codepoint=ord(substr($_,3,1)); goto PR; };
            if(/🙂👍.❤™/)      { $pattern=583; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/..[.]33/)    { $pattern=584; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/3B-.B/)      { $pattern=585; $codepoint=ord(substr($_,3,1)); goto PR; };
                            $pattern=599; $codepoint=ord(substr($_,2,1)); goto PR;
          };

        PR:
          for(@bl){if($_->[0] <= $codepoint and $codepoint <= $_->[1]){$unicodeblock=$_->[2]}};
          printf("%06x %s %03d %s %s\n",$codepoint,$unicodeblock,$pattern,$_,$hunkposition);
          next LINE;
        }

        # only reach this point if its not an actual string; discard "---" and otherwise this 
        # line is a diff hunk position/heading. store it so we can output with subsequent lines
        if(!/^---/) { $hunkposition=$_; }
      }
    ' diff.tmp >changelist1.tmp

    # generate a summary report, listing the patterns that appear for each block and the count of
    # distinct code points that appear for each pattern in each block.
    SUMMARY="$PREFIX/$AMI/summary_en-US_from-${PREV_GLIBC_VERS}_to-${GLIBC_VERS}.txt"
    echo "# Pattern ID (count of distinct codepoints in diff output)" >$SUMMARY
    echo "" >>$SUMMARY
    awk '{print$2}' changelist1.tmp|sort -u >blocks.tmp
    cat blocks.tmp|while read BLOCK; do
      grep ^$BLOCK[.] Blocks.txt >>$SUMMARY
      echo -n "  " >>$SUMMARY
      INIT=1
      awk '{if($2=="'$BLOCK'"){print$3}}' changelist1.tmp|sort -u|while read PATTERN; do
        # except for the first block, prefix each output with a comma
        ((INIT)) || echo -n ", " >>$SUMMARY
        INIT=0

        COUNT=$(awk '{if($2=="'$BLOCK'" && $3=="'$PATTERN'"){print$1}}' changelist1.tmp|sort -u|wc -l)
        echo -n "$PATTERN ($COUNT)" >>$SUMMARY
      done
      echo "" >>$SUMMARY
      echo "" >>$SUMMARY
    done

    # string for count of changed blocks (includes markdown link to sumamry data)
    BLOCKCOUNT=$(cat blocks.tmp|wc -l)
    SUMMARY_STR="0"; (( BLOCKCOUNT > 0 )) && SUMMARY_STR="[$BLOCKCOUNT]($SUMMARY)"

    # final master code point data file: uploaded to git
    CHANGELIST="$PREFIX/$AMI/changelist_en-US_from-${PREV_GLIBC_VERS}_to-${GLIBC_VERS}.txt"
    echo "">"${CHANGELIST}"
    cp changelist1.tmp changelist2.tmp
    INIT=1
    awk '{print$3}' changelist1.tmp|sort -u|while read PATTERN; do
      COUNT=$(awk '{if($3=="'$PATTERN'"){print$1}}' changelist1.tmp|sort -u|wc -l)
      if ((COUNT>25000)); then
        # there are more than 25,000 distinct code points for this pattern, so summarize
        # and filter the individual code points out for the data file. the purpose is to
        # keep file size manageable for git.
        if ((INIT)); then
          echo "# Filtering out patterns with more than 25,000 distinct codepoints to preserve version control sanity." >>"${CHANGELIST}"
          echo "# " >>"${CHANGELIST}"
          echo "# Filtered Pattern IDs (count of total distinct codepoints in diff output):" >>"${CHANGELIST}"
          echo -n "#   " >>"${CHANGELIST}"
        else
          echo -n ", " >>"${CHANGELIST}"
        fi
        INIT=0
        echo -n "$PATTERN ($COUNT)" >>"${CHANGELIST}"

        # actually remove the data
        mv changelist2.tmp changelist3.tmp
        awk '{if($3!="'$PATTERN'"){print$0}}' changelist3.tmp >changelist2.tmp
        rm changelist3.tmp
      fi
    done
    echo "" >>"${CHANGELIST}"
    echo "" >>"${CHANGELIST}"

    # write headers (after listing code points that were removed)
    echo "# CodePoint UnicodeBlock PatternID String PositionChange" >>"${CHANGELIST}"

    # most codepoints appear twice in the datafile (diff reports line removed and line 
    # added); consolidate to single line per codepoint
    sort -u changelist2.tmp|awk '
      BEGIN { prev_codepoint="z"; prev_pattern="z"; }
      {
        if( $1!=prev_codepoint || $3!= prev_pattern ) {
          printf("\n"$0);
          prev_codepoint=$1;
          prev_pattern=$3;
        } else {
          printf(":"$NF)
        }
      }
    ' >>$CHANGELIST

    CHANGECOUNT=$(awk '{print$1}' changelist1.tmp|sort -u|wc -l)

    # master locale data file (the LC_ prefix is for processing the locale files that were copied)
    LC_CHANGELIST="$PREFIX/$AMI/changelist_locales_from-${PREV_GLIBC_VERS}_to-${GLIBC_VERS}.txt"
    # the LC_COLLATE directory contains files with only the collation data for each locale; do
    # a recursive diff and generate a single output file
    diff -byt --suppress-common-lines $PREFIX/$PREV_AMI/LC_COLLATE $PREFIX/$AMI/LC_COLLATE >"${LC_CHANGELIST}" || true
    # count number of line changes detected by the diff in all locales
    LC_CHANGECOUNT=$(grep -vE '^(diff|Only)' $LC_CHANGELIST|wc -l)
    # extract the locales from the filenames, for a summary (if 20 or less)
    grep -E '^diff' $LC_CHANGELIST|tr / ' '|awk '{print" "$7}' >langs.tmp
    grep -E "^Only in $PREFIX/$PREV_AMI" $LC_CHANGELIST|awk '{print" "$4" (removed)"}' >>langs.tmp
    (( `cat langs.tmp|wc -l` > 20 )) && echo "(More than 20 languages)" >langs.tmp
    # string for count of changed codepoints (includes markdown link to data)
    CHANGECOUNT_STR="0"; (( CHANGECOUNT > 0 )) && CHANGECOUNT_STR="[$CHANGECOUNT]($CHANGELIST)"
    # string for count of changed locales (includes markdown link to data)
    LC_CHANGECOUNT_STR="0"; (( LC_CHANGECOUNT > 0 )) && LC_CHANGECOUNT_STR="[$LC_CHANGECOUNT]($LC_CHANGELIST)"
    # don't upload a data file bigger than 50GB to git
    (( `stat --printf="%s" $CHANGELIST` > 50000000 )) && echo "File too large (over 50 GB) - removed to preserve version control sanity" >$CHANGELIST
  fi
  echo "| $GLIBC_VERS | $CHANGECOUNT_STR | $SUMMARY_STR | $LC_CHANGECOUNT_STR | $(paste -sd, langs.tmp) | $LOCALE_COUNT | $OS_VERS | [$AMI]($PREFIX/$AMI) |"
  PREV_AMI="$AMI"
  PREV_GLIBC_VERS="$GLIBC_VERS"
done 

# cleanup
rm diff.tmp
rm changelist1.tmp
rm changelist2.tmp
rm langs.tmp
rm blocks.tmp
rm Blocks.txt

done
