
# Collation Changes Across Ubuntu Versions

## Methodology

A simple perl snippit is used to generate a text file containing one line with every legal unicode character. The unix "sort" utility processes this file with the locale configured to en_US for collation. This process is repeated on each Ubuntu release from the past 10 years, and then the unix "diff" utility is used to compare the sorted output files and count how many characters have different positions after sorting.

## Results

| GLIBC Version | Total Changes Detected | Unicode Blocks of Detected Changes | Operating System  | AMI |
| ---- | ---- | ---- | ----  | ---- |
| 2.11.1-0ubuntu7.10 |  |  | Ubuntu 10.04.4 LTS  | ami-0baf7662 |
| 2.12.1-0ubuntu10.4 |        0 |  | Ubuntu 10.10  | ami-c412cead |
| 2.13-0ubuntu13.1 |        0 |  | Ubuntu 11.04  | ami-6d9f3604 |
| 2.13-20ubuntu5.1 |      [107](ami-4fad7426/changelist_from-2.13-0ubuntu13.1_to-2.13-20ubuntu5.1.txt) |  107 Tibetan | Ubuntu 11.10  | ami-4fad7426 |
| 2.15-0ubuntu10.18 |        0 |  | Ubuntu 12.04.5 LTS  | ami-024a2614 |
| 2.15-0ubuntu20 |        0 |  | Ubuntu 12.10  | ami-02df496b |
| 2.17-0ubuntu5 |        0 |  | Ubuntu 13.04  | ami-12314d7b |
| 2.17-93ubuntu4 |        0 |  | Ubuntu 13.10  | ami-137e4f7a |
| 2.19-0ubuntu6.15 |        0 |  | Ubuntu 14.04.6 LTS  | ami-000b3a073fc20e415 |
| 2.19-10ubuntu2 |        0 |  | Ubuntu 14.10  | ami-12a3247a |
| 2.21-0ubuntu4 |       [48](ami-002f0f6a/changelist_from-2.19-10ubuntu2_to-2.21-0ubuntu4.txt) |   48 Arabic | Ubuntu 15.10  | ami-002f0f6a |
| 2.21-0ubuntu4 |        0 |  | Ubuntu 15.04  | ami-04a6816e |
| 2.23-0ubuntu11.3 |        0 |  | Ubuntu 16.04.7 LTS  | ami-0b0ea68c435eb488d |
| 2.24-3ubuntu2.2 |        0 |  | Ubuntu 16.10  | ami-055d7213 |
| 2.24-9ubuntu2.2 |        0 |  | Ubuntu 17.04  | ami-10d4f76b |
| 2.26-0ubuntu2.1 |    [40588](ami-10eadd6a/changelist_from-2.24-9ubuntu2.2_to-2.26-0ubuntu2.1.txt) |   84 Basic Latin,  83 Latin-1 Supplement,  17 Latin Extended-A, 190 Latin Extended-B,  96 IPA Extensions,  80 Spacing Modifier Letters, 112 Combining Diacritical Marks, 101 Greek and Coptic, 205 Cyrillic,  48 Cyrillic Supplement,  52 Armenian,  88 Hebrew, 256 Arabic,  77 Syriac,  48 Arabic Supplement,  50 Thaana,  62 NKo,  61 Samaritan,  29 Mandaic,  11 Syriac Supplement,  41 Arabic Extended-B,  96 Arabic Extended-A,  57 Devanagari,  96 Bengali,  80 Gurmukhi,  29 Gujarati,  91 Oriya,  72 Tamil,  34 Telugu,  90 Kannada, 118 Malayalam,  91 Sinhala,  87 Thai,  82 Lao, 211 Tibetan, 160 Myanmar,  88 Georgian, 256 Hangul Jamo, 358 Ethiopic,  26 Ethiopic Supplement,  92 Cherokee, 640 Unified Canadian Aboriginal Syllabics,  29 Ogham,  89 Runic,  23 Tagalog,  23 Hanunoo,  20 Buhid,  18 Tagbanwa, 114 Khmer, 158 Mongolian,  70 Unified Canadian Aboriginal Syllabics Extended,  68 Limbu,  35 Tai Le,  83 New Tai Lue,  32 Khmer Symbols,  30 Buginese, 127 Tai Tham,  31 Combining Diacritical Marks Extended, 124 Balinese,  64 Sundanese,  56 Batak,  74 Lepcha,  48 Ol Chiki,   9 Cyrillic Extended-C,  46 Georgian Extended,   8 Sundanese Supplement,  43 Vedic Extensions, 128 Phonetic Extensions,  64 Phonetic Extensions Supplement,  64 Combining Diacritical Marks Supplement, 256 Latin Extended Additional, 233 Greek Extended, 111 General Punctuation,  42 Superscripts and Subscripts,  33 Currency Symbols,  33 Combining Diacritical Marks for Symbols,  80 Letterlike Symbols,  60 Number Forms, 112 Arrows, 256 Mathematical Operators, 256 Miscellaneous Technical,  39 Control Pictures,  11 Optical Character Recognition, 160 Enclosed Alphanumerics, 128 Box Drawing,  32 Block Elements,  96 Geometric Shapes, 255 Miscellaneous Symbols, 192 Dingbats,  48 Miscellaneous Mathematical Symbols-A,  16 Supplemental Arrows-A, 256 Braille Patterns, 128 Supplemental Arrows-B, 128 Miscellaneous Mathematical Symbols-B, 256 Supplemental Mathematical Operators, 253 Miscellaneous Symbols and Arrows,  96 Glagolitic,  32 Latin Extended-C, 123 Coptic,  40 Georgian Supplement,  59 Tifinagh,  79 Ethiopic Extended,  32 Cyrillic Extended-A,  94 Supplemental Punctuation, 115 CJK Radicals Supplement, 214 Kangxi Radicals,  12 Ideographic Description Characters,  64 CJK Symbols and Punctuation,  93 Hiragana,  96 Katakana,  43 Bopomofo,  94 Hangul Compatibility Jamo,  16 Kanbun,  32 Bopomofo Extended,  36 CJK Strokes,  16 Katakana Phonetic Extensions, 255 Enclosed CJK Letters and Months, 256 CJK Compatibility,6592 CJK Unified Ideographs Extension A,  64 Yijing Hexagram Symbols,  90 CJK Unified Ideographs,1165 Yi Syllables,  55 Yi Radicals,  48 Lisu, 300 Vai,  96 Cyrillic Extended-B,  88 Bamum,  32 Modifier Tone Letters, 193 Latin Extended-D,  45 Syloti Nagri,  10 Common Indic Number Forms,  56 Phags-pa,  82 Saurashtra,  32 Devanagari Extended,  48 Kayah Li,  37 Rejang,  29 Hangul Jamo Extended-A,  91 Javanese,  31 Myanmar Extended-B,  83 Cham,  32 Myanmar Extended-A,  72 Tai Viet,  23 Meetei Mayek Extensions,  32 Ethiopic Extended-A,  60 Latin Extended-E,  80 Cherokee Supplement,  56 Meetei Mayek,11172 Hangul Syllables,  72 Hangul Jamo Extended-B,6400 Private Use Area, 472 CJK Compatibility Ideographs,  58 Alphabetic Presentation Forms, 631 Arabic Presentation Forms-A,  16 Variation Selectors,  10 Vertical Forms,  16 Combining Half Marks,  32 CJK Compatibility Forms,  26 Small Form Variants, 141 Arabic Presentation Forms-B, 225 Halfwidth and Fullwidth Forms,   5 Specials | Ubuntu 17.10  | ami-10eadd6a |
| 2.27-3ubuntu1.4 |        0 |  | Ubuntu 18.04.6 LTS  | ami-0279c3b3186e54acd |
| 2.28-0ubuntu1 |       [71](ami-00191485461dfb374/changelist_from-2.27-3ubuntu1.4_to-2.28-0ubuntu1.txt) |    2 Armenian,   1 Hebrew,   3 NKo,   1 Arabic Extended-A,   1 Bengali,   1 Gurmukhi,   1 Telugu,   1 Kannada,   1 Mongolian,  43 Miscellaneous Symbols and Arrows,   5 Supplemental Punctuation,   1 Bopomofo,   5 CJK Unified Ideographs,   3 Latin Extended-D,   2 Devanagari Extended | Ubuntu 18.10  | ami-00191485461dfb374 |
| 2.29-0ubuntu2 |        0 |  | Ubuntu 19.04  | ami-001084c942f9e0391 |
| 2.30-0ubuntu2.1 |       [34](ami-013728cad753192a4/changelist_from-2.29-0ubuntu2_to-2.30-0ubuntu2.1.txt) |    1 Telugu,  15 Lao,   1 Vedic Extensions,   2 Miscellaneous Symbols and Arrows,   1 Supplemental Punctuation,   1 Enclosed CJK Letters and Months,  11 Latin Extended-D,   2 Latin Extended-E | Ubuntu 19.10  | ami-013728cad753192a4 |
| 2.31-0ubuntu9.2 |        0 |  | Ubuntu 20.04.3 LTS  | ami-083654bd07b5da81d |
| 2.32-0ubuntu3 | [58](ami-00630aa67c689d2ab/changelist_from-2.31-0ubuntu9.2_to-2.32-0ubuntu3.txt) |   10 Arabic Extended-A,   1 Oriya,   1 Malayalam,   1 Sinhala,   2 Combining Diacritical Marks Extended,   1 Miscellaneous Symbols and Arrows,   3 Supplemental Punctuation,   5 Bopomofo Extended,  10 CJK Unified Ideographs Extension A,  13 CJK Unified Ideographs,   6 Latin Extended-D,   1 Syloti Nagri,   4 Latin Extended-E | Ubuntu 20.10  | ami-00630aa67c689d2ab |
| 2.33-0ubuntu5 |        0 |  | Ubuntu 21.04  | ami-02bd521ab3d72d1c6 |
| 2.34-0ubuntu3 |       [86](ami-00482f016b2410dc8/changelist_from-2.33-0ubuntu5_to-2.34-0ubuntu3.txt) |    1 Latin-1 Supplement,   1 Latin Extended-A,   1 Latin Extended-B,   1 IPA Extensions,   1 Spacing Modifier Letters,   1 Combining Diacritical Marks,   1 Greek and Coptic,   1 Cyrillic,   1 Cyrillic Supplement,   1 Armenian,   1 Arabic,   1 Syriac,   1 Arabic Supplement,   1 NKo,   1 Arabic Extended-A,   1 Devanagari,   1 Gujarati,   1 Telugu,   1 Malayalam,   1 Myanmar,   1 Georgian,   1 Hangul Jamo,   1 Unified Canadian Aboriginal Syllabics,   1 Limbu,   1 New Tai Lue,   1 Khmer Symbols,   1 Buginese,   1 Sundanese,   1 Batak,   1 Lepcha,   1 Ol Chiki,   1 Phonetic Extensions,   1 Phonetic Extensions Supplement,   1 Combining Diacritical Marks Supplement,   1 Latin Extended Additional,   1 General Punctuation,   1 Letterlike Symbols,   1 Arrows,   1 Mathematical Operators,   1 Miscellaneous Technical,   1 Enclosed Alphanumerics,   1 Box Drawing,   1 Block Elements,   1 Geometric Shapes,   1 Miscellaneous Symbols,   1 Dingbats,   1 Miscellaneous Mathematical Symbols-A,   1 Supplemental Arrows-A,   1 Braille Patterns,   1 Supplemental Arrows-B,   1 Miscellaneous Mathematical Symbols-B,   1 Supplemental Mathematical Operators,   1 Miscellaneous Symbols and Arrows,   1 Latin Extended-C,   1 Coptic,   1 Tifinagh,   1 Cyrillic Extended-A,   1 CJK Symbols and Punctuation,   1 Hiragana,   1 Katakana,   1 Bopomofo,   1 Kanbun,   1 Bopomofo Extended,   1 Katakana Phonetic Extensions,   1 Enclosed CJK Letters and Months,   1 CJK Compatibility,   1 CJK Unified Ideographs Extension A,   1 Yijing Hexagram Symbols,   1 Lisu,   1 Cyrillic Extended-B,   1 Modifier Tone Letters,   1 Latin Extended-D,   1 Devanagari Extended,   1 Kayah Li,   1 Rejang,   1 Javanese,   1 Cham,   1 Myanmar Extended-A,   1 Tai Viet,   1 Cherokee Supplement,   1 Private Use Area,   1 Alphabetic Presentation Forms,   1 Variation Selectors,   1 Combining Half Marks,   1 CJK Compatibility Forms,   1 Arabic Presentation Forms-B | Ubuntu 21.10  | ami-00482f016b2410dc8 |

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


