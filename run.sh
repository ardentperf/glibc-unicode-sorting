# run.sh - worker script to generate sorted list of unicode strings
#
# This script is written to be compatible with very old Linux 
# distributions, both RHEL and Ubuntu, as well as the latest 
# available versions.  This requires significant care around what 
# features of bash and perl are used in the script.  This script 
# has been tested with RHEL5 using bash v3.2.25 and perl v5.8.8
#
# The script requires internet access because it downloads the Unicode
# spec directly from unicode.org which is then used to generate every
# valid code point. For each code point, a large number of carefully
# built strings are generated. See the main README for more information
# about this.
#
# This script is entirely self-contained so that it can be easily cut 
# and pasted to any system and then it can be executed to generate a 
# sorted file directly on that system.
#
# The script generates two outputs. First (and most important) is a file 
# named unicode-${UNICODE_VERS}-chars-sorted-glibc-${GLIBC_VERS}.txt which
# contains the sorted list of strings. Second, the direct "stdout" of the
# script is intended to be captured. This will show additional diagnostics
# information, like the output of dpkg and rpm queries, execution timestamps, 
# the version of the operating system, the AMI used (if applicable), etc.
#
set -x -e

# make sure that locale is set to en_US (utf8)
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

date

# print information about the system to stdout
cd $(dirname $0)
pwd
which dpkg && dpkg -l libc6 locales
which rpm && rpm -qa|grep -E '(glibc|langpack)'
SOURCE_AMI=$(curl -s http://169.254.169.254/latest/meta-data/ami-id)
[ -z "$SOURCE_AMI" ] && SOURCE_AMI=$(TOKEN=`curl -sX PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` && curl -sH "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/ami-id)
OS_VERS=$(cat /etc/issue)
which dpkg && GLIBC_VERS="$(dpkg -l libc6|awk '/libc6/{print$3}')"
which rpm && GLIBC_VERS="$(rpm -q glibc --queryformat '%{version}-%{release}')"
[ -f /etc/os-release ] && cat /etc/os-release
[ -f /etc/system-release ] && cat /etc/system-release
[ -f /etc/system-release-cpe ] && cat /etc/system-release-cpe

# directly download unicode spec, will use this to generate all legal code points
UNICODE_VERS="14"
time curl -kO https://www.unicode.org/Public/${UNICODE_VERS}.0.0/ucd/UnicodeData.txt

# this perl program will read the unicode spec source and use it to output each
# legal code point. for each code point, we output all the strings specified
# in the main README. note that the output is split into multiple files of 500k
# strings each. those files can be sorted in parallel to leverage multiple CPUs for
# increased performance.
#
# IMPORTANT: make sure to keep this block in sync with README and table.sh
#
time perl -naF';' -CO -e'
  use utf8;
  sub pr {
    print chr($_[0]) . "\n";  # 199

    print chr($_[0]) . "B\n";              # 200
    print chr($_[0]) . "O\n";              # 201
    print chr($_[0]) . "3\n";              # 202
    print chr($_[0]) . ".\n";              # 203
    print chr($_[0]) . " \n";              # 204
    print chr($_[0]) . "様\n";              # 205
    print chr($_[0]) . "ク\n";              # 206
    print "B" . chr($_[0]) . "\n";         # 210
    print "O" . chr($_[0]) . "\n";         # 211
    print "3" . chr($_[0]) . "\n";         # 212
    print "." . chr($_[0]) . "\n";         # 213
    print " " . chr($_[0]) . "\n";         # 214
    print "様" . chr($_[0]) . "\n";         # 215
    print "ク" . chr($_[0]) . "\n";         # 216
    print chr($_[0]) . chr($_[0]) . "\n";  # 299

    print chr($_[0]) . "BB\n";                          # 300
    print chr($_[0]) . "OO\n";                          # 301
    print chr($_[0]) . "33\n";                          # 302
    print chr($_[0]) . "..\n";                          # 303
    print chr($_[0]) . "  \n";                          # 304
    print chr($_[0]) . "様様\n";                          # 305
    print chr($_[0]) . "クク\n";                          # 306
    print "B" . chr($_[0]) . "B\n";                     # 310
    print "O" . chr($_[0]) . "O\n";                     # 311
    print "3" . chr($_[0]) . "3\n";                     # 312
    print "." . chr($_[0]) . ".\n";                     # 313
    print " " . chr($_[0]) . " \n";                     # 314
    print "様" . chr($_[0]) . "様\n";                     # 315
    print "ク" . chr($_[0]) . "ク\n";                     # 316
    print "BB" . chr($_[0]) . "\n";                     # 320
    print "OO" . chr($_[0]) . "\n";                     # 321
    print "33" . chr($_[0]) . "\n";                     # 322
    print ".." . chr($_[0]) . "\n";                     # 323
    print "  " . chr($_[0]) . "\n";                     # 324
    print "様様" . chr($_[0]) . "\n";                     # 325
    print "クク" . chr($_[0]) . "\n";                     # 326
    print chr($_[0]) . chr($_[0]) . "B\n";              # 330
    print chr($_[0]) . chr($_[0]) . "O\n";              # 331
    print chr($_[0]) . chr($_[0]) . "3\n";              # 332
    print chr($_[0]) . chr($_[0]) . ".\n";              # 333
    print chr($_[0]) . chr($_[0]) . " \n";              # 334
    print chr($_[0]) . chr($_[0]) . "様\n";              # 335
    print chr($_[0]) . chr($_[0]) . "ク\n";              # 336
    print chr($_[0]) . "B" . chr($_[0]) . "\n";         # 340
    print chr($_[0]) . "O" . chr($_[0]) . "\n";         # 341
    print chr($_[0]) . "3" . chr($_[0]) . "\n";         # 342
    print chr($_[0]) . "." . chr($_[0]) . "\n";         # 343
    print chr($_[0]) . " " . chr($_[0]) . "\n";         # 344
    print chr($_[0]) . "様" . chr($_[0]) . "\n";         # 345
    print chr($_[0]) . "ク" . chr($_[0]) . "\n";         # 346
    print "B" . chr($_[0]) . chr($_[0]) . "\n";         # 350
    print "O" . chr($_[0]) . chr($_[0]) . "\n";         # 351
    print "3" . chr($_[0]) . chr($_[0]) . "\n";         # 352
    print "." . chr($_[0]) . chr($_[0]) . "\n";         # 353
    print " " . chr($_[0]) . chr($_[0]) . "\n";         # 354
    print "様" . chr($_[0]) . chr($_[0]) . "\n";         # 355
    print "ク" . chr($_[0]) . chr($_[0]) . "\n";         # 356
    print "3B" . chr($_[0]) . "\n";                     # 380
    print chr($_[0]) . chr($_[0]) . chr($_[0]) . "\n";  # 399

    print chr($_[0]) . chr($_[0]) . "BB\n";       # 400
    print chr($_[0]) . chr($_[0]) . "OO\n";       # 401
    print chr($_[0]) . chr($_[0]) . "33\n";       # 402
    print chr($_[0]) . chr($_[0]) . "..\n";       # 403
    print chr($_[0]) . chr($_[0]) . "  \n";       # 404
    print chr($_[0]) . chr($_[0]) . "様様\n";       # 405
    print chr($_[0]) . chr($_[0]) . "クク\n";       # 406
    print "B" . chr($_[0]) . chr($_[0]) . "B\n";  # 410
    print "O" . chr($_[0]) . chr($_[0]) . "O\n";  # 411
    print "3" . chr($_[0]) . chr($_[0]) . "3\n";  # 412
    print "." . chr($_[0]) . chr($_[0]) . ".\n";  # 413
    print " " . chr($_[0]) . chr($_[0]) . " \n";  # 414
    print "様" . chr($_[0]) . chr($_[0]) . "様\n";  # 415
    print "ク" . chr($_[0]) . chr($_[0]) . "ク\n";  # 416
    print "BB" . chr($_[0]) . chr($_[0]) . "\n";  # 420
    print "OO" . chr($_[0]) . chr($_[0]) . "\n";  # 421
    print "33" . chr($_[0]) . chr($_[0]) . "\n";  # 422
    print ".." . chr($_[0]) . chr($_[0]) . "\n";  # 423
    print "  " . chr($_[0]) . chr($_[0]) . "\n";  # 424
    print "様様" . chr($_[0]) . chr($_[0]) . "\n";  # 425
    print "クク" . chr($_[0]) . chr($_[0]) . "\n";  # 426
    print "3B" . chr($_[0]) . "B\n";                     # 480
    print "3B-" . chr($_[0]) . "\n";                     # 481
    print chr($_[0]) . chr($_[0]) . chr($_[0]) . chr($_[0]) . "\n";  # 499

    print "BB" . chr($_[0]) . chr($_[0]) . "\t\n";   # 580
    print "\tBB" . chr($_[0]) . chr($_[0]) . "\n";   # 581
    print "BB-" . chr($_[0]) . chr($_[0]) . "\n";    # 582
    print "🙂👍" . chr($_[0]) . "❤™\n";                # 583
    print chr($_[0]) . chr($_[0]) . ".33\n";         # 584
    print "3B-" . chr($_[0]) . "B\n";                # 585
    print chr($_[0]) . chr($_[0]) . chr($_[0]) . chr($_[0]) . chr($_[0]) . "\n";  # 599
  }
  if(/<control>/){next}; # skip control characters
  if($F[2] eq "Cs"){next}; # skip surrogates
  if(/ First>/){$fi=hex("0x".$F[0]);next}; # generate blocks
  if(/ Last>/){$la=hex("0x".$F[0]);for($fi..$la){pr($_)};next};
  pr(hex("0x".$F[0])) # generate individual characters
' UnicodeData.txt |split -l500000 - _base-characters

# write counts of strings (lines) to stdout
wc _base-characters*

# write locale to stdout, so that we have proof it was correct
locale

# this logic (which sorts files in parallel and waits for all to complete) was written 
# to be backwards-compatible to bash 3.2.25
date
for FILE in $(ls -1 _base-characters*); do sort $FILE -o _s$FILE & done; jobs; wait
date

# note that "sort -m" expects the input files to all be pre-sorted
time sort -m _s_base-characters* -o unicode-${UNICODE_VERS}-chars-sorted-glibc-${GLIBC_VERS}.txt

# cleanup
rm -v _base-characters* _s_base-characters* UnicodeData.txt

# write file sizes and final count of strings (lines) to stdout, can crosscheck w earlier count
ls -ltr
wc unicode-${UNICODE_VERS}-chars-sorted-glibc-${GLIBC_VERS}.txt

# the simple test that started it all; might as well run it and write to stdout
# cf. https://wiki.postgresql.org/wiki/Locale_data_changes
( echo "1-1"; echo "11" ) | LC_COLLATE=en_US.UTF-8 sort

date
