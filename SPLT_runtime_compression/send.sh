h2 iperf -s  > h2.out &
h1 iperf -c h2 -i 1 -t 60 -e > h1_iperf_h2.out
h3 iperf -c h2 -i 1 -t 60 -e > h3_iperf_h2.out

h3 iperf -s >h3.out &
h1 iperf -c h3 -i 1 -t 60 -e  > h1_iperf_h3.out
h2 iperf -c h3 -i 1 -t 60 -e > h2_iperf_h3.out


h1 iperf -s >h1.out &
h2 iperf -c h1 -i 1 -t 60 -e > h2_iperf_h1.out
h3 iperf -c h1 -i 1 -t 60 -e > h3_iperf_h1.out

