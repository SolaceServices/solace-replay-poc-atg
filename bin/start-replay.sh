#!/bin/bash
#post json to solace 
#Ramesh Natarajan, Solace PSG

me=start-replay

# read env
[ -f env.sh ] || { echo Missing env file env.sh ; exit 1; }
echo "Reading env.sh"
. env.sh

if [ $# -lt 2 ]; then
   echo "ERROR $me: missing arguments"
   echo "Usage: $me router-config-file queue1 queue2 ..."
   exit 1
fi

# read router config
router_cfg="$1"
shift
[ -f $router_cfg ] || { echo Missing router-cfg $router_cfg; exit 1; }
echo "Reading $router_cfg"
. $router_cfg

tfile=templates/$me.json
stfile=templates/$me-sub.json
[ -f $tfile ] || { echo Missing template file $tfile; exit 1; }


function put_json() {
	_jsonfile=$1
	_url=$2
	curl  -X PUT -d @${_jsonfile} -u ${cli_user}:${cli_pass} -H "content-type:application/json" $_url      
}

echo "Creating $nqueues $qname_prefix queues"
url=http://$mgmt_ip/SEMP/v2/action/msgVpns/${vpn}/queues
ts=$(date "+%s")
outfile=out/run-$me-$ts.out
> $outfile || { echo unable to create output file $outfile; exit 1; }
for qname; 
do    
   surl=$url/$qname/startReplay
   echo "Putting $tfile to $surl"
   put_json $tfile $surl >> $outfile 2>&1
done
echo Check output file $outfile