import nnpy
import struct
from scapy.all import Ether, sniff, Packet, BitField, raw

from p4utils.utils.helper import load_topo
from p4utils.utils.sswitch_p4runtime_API import SimpleSwitchP4RuntimeAPI
from p4utils.utils.sswitch_thrift_API import SimpleSwitchThriftAPI
import os 
from multiprocessing import Process, current_process

class CpuHeader(Packet):
    name = 'CpuPacket'
    fields_desc = [BitField('macAddr',0,48), BitField('ingress_port', 0, 16)]
    
    
class L2Controller:
    def __init__(self, sw_name):
        self.topo = load_topo('topology.json')
        self.sw_name = sw_name
        self.cpu_port =  self.topo.get_cpu_port_index(self.sw_name)
        device_id = self.topo.get_p4switch_id(sw_name)
        grpc_port = self.topo.get_grpc_port(sw_name)
        sw_data = self.topo.get_p4rtswitches()[sw_name]
        self.controller = SimpleSwitchP4RuntimeAPI(device_id, grpc_port,
                                                   p4rt_path=sw_data['p4rt_path'],
                                                   json_path=sw_data['json_path'])
        
    def learn(self, learning_data):
        for timestamp, packet_length in  learning_data:
            print("timestamp: %d, packet length: %s." % (timestamp, packet_length))
            print("")

    def unpack_digest(self, dig_list):
        learning_data = []
        for dig in dig_list.data:
            time_stamps = int.from_bytes(dig.struct.members[0].bitstring, byteorder='big')
            packet_length = int.from_bytes(dig.struct.members[1].bitstring, byteorder='big')
            # count   =int.from_bytes(dig.struct.members[2].bitstring, byteorder='big')
            learning_data.append((time_stamps, packet_length))
        return learning_data

    def recv_msg_digest(self, dig_list):
        learning_data = self.unpack_digest(dig_list)
        self.learn(learning_data)

    def run_digest_loop(self):
        # Up to 10 digests can be sent in a single message. Max timeout set to 1 ms.
        # self.controller.digest_enable('learn_t', 1000000, 10, 1000000)
        for num in [1,2,3,4,5,6]:
            self.controller.digest_enable('learn_'+str(num)+'t', 1000000, 100, 1000000)
        while True:
            dig_list = self.controller.get_digest_list()
            self.recv_msg_digest(dig_list)
        


if __name__ == "__main__":
    # import sys
    # sw_name = sys.argv[1]
    # receive_from = sys.argv[2]
    sw_name = 's4'
    receive_from = 'digest'
    if receive_from == "digest":
        controller = L2Controller(sw_name).run_digest_loop()
