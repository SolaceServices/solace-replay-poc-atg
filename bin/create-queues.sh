#!/bin/bash
#post json to solace 
#Ramesh Natarajan, Solace PSG

me=create-queue

# read env
[ -f env.sh ] || { echo Missing env file env.sh ; exit 1; }
echo "Reading env.sh"
. env.sh

if [ $# -lt 2 ]; then
   echo "ERROR $me: missing arguments"
   echo "Usage: $me router-config-file num-queues"
   exit 1
fi

# read router config
router_cfg="$1"
nqueues="$2"
shift
[ -f $router_cfg ] || { echo Missing router-cfg $router_cfg; exit 1; }
echo "Reading $router_cfg"
. $router_cfg


stfile=templates/$me-sub.json
[ -f $tfile ] || { echo Missing template file $tfile; exit 1; }


function make_json() {
	_qname=$1
	_tfile=$2
	_jfile=$3
   _topics=$4
	sed -e "s/{{VPN}}/$vpn/g" \
		-e "s/{{CLIENT_USERNAME}}/$user/g" \
		-e "s/{{QUEUE}}/$_qname/g" \
		-e "s#{{TOPIC_SUB}}#$_topics#g" \
		$_tfile > $_jfile	
}

function post_json() {
	_jsonfile=$1
	_url=$2
	curl  -X POST -d @${_jsonfile} -u ${cli_user}:${cli_pass} -H "content-type:application/json" $_url      
}

echo "Creating $nqueues $qname_prefix queues"
url=$mgmt_ip/SEMP/v2/config/msgVpns/${vpn}/queues
ts=$(date "+%s")
outfile=out/run-$me-$ts.out
> $outfile || { echo unable to create output file $outfile; exit 1; }

# create lvq
qname="${qname_prefix}-LVQ"
echo "Creating LVQ $qname"
tfile=templates/create-queue-lvq.json
jsonfile=tmp/create-lvq.json
make_json $qname $tfile $jsonfile $lvq_topic
echo "   [POST] $url $jsonfile"
post_json $jsonfile $url >> $outfile 2>&1
jsonfile=tmp/create-sub-$qname.json
surl=$url/$qname/subscriptions
make_json $qname $stfile $jsonfile $lvq_topic
echo "   [POST] $surl $jsonfile"
post_json $jsonfile $surl >> $outfile 2>&1

tfile=templates/$me.json
for ((i=1;i<=$nqueues;i++)); 
do 
   qname="${qname_prefix}-${i}"
   echo "Creating queue $qname"
   jsonfile=tmp/create-$qname.json
   make_json $qname $tfile $jsonfile "$topic_prefix/>"
   echo "   [POST] $url $jsonfile"
   post_json $jsonfile $url >> $outfile 2>&1
   
   jsonfile=tmp/create-sub-$qname.json
   surl=$url/$qname/subscriptions
   make_json $qname $stfile $jsonfile "$topic_prefix/>"
   echo "   [POST] $surl $jsonfile"
   post_json $jsonfile $surl >> $outfile 2>&1
done
echo Check output file $outfile