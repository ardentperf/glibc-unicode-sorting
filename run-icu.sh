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

# make sure that locale is set to en_US (utf8)
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

date

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
sudo su - postgres -c "psql -v ON_ERROR_STOP=on" <<EOF

\\timing

drop table if exists unicode_spec;
create table unicode_spec(f1 text,f2 text,f3 text);

copy unicode_spec from program 'curl -ks https://www.unicode.org/Public/${UNICODE_VERS}.0.0/ucd/UnicodeData.txt|cut -d\\; -f1-3' with (delimiter ';');

drop table if exists unicode_data;
create table unicode_data(d1 text);

create or replace function insert_codepoint(cp int) returns int as \$\$
  begin
    insert into unicode_data values( chr(cp) );   -- 199

    insert into unicode_data values( chr(cp)||'B' );   -- 200
    insert into unicode_data values( chr(cp)||'O' );   -- 201
    insert into unicode_data values( chr(cp)||'3' );   -- 202
    insert into unicode_data values( chr(cp)||'.' );   -- 203
    insert into unicode_data values( chr(cp)||' ' );   -- 204
    insert into unicode_data values( chr(cp)||'様' );   -- 205
    insert into unicode_data values( chr(cp)||'ク' );   -- 206
    insert into unicode_data values( 'B'||chr(cp) );   -- 210
    insert into unicode_data values( 'O'||chr(cp) );   -- 211
    insert into unicode_data values( '3'||chr(cp) );   -- 212
    insert into unicode_data values( '.'||chr(cp) );   -- 213
    insert into unicode_data values( ' '||chr(cp) );   -- 214
    insert into unicode_data values( '様'||chr(cp) );   -- 215
    insert into unicode_data values( 'ク'||chr(cp) );   -- 216
    insert into unicode_data values( chr(cp)||chr(cp) );   -- 299

    insert into unicode_data values( chr(cp)||'BB' );   -- 300
    insert into unicode_data values( chr(cp)||'OO' );   -- 301
    insert into unicode_data values( chr(cp)||'33' );   -- 302
    insert into unicode_data values( chr(cp)||'..' );   -- 303
    insert into unicode_data values( chr(cp)||'  ' );   -- 304
    insert into unicode_data values( chr(cp)||'様様' );   -- 305
    insert into unicode_data values( chr(cp)||'クク' );   -- 306
    insert into unicode_data values( 'B'||chr(cp)||'B' );   -- 310
    insert into unicode_data values( 'O'||chr(cp)||'O' );   -- 311
    insert into unicode_data values( '3'||chr(cp)||'3' );   -- 312
    insert into unicode_data values( '.'||chr(cp)||'.' );   -- 313
    insert into unicode_data values( ' '||chr(cp)||' ' );   -- 314
    insert into unicode_data values( '様'||chr(cp)||'様' );   -- 315
    insert into unicode_data values( 'ク'||chr(cp)||'ク' );   -- 316
    insert into unicode_data values( 'BB'||chr(cp) );   -- 320
    insert into unicode_data values( 'OO'||chr(cp) );   -- 321
    insert into unicode_data values( '33'||chr(cp) );   -- 322
    insert into unicode_data values( '..'||chr(cp) );   -- 323
    insert into unicode_data values( '  '||chr(cp) );   -- 324
    insert into unicode_data values( '様様'||chr(cp) );   -- 325
    insert into unicode_data values( 'クク'||chr(cp) );   -- 326
    insert into unicode_data values( chr(cp)||chr(cp)||'B' );   -- 330
    insert into unicode_data values( chr(cp)||chr(cp)||'O' );   -- 331
    insert into unicode_data values( chr(cp)||chr(cp)||'3' );   -- 332
    insert into unicode_data values( chr(cp)||chr(cp)||'.' );   -- 333
    insert into unicode_data values( chr(cp)||chr(cp)||' ' );   -- 334
    insert into unicode_data values( chr(cp)||chr(cp)||'様' );   -- 335
    insert into unicode_data values( chr(cp)||chr(cp)||'ク' );   -- 336
    insert into unicode_data values( chr(cp)||'B'||chr(cp) );   -- 340
    insert into unicode_data values( chr(cp)||'O'||chr(cp) );   -- 341
    insert into unicode_data values( chr(cp)||'3'||chr(cp) );   -- 342
    insert into unicode_data values( chr(cp)||'.'||chr(cp) );   -- 343
    insert into unicode_data values( chr(cp)||' '||chr(cp) );   -- 344
    insert into unicode_data values( chr(cp)||'様'||chr(cp) );   -- 345
    insert into unicode_data values( chr(cp)||'ク'||chr(cp) );   -- 346
    insert into unicode_data values( 'B'||chr(cp)||chr(cp) );   -- 350
    insert into unicode_data values( 'O'||chr(cp)||chr(cp) );   -- 351
    insert into unicode_data values( '3'||chr(cp)||chr(cp) );   -- 352
    insert into unicode_data values( '.'||chr(cp)||chr(cp) );   -- 353
    insert into unicode_data values( ' '||chr(cp)||chr(cp) );   -- 354
    insert into unicode_data values( '様'||chr(cp)||chr(cp) );   -- 355
    insert into unicode_data values( 'ク'||chr(cp)||chr(cp) );   -- 356
    insert into unicode_data values( '3B'||chr(cp) );   -- 380
    insert into unicode_data values( chr(cp)||chr(cp)||chr(cp) );   -- 399

    insert into unicode_data values( chr(cp)||chr(cp)||'BB' );   -- 400
    insert into unicode_data values( chr(cp)||chr(cp)||'OO' );   -- 401
    insert into unicode_data values( chr(cp)||chr(cp)||'33' );   -- 402
    insert into unicode_data values( chr(cp)||chr(cp)||'..' );   -- 403
    insert into unicode_data values( chr(cp)||chr(cp)||'  ' );   -- 404
    insert into unicode_data values( chr(cp)||chr(cp)||'様様' );   -- 405
    insert into unicode_data values( chr(cp)||chr(cp)||'クク' );   -- 406
    insert into unicode_data values( 'B'||chr(cp)||chr(cp)||'B' );   -- 410
    insert into unicode_data values( 'O'||chr(cp)||chr(cp)||'O' );   -- 411
    insert into unicode_data values( '3'||chr(cp)||chr(cp)||'3' );   -- 412
    insert into unicode_data values( '.'||chr(cp)||chr(cp)||'.' );   -- 413
    insert into unicode_data values( ' '||chr(cp)||chr(cp)||' ' );   -- 414
    insert into unicode_data values( '様'||chr(cp)||chr(cp)||'様' );   -- 415
    insert into unicode_data values( 'ク'||chr(cp)||chr(cp)||'ク' );   -- 416
    insert into unicode_data values( 'BB'||chr(cp)||chr(cp) );   -- 420
    insert into unicode_data values( 'OO'||chr(cp)||chr(cp) );   -- 421
    insert into unicode_data values( '33'||chr(cp)||chr(cp) );   -- 422
    insert into unicode_data values( '..'||chr(cp)||chr(cp) );   -- 423
    insert into unicode_data values( '  '||chr(cp)||chr(cp) );   -- 424
    insert into unicode_data values( '様様'||chr(cp)||chr(cp) );   -- 425
    insert into unicode_data values( 'クク'||chr(cp)||chr(cp) );   -- 426
    insert into unicode_data values( '3B'||chr(cp)||'B' );   -- 480
    insert into unicode_data values( '3B-'||chr(cp) );   -- 481
    insert into unicode_data values( chr(cp)||chr(cp)||chr(cp)||chr(cp) );   -- 499

    insert into unicode_data values( 'BB'||chr(cp)||chr(cp)||'' );   -- 580
    insert into unicode_data values( 'BB'||chr(cp)||chr(cp) );   -- 581
    insert into unicode_data values( 'BB-'||chr(cp)||chr(cp) );   -- 582
    insert into unicode_data values( '🙂👍'||chr(cp)||'❤™' );   -- 583
    insert into unicode_data values( chr(cp)||chr(cp)||'.33' );   -- 584
    insert into unicode_data values( '3B-'||chr(cp)||'B' );   -- 585
    insert into unicode_data values( chr(cp)||chr(cp)||chr(cp)||chr(cp)||chr(cp) );   -- 599

    return null;
  end;
\$\$ language plpgsql;

do \$\$
  declare
    t1 text; t2 text; t3 text;
    first int; last int;
  begin
    for t1,t2,t3 in select * from unicode_spec loop
      continue when t2='<control>';
      continue when t3='Cs';
      if t2 like '% First>' then first=('x'||lpad(t1, 8, '0'))::bit(32)::int; continue; end if;
      if t2 like '% Last>' then
        last=('x'||lpad(t1, 8, '0'))::bit(32)::int;
        for i in first..last loop perform insert_codepoint(i); end loop;
        continue;
      end if;
      perform insert_codepoint(('x'||lpad(t1, 8, '0'))::bit(32)::int);
    end loop;
  end;
\$\$;

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
