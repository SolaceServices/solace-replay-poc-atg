# Replay POC for ATG

## About

Scritps to setup and run replay POC for ATG.

### Author

Ramesh Natarajan (nram), Solace PSG

## Directories and files

### cfg/router.cfg

Clone sample.cfg

``` bash
cp cfg/sample.cfg cfg/router.cfg
```

Make changes where required.

```  bash
# Solace broker Management IPP
mgmt_ip="192.168.128.27:80"

# CLI/SEMP user and password
cli_user="admin"
cli_pass="admin"

# message backbone IPP
msg_ip="192.168.160.127:55555"

# VPN name
vpn="atg-poc"

# Client username and password
user="test-user"
pass="test123"

# default connection factory
cf="test-cf"

# Queue name prefix for creating/deleting queues.
# actual qname will be <prefix>-<n>
# eg: replay-poc-1
qname_prefix="replay-poc"

# topic subscription to add on created queues
# this is added to all created queues.
# any customization has to be done manually after script ran
topic_prefix="atg/poc/replay"

# topic subscription for last value queue
lvq_topic=">"
```

### tests/mytest

Create a folder under tests/ dir for each test. Drop any number of test files in the folder. All of them will be run in the listing order. Each file has the following syntax. Variable names are self explanatory.

``` bash
topic_p=atg/poc/replay/persistent/test1
msg_num=100
msg_transport=persistent
msg_rate=100
msg_size=1024
num_clients=1
num_threads=1
conn_factory=persistent-cf
nap_time=2
```

## Commands

### Creating queues

```bash
▶ bin/create-queues.sh cfg/lab-128-27.cfg 100
Reading env.sh
env: sdkperf_path: /Users/nram/Solace/sdkperf/jms
Reading cfg/lab-128-27.cfg

-----------------------------------------------
message-ip        : 192.168.160.127:55555
message-vpn       : atg-poc
client-user       : test-user
connection-factory: test-cf
mgmt-ip           : 192.168.128.27:80
cli-user          : admin
queue-prefix      : replay-poc
topic-prefix      : atg/poc/replay
lvq-topic         : >
-----------------------------------------------

Creating 100 replay-poc queues
Creating LVQ replay-poc-LVQ
   [POST] http://192.168.128.27:80/SEMP/v2/config/msgVpns/atg-poc/queues tmp/create-lvq.json
   [POST] http://192.168.128.27:80/SEMP/v2/config/msgVpns/atg-poc/queues/replay-poc-LVQ/subscriptions tmp/create-sub-replay-poc-LVQ.json
Creating queue replay-poc-1
   [POST] http://192.168.128.27:80/SEMP/v2/config/msgVpns/atg-poc/queues tmp/create-replay-poc-1.json
   [POST] http://192.168.128.27:80/SEMP/v2/config/msgVpns/atg-poc/queues/replay-poc-1/subscriptions tmp/create-sub-replay-poc-1.json
Creating queue replay-poc-2
   [POST] http://192.168.128.27:80/SEMP/v2/config/msgVpns/atg-poc/queues tmp/create-replay-poc-2.json
   [POST] http://192.168.128.27:80/SEMP/v2/config/msgVpns/atg-poc/queues/replay-poc-2/subscriptions tmp/create-sub-replay-poc-2.json
Creating queue replay-poc-3
   [POST] http://192.168.128.27:80/SEMP/v2/config/msgVpns/atg-poc/queues tmp/create-replay-poc-3.json
   [POST] http://192.168.128.27:80/SEMP/v2/config/msgVpns/atg-poc/queues/replay-poc-3/subscriptions tmp/create-sub-replay-poc-3.json

   ...

```

### Deleting Queues

```bash
▶ bin/delete-all-test-queues.sh cfg/lab-128-27.cfg
Reading env.sh
env: sdkperf_path: /Users/nram/Solace/sdkperf/jms
Reading cfg/lab-128-27.cfg

-----------------------------------------------
message-ip        : 192.168.160.127:55555
message-vpn       : atg-poc
client-user       : test-user
connection-factory: test-cf
mgmt-ip           : 192.168.128.27:80
cli-user          : admin
queue-prefix      : replay-poc
topic-prefix      : atg/poc/replay
lvq-topic         : >
-----------------------------------------------

Deleting Queue replay-poc-1
   [DELETE] http://192.168.128.27:80/SEMP/v2/config/msgVpns/atg-poc/queues/replay-poc-1
Deleting Queue replay-poc-2
   [DELETE] http://192.168.128.27:80/SEMP/v2/config/msgVpns/atg-poc/queues/replay-poc-2
Deleting Queue replay-poc-3
   [DELETE] http://192.168.128.27:80/SEMP/v2/config/msgVpns/atg-poc/queues/replay-poc-3

   ...
```

