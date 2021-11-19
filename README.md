
# Collation Changes Across Ubuntu Versions

## Methodology

A simple perl snippit is used to generate a text file containing one line with every legal unicode character. The unix "sort" utility processes this file with the locale configured to en_US for collation. This process is repeated on each Ubuntu release from the past 10 years, and then the unix "diff" utility is used to compare the sorted output files and count how many characters have different positions after sorting.

## Caveats

This is not comprehensive. Unicode collation includes a capability to change the sort order based on combinations of characters. (Some languages have characters which modify the letter before or after that letter.) Nonetheless, while not comprehensive, this is still helpful because it gives a little more perspective on how collation is changing over multiple versions of glibc.

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

| GLIBC Version | Total Changes Detected | Unicode Blocks of Detected Changes | Operating System  | AMI |
| ---- | ---- | ---- | ----  | ---- |
| 2.11.1-0ubuntu7.10 |  |  | Ubuntu 10.04.4 LTS  | ami-0baf7662 |
| 2.12.1-0ubuntu10.4 | 0 |  | Ubuntu 10.10  | ami-c412cead |
| 2.13-0ubuntu13.1 | 0 |  | Ubuntu 11.04  | ami-6d9f3604 |
| 2.13-20ubuntu5.1 | [107](ami-4fad7426/changelist_from-2.13-0ubuntu13.1_to-2.13-20ubuntu5.1.txt) |     107 Tibetan | Ubuntu 11.10  | ami-4fad7426 |
| 2.15-0ubuntu10.18 | 0 |  | Ubuntu 12.04.5 LTS  | ami-024a2614 |
| 2.15-0ubuntu20 | 0 |  | Ubuntu 12.10  | ami-02df496b |
| 2.17-0ubuntu5 | 0 |  | Ubuntu 13.04  | ami-12314d7b |
| 2.17-93ubuntu4 | 0 |  | Ubuntu 13.10  | ami-137e4f7a |
| 2.19-0ubuntu6.15 | 0 |  | Ubuntu 14.04.6 LTS  | ami-000b3a073fc20e415 |
| 2.19-10ubuntu2 | 0 |  | Ubuntu 14.10  | ami-12a3247a |
| 2.21-0ubuntu4 | [48](ami-002f0f6a/changelist_from-2.19-10ubuntu2_to-2.21-0ubuntu4.txt) |      48 Arabic | Ubuntu 15.10  | ami-002f0f6a |
| 2.21-0ubuntu4 | 0 |  | Ubuntu 15.04  | ami-04a6816e |
| 2.23-0ubuntu11.3 | 0 |  | Ubuntu 16.04.7 LTS  | ami-0b0ea68c435eb488d |
| 2.24-3ubuntu2.2 | 0 |  | Ubuntu 16.10  | ami-055d7213 |
| 2.24-9ubuntu2.2 | 0 |  | Ubuntu 17.04  | ami-10d4f76b |
| 2.26-0ubuntu2.1 | [7](ami-10eadd6a/changelist_from-2.24-9ubuntu2.2_to-2.26-0ubuntu2.1.txt) |       7 Malayalam | Ubuntu 17.10  | ami-10eadd6a |
| 2.27-3ubuntu1.4 | 0 |  | Ubuntu 18.04.6 LTS  | ami-0279c3b3186e54acd |
| 2.28-0ubuntu1 | [113261](ami-00191485461dfb374/changelist_from-2.27-3ubuntu1.4_to-2.28-0ubuntu1.txt) |       1 Basic Latin,     11 Latin-1 Supplement,      6 Latin Extended-A,    104 Latin Extended-B,     95 IPA Extensions,     24 Spacing Modifier Letters,     13 Combining Diacritical Marks,    128 Greek and Coptic,    248 Cyrillic,     48 Cyrillic Supplement,     79 Armenian,     30 Hebrew,    155 Arabic,     34 Syriac,     48 Arabic Supplement,     50 Thaana,     45 NKo,     26 Samaritan,     25 Mandaic,     29 Arabic Extended-A,    110 Devanagari,     78 Bengali,     67 Gurmukhi,     73 Gujarati,     79 Oriya,     51 Tamil,     78 Telugu,     76 Kannada,     85 Malayalam,     90 Sinhala,     76 Thai,     61 Lao,     76 Tibetan,     66 Myanmar,     87 Georgian,    256 Hangul Jamo,    335 Ethiopic,     16 Ethiopic Supplement,     92 Cherokee,    637 Unified Canadian Aboriginal Syllabics,     26 Ogham,     86 Runic,     20 Tagalog,     21 Hanunoo,     20 Buhid,     18 Tagbanwa,     92 Khmer,    141 Mongolian,     70 Unified Canadian Aboriginal Syllabics Extended,     62 Limbu,     35 Tai Le,     83 New Tai Lue,     28 Buginese,    104 Tai Tham,     80 Balinese,     61 Sundanese,     51 Batak,     68 Lepcha,     46 Ol Chiki,      9 Cyrillic Extended-C,     10 Vedic Extensions,    128 Phonetic Extensions,     64 Phonetic Extensions Supplement,     36 Combining Diacritical Marks Supplement,     11 Latin Extended Additional,    218 Greek Extended,     25 Superscripts and Subscripts,     31 Currency Symbols,     58 Letterlike Symbols,     52 Number Forms,    160 Enclosed Alphanumerics,      1 Miscellaneous Symbols,     30 Dingbats,     94 Glagolitic,     32 Latin Extended-C,    107 Coptic,     40 Georgian Supplement,      2 Tifinagh,     79 Ethiopic Extended,     32 Cyrillic Extended-A,      1 Supplemental Punctuation,    115 CJK Radicals Supplement,    214 Kangxi Radicals,     22 CJK Symbols and Punctuation,     89 Hiragana,     94 Katakana,     41 Bopomofo,     94 Hangul Compatibility Jamo,     14 Kanbun,     27 Bopomofo Extended,     16 Katakana Phonetic Extensions,    253 Enclosed CJK Letters and Months,    256 CJK Compatibility,   1165 Yi Syllables,     55 Yi Radicals,     48 Lisu,    300 Vai,     96 Cyrillic Extended-B,     88 Bamum,     32 Modifier Tone Letters,    193 Latin Extended-D,     45 Syloti Nagri,     10 Common Indic Number Forms,     56 Phags-pa,     82 Saurashtra,     32 Devanagari Extended,     48 Kayah Li,     37 Rejang,     29 Hangul Jamo Extended-A,     91 Javanese,     31 Myanmar Extended-B,     83 Cham,     32 Myanmar Extended-A,     72 Tai Viet,     23 Meetei Mayek Extensions,     32 Ethiopic Extended-A,     60 Latin Extended-E,     80 Cherokee Supplement,     56 Meetei Mayek,  11172 Hangul Syllables,     72 Hangul Jamo Extended-B,   6400 Private Use Area,    472 CJK Compatibility Ideographs,     58 Alphabetic Presentation Forms,    631 Arabic Presentation Forms-A,     16 Variation Selectors,     10 Vertical Forms,     16 Combining Half Marks,     32 CJK Compatibility Forms,     26 Small Form Variants,    141 Arabic Presentation Forms-B,    225 Halfwidth and Fullwidth Forms,      5 Specials,     88 Linear B Syllabary,    123 Linear B Ideograms,     57 Aegean Numbers,     79 Ancient Greek Numbers,     14 Ancient Symbols,     46 Phaistos Disc,     29 Lycian,     49 Carian,     28 Coptic Epact Numbers,     39 Old Italic,     27 Gothic,     43 Old Permic,     31 Ugaritic,     50 Old Persian,     80 Deseret,     48 Shavian,     40 Osmanya,     72 Osage,     40 Elbasan,     53 Caucasian Albanian,     70 Vithkuqi,    341 Linear A,     57 Latin Extended-F,     55 Cypriot Syllabary,     31 Imperial Aramaic,     32 Palmyrene,     40 Nabataean,     26 Hatran,     29 Phoenician,     27 Lydian,     32 Meroitic Hieroglyphs,     90 Meroitic Cursive,     68 Kharoshthi,     32 Old South Arabian,     32 Old North Arabian,     51 Manichaean,     61 Avestan,     30 Inscriptional Parthian,     27 Inscriptional Pahlavi,     29 Psalter Pahlavi,     73 Old Turkic,    108 Old Hungarian,     50 Hanifi Rohingya,     31 Rumi Numeral Symbols,     47 Yezidi,     40 Old Sogdian,     42 Sogdian,     26 Old Uyghur,     28 Chorasmian,     23 Elymaic,    115 Brahmi,     68 Kaithi,     35 Sora Sompeng,     71 Chakma,     39 Mahajani,     96 Sharada,     20 Sinhala Archaic Numbers,     62 Khojki,     38 Multani,     69 Khudawadi,     86 Grantha,     97 Newa,     82 Tirhuta,     92 Siddham,     79 Modi,     13 Mongolian Supplement,     68 Takri,     65 Ahom,     60 Dogra,     84 Warang Citi,     72 Dives Akuru,     65 Nandinagari,     72 Zanabazar Square,     83 Soyombo,     16 Unified Canadian Aboriginal Syllabics Extended-A,     57 Pau Cin Hau,     97 Bhaiksuki,     68 Marchen,     75 Masaram Gondi,     63 Gunjala Gondi,     25 Makasar,      1 Lisu Supplement,     51 Tamil Supplement,    922 Cuneiform,    116 Cuneiform Numbers and Punctuation,    196 Early Dynastic Cuneiform,     99 Cypro-Minoan,   1071 Egyptian Hieroglyphs,      9 Egyptian Hieroglyph Format Controls,    583 Anatolian Hieroglyphs,    569 Bamum Supplement,     43 Mro,     89 Tangsa,     36 Bassa Vah,    127 Pahawh Hmong,     91 Medefaidrin,    149 Miao,      7 Ideographic Symbols and Punctuation,   6136 Tangut,    768 Tangut Components,    470 Khitan Small Script,      9 Tangut Supplement,     13 Kana Extended-B,    256 Kana Supplement,     35 Kana Extended-A,      7 Small Kana Extension,    396 Nushu,    143 Duployan,      4 Shorthand Format Controls,    185 Znamenny Musical Notation,    246 Byzantine Musical Symbols,    233 Musical Symbols,     70 Ancient Greek Musical Notation,     20 Mayan Numerals,     87 Tai Xuan Jing Symbols,     25 Counting Rod Numerals,    996 Mathematical Alphanumeric Symbols,    672 Sutton SignWriting,     31 Latin Extended-G,     38 Glagolitic Supplement,     71 Nyiakeng Puachue Hmong,     31 Toto,     59 Wancho,     28 Ethiopic Extended-B,    213 Mende Kikakui,     88 Adlam,     68 Indic Siyaq Numbers,     61 Ottoman Siyaq Numbers,    143 Arabic Mathematical Alphabetic Symbols,     44 Mahjong Tiles,    100 Domino Tiles,     82 Playing Cards,    200 Enclosed Alphanumeric Supplement,     64 Enclosed Ideographic Supplement,    768 Miscellaneous Symbols and Pictographs,     80 Emoticons,     48 Ornamental Dingbats,    117 Transport and Map Symbols,    116 Alchemical Symbols,    102 Geometric Shapes Extended,    150 Supplemental Arrows-C,    256 Supplemental Symbols and Pictographs,     98 Chess Symbols,     88 Symbols and Pictographs Extended-A,    212 Symbols for Legacy Computing,  42720 CJK Unified Ideographs Extension B,   4153 CJK Unified Ideographs Extension C,    222 CJK Unified Ideographs Extension D,   5762 CJK Unified Ideographs Extension E,   7473 CJK Unified Ideographs Extension F,    542 CJK Compatibility Ideographs Supplement | Ubuntu 18.10  | ami-00191485461dfb374 |
| 2.29-0ubuntu2 | 0 |  | Ubuntu 19.04  | ami-001084c942f9e0391 |
| 2.30-0ubuntu2.1 | 0 |  | Ubuntu 19.10  | ami-013728cad753192a4 |
| 2.31-0ubuntu9.2 | 0 |  | Ubuntu 20.04.3 LTS  | ami-083654bd07b5da81d |
| 2.32-0ubuntu3 | 0 |  | Ubuntu 20.10  | ami-00630aa67c689d2ab |
| 2.33-0ubuntu5 | 0 |  | Ubuntu 21.04  | ami-02bd521ab3d72d1c6 |
| 2.34-0ubuntu3 | 0 |  | Ubuntu 21.10  | ami-00482f016b2410dc8 |

