set -x -e
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
date
cd $(dirname $0)
pwd
dpkg -l libc6 locales
SOURCE_AMI=$(curl -s http://169.254.169.254/latest/meta-data/ami-id)
OS_VERS=$(cat /etc/issue)
UNICODE_VERS="14"
GLIBC_VERS="$(dpkg -l libc6|awk '/libc6/{print$3}')"

time curl -kO https://www.unicode.org/Public/${UNICODE_VERS}.0.0/ucd/UnicodeData.txt

time perl -naF';' -CO -e'
  sub pr3 {printf("%s        %08d\n",$_[1],$_[0])}
  sub pr2 {pr3($_[0],"B".$_[1]."B");pr3($_[0],"D".$_[1]."D");pr3($_[0],$_[1]);pr3($_[0],$_[1]."B");pr3($_[0],$_[1]."BB");pr3($_[0],$_[1]."D");pr3($_[0],$_[1]."DD")}
  sub pr {pr2($_[0],$_[1].chr($_[0]));pr2($_[0],$_[1].chr($_[0]).chr($_[0]))}
  if(/<control>/){next}; # skip control characters
  if($F[2] eq "Cs"){next}; # skip surrogates
  if(/ First>/){$fi=hex("0x".$F[0]);next}; # generate blocks
  if(/ Last>/){$la=hex("0x".$F[0]);for($fi..$la){pr($_)};next};
  pr(hex("0x".$F[0])) # generate individual characters
' UnicodeData.txt |split -l500000 - _base-characters

wc _base-characters*

locale

date
for FILE in $(ls -1 _base-characters*); do sort $FILE -o _s$FILE & done; jobs; wait
date

time sort -m _s_base-characters* -o unicode-${UNICODE_VERS}-chars-sorted-glibc-${GLIBC_VERS}.txt

rm -v _base-characters* _s_base-characters* UnicodeData.txt
ls -ltr
wc unicode-${UNICODE_VERS}-chars-sorted-glibc-${GLIBC_VERS}.txt

( echo "1-1"; echo "11" ) | LC_COLLATE=en_US.UTF-8 sort
date
