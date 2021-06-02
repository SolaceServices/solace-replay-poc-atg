#!/bin/bash
#sdk-perf publish wrapper
#usage: sdk-pub.sh router.cfg test1.cfg test2.cfg ...
#Ramesh Natarajan, Solace PSG

me=sdk-pub

# read env
[ -f env.sh ] || { echo Missing env file env.sh ; exit 1; }
echo "Reading env.sh"
. env.sh
[ -d  $sdkperf_path ] || { echo Invalid sdkperf_path $sdkperf_path; exit 1; }
[ -x $sdkperf_path/sdkperf_jms.sh ] || { echo Missing sdkperf_jms.sh in $sdkperf_path; exit 1; }

if [ $# -lt 2 ]; then
   echo "ERROR $me: missing arguments"
   echo "Usage: $me router-config-file test-dir"
   exit 1
fi

# read router config
router_cfg="$1"
test_dir="$2"
shift
[ -f $router_cfg ] || { echo Missing router-cfg $router_cfg; exit 1; }
[ -d $test_dir ] || { echo Missing test dir $test_dir; exit 1; }
echo "Reading $router_cfg"
. $router_cfg
sdk_flags="-psm"
#sdk_flags=""

nap_time=10
for fname in $(ls $test_dir); do
   file="$test_dir/$fname"
   [ -f $file ] || { echo Missing test-file $file; exit 1; }
   echo "---"
   echo "Reading test file $file"
   . $file
   ts=$(date "+%s")
   outfile=$PWD/out/run-$me-$ts.out
   > $outfile || { echo Unable to create output file $outfile; exit 1; }
   echo "$file: Topic: $topic_p Num: $msg_num Rate: $msg_rate Size: $msg_size  Transport: $msg_trans Clients: $num_clients Threads: $num_threads CF: $conn_factory"
   ( $sdkperf_path/sdkperf_jms.sh -cip=$msg_ip -cu=$user@$vpn -cp=$pass -ptl=$topic_p -mn=$msg_num -jcf=$conn_factory -mt=$msg_transport -mr=$msg_rate -msx=$msg_size -cc=$num_clients -cpt=$num_threads $sdk_flags  > $outfile 2>&1 ) &
   echo "Check out-file: $outfile"
   echo "Wait $nap_time seconds ..."; sleep $nap_time
done