## Detailed Instructions

The script `table.sh` generates the table above.

The data is generated by running the following commands:

```
ssh ubuntu@...
   ^^^ verify successful host connection
   
HOST=...
ssh ubuntu@$HOST mkdir -v glibc-unicode-sorting
scp run.sh ubuntu@$HOST:glibc-unicode-sorting/
ssh ubuntu@$HOST 'script -c "sh glibc-unicode-sorting/run.sh" glibc-unicode-sorting/run.out'
   ^^^ if prompted with "WARNING: terminal is not fully functional" then press RETURN
   ^^^ if prompted with "lines 1-6/6 (END)" then type the letter "q" and press RETURN
ssh ubuntu@$HOST cat glibc-unicode-sorting/run.out|grep SOURCE_AMI

SOURCE_AMI=...
mkdir -v $SOURCE_AMI
scp ubuntu@$HOST:glibc-unicode-sorting/* $SOURCE_AMI/
```

### Example Output
```
$ ssh ubuntu@ec2-3-86-94-173.compute-1.amazonaws.com
The authenticity of host 'ec2-3-86-94-173.compute-1.amazonaws.com (3.86.94.173)' can't be established.
ECDSA key fingerprint is SHA256:qJN6Qk+LdixnO6pwNzg2FW7XMtpzKEwlRjqkrQMJrh0.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'ec2-3-86-94-173.compute-1.amazonaws.com,3.86.94.173' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 14.04.6 LTS (GNU/Linux 3.13.0-170-generic x86_64)
...
Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.
ubuntu@ip-172-31-85-146:~$ exit
logout
Connection to ec2-3-86-94-173.compute-1.amazonaws.com closed.

$ HOST=ec2-3-86-94-173.compute-1.amazonaws.com

$ ssh ubuntu@$HOST mkdir -v glibc-unicode-sorting
mkdir: created directory ‘glibc-unicode-sorting’

$ scp run.sh ubuntu@$HOST:glibc-unicode-sorting/
run.sh                                                                          100%  909     4.2KB/s   00:00

$ ssh ubuntu@$HOST 'script -c "sh glibc-unicode-sorting/run.sh" glibc-unicode-sorting/run.out'
+ dirname glibc-unicode-sorting/run.sh
...
+ file unicode-14-chars-sorted-glibc-2.19-0ubuntu6.15.txt
unicode-14-chars-sorted-glibc-2.19-0ubuntu6.15.txt: UTF-8 Unicode text
Script started, file is glibc-unicode-sorting/run.out
Script started, file is glibc-unicode-sorting/run.out
Script done, file is glibc-unicode-sorting/run.out
186590ce269b:glibc-unicode-sorting schnjere$ ssh ubuntu@$HOST cat glibc-unicode-sorting/run.out|grep SOURCE_AMI
+ SOURCE_AMI=ami-000b3a073fc20e415
186590ce269b:glibc-unicode-sorting schnjere$ SOURCE_AMI=ami-000b3a073fc20e415
186590ce269b:glibc-unicode-sorting schnjere$ mkdir -v $SOURCE_AMI
mkdir: created directory 'ami-000b3a073fc20e415'
186590ce269b:glibc-unicode-sorting schnjere$ scp ubuntu@$HOST:glibc-unicode-sorting/* $SOURCE_AMI/
base-characters.txt                                                             100% 7465KB   1.4MB/s   00:05
run.out                                                                         100% 3012    15.0KB/s   00:00
run.sh                                                                          100%  909     5.0KB/s   00:00
unicode-14-chars-sorted-glibc-2.19-0ubuntu6.15.txt                              100% 7465KB   2.7MB/s   00:02
UnicodeData.txt                                                                 100% 1853KB   2.8MB/s   00:00
```


