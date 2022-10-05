# filter.sh - utility script to filter (or un-filter) strings in the already-sorted lists
#
# This is an extra, optional script. After using the test-host script to generate sorted lists 
# on many remote systems and download results from all of those remote systems, this script will 
# iterate through all the downloaded lists (ordered by glibc version) and filter them to a
# subset of the initial strings, or restore the full list.
#
# after running this script, be sure to re-execute diff.sh
#
# usage: sh filter.sh [iso88591|all] [ubuntu|rhel]
#
case $1 in (iso88591|all) ;; (*) echo "ERROR: first parameter must be a recognized character filter" && exit 1 ;; esac

type git sort awk uniq grep paste wc tr cut >/dev/null || exit 2
set -x -e

date
for PREFIX in _ubuntu _rhel; do
[ -n "$2" ] && [ "_$2" != "$PREFIX" ] && continue

# IMPORTANT: KEEP IN SYNC WITH "table.sh"
#   this logic is tricky, reference that file for more extensive comments/explanation
for SFILE in $PREFIX/ami-*/unicode-*-chars-sorted-glibc-*.txt
do
  # create a master copy of original that can be used later to restore all strings unfiltered
  [ -f $SFILE.orig ] || time cp $SFILE $SFILE.orig

  # use the master copy to create a filtered (or unfiltered) file
  case $1 in
    all)
      # copy unfiltered file
      time cp $SFILE.orig $SFILE
      ;;
    iso88591)
      # the first 256 code points of unicode are the ISO-8859-1 characters
      time perl -CSDA -ne'foreach $c (split //) {if(ord($c)>256){goto LINE}};print' $SFILE.orig >$SFILE
      wc $SFILE
      ;;
  esac
done

done
date
