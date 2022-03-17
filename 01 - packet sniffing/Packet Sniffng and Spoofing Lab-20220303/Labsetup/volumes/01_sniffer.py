from scapy.all import *
from scapy.all import ICMP, IP, UDP

# Task 1.2A
# sniff all the icmp packets
# def printer(pkt):
#     pkt.show()
# pkt = sniff(iface="br-08174a224f46", filter="icmp", prn=printer)

# Task 1.1B
# sniff all the tcp packets from 10.9.0.5 with port 23
    # sniff() uses Berkeley Packet Filter (BPF) syntax (the same one as tcpdump)
# pkt = sniff(iface="br-08174a224f46", filter="tcp and src host 10.9.0.5 and dst port 23", prn=printer)

# Task 1.2: Spoofing ICMP Packets
# pkt = IP(src='10.9.0.5', dst='10.9.0.6')/ICMP()
# send(pkt, count=1, verbose=0)

# Task 1.3: Traceroute
    # ttl (Time-To-Live)attribute is present in IP packets. 
        # Each time a machine receives an IP packet decrease ttl by 1. 
        # This is used to avoid infinite loops.
# hostname = "youtube.com"
# dport = 80
# counter = 27
# for i in range(27):
#     pkt = IP(dst=hostname, ttl=i) / UDP(dport=dport)
#     # Send the packet and get a reply
#     response = sr1(pkt, verbose=0, timeout=1)
#     if response is None: # there is no reply!
#         print("[*] There is no reply")
#         continue

#     elif response.type == 3: # destination reached
#         print("Destination reached! ", response.src)
#         break
#     else: # we are in the path
#         print("[{}] ".format(i), response.src)


# Task 1.4: Sniﬀing and-then Spoofing
    # ICMP Type --> https://www.ibm.com/docs/en/qsip/7.4?topic=applications-icmp-type-code-ids

# # host = '1.2.3.4'
# host = '10.9.0.99'
# # host = '8.8.8.8'

# def spoof(pkt):
#     # icmp type == 8 --> echo 
#     if pkt[ICMP].type == 8:
#         # spoof an icmp echo reply
#         # icmp type == 0 --> echo reply
#         s_pck = IP(src=pkt[IP].dst, dst=pkt[IP].src, ihl=pkt[IP].ihl) / ICMP(type=0, id=pkt[ICMP].id, seq=pkt[ICMP].seq) / pkt[Raw].load
#         send(s_pck, verbose=0)
#         print("packet sent")
#         # IP PACKET
#         # Internet Header Length (IHL)
#             # The IPv4 header is variable in size due to the optional 14th field (options). 
#             # The IHL field contains the size of the IPv4 header, it has 4 bits that specify the number of 32-bit words in the header. 
#             # The minimum value for this field is 5, which indicates a length of 5 × 32 bits = 160 bits = 20 bytes. As a 4-bit field, 
#             # the maximum value is 15, this means that the maximum size of the IPv4 header is 15 × 32 bits = 480 bits = 60 bytes.
# pkt = sniff(iface="br-08174a224f46", filter="icmp and host " + host, prn=spoof)