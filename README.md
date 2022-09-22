
# Collation Changes Across Linux Versions

## Methodology

There are two aspects to this analysis: comparing the results of actual sorts in
en_US locale, and comparing the LC_COLLATE section of the Operating System
locale data files.

Comparing the results of actual sorts should catch any changes to default
sorting which is not defined in the OS collation data. A simple perl script is
used to generate a text file containing 91 different strings for every legal
unicode character. The unix "sort" utility processes this file with the locale
configured to en_US for collation. This process is repeated on each
release from the past 10 years, and then the unix "diff" utility is used to
compare the sorted output files and count how many characters have different
positions after sorting. The results show how many individual code points have
changed positions in the sorted data across different Operating System releases
and which Unicode Blocks contain the changed code points.

The Operating System locale data files from `/usr/share/i18n/locales` are
compared directly. The results show the total number of lines in the data files
that are changed, and which locales contain the changes.


## Results

### Ubuntu

*Note: Generated with an older version of scripts; not yet updated. This Ubuntu table may be missing some changes.*

| GLIBC Version | Total Detected en_US Sort Order Changes | Unicode Blocks of Detected en_US Sort Order Changes | Total Detected Collation Data File Changes | Locales of Detected Data File Changes | Operating System  | AMI | 
| ---- | ---- | ---- | ----  | ---- | ---- | ---- |
| 2.11.1-0ubuntu7.10 |  |  |  |  | Ubuntu 10.04.4 LTS  | [ami-0baf7662](_ubuntu/ami-0baf7662) |
| 2.12.1-0ubuntu10.4 | 0 |  | [1987](_ubuntu/ami-c412cead/changelist_locales_from-2.11.1-0ubuntu7.10_to-2.12.1-0ubuntu10.4.txt) |  et_EE | Ubuntu 10.10  | [ami-c412cead](_ubuntu/ami-c412cead) |
| 2.13-0ubuntu13.1 | 0 |  | 0 |  | Ubuntu 11.04  | [ami-6d9f3604](_ubuntu/ami-6d9f3604) |
| 2.13-20ubuntu5.1 | [107](_ubuntu/ami-4fad7426/changelist_en-US_from-2.13-0ubuntu13.1_to-2.13-20ubuntu5.1.txt) |     107 Tibetan | [2578](_ubuntu/ami-4fad7426/changelist_locales_from-2.13-0ubuntu13.1_to-2.13-20ubuntu5.1.txt) |  dz_BT, iso14651_t1_common, se_NO | Ubuntu 11.10  | [ami-4fad7426](_ubuntu/ami-4fad7426) |
| 2.15-0ubuntu10.18 | 0 |  | [245](_ubuntu/ami-024a2614/changelist_locales_from-2.13-20ubuntu5.1_to-2.15-0ubuntu10.18.txt) |  hu_HU, ug_CN | Ubuntu 12.04.5 LTS  | [ami-024a2614](_ubuntu/ami-024a2614) |
| 2.15-0ubuntu20 | 0 |  | 0 |  | Ubuntu 12.10  | [ami-02df496b](_ubuntu/ami-02df496b) |
| 2.17-0ubuntu5 | 0 |  | 0 |  la_AU (removed), tlh_GB (removed) | Ubuntu 13.04  | [ami-12314d7b](_ubuntu/ami-12314d7b) |
| 2.17-93ubuntu4 | 0 |  | 0 |  | Ubuntu 13.10  | [ami-137e4f7a](_ubuntu/ami-137e4f7a) |
| 2.19-0ubuntu6.15 | 0 |  | 0 |  | Ubuntu 14.04.6 LTS  | [ami-000b3a073fc20e415](_ubuntu/ami-000b3a073fc20e415) |
| 2.19-10ubuntu2 | 0 |  | 0 |  | Ubuntu 14.10  | [ami-12a3247a](_ubuntu/ami-12a3247a) |
| 2.21-0ubuntu4 | [204](_ubuntu/ami-04a6816e/changelist_en-US_from-2.19-10ubuntu2_to-2.21-0ubuntu4.txt) |      37 Arabic,      2 Bengali,      6 Georgian,     34 Arabic Presentation Forms-A,    125 Arabic Presentation Forms-B | 0 |  | Ubuntu 15.04  | [ami-04a6816e](_ubuntu/ami-04a6816e) |
| 2.21-0ubuntu4 | 0 |  | 0 |  | Ubuntu 15.10  | [ami-002f0f6a](_ubuntu/ami-002f0f6a) |
| 2.23-0ubuntu11.3 | 0 |  | [4081](_ubuntu/ami-0b0ea68c435eb488d/changelist_locales_from-2.21-0ubuntu4_to-2.23-0ubuntu11.3.txt) |  cs_CZ, es_US, et_EE, fil_PH, gd_GB, ha_NG, hsb_DE, mr_IN, sv_SE, ug_CN, uk_UA, ia (removed) | Ubuntu 16.04.7 LTS  | [ami-0b0ea68c435eb488d](_ubuntu/ami-0b0ea68c435eb488d) |
| 2.24-3ubuntu2.2 | 0 |  | [392728](_ubuntu/ami-055d7213/changelist_locales_from-2.23-0ubuntu11.3_to-2.24-3ubuntu2.2.txt) |  C, eo, kk_KZ, ln_CD, iw_IL (removed), pap_AN (removed) | Ubuntu 16.10  | [ami-055d7213](_ubuntu/ami-055d7213) |
| 2.24-9ubuntu2.2 | 0 |  | [33](_ubuntu/ami-10d4f76b/changelist_locales_from-2.24-3ubuntu2.2_to-2.24-9ubuntu2.2.txt) |  C | Ubuntu 17.04  | [ami-10d4f76b](_ubuntu/ami-10d4f76b) |
| 2.26-0ubuntu2.1 | [7](_ubuntu/ami-10eadd6a/changelist_en-US_from-2.24-9ubuntu2.2_to-2.26-0ubuntu2.1.txt) |       7 Malayalam | [176](_ubuntu/ami-10eadd6a/changelist_locales_from-2.24-9ubuntu2.2_to-2.26-0ubuntu2.1.txt) |  hu_HU, iso14651_t1_common, the_NP | Ubuntu 17.10  | [ami-10eadd6a](_ubuntu/ami-10eadd6a) |
| 2.27-3ubuntu1.4 | [55](_ubuntu/ami-0279c3b3186e54acd/changelist_en-US_from-2.26-0ubuntu2.1_to-2.27-3ubuntu1.4.txt) |       2 Latin-1 Supplement,      4 Latin Extended-A,      2 Latin Extended-B,      3 IPA Extensions,      2 Bengali,      6 Georgian,     16 Latin Extended Additional,      2 Arabic Presentation Forms-A,     18 Arabic Presentation Forms-B | [6523](_ubuntu/ami-0279c3b3186e54acd/changelist_locales_from-2.26-0ubuntu2.1_to-2.27-3ubuntu1.4.txt) |  bs_BA, cmn_TW, cs_CZ, de_DE, et_EE, fr_CA, hr_HR, hsb_DE, hu_HU, is_IS, iso14651_t1_common, ky_KG, lb_LU, lt_LT, lv_LV, om_KE, pl_PL, sr_RS, tr_TR, uk_UA | Ubuntu 18.04.6 LTS  | [ami-0279c3b3186e54acd](_ubuntu/ami-0279c3b3186e54acd) |
| 2.28-0ubuntu1 | [282166](_ubuntu/ami-00191485461dfb374/changelist_en-US_from-2.27-3ubuntu1.4_to-2.28-0ubuntu1.txt) | (Blocks not listed for this many en_US sort order changes) | [94091](_ubuntu/ami-00191485461dfb374/changelist_locales_from-2.27-3ubuntu1.4_to-2.28-0ubuntu1.txt) | (More than 20 languages) | Ubuntu 18.10  | [ami-00191485461dfb374](_ubuntu/ami-00191485461dfb374) |
| 2.29-0ubuntu2 | 0 |  | 0 |  | Ubuntu 19.04  | [ami-001084c942f9e0391](_ubuntu/ami-001084c942f9e0391) |
| 2.30-0ubuntu2.1 | 0 |  | 0 |  | Ubuntu 19.10  | [ami-013728cad753192a4](_ubuntu/ami-013728cad753192a4) |
| 2.31-0ubuntu9.2 | 0 |  | 0 |  | Ubuntu 20.04.3 LTS  | [ami-083654bd07b5da81d](_ubuntu/ami-083654bd07b5da81d) |
| 2.32-0ubuntu3 | 0 |  | [738](_ubuntu/ami-00630aa67c689d2ab/changelist_locales_from-2.31-0ubuntu9.2_to-2.32-0ubuntu3.txt) |  ckb_IQ, or_IN | Ubuntu 20.10  | [ami-00630aa67c689d2ab](_ubuntu/ami-00630aa67c689d2ab) |
| 2.33-0ubuntu5 | 0 |  | 0 |  | Ubuntu 21.04  | [ami-02bd521ab3d72d1c6](_ubuntu/ami-02bd521ab3d72d1c6) |
| 2.34-0ubuntu3 | 0 |  | [2](_ubuntu/ami-00482f016b2410dc8/changelist_locales_from-2.33-0ubuntu5_to-2.34-0ubuntu3.txt) |  sv_SE | Ubuntu 21.10  | [ami-00482f016b2410dc8](_ubuntu/ami-00482f016b2410dc8) |


