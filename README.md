# SPLT-collection-using-P4
The implementation of MES SPLT collection scheme. Our simulation environment is based the P4 language on a BMV2 software switch. We utilize the network simulator Mininet to construct the network topology
and to test network bandwidth and delay. The entire simulation
is deployed within a Docker container running Ubuntu 18.04,
which is equipped with 16GB of memory and a 16-core CPU.

The network topology is depicted in the Fig.1.  The simulated network comprises seven switches: s1, s2, s3, s4, s5, s6, and s7.  Each switch is equipped with basic routing strategy. Switch s4 is responsible for executing the SPLT measurement. 
Additionally, there are three hosts: h1, h2, and h3.
Host h1 is connected to switch s1 with a bandwidth of 10 Mbps. On the other hand, hosts h2 and h3 are connected to switch s7, each having a bandwidth of 10 Mbps. The bandwidth between switches is set to 1 Gbps.
We do not specify upstream and downstream ports, so for example, in the case of s4, both the upstream and downstream bandwidth for each port are set to be 1Gbps.
![Fig.1](./figs/image.png "Fig.1")


We conduct simulations in two scenarios: 
1) No measurement, where the s4 switch implements basic routing strategy without any SPLT collection.
2) SPLT measurement, where the s4 switch incorporates the SPLT measurements we designed alongside the basic routing strategy. 

In each simulation, we utilize the iperf network tool to measure the end-to-end bandwidth and delay. Iperf is a freely available open-source tool designed for evaluating the throughput between network nodes using TCP or UDP protocols. In our simulations, we employ the iperf tool to send TCP packets from each host to the other hosts for a duration of 60 seconds.
Following the collection of end-to-end bandwidth and delay measurements every 1 second, we compute the mean values and 95% confidence intervals for these two metrics.

## How to build your own P4 simulation environment with Docker.
1. Download the preconfigured QEMU VM from the [link](https://polybox.ethz.ch/index.php/s/9orcmetpNxOAhlI).
2. Convert the QEMU VM to a docker image. For this step, you can refer to the [link](https://azhercan.com/converting-qcow2-to-docker-image).
   Assuming the converted docker image is denoted as p4-utils-vm:1.0.0.
3. Use docker run command to run P4 simulation environment inside the container
```
docker run --privileged -v /sda2:/home/ -p 221:22 -itd p4-utils-vm:1.0.0  /bin/bash
```

Now you can run P4 simulation codes within the docker container.

## How to run the SPLT measurement simulation

1. Build the topology: 
   ```
   cd ./SPLT_runtime_compression/
   sudo python network.py 
   ```
   Wait for the mininet to compile.
2. Run the iperf test script:
   ```
   mininet> source send.sh
   ```

## How to run the simulation without SPLT collection

1. Build the topology: 
   ```
   cd ./SPLT_runtime_no_op/
   sudo python network.py 
   ```
   Wait for the mininet to compile.
2. Run the iperf test script:
   ```
   mininet> source send.sh
   ```

