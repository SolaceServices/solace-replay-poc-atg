#!/bin/bash
#Drain multiple Solace Queues
#usage: sdk-drainq.sh router.cfg queue1,queue2,...
#WARNING: THIS IS FOR TESTING / POC PURPOSES ONLY.
#Ramesh Natarajan, Solace PSG

me=sdk-drainq

# read env
[ -f env.sh ] || { echo Missing env file env.sh ; exit 1; }
echo "Reading env.sh"
. env.sh
[ -d  $sdkperf_path ] || { echo Invalid sdkperf_path $sdkperf_path; exit 1; }
[ -x $sdkperf_path/sdkperf_jms.sh ] || { echo Missing sdkperf_jms.sh in $sdkperf_path; exit 1; }

if [ $# -lt 2 ]; then
   echo "ERROR $me: missing arguments"
   echo "Usage: $me router-config-file queue1,queue2,..."
   exit 1
fi

# read router config
router_cfg="$1"
shift
[ -f $router_cfg ] || { echo Missing router-cfg $router_cfg; exit 1; }
echo "Reading $router_cfg"
. $router_cfg
qlist=$1

ts=$(date "+%s")
outfile=$PWD/out/run-$me-$ts.out
> $outfile || { echo Unable to create output file $outfile; exit 1; }
echo "$test_cfg: Queues: $qlist"
#sdk_flags="-q"
sdk_flags="-jcf=test-cf"
echo "Queues: $qlist Flags: $sdk_flags"
( $sdkperf_path/sdkperf_jms.sh -cip=$msg_ip -cu=$user@$vpn -cp=$pass -sql=$qlist $sdk_flags > $outfile 2>&1 ) &
echo "check out-file: $outfile"