### Red Hat Enterprise Linux

| GLIBC Version | Total Detected en_US Sort Order Changes | Unicode Blocks of Detected en_US Sort Order Changes | Total Detected Collation Data File Changes | Locales of Detected Data File Changes | Number of Locales | Operating System  | AMI |
| ---- | ---- | ---- | ----  | ---- | ---- | ---- | ---- |
| 2.5-49.el5_5.7 |  |  |  |  | 231 | Red Hat Enterprise Linux Server release 5.5 (Tikanga) | [ami-eb84ed82](_rhel/ami-eb84ed82) |
| 2.5-1232.5-123 | 0 |  | 0 |  | 231 | Red Hat Enterprise Linux Server release 5.11 (Tikanga) | [ami-3268da5a](_rhel/ami-3268da5a) |
| 2.12-1.7.el6_0.8 | [22908](_rhel/ami-09680160/changelist_en-US_from-2.5-1232.5-123_to-2.12-1.7.el6_0.8.txt) |       4 Basic Latin,     10 Latin-1 Supplement,     18 Latin Extended-A,    131 Latin Extended-B,      9 IPA Extensions,    206 Cyrillic,     16 Cyrillic Supplement,     76 Armenian,     26 Hebrew,     45 Arabic,    108 Devanagari,     86 Bengali,     79 Gurmukhi,     82 Gujarati,     58 Tamil,     93 Telugu,     86 Kannada,     82 Malayalam,     80 Sinhala,    130 Myanmar,     82 Georgian,    246 Latin Extended Additional,      1 Miscellaneous Symbols,     38 Georgian Supplement,     55 Tifinagh,  20902 CJK Unified Ideographs,     34 Arabic Presentation Forms-A,    125 Arabic Presentation Forms-B | [16282](_rhel/ami-09680160/changelist_locales_from-2.5-1232.5-123_to-2.12-1.7.el6_0.8.txt) | (More than 20 languages) | 275 | Red Hat Enterprise Linux Server release 6.0 (Santiago) | [ami-09680160](_rhel/ami-09680160) |
| 2.12-1.212.el6_10.3 | 0 |  | [42](_rhel/ami-0351faf7328fdb373/changelist_locales_from-2.12-1.7.el6_0.8_to-2.12-1.212.el6_10.3.txt) |  fi_FI | 275 | Red Hat Enterprise Linux Server release 6.10 (Santiago) | [ami-0351faf7328fdb373](_rhel/ami-0351faf7328fdb373) |
| 2.17-55.el7_0.5 | [107](_rhel/ami-60a1e808/changelist_en-US_from-2.12-1.212.el6_10.3_to-2.17-55.el7_0.5.txt) |     107 Tibetan | [2168](_rhel/ami-60a1e808/changelist_locales_from-2.12-1.212.el6_10.3_to-2.17-55.el7_0.5.txt) |  dz_BT, hu_HU, iso14651_t1_common, se_NO, ug_CN, no_NO (removed) | 300 | Red Hat Enterprise Linux Server release 7.0 (Maipo) | [ami-60a1e808](_rhel/ami-60a1e808) |
| 2.17-317.el7 | 0 |  | 0 |  | 300 | Red Hat Enterprise Linux Server release 7.9 (Maipo) | [ami-005b7876121b7244d](_rhel/ami-005b7876121b7244d) |
| 2.28-42.el8_0.1 | [282167](_rhel/ami-043fbed28a389c721/changelist_en-US_from-2.17-317.el7_to-2.28-42.el8_0.1.txt) | (Blocks not listed for this many en_US sort order changes) | [112164](_rhel/ami-043fbed28a389c721/changelist_locales_from-2.17-317.el7_to-2.28-42.el8_0.1.txt) | (More than 20 languages) | 341 | Red Hat Enterprise Linux release 8.0 (Ootpa) | [ami-043fbed28a389c721](_rhel/ami-043fbed28a389c721) |
| 2.28-164.el8 | 0 |  | [10](_rhel/ami-06644055bed38ebd9/changelist_locales_from-2.28-42.el8_0.1_to-2.28-164.el8.txt) |  C | 341 | Red Hat Enterprise Linux release 8.5 (Ootpa) | [ami-06644055bed38ebd9](_rhel/ami-06644055bed38ebd9) |
| 2.34-7.el9_b | 0 |  | [543](_rhel/ami-0fb33ec3ead0b8e3f/changelist_locales_from-2.28-164.el8_to-2.34-7.el9_b.txt) |  C, or_IN, sv_SE | 343 | Red Hat Enterprise Linux release 9.0 Beta (Plow) | [ami-0fb33ec3ead0b8e3f](_rhel/ami-0fb33ec3ead0b8e3f) |


