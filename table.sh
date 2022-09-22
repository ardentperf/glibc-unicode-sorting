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
type perl curl sort awk uniq grep wc tr cut >/dev/null || exit 2
set -e

# make sure the unicode version here matches the "run.sh" script
UNICODE_VERS="14"
curl -kO https://www.unicode.org/Public/${UNICODE_VERS}.0.0/ucd/Blocks.txt

date

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
    [ ! -f $PREFIX/$AMI/diff.tmp ] && echo "ERROR: run diff.sh first" && exit 1

    # most words still appear twice in the diff, as deleted from old position and added to new 
    # position. we'll process the diff in two stages. first, read each word and reverse-engineer
    # which pattern and code point were used to compose the word. create an intermediate file by
    # stream processing the diff and creating a line for each word, with the additional fields.
    #     OUTPUT FIELDS: CodePoint, UnicodeBlock, PatternID, String, PositionChange
    #
    # pass input through uniq since a few strings can be generated by multiple patterns (on different code 
    # points) and we only need each string counted/reported once. the first matching pattern will always be 
    # used for each string. uniq doesn't sort, and doesn't change ordering of lines in the diff output.
    cat $PREFIX/$AMI/diff.tmp | uniq | perl -CSDA -e'
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
        
        # diff hunk position/heading. store it so we can output with subsequent lines
        if(/^@@ (.*) @@/) { $hunkposition=$1; $hunkposition=~s/ //; next LINE; };

        # skip filename lines in unified diff output, which would also match main regex below
        if(/^---|^[+][+][+]/){ next LINE; };

        # match lines of the diff with actual strings
        if(/^[-+]/) {
          # remove first character from string (unified diff prefixes each line with + or -)
          substr($_,0,1)="";

          # find the first matching pattern, using length then chars, and determine code point 
          # used for generation. there will be cases of the same string generated by multiple 
          # code points; this approach will take the first matched pattern for all occurrences 
          # of dup strings. this approach is worthwhile in order to keep things simple.
          #
          # IMPORTANT: make sure to keep this block in sync with README and run.sh
          #

          # the initialization values are important, because they will appear in the output
          # data if there are no matches. it should be a value that stands out as clearly
          # not a "normal" value, so its obvious something went wrong. Use codepoint 0
          # so that it appears at the very top of the data file.
          my $pattern=999;
          my $codepoint=0;
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

            if(substr($_,0,1) ne substr($_,1,1)) { goto PR; };  # something went wrong

                            $pattern=299; $codepoint=ord(substr($_,1,1)); goto PR;
          }
          elsif(length()==3) {
            # check this first, otherwise get false match on pattern number 340
            if(/3B./)      { $pattern=380; $codepoint=ord(substr($_,2,1)); goto PR; };

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

            if(substr($_,1,1) ne substr($_,2,1)) { goto PR; };  # something went wrong

                            $pattern=399; $codepoint=ord(substr($_,2,1)); goto PR;
          }
          elsif(length()==4) {
            # check these first to avoid false positives on other patterns
            if(/3B.B/)      { $pattern=480; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/3B-./)      { $pattern=481; $codepoint=ord(substr($_,3,1)); goto PR; };

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

            if(substr($_,1,1) ne substr($_,2,1)) { goto PR; };  # something went wrong

                            $pattern=499; $codepoint=ord(substr($_,2,1)); goto PR;
          }
          elsif(length()==5) {
            if(/BB..[\t]/)    { $pattern=580; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/[\t]BB../)      { $pattern=581; $codepoint=ord(substr($_,3,1)); goto PR; };
            if(/BB-../)      { $pattern=582; $codepoint=ord(substr($_,3,1)); goto PR; };
            if(/🙂👍.❤™/)      { $pattern=583; $codepoint=ord(substr($_,2,1)); goto PR; };
            if(/..[.]33/)    { $pattern=584; $codepoint=ord(substr($_,0,1)); goto PR; };
            if(/3B-.B/)      { $pattern=585; $codepoint=ord(substr($_,3,1)); goto PR; };

            if(substr($_,1,1) ne substr($_,2,1)) { goto PR; };  # something went wrong

                            $pattern=599; $codepoint=ord(substr($_,2,1)); goto PR;
          };

        PR:
          for(@bl){if($_->[0] <= $codepoint and $codepoint <= $_->[1]){$unicodeblock=$_->[2]}};
          printf("%06x %s S-%03d %s %s\n",$codepoint,$unicodeblock,$pattern,$_,$hunkposition);
          next LINE;
        }
      }
    ' >$PREFIX/$AMI/changelist1.tmp

    # generate a summary report, listing the patterns that appear for each block and the count of
    # distinct code points that appear for each pattern in each block. the awk command is necessary
    # because at this stage, many strings appear twice in the changelist (a removal and an addition).
    # these are later combined into single lines for the final data file.
    SUMMARY="$PREFIX/$AMI/summary_en-US_from-${PREV_GLIBC_VERS}_to-${GLIBC_VERS}.txt"
    echo "" >$SUMMARY
    echo "# Unicode Block" >>$SUMMARY
    echo "#   Pattern ID (total count of distinct codepoints in diff output), Pattern ID (codepoints), ..." >>$SUMMARY
    echo "" >>$SUMMARY
    awk '{print$1" "$2" "$3}' $PREFIX/$AMI/changelist1.tmp|sort -u|perl -CSDA -e'
      use strict;
      use warnings;
      use utf8;
      my %bl;            # hash of unicode blocks, to count patterns within each block
      my %all_patterns;  # hash of patterns only, for total count of each pattern

      # open files first, so that any errors are surfaced quickly
      #   this will also cause existing patternfilter.tmp and blocks.tmp 
      #   to be clobbered/truncated
      open(BLOCKS,"<","Blocks.txt") or die ("Cannot open Blocks.txt");
      open(PF,">","patternfilter.tmp") or die ("Cannot open patternfilter.tmp");
      open(BL,">","blocks.tmp") or die ("Cannot open blocks.tmp");

      # read the unicode blocks into a variable for later lookups
      while(<BLOCKS>){
        # lines look like this:
        #   102E0..102FF; Coptic Epact Numbers
        # use beginning of range as hash key, because thats what data records
        # will contain. pad the keys with "0" so that a text sort orders them
        # nicely in the final report output. initialize an empty hash to contain
        # patterns that are encountered as the data file is processed.
        if(/^([0-9A-Z]*)[.][.]([0-9A-Z]*); (.*)/){
          my $padded_key="0"x(8-length($1)).$1;
          $bl{$padded_key}{"label"} = "$3 (U+$1..U+$2)";
          $bl{$padded_key}{"name"} = "$3";
          $bl{$padded_key}{"patterns"} = {};
        }
      }
      close BLOCKS;

      # main block; read each data record line from stdin and process fields,
      # using pre-initialized hash structures to count how many times each 
      # pattern is seen.
      while (<>) {
        my @F=split;
        my $padded_key="0"x(8-length($F[1])).$F[1];
        if(exists $bl{$padded_key}{"patterns"}{$F[2]}) {
          $bl{$padded_key}{"patterns"}{$F[2]}++;
        } else {
          $bl{$padded_key}{"patterns"}{$F[2]}=1;
        }

        if(exists $all_patterns{$F[2]}) {
          $all_patterns{$F[2]}++;
        } else {
          $all_patterns{$F[2]}=1;
        }
      }

      # create a file with patterns that are seen more than 20,000 times. this
      # is later used to filter most of these from the data file thats uploaded
      # to github.
      for(keys %all_patterns) {
          print PF $_." (".$all_patterns{$_}."x)\n" if $_ ne "S-199" && $all_patterns{$_}>20000;
      }
      close PF;

      # generate a pretty summary report by walking the hash structure and printing
      # data for any blocks that encountered at least one pattern.
      for my $block (sort keys %bl) {
        if(keys $bl{$block}{"patterns"}>0) {
          # while generating the report, also create a file (BL) with a list of 
          # unicode blocks that were encountered.
          print BL $bl{$block}{"name"}."\n";
          print $bl{$block}{"label"}."\n"."  ";
          my $first_pattern=1;
          for my $p (sort keys $bl{$block}{"patterns"}) {
            if($first_pattern) { $first_pattern=0; } else { print ", "; }
            print $p." (".$bl{$block}{"patterns"}{$p}."x)";
          }
          print "\n\n";
        }
      }
      close BL;
    ' >>$SUMMARY

    # string for count of changed blocks (includes markdown link to sumamry data)
    BLOCKCOUNT=$(cat blocks.tmp|wc -l)
    if (( BLOCKCOUNT > 10 )); then
      BLOCKCOUNT_STR="($BLOCKCOUNT blocks)"
    else
      BLOCKCOUNT_STR="$(cat blocks.tmp|awk '{s=(NR==1?s:s ", ")$0}END{print s}')"
    fi
    SUMMARY_STR="0"; (( BLOCKCOUNT > 0 )) && SUMMARY_STR="[$BLOCKCOUNT_STR]($SUMMARY)"

    # final master code point data file: uploaded to git
    CHANGELIST="$PREFIX/$AMI/changelist_en-US_from-${PREV_GLIBC_VERS}_to-${GLIBC_VERS}.txt"
    echo "">"${CHANGELIST}"

    if (( $(cat patternfilter.tmp|wc -l) > 0 )); then
      echo "# Filtering out patterns with more than 20,000 distinct codepoints to preserve version control sanity." >>"${CHANGELIST}"
      echo "#   Exceptions:"  >>"${CHANGELIST}"
      echo "#   - full data for Basic Latin and Latin-1 Supplement blocks, aka ASCII & ISO-8859-1" >>"${CHANGELIST}"
      echo "#   - full data for pattern S-199, aka single-character strings" >>"${CHANGELIST}"
      echo "# " >>"${CHANGELIST}"
      echo "# Filtered Pattern ID (total count of distinct codepoints in diff output), Pattern ID (codepoints), etc:" >>"${CHANGELIST}"
      echo "#   $(cat patternfilter.tmp|awk '{s=(NR==1?s:s ", ")$0}END{print s}') " >>"${CHANGELIST}"
      echo "" >>"${CHANGELIST}"
    fi

    # write headers (after listing code points that were removed)
    echo "# CodePoint UnicodeBlock PatternID String PositionChange" >>"${CHANGELIST}"

    sort -u $PREFIX/$AMI/changelist1.tmp|perl -CSDA -e'
      use strict;
      use warnings;
      use utf8;
      my %filter;
      my $prev_codepoint="z";
      my $prev_pattern="z";

      # read the patterns into an array that we want to filter out
      open(PF,"patternfilter.tmp");
      while(<PF>) {
        my @F=split;
        $filter{$F[0]}=0
      };

      my $first_line=1;
      LINE:
      while (<>) {
        chomp;
        my @F=split;
        if( $F[1] eq "0000" || $F[1] eq "0080" || ! exists $filter{$F[2]} ) {
          if( $F[0] ne $prev_codepoint || $F[2] ne $prev_pattern ) {
            if($first_line) { $first_line=0; } else { print "\n"; }
            print;
            $prev_codepoint=$F[0]; $prev_pattern=$F[2];
          } else {
            print ":".$F[-1];
          }
        }
      }
      print "\n";
    ' >>"${CHANGELIST}"

    CHANGECOUNT=$(awk '{print$1}' $PREFIX/$AMI/changelist1.tmp|sort -u|wc -l)

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
    CHANGELIST_SIZE=$(stat --printf="%s" $CHANGELIST)
    if (( CHANGELIST_SIZE > 40000000 )); then
      mv $CHANGELIST changelist2.tmp
      echo "File size $CHANGELIST_SIZE too large - truncating at 40MB to preserve version control sanity" >$CHANGELIST
      echo "" >>$CHANGELIST
      head -c40000000 changelist2.tmp >>$CHANGELIST
      rm changelist2.tmp
    fi
    # upload a copy of the diff to git, unless it's bigger than 50GB
    #   (using a copy so that the original can be left as a local working file)
    SORTDIFF="$PREFIX/$AMI/diff_en-US_from-${PREV_GLIBC_VERS}_to-${GLIBC_VERS}.txt"
    cp $PREFIX/$AMI/diff.tmp $SORTDIFF
    SORTDIFF_SIZE=$(stat --printf="%s" $SORTDIFF)
    if (( SORTDIFF_SIZE > 40000000 )); then
      echo "File size $SORTDIFF_SIZE too large - truncating at 40MB to preserve version control sanity" >$SORTDIFF
      echo "" >>$SORTDIFF
      head -c40000000 $PREFIX/$AMI/diff.tmp >>$SORTDIFF
    fi
  fi
  echo "| $GLIBC_VERS | $SUMMARY_STR | $CHANGECOUNT_STR | $LC_CHANGECOUNT_STR | $(paste -sd, langs.tmp) | $LOCALE_COUNT | $OS_VERS | [$AMI]($PREFIX/$AMI) |"
  PREV_AMI="$AMI"
  PREV_GLIBC_VERS="$GLIBC_VERS"
done 

# cleanup
rm patternfilter.tmp
rm langs.tmp
rm blocks.tmp
rm Blocks.txt

done
date
