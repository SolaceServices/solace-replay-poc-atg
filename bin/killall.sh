echo "killing SDKPerf_java ... "
pgrep -f SDKPerf_java && pkill -f SDKPerf_java
sleep 2
echo "killing sdkperf_jms.sh ..."
pgrep -f sdkperf_jms.sh && pkill -f sdkperf_jms.sh
sleep 2