## Generated Strings for en_US Sort Order Comparison

For every legal unicode code point, the following 91 string patterns are generated:

*(Each unicode character is substituted for the wine glass in the strings below.)*

```
S-199: 🍷

S-200: 🍷B
S-201: 🍷O
S-202: 🍷3
S-203: 🍷.
S-204: 🍷 
S-205: 🍷様
S-206: 🍷ク
S-210: B🍷
S-211: O🍷
S-212: 3🍷
S-213: .🍷
S-214:  🍷
S-215: 様🍷
S-216: ク🍷
S-299: 🍷🍷

S-300: 🍷BB
S-301: 🍷OO
S-302: 🍷33
S-303: 🍷..
S-304: 🍷  
S-305: 🍷様様
S-306: 🍷クク
S-310: B🍷B
S-311: O🍷O
S-312: 3🍷3
S-313: .🍷.
S-314:  🍷 
S-315: 様🍷様
S-316: ク🍷ク
S-320: BB🍷
S-321: OO🍷
S-322: 33🍷
S-323: ..🍷
S-324:   🍷
S-325: 様様🍷
S-326: クク🍷
S-330: 🍷🍷B
S-331: 🍷🍷O
S-332: 🍷🍷3
S-333: 🍷🍷.
S-334: 🍷🍷 
S-335: 🍷🍷様
S-336: 🍷🍷ク
S-340: 🍷B🍷
S-341: 🍷O🍷
S-342: 🍷3🍷
S-343: 🍷.🍷
S-344: 🍷 🍷
S-345: 🍷様🍷
S-346: 🍷ク🍷
S-350: B🍷🍷
S-351: O🍷🍷
S-352: 3🍷🍷
S-353: .🍷🍷
S-354:  🍷🍷
S-355: 様🍷🍷
S-356: ク🍷🍷
S-380: 3B🍷
S-399: 🍷🍷🍷

S-400: 🍷🍷BB
S-401: 🍷🍷OO
S-402: 🍷🍷33
S-403: 🍷🍷..
S-404: 🍷🍷  
S-405: 🍷🍷様様
S-406: 🍷🍷クク
S-410: B🍷🍷B
S-411: O🍷🍷O
S-412: 3🍷🍷3
S-413: .🍷🍷.
S-414:  🍷🍷 
S-415: 様🍷🍷様
S-416: ク🍷🍷ク
S-420: BB🍷🍷
S-421: OO🍷🍷
S-422: 33🍷🍷
S-423: ..🍷🍷
S-424:   🍷🍷
S-425: 様様🍷🍷
S-426: クク🍷🍷
S-480: 3B🍷B
S-481: 3B-🍷
S-499: 🍷🍷🍷🍷

S-580: BB🍷🍷[tab]
S-581: [tab]BB🍷🍷
S-582: BB-🍷🍷
S-583: 🙂👍🍷❤™
S-584: 🍷🍷.33
S-585: 3B-🍷B
S-599: 🍷🍷🍷🍷🍷
```

