# if [ $( ls *.out ) ]; then rm *.out; fi
# h1 python send.py -d h_2 --duration 60 -f 2M > h1_send_h2.out &
# h1 python send.py -d h_3 --duration 60 -f 2M > h1_send_h3.out &
# h2 python send.py -d h_1 --duration 60 -f 2M > h2_send_h1.out &
# h2 python send.py -d h_3 --duration 60 -f 2M > h2_send_h3.out &
# h3 python send.py -d h_2 --duration 60 -f 2M > h3_send_h2.out &
# h3 python send.py -d h_1 --duration 60 -f 2M > h3_send_h1.out &
# source send.sh


h2 iperf -s  > h2.out &
h1 iperf -c h2 -i 1 -t 60 -e > h1_iperf_h2.out
h3 iperf -c h2 -i 1 -t 60 -e > h3_iperf_h2.out

h3 iperf -s >h3.out &
h1 iperf -c h3 -i 1 -t 60 -e > h1_iperf_h3.out
h2 iperf -c h3 -i 1 -t 60 -e > h2_iperf_h3.out


h1 iperf -s >h1.out &
h2 iperf -c h1 -i 1 -t 60 -e > h2_iperf_h1.out
h3 iperf -c h1 -i 1 -t 60 -e > h3_iperf_h1.out

