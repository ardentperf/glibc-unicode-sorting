# usage: sh ubuntu.sh [HOSTNAME]
#
# one-liners that I found helpful:
#   aws ec2 describe-instances |jq -r '.Reservations[].Instances[] |
#     select(.Tags[].Value | startswith("ubuntu-")) | [ .Tags[].Value,
#     .PublicDnsName ] | @tsv' | sort  >hosts
#   NN=0; for HOST in $(awk '{print$2}' hosts); do date; echo $((NN++)) $HOST;
#     sh ubuntu.sh $HOST; done
[ -z "$1" ] && echo "ERROR: pass hostname as parameter" && exit 1
set -e

HOST=$1
echo 'if prompted with "WARNING: terminal is not fully functional" then press RETURN'
echo 'if prompted with "lines 1-6/6 (END)" then type the letter "q" and press RETURN'
echo '' 
echo '(press RETURN now to begin)'
read X

set -x -e

ssh ubuntu@$HOST rm -rf glibc-unicode-sorting
ssh ubuntu@$HOST mkdir -v glibc-unicode-sorting
scp run.sh ubuntu@$HOST:glibc-unicode-sorting/
ssh ubuntu@$HOST 'script -c "sh glibc-unicode-sorting/run.sh" glibc-unicode-sorting/run.out'

SOURCE_AMI=$(ssh ubuntu@$HOST cat glibc-unicode-sorting/run.out|grep SOURCE_AMI|cut -c2-|tr -d '\r')
eval $SOURCE_AMI

[ -d _ubuntu/$SOURCE_AMI ] && rm -rf _ubuntu/$SOURCE_AMI
mkdir -pv _ubuntu/$SOURCE_AMI
scp ubuntu@$HOST:glibc-unicode-sorting/* _ubuntu/$SOURCE_AMI/

mkdir -v _ubuntu/$SOURCE_AMI/locales
ssh ubuntu@$HOST "tar czf - -C /usr/share/i18n/locales ." | tar xvzf - -C _ubuntu/$SOURCE_AMI/locales/

