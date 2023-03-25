# test-host.sh - utility script to connect to a remote system and download collation info
#
# This script connects to a remote ubuntu or rhel system, uses the "run.sh" script to
# generate the en_US sorted data set on the remote system, and also downloads the full locale
# data. This data is stored in a local directory structure that can later be read by the
# script "table.sh" to compare across different versions of RHEL/Ubuntu and ICU and create
# a summary of the differences.
#
# This script presently uses the AMI as the name of the local directory where the results
# are downloaded and stored.
#
# usage: sh test-host.sh [ubuntu|rhel] [LOGIN-USERNAME@HOSTNAME]
#
# one-liners that I found helpful:
#   aws ec2 run-instances --instance-type c6i.4xlarge --image-id ami-10eadd6a
#     --region us-east-1  --monitoring Enabled=true --key-name <my-key-name>
#     --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=ubuntu-1710}]'
#   (Note that c3 supports paravirt, used by AMIs for some old OS versions like RHEL5)
#   aws ec2 describe-instances --region=us-east-1 |jq -r '.Reservations[].Instances[] |
#     select(.Tags[].Value | startswith("ubuntu-")) | [ .Tags[].Value,
#     .PublicDnsName ] | @tsv' | sort  >hosts
#   wc hosts ; split -l7 hosts hostpart
#   NN=0; for HOST in $(awk '{print$2}' hosts); do date; echo $((NN++)) $HOST;
#     sh test-host.sh ubuntu ubuntu@$HOST; done
#
# finding AMIs for specific OS releases:
#   aws ec2 describe-images --region us-east-1 --image-ids ami-00482f016b2410dc8
#   aws ec2 describe-images --region us-east-1 --include-deprecated --filters "Name=description,\
#     Values='Canonical, Ubuntu, 22.04 LTS, amd64*'"|egrep '(ImageId|Description|CreationDate|OwnerId)'
#
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

# cleanup remote results of any previous run, copy self contained "run.sh" then execute it remotely
ssh $HOST rm -rf icu-unicode-sorting
ssh $HOST mkdir -v icu-unicode-sorting
scp run-icu.sh $HOST:icu-unicode-sorting/run.sh
ssh $HOST 'set -o pipefail;sh icu-unicode-sorting/run.sh 2>&1 | tee icu-unicode-sorting/run.out'

# output of run.sh has a line like "SOURCE_AMI=ami-xxxxx" so we find & eval that line to set the var correctly
SOURCE_AMI=$(ssh $HOST cat icu-unicode-sorting/run.out|grep SOURCE_AMI|cut -c2-|tr -d '\r')
eval $SOURCE_AMI

# cleanup local results of any previous run, copy remote output to the local tree
[ -d _$1-icu/$SOURCE_AMI ] && rm -rf _$1-icu/$SOURCE_AMI
mkdir -pv _$1-icu/$SOURCE_AMI
scp $HOST:icu-unicode-sorting/* _$1-icu/$SOURCE_AMI/

