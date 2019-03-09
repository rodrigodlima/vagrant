$TTL 3H
@	IN SOA	@ root.example.com. (
					0	; serial
					1D	; refresh
					1H	; retry
					1W	; expire
					3H )	; minimum
	NS	@
	A	127.0.0.1
	AAAA	::1

server1	A 192.168.33.200
ns1	A 192.168.33.100