### Run publishers

```bash
▶ bin/pub.sh cfg/lab/lab-128-27.cfg tests/test1
Reading env.sh
env: sdkperf_path: /Users/nram/Solace/sdkperf/jms
Reading cfg/lab/lab-128-27.cfg

-----------------------------------------------
message-ip        : 192.168.160.127:55555
message-vpn       : atg-poc
client-user       : test-user
connection-factory: test-cf
mgmt-ip           : 192.168.128.27:80
cli-user          : admin
queue-prefix      : replay-poc
topic-prefix      : atg/poc/replay
lvq-topic         : >
-----------------------------------------------

---
Reading test file tests/test1/test1.cfg
tests/test1/test1.cfg: Topic: atg/poc/replay/persistent/test1 Num: 100 Rate: 100 Size: 1024  Transport:  Clients: 1 Threads: 1 CF: persistent-cf
Check out-file: /Users/nram/Accounts/ATG/replay-poc-202103/solace-replay-poc-atg/out/run-sdk-pub-1622663899.out
Wait 2 seconds ...
---
Reading test file tests/test1/test2.cfg
tests/test1/test2.cfg: Topic: atg/poc/replay/non-persistent/test2 Num: 200 Rate: 100 Size: 1024  Transport:  Clients: 1 Threads: 1 CF: persistent-cf
Check out-file: /Users/nram/Accounts/ATG/replay-poc-202103/solace-replay-poc-atg/out/run-sdk-pub-1622663901.out
Wait 2 seconds ...
---
Reading test file tests/test1/test3.cfg
tests/test1/test3.cfg: Topic: atg/poc/replay/direct/test3 Num: 300 Rate: 100 Size: 1024  Transport:  Clients: 1 Threads: 1 CF: direct-cf
Check out-file: /Users/nram/Accounts/ATG/replay-poc-202103/solace-replay-poc-atg/out/run-sdk-pub-1622663903.out
Wait 2 seconds ...

```

### Run consumers

```bash
▶ bin/drainq.sh cfg/lab-128-27.cfg replay-poc-4
Reading env.sh
env: sdkperf_path: /Users/nram/Solace/sdkperf/jms
Reading cfg/lab-128-27.cfg

-----------------------------------------------
message-ip        : 192.168.160.127:55555
message-vpn       : atg-poc
client-user       : test-user
connection-factory: test-cf
mgmt-ip           : 192.168.128.27:80
cli-user          : admin
queue-prefix      : replay-poc
topic-prefix      : atg/poc/replay
lvq-topic         : >
-----------------------------------------------

: Queues: replay-poc-4
Queues: replay-poc-4 Flags: -jcf=test-cf
check out-file: /Users/nram/Accounts/ATG/replay-poc-202103/solace-replay-poc-atg/out/run-sdk-drainq-1622658334.out
```

### Start Replay

```bash
▶ bin/start-replay.sh cfg/lab-128-27.cfg replay-poc-4 replay-poc-5
Reading env.sh
env: sdkperf_path: /Users/nram/Solace/sdkperf/jms
Reading cfg/lab-128-27.cfg

-----------------------------------------------
message-ip        : 192.168.160.127:55555
message-vpn       : atg-poc
client-user       : test-user
connection-factory: test-cf
mgmt-ip           : 192.168.128.27:80
cli-user          : admin
queue-prefix      : replay-poc
topic-prefix      : atg/poc/replay
lvq-topic         : >
-----------------------------------------------

Creating  replay-poc queues
Putting templates/start-replay.json to http://192.168.128.27:80/SEMP/v2/action/msgVpns/atg-poc/queues/replay-poc-4/startReplay
Putting templates/start-replay.json to http://192.168.128.27:80/SEMP/v2/action/msgVpns/atg-poc/queues/replay-poc-5/startReplay
Check output file out/run-start-replay-1622658299.out
```

### Kill sdkperf
__WARNING__: This will terminate ALL running sdkperfs.

```bash
▶ bin/killall.sh
killing SDKPerf_java ...
63518
63837
killing sdkperf_jms.sh ...
63514
63833
```
