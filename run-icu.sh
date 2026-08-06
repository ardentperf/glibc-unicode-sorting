# run-icu.sh - worker script to generate sorted list of unicode strings
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
# The script expects PostgreSQL v10 or newer to be installed and running
# under the user "postgres". It has been tested only with default
# installs from the official PGDG apt respositories and Ubuntu (including
# apt-archive.postgresql.org for historical ubuntu distributions). The
# "postgres" user should be able to run psql and connect directly
# without needing to enter a password.
#
# This script is entirely self-contained so that it can be easily cut 
# and pasted to any system and then it can be executed to generate a 
# sorted file directly on that system.
#
# The script generates two outputs. First (and most important) is a file 
# named unicode-${UNICODE_VERS}-chars-sorted-icu-${ICU_VERS}.txt which
# contains the sorted list of strings. Second, the direct "stdout" of the
# script is intended to be captured. This will show additional diagnostics
# information, like the output of dpkg and rpm queries, execution timestamps, 
# the version of the operating system, the AMI used (if applicable), etc.
#
set -x -e
test_started="$(date +%s)"
libc_version="$(dpkg-query -W -f='${Version}' libc6 2>/dev/null || true)"
icu_version="$(dpkg-query -W -f='${Version}' libicu-dev 2>/dev/null || true)"

# make sure that locale is set to en_US (utf8)
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

date
echo "libc_version=${libc_version} icu_version=${icu_version} test_runtime_seconds=$(( $(date +%s) - test_started ))"

# print information about the system to stdout
cd $(dirname $0)
pwd
which dpkg && dpkg -l libicu* postgresql*
SOURCE_AMI=$(curl -s http://169.254.169.254/latest/meta-data/ami-id)
OS_VERS=$(cat /etc/issue)
which dpkg && ICU_VERS="$(dpkg -l libicu*|awk '/^ii  libicu/{print$3}')"
[ -f /etc/os-release ] && cat /etc/os-release
[ -f /etc/system-release ] && cat /etc/system-release
[ -f /etc/system-release-cpe ] && cat /etc/system-release-cpe

# directly download unicode spec, will use this to generate all legal code points
UNICODE_VERS="15"
curl -ks "https://www.unicode.org/Public/${UNICODE_VERS}.0.0/ucd/UnicodeData.txt" | cut -d';' -f1-3 > "$PWD/UnicodeData.txt"
chmod 644 "$PWD/UnicodeData.txt"

# this psql program will read the unicode spec source and use it to output each
# legal code point. for each code point, we output all the strings specified
# in the main README. 
# 
# we use a function instead of a procedure to work around a postgresql bug (commit 
# a6b1f536) where there's a memory leak with calling procedures from a DO block.
# workaround enables testing on older distributions like ubuntu 14.04 and 19.04
# where latest PostgreSQL minors are not available in the package archives.
#
# IMPORTANT: make sure to keep this block in sync with README and table.sh
#
sudo su - postgres -c "psql -v ON_ERROR_STOP=on -v UNICODE_VERS=${UNICODE_VERS} -v ICU_VERS=${ICU_VERS} -v UNICODE_FILE=$PWD/UnicodeData.txt -f $PWD/unicode-sorting.sql"

sudo su - postgres -c "psql -v ON_ERROR_STOP=on -v UNICODE_VERS=${UNICODE_VERS} -v ICU_VERS=${ICU_VERS}" <<EOF

\\timing

set work_mem="100MB";

copy (select * from unicode_data order by d1 collate "en-US-x-icu") to '/tmp/unicode-${UNICODE_VERS}-chars-sorted-icu-${ICU_VERS}-en.txt' with (format text);
copy (select * from unicode_data order by d1 collate "zh-Hans-CN-x-icu") to '/tmp/unicode-${UNICODE_VERS}-chars-sorted-icu-${ICU_VERS}-zh.txt' with (format text);
copy (select * from unicode_data order by d1 collate "ja-JP-x-icu") to '/tmp/unicode-${UNICODE_VERS}-chars-sorted-icu-${ICU_VERS}-ja.txt' with (format text);
copy (select * from unicode_data order by d1 collate "fr-FR-x-icu") to '/tmp/unicode-${UNICODE_VERS}-chars-sorted-icu-${ICU_VERS}-fr.txt' with (format text);
copy (select * from unicode_data order by d1 collate "ru-RU-x-icu") to '/tmp/unicode-${UNICODE_VERS}-chars-sorted-icu-${ICU_VERS}-ru.txt' with (format text);
copy (select * from unicode_data order by d1 collate "de-DE-x-icu") to '/tmp/unicode-${UNICODE_VERS}-chars-sorted-icu-${ICU_VERS}-de.txt' with (format text);
copy (select * from unicode_data order by d1 collate "es-ES-x-icu") to '/tmp/unicode-${UNICODE_VERS}-chars-sorted-icu-${ICU_VERS}-es.txt' with (format text);

EOF

# write file sizes and final count of strings (lines) to stdout, can crosscheck w earlier count
ls -ltr /tmp/unicode-*
wc /tmp/unicode-${UNICODE_VERS}-chars-sorted-icu-${ICU_VERS}*

cp -v /tmp/unicode-${UNICODE_VERS}-chars-sorted-icu-${ICU_VERS}* $PWD/

date
