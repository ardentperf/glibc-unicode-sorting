set -x -e
cd $(dirname $0)
pwd
dpkg -l libc6
SOURCE_AMI=$(curl -s http://169.254.169.254/latest/meta-data/ami-id)
OS_VERS=$(cat /etc/issue)
UNICODE_VERS="14"
GLIBC_VERS="$(dpkg -l libc6|awk '/libc6/{print$3}')"

time curl -kO https://www.unicode.org/Public/${UNICODE_VERS}.0.0/ucd/UnicodeData.txt

time perl -naF';' -CO -e'
  sub pr {print "0".chr($_[0]).chr($_[0]).chr($_[0]).chr($_[0])."0 ";printf("%08d\n",$_[0])}
  if(/<control>/){next}; # skip control characters
  if($F[2] eq "Cs"){next}; # skip surrogates
  if(/ First>/){$fi=hex("0x".$F[0]);next}; # generate blocks
  if(/ Last>/){$la=hex("0x".$F[0]);for($fi..$la){pr($_)};next};
  pr(hex("0x".$F[0])) # generate individual characters
' UnicodeData.txt >base-characters.txt

locale

time sort base-characters.txt >unicode-${UNICODE_VERS}-chars-sorted-glibc-${GLIBC_VERS}.txt

ls -ltr
file unicode-${UNICODE_VERS}-chars-sorted-glibc-${GLIBC_VERS}.txt