These patterns are based on some knowledge of collation algorithms and 
areas where change is common or likely, informed by a review of actual 
changes in past versions of glibc. For example: we intentionally generate 
interactions between character classes like consonants, vowels, numbers, 
punctuation and whitespace; we generate similar strings of different 
lengths; we generate some strings with CJK characters only; and we 
include a few miscellaneous strings to add some specific extra patterns
based on known past corner case changes. Some characters may behave
differently when doubled so we also include combinations with letters
twice in a row. While not comprehensive, this set of strings has caught
a very high number of changes across many versions of glibc going back 
more than 10 years.

The test suite will generate a sorted list of all strings (around 25
million) on various systems. It will then use the unix "diff" utility 
to look for a minimal set of differences between the sorted lists
and create reports summarizing those differences.

Each pattern is numbered, and the pattern numbers are referenced in the
report produced by this code. You can see lists of exactly which strings 
changed, as well as summaries of which patterns appeared in which unicode 
blocks.

## Caveats

This is fairly thorough but may not be completely comprehensive. Unicode
collation includes a capability to change the sort order based on combinations
of characters. For example, some languages have characters which modify the
letter before or after that letter. Nonetheless, while not comprehensive, this
is still helpful because it gives a little more perspective on how collation is
changing over multiple versions of glibc.

