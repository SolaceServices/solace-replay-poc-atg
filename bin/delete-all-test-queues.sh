#!/bin/bash
#post json to solace 
#Ramesh Natarajan, Solace PSG

me=delete-queue

# read env
[ -f env.sh ] || { echo Missing env file env.sh ; exit 1; }
echo "Reading env.sh"
. env.sh

if [ $# -lt 1 ]; then
   echo "ERROR $me: missing arguments"
   echo "Usage: $me router-config-file"
   exit 1
fi

# read router config
router_cfg="$1"
shift
[ -f $router_cfg ] || { echo Missing router-cfg $router_cfg; exit 1; }
echo "Reading $router_cfg"
. $router_cfg

url=$mgmt_ip/SEMP/v2/config/msgVpns/${vpn}/queues
ts=$(date "+%s")
outfile=out/run-$me-$ts.out
curl -X GET -u ${cli_user}:${cli_pass} -H "content-type:application/json" "$url?select=queueName&where=queueName==${qname_prefix}*&count=100" > $outfile 2>&1
grep '"queueName"' $outfile | cut -f2 -d: | sed 's/"//g'> $outfile-1
for qname in $(cat $outfile-1); do
	qurl=$url/$qname
	echo "Deleting Queue $qname"
    echo "   [DELETE] $qurl"
    curl -X DELETE -u ${cli_user}:${cli_pass} -H "content-type:application/json" "$qurl" >> $outfile 2>&1
done
echo Check output file $outfile

