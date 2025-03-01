# diff.sh - utility script to compare sorted lists from many systems using unix diff
#
# After using the test-host script to generate sorted lists on many remote systems and download
# results from all of those remote systems, this script will iterate through all the downloaded
# lists (ordered by glibc version) and generate a DIFF of the sorted lists. 
#
# NOTE: keep this script in sync with table.sh
#
# usage: sh diff.sh [ubuntu|rhel|ubuntu-icu]
#
type git sort awk uniq grep paste wc tr cut >/dev/null || exit 2
set -x -e

# make sure the unicode version here matches the "run.sh" script
UNICODE_VERS="14"

date
for PREFIX in _ubuntu _rhel _ubuntu-icu; do
[ -n "$1" ] && [ "_$1" != "$PREFIX" ] && continue

# IMPORTANT: KEEP IN SYNC WITH "table.sh"
#   this logic is tricky, reference that file for more extensive comments/explanation
case $PREFIX in
  _ubuntu)
    SORTED_AMI_LIST="$(grep -E '(GLIBC_VERS|OS_VERS)' $PREFIX/*/run.out|sed 's.[/=].  .g;s.[\r\]..g;s.LTS..'|paste -d" " - -|sort -k13 -k6 -V|awk '{print$2}')"
    ;;
  _ubuntu-icu)
    SORTED_AMI_LIST="$(grep -E '(ICU_VERS|OS_VERS)' $PREFIX/*/run.out|sed 's.[/=].  .g;s.[\r\]..g;s.LTS..'|paste -d" " - -|sort -k13 -k6 -V|awk '{print$2}')"
    ;;
  _rhel)
    SORTED_AMI_LIST="$(grep GLIBC_VERS $PREFIX/*/run.out|sed 's.[/=].  .g'|sort -k5 -V|awk '{print$2}')"
    ;;
esac
for AMI in $(echo "$SORTED_AMI_LIST")
do
  GLIBC_VERS=$(grep GLIBC_VERS $PREFIX/$AMI/run.out|tr -d '\r'|cut -d= -f2)
  ICU_VERS=$(grep ICU_VERS $PREFIX/$AMI/run.out|tr -d '\r'|cut -d= -f2)
  if [ -n "$PREV_AMI" ]; then
    # run "diff" to compare sorted word lists from previous system and this system. everything else is based on this.
    #
    # standard unix "diff" command uses the classic Myers algorithm. this works if the changeset is very small but
    # unfortunately a large changeset produced by this particular test suite will break the algorithm. when this was 
    # used to compare sorted lists from glibc 2.27 and glibc 2.28, the diff command ran at 100% CPU for 4 days before 
    # we gave up waiting. This was true with default flags and also with "--speed-large-files" flag. an easy way to 
    # get access to a different algorithm was to leverage git. it's "histogram" algorithm completed the glibc 2.27 
    # and 2.28 comparison in about 26 minutes.
    date
    case $PREFIX in
      _ubuntu|_rhel)
        time git diff --no-index --diff-algorithm=histogram \
            $PREFIX/$PREV_AMI/unicode-${UNICODE_VERS}-chars-sorted-glibc-${PREV_GLIBC_VERS}.txt \
            $PREFIX/$AMI/unicode-${UNICODE_VERS}-chars-sorted-glibc-${GLIBC_VERS}.txt \
            > $PREFIX/$AMI/diff.tmp || true
        ;;
      _ubuntu-icu)
        for MYLANG in en zh ja fr ru de es; do
          mkdir -v $PREFIX/$AMI/$MYLANG
          time git diff --no-index --diff-algorithm=histogram \
              $PREFIX/$PREV_AMI/unicode-${UNICODE_VERS}-chars-sorted-icu-${PREV_ICU_VERS}-${MYLANG}.txt \
              $PREFIX/$AMI/unicode-${UNICODE_VERS}-chars-sorted-icu-${ICU_VERS}-${MYLANG}.txt \
              > $PREFIX/$AMI/$MYLANG/diff.tmp || true
        done
        ;;
    esac
  fi  
  PREV_AMI="$AMI"
  PREV_GLIBC_VERS="$GLIBC_VERS"
  PREV_ICU_VERS="$ICU_VERS"
done

done
date
