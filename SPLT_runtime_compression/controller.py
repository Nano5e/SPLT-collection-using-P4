from p4utils.utils.helper import load_topo
from p4utils.utils.sswitch_p4runtime_API import SimpleSwitchP4RuntimeAPI
from p4utils.utils.sswitch_thrift_API import SimpleSwitchThriftAPI


topo = load_topo('topology.json')
controllers = {}


for switch, data in topo.get_p4rtswitches().items():
    controllers[switch] = SimpleSwitchP4RuntimeAPI(data['device_id'], data['grpc_port'],
                                                   p4rt_path=data['p4rt_path'],
                                                   json_path=data['json_path'])
    

controller = controllers['s1']
controller.table_add('ipv4_lpm','set_nhop',['10.0.1.1/24'],['00:00:0a:00:01:01','1'])
controller.table_add('ipv4_lpm','set_nhop',['10.0.7.2/32'],['00:00:00:02:01:00','2'])
controller.table_add('ipv4_lpm','set_nhop',['10.0.7.3/32'],['00:00:00:03:01:00','3'])



controller = controllers['s2']
controller.table_add('ipv4_lpm','set_nhop',['10.0.1.1/24'],['00:00:00:01:02:00','1'])
controller.table_add('ipv4_lpm','set_nhop',['10.0.7.1/24'],['00:00:00:04:02:00','2'])

controller = controllers['s3']
controller.table_add('ipv4_lpm','set_nhop',['10.0.1.1/24'],['00:00:00:01:03:00','1'])
controller.table_add('ipv4_lpm','set_nhop',['10.0.7.1/24'],['00:00:00:04:03:00','2'])



controller  = controllers['s5']
controller.table_add('ipv4_lpm','set_nhop',['10.0.1.1/24'],['00:00:00:04:05:00','1']) 
controller.table_add('ipv4_lpm','set_nhop',['10.0.7.1/24'],['00:00:00:07:05:00','2'])



controller  = controllers['s6'] 
controller.table_add('ipv4_lpm','set_nhop',['10.0.1.1/24'],['00:00:00:04:06:00','1']) 
controller.table_add('ipv4_lpm','set_nhop',['10.0.7.1/24'],['00:00:00:07:06:00','2'])

controller  = controllers['s7']  
controller.table_add('ipv4_lpm','set_nhop',['10.0.7.2/32'],['00:00:0a:00:07:02','3'])
controller.table_add('ipv4_lpm','set_nhop',['10.0.7.3/32'],['00:00:0a:00:07:03','4'])
controller.table_add('ipv4_lpm','set_nhop',['10.0.1.1/32'],['00:00:00:05:07:00','1'])



controller = controllers['s4']
controller.table_add('ipv4_lpm','set_nhop',['10.0.7.2/32'],['00:00:00:05:04:00','3'])
controller.table_add('ipv4_lpm','set_nhop',['10.0.7.3/32'],['00:00:00:06:04:00','4'])

controller.table_add('ipv4_lpm','set_nhop',['10.0.1.1/32'],['00:00:00:02:04:00','1'])