Example:
```
$ dpkg -l libc6
Desired=Unknown/Install/Remove/Purge/Hold
| Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
|/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
||/ Name                   Version          Architecture     Description
+++-======================-================-================-==================================================
ii  libc6:amd64            2.27-3ubuntu1.4  amd64            GNU C Library: Shared libraries

$ ( echo 1-; echo 11; echo 1-1; echo 111; echo 1a; echo 1b; echo 1-aa; echo 1-a) | LC_COLLATE=en_US.UTF-8 sort
1-
11
1-1
111
1a
1-a
1-aa
1b
```

From a different version:
```
$ dpkg -l libc6
Desired=Unknown/Install/Remove/Purge/Hold
| Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
|/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
||/ Name                   Version          Architecture     Description
+++-======================-================-================-==================================================
ii  libc6:amd64            2.28-0ubuntu1    amd64            GNU C Library: Shared libraries

$ ( echo 1-; echo 11; echo 1-1; echo 111; echo 1a; echo 1b; echo 1-aa; echo 1-a) | LC_COLLATE=en_US.UTF-8 sort
1-
1-1
11
111
1-a
1a
1-aa
1b
```


## Detailed Instructions

The script `table.sh` generates the table above.

The data is generated by running the following command using the DNS or IP of a
linux server:

```
test-host.sh [ubuntu|rhel] $USER@$HOST
```

I searched public community AMIs on AWS to find old versions of linux. Older
versions of RHEL might not have an ec2-user account (I just used root), and
newer versions of RHEL might not come with perl or glibc-locale-source installed
by default. Newer versions of Ubuntu require keyboard input when running some
dpkg commands (a warning about this appears when running the `test-host.sh` script).

```
sudo yum install perl
sudo yum install glibc-locale-source-$(rpm -q glibc --queryformat '%{version}-%{release}')
```

