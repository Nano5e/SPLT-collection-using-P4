/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

const bit<16> TYPE_IPV4 = 0x800;

typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ip4Addr_t;


header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

header ipv4_t {
    bit<4>    version;
    bit<4>    ihl;
    bit<6>    dscp;
    bit<2>    ecn;
    bit<16>   totalLen;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   fragOffset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdrChecksum;
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}

header tcp_t{
    bit<16> srcPort;
    bit<16> dstPort;
    bit<32> seqNo;
    bit<32> ackNo;
    bit<4>  dataOffset;
    bit<4>  res;
    bit<1>  cwr;
    bit<1>  ece;
    bit<1>  urg;
    bit<1>  ack;
    bit<1>  psh;
    bit<1>  rst;
    bit<1>  syn;
    bit<1>  fin;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgentPtr;
}

// struct metadata {
//     bit<14> ecmp_hash;
//     bit<14> ecmp_group_id;
// }




struct headers {
    ethernet_t   ethernet;
    ipv4_t       ipv4;
    tcp_t        tcp;
}

struct learn_t {
    bit<48> time_stamps;
    bit<3> packet_length;
    bit<4>  count;
}


struct learn_1t {     
    bit<8> time_stamps;     
    bit<3> packet_length; 
}  

struct learn_2t {     
    bit<16> time_stamps;     
    bit<3> packet_length; 
}  

struct learn_3t {     
    bit<24> time_stamps;     
    bit<3> packet_length; 
}   

struct learn_4t {     
    bit<32> time_stamps;     
    bit<3> packet_length; 
    }  

struct learn_5t {     
    bit<40> time_stamps;     
    bit<3> packet_length; 
    }  

struct learn_6t {     
    bit<48> time_stamps;     
    bit<3> packet_length; 
    }

struct metadata {     
    bit<14> ecmp_hash;    
    bit<14> ecmp_group_id;
    bit<1> is_ingress_border;     
    bit<1> is_egress_border;     
    learn_t   learn;     
    learn_1t  learn1;     
    learn_2t  learn2;     
    learn_3t  learn3;     
    learn_4t  learn4;     
    learn_5t  learn5;     
    learn_6t  learn6;    
}