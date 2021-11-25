
# Collation Changes Across Ubuntu Versions

## Methodology

There are two aspects to this analysis: comparing the results of actual sorts in
en_US locale, and comparing the LC_COLLATE section of the Operating System
locale data files.

Comparing the results of actual sorts should catch any changes to default
sorting which is not defined in the OS collation data. A simple perl script is
used to generate a text file containing 30 different strings for every legal
unicode character. The unix "sort" utility processes this file with the locale
configured to en_US for collation. This process is repeated on each Ubuntu
release from the past 10 years, and then the unix "diff" utility is used to
compare the sorted output files and count how many characters have different
positions after sorting. The results show how many individual code points have
changed positions in the sorted data across different Operating System releases
and which Unicode Blocks contain the changed code points.

The Operating System locale data files are compared directly. The results show
the total number of lines in the data files that are changed, and which locales
contain the changes.

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

## Results

| GLIBC Version | Total Detected en_US Sort Order Changes | Unicode Blocks of Detected en_US Sort Order Changes | Total Detected Collation Data File Changes | Locales of Detected Data File Changes | Operating System  | AMI | 
| ---- | ---- | ---- | ----  | ---- | ---- | ---- |
| 2.11.1-0ubuntu7.10 |  |  |  |  | Ubuntu 10.04.4 LTS  | ami-0baf7662 |
| 2.12.1-0ubuntu10.4 | 0 |  | [1987](_ubuntu/ami-c412cead/changelist_locales_from-2.11.1-0ubuntu7.10_to-2.12.1-0ubuntu10.4.txt) |  et_EE | Ubuntu 10.10  | ami-c412cead |
| 2.13-0ubuntu13.1 | 0 |  | 0 |  | Ubuntu 11.04  | ami-6d9f3604 |
| 2.13-20ubuntu5.1 | [107](_ubuntu/ami-4fad7426/changelist_en-US_from-2.13-0ubuntu13.1_to-2.13-20ubuntu5.1.txt) |     107 Tibetan | [2578](_ubuntu/ami-4fad7426/changelist_locales_from-2.13-0ubuntu13.1_to-2.13-20ubuntu5.1.txt) |  dz_BT, iso14651_t1_common, se_NO | Ubuntu 11.10  | ami-4fad7426 |
| 2.15-0ubuntu10.18 | 0 |  | [245](_ubuntu/ami-024a2614/changelist_locales_from-2.13-20ubuntu5.1_to-2.15-0ubuntu10.18.txt) |  hu_HU, ug_CN | Ubuntu 12.04.5 LTS  | ami-024a2614 |
| 2.15-0ubuntu20 | 0 |  | 0 |  | Ubuntu 12.10  | ami-02df496b |
| 2.17-0ubuntu5 | 0 |  | 0 |  la_AU (removed), tlh_GB (removed) | Ubuntu 13.04  | ami-12314d7b |
| 2.17-93ubuntu4 | 0 |  | 0 |  | Ubuntu 13.10  | ami-137e4f7a |
| 2.19-0ubuntu6.15 | 0 |  | 0 |  | Ubuntu 14.04.6 LTS  | ami-000b3a073fc20e415 |
| 2.19-10ubuntu2 | 0 |  | 0 |  | Ubuntu 14.10  | ami-12a3247a |
| 2.21-0ubuntu4 | [204](_ubuntu/ami-04a6816e/changelist_en-US_from-2.19-10ubuntu2_to-2.21-0ubuntu4.txt) |      37 Arabic,      2 Bengali,      6 Georgian,     34 Arabic Presentation Forms-A,    125 Arabic Presentation Forms-B | 0 |  | Ubuntu 15.04  | ami-04a6816e |
| 2.21-0ubuntu4 | 0 |  | 0 |  | Ubuntu 15.10  | ami-002f0f6a |
| 2.23-0ubuntu11.3 | 0 |  | [4081](_ubuntu/ami-0b0ea68c435eb488d/changelist_locales_from-2.21-0ubuntu4_to-2.23-0ubuntu11.3.txt) |  cs_CZ, es_US, et_EE, fil_PH, gd_GB, ha_NG, hsb_DE, mr_IN, sv_SE, ug_CN, uk_UA, ia (removed) | Ubuntu 16.04.7 LTS  | ami-0b0ea68c435eb488d |
| 2.24-3ubuntu2.2 | 0 |  | [392728](_ubuntu/ami-055d7213/changelist_locales_from-2.23-0ubuntu11.3_to-2.24-3ubuntu2.2.txt) |  C, eo, kk_KZ, ln_CD, iw_IL (removed), pap_AN (removed) | Ubuntu 16.10  | ami-055d7213 |
| 2.24-9ubuntu2.2 | 0 |  | [33](_ubuntu/ami-10d4f76b/changelist_locales_from-2.24-3ubuntu2.2_to-2.24-9ubuntu2.2.txt) |  C | Ubuntu 17.04  | ami-10d4f76b |
| 2.26-0ubuntu2.1 | [7](_ubuntu/ami-10eadd6a/changelist_en-US_from-2.24-9ubuntu2.2_to-2.26-0ubuntu2.1.txt) |       7 Malayalam | [176](_ubuntu/ami-10eadd6a/changelist_locales_from-2.24-9ubuntu2.2_to-2.26-0ubuntu2.1.txt) |  hu_HU, iso14651_t1_common, the_NP | Ubuntu 17.10  | ami-10eadd6a |
| 2.27-3ubuntu1.4 | [55](_ubuntu/ami-0279c3b3186e54acd/changelist_en-US_from-2.26-0ubuntu2.1_to-2.27-3ubuntu1.4.txt) |       2 Latin-1 Supplement,      4 Latin Extended-A,      2 Latin Extended-B,      3 IPA Extensions,      2 Bengali,      6 Georgian,     16 Latin Extended Additional,      2 Arabic Presentation Forms-A,     18 Arabic Presentation Forms-B | [6523](_ubuntu/ami-0279c3b3186e54acd/changelist_locales_from-2.26-0ubuntu2.1_to-2.27-3ubuntu1.4.txt) |  bs_BA, cmn_TW, cs_CZ, de_DE, et_EE, fr_CA, hr_HR, hsb_DE, hu_HU, is_IS, iso14651_t1_common, ky_KG, lb_LU, lt_LT, lv_LV, om_KE, pl_PL, sr_RS, tr_TR, uk_UA | Ubuntu 18.04.6 LTS  | ami-0279c3b3186e54acd |
| 2.28-0ubuntu1 | [282166](_ubuntu/ami-00191485461dfb374/changelist_en-US_from-2.27-3ubuntu1.4_to-2.28-0ubuntu1.txt) | (Blocks not listed for this many en_US sort order changes) | [94091](_ubuntu/ami-00191485461dfb374/changelist_locales_from-2.27-3ubuntu1.4_to-2.28-0ubuntu1.txt) | (More than 20 languages) | Ubuntu 18.10  | ami-00191485461dfb374 |
| 2.29-0ubuntu2 | 0 |  | 0 |  | Ubuntu 19.04  | ami-001084c942f9e0391 |
| 2.30-0ubuntu2.1 | 0 |  | 0 |  | Ubuntu 19.10  | ami-013728cad753192a4 |
| 2.31-0ubuntu9.2 | 0 |  | 0 |  | Ubuntu 20.04.3 LTS  | ami-083654bd07b5da81d |
| 2.32-0ubuntu3 | 0 |  | [738](_ubuntu/ami-00630aa67c689d2ab/changelist_locales_from-2.31-0ubuntu9.2_to-2.32-0ubuntu3.txt) |  ckb_IQ, or_IN | Ubuntu 20.10  | ami-00630aa67c689d2ab |
| 2.33-0ubuntu5 | 0 |  | 0 |  | Ubuntu 21.04  | ami-02bd521ab3d72d1c6 |
| 2.34-0ubuntu3 | 0 |  | [2](_ubuntu/ami-00482f016b2410dc8/changelist_locales_from-2.33-0ubuntu5_to-2.34-0ubuntu3.txt) |  sv_SE | Ubuntu 21.10  | ami-00482f016b2410dc8 |


## Generated Strings for en_US Sort Order Comparison

For every legal unicode code point, the following 30 string patterns are generated:

```
🍷
🍷🍷
🍷🍷B
🍷B
🍷🍷BB
🍷BB
B🍷🍷B
B🍷B
🍷🍷D
🍷D
🍷🍷DD
🍷DD
D🍷🍷D
D🍷D
```

Note that the string patterns are listed above in correctly sorted order. This
alone should give some sense about the sophistication of collation rules, and
the difficulty of writing a test to catch changes.


## Detailed Instructions

The script `table.sh` generates the table above.

The data is generated by running the following command using the DNS or IP of a
ubuntu server:

```
ubuntu.sh $HOST
```

