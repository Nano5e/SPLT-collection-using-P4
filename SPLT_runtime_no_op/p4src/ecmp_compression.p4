/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

//My includes
#include "include/headers.p4"
#include "include/parsers.p4"

/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {
    apply {  }
}

/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {

    register<bit<4>>(1) counts;     
    register<bit<48>>(1) timestamp_tmp;

    action drop() {
        mark_to_drop(standard_metadata);
    }

    action ecmp_group(bit<14> ecmp_group_id, bit<16> num_nhops){
        hash(meta.ecmp_hash,
	    HashAlgorithm.crc16,
	    (bit<1>)0,
	    { hdr.ipv4.srcAddr,
	      hdr.ipv4.dstAddr,
          hdr.tcp.srcPort,
          hdr.tcp.dstPort,
          hdr.ipv4.protocol},
	    num_nhops);

	    meta.ecmp_group_id = ecmp_group_id;
    }

    action set_nhop(macAddr_t dstAddr, egressSpec_t port) {

        //set the src mac address as the previous dst, this is not correct right?
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;

       //set the destination mac address that we got from the match in the table
        hdr.ethernet.dstAddr = dstAddr;

        //set the output port that we also get from the table
        standard_metadata.egress_spec = port;

        //decrease ttl by 1
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    table ecmp_group_to_nhop {
        key = {
            meta.ecmp_group_id:    exact;
            meta.ecmp_hash: exact;
        }
        actions = {
            drop;
            set_nhop;
        }
        size = 1024;
        default_action = drop;
    }

    table ipv4_lpm {
        key = {
            hdr.ipv4.dstAddr: lpm;
        }
        actions = {
            set_nhop;
            ecmp_group;
            drop;
        }
        size = 1024;
        default_action = drop;
    }

    action mac_learn(){
        // Compression 
        bit<48> tmp;
        counts.read(meta.learn.count,0);

        meta.learn.count= meta.learn.count+1;

        if (meta.learn.count == 15){
            meta.learn.count = 0; 
        }

        counts.write(0,meta.learn.count);

        timestamp_tmp.read(tmp,0);
        if (meta.learn.count != 0){
            
            meta.learn.time_stamps =(standard_metadata.ingress_global_timestamp - tmp);

            
        }
        else {
            meta.learn.time_stamps = standard_metadata.ingress_global_timestamp;
        }
        timestamp_tmp.write(0,standard_metadata.ingress_global_timestamp);

    
        // meta.learn.packet_length = standard_metadata.packet_length;

    }

    action set_packet_length(bit<3> compressed_packet_length){
        meta.learn.packet_length = compressed_packet_length;
    }

    table packet_compression {
        key = {
            standard_metadata.packet_length: range;
        }

        actions = {
            set_packet_length;
            NoAction;
        }
        size = 1024;
        default_action = NoAction;

        const entries = {
            60..80: set_packet_length(1);
            81..200: set_packet_length(2);
            201..300: set_packet_length(3);
            301..400: set_packet_length(4);
            401..800: set_packet_length(5);
            801..1200: set_packet_length(6);
            1200..9999: set_packet_length(7);
        }

    }


    action digest_1t() {
        // encoded_packet_length = bit<3> 2;
        meta.learn1.time_stamps = standard_metadata.ingress_global_timestamp[7:0];
        meta.learn1.packet_length = meta.learn.packet_length;
        digest<learn_1t>(1, meta.learn1);
    }

    action digest_2t() {
        // encoded_packet_length = bit<3> 2;
        meta.learn2.time_stamps = standard_metadata.ingress_global_timestamp[15:0];
        meta.learn2.packet_length = meta.learn.packet_length;
        digest<learn_2t>(1, meta.learn2);
    }

    action digest_3t() {
        // encoded_packet_length = bit<3> 2;
        meta.learn3.time_stamps = standard_metadata.ingress_global_timestamp[23:0];
        meta.learn3.packet_length = meta.learn.packet_length;
        digest<learn_3t>(1, meta.learn3);
    }

    action digest_4t() {
        // encoded_packet_length = bit<3> 2;
        meta.learn4.time_stamps = standard_metadata.ingress_global_timestamp[31:0];
        meta.learn4.packet_length = meta.learn.packet_length;
        digest<learn_4t>(1, meta.learn4);
    }

    action digest_5t() {
        // encoded_packet_length = bit<3> 2;
        meta.learn5.time_stamps = standard_metadata.ingress_global_timestamp[39:0];
        meta.learn5.packet_length = meta.learn.packet_length;
        digest<learn_5t>(1, meta.learn5);
    }

    action digest_6t() {
        // encoded_packet_length = bit<3> 2;
        meta.learn6.time_stamps = standard_metadata.ingress_global_timestamp[47:0];
        meta.learn6.packet_length = meta.learn.packet_length;
        digest<learn_6t>(1, meta.learn6);
    }



    table d_info {
        key = {
            meta.learn.time_stamps: range;
        }
        
        actions = {
            digest_1t;
            digest_2t;
            digest_3t;
            digest_4t;
            digest_5t;
            digest_6t;
            NoAction;
        }
        size = 2048;
        default_action = NoAction;

        const entries= {
            0x000000000000..0x0000000000ff : digest_1t();
            0x000000000100..0x00000000ffff : digest_2t();
            0x000000010000..0x000000ffffff : digest_3t();
            0x000001000000..0x0000ffffffff : digest_4t();
            0x000100000000..0x00ffffffffff : digest_5t();
            0x010000000000..0xffffffffffff : digest_6t();
        }
    }

    apply {
        mac_learn();
        packet_compression.apply();
        d_info.apply();

        if (hdr.ipv4.isValid()) {
            switch (ipv4_lpm.apply().action_run){
                ecmp_group: {
                    ecmp_group_to_nhop.apply();
                }
            }
        }
    }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply {

    }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers hdr, inout metadata meta) {
     apply {
	update_checksum(
	    hdr.ipv4.isValid(),
            { hdr.ipv4.version,
	          hdr.ipv4.ihl,
              hdr.ipv4.dscp,
              hdr.ipv4.ecn,
              hdr.ipv4.totalLen,
              hdr.ipv4.identification,
              hdr.ipv4.flags,
              hdr.ipv4.fragOffset,
              hdr.ipv4.ttl,
              hdr.ipv4.protocol,
              hdr.ipv4.srcAddr,
              hdr.ipv4.dstAddr },
              hdr.ipv4.hdrChecksum,
              HashAlgorithm.csum16);
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

//switch architecture
V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;

