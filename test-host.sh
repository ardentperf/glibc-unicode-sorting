# usage: sh test-host.sh [ubuntu|rhel] [LOGIN-USERNAME@HOSTNAME]
#
# one-liners that I found helpful:
#   aws ec2 describe-instances |jq -r '.Reservations[].Instances[] |
#     select(.Tags[].Value | startswith("ubuntu-")) | [ .Tags[].Value,
#     .PublicDnsName ] | @tsv' | sort  >hosts
#   NN=0; for HOST in $(awk '{print$2}' hosts); do date; echo $((NN++)) $HOST;
#     sh test-host.sh ubuntu ubuntu@$HOST; done
[ -z "$2" ] && echo "ERROR: pass user@hostname as parameter" && exit 1
case $1 in (ubuntu|rhel) ;; (*) echo "ERROR: first parameter must be a recognized OS" && exit 1 ;; esac

HOST=$2
echo 'if prompted with "WARNING: terminal is not fully functional" then press RETURN'
echo 'if prompted with "lines 1-6/6 (END)" then type the letter "q" and press RETURN'
echo '' 
echo '(press RETURN now to begin)'
read X

[ -d _$1 ] || mkdir -v _$1

set -x -e

ssh $HOST rm -rf glibc-unicode-sorting
ssh $HOST mkdir -v glibc-unicode-sorting
scp run.sh $HOST:glibc-unicode-sorting/run.sh
ssh $HOST 'set -o pipefail;sh glibc-unicode-sorting/run.sh 2>&1 | tee glibc-unicode-sorting/run.out'

SOURCE_AMI=$(ssh $HOST cat glibc-unicode-sorting/run.out|grep SOURCE_AMI|cut -c2-|tr -d '\r')
eval $SOURCE_AMI

[ -d _$1/$SOURCE_AMI ] && rm -rf _$1/$SOURCE_AMI
mkdir -pv _$1/$SOURCE_AMI
scp $HOST:glibc-unicode-sorting/* _$1/$SOURCE_AMI/

mkdir -v _$1/$SOURCE_AMI/locales
ssh $HOST "tar czf - -C /usr/share/i18n/locales ." | tar xvzf - -C _$1/$SOURCE_AMI/locales/

