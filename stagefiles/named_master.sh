
if [ -f /var/named/internal.lab ];then
  echo "named already configured in $HOSTNAME"
  exit 0
fi

chkconfig named on
touch /var/named/internal.lab
chmod 664 /var/named/internal.lab
chgrp named /var/named/internal.lab
chmod g+w /var/named
chmod g+w /var/named/internal.lab

cp /etc/named.conf /etc/named.conf.ori

grep '192.168.78.51' /etc/named.conf && echo "already configured " || sed -i -e 's/listen-on .*/listen-on port 53 { 192.168.78.51; 127.0.0.1; };/' \
-e 's/allow-query .*/allow-query     { 192.168.78.0\/24; localhost; };\n        allow-transfer  { 192.168.78.0\/24; };/' \
-e '$azone "internal.lab" {\n  type master;\n  file "internal.lab";\n};\n\nzone "in-addr.arpa" {\n  type master;\n  file "in-addr.arpa";\n};' \
/etc/named.conf


echo '$ORIGIN .
$TTL 10800      ; 3 hours
internal.lab               IN SOA  dbnode1.internal.lab. hostmaster.internal.lab. (
                                101        ; serial
                                86400      ; refresh (1 day)
                                3600       ; retry (1 hour)
                                604800     ; expire (1 week)
                                10800      ; minimum (3 hours)
                                )
                        NS      dbnode1.internal.lab.
                        NS      dbnode2.internal.lab.
$ORIGIN internal.lab.
dbnode-cluster-scan    A       192.168.78.251
                        A       192.168.78.252
                        A       192.168.78.253
dbnode1                A       192.168.78.51
dbnode1-priv           A       172.16.100.51
dbnode1-vip            A       192.168.78.61
dbnode2                A       192.168.78.52
dbnode2-priv           A       172.16.100.52
dbnode2-vip            A       192.168.78.62
dbnode3                A       192.168.78.53
dbnode3-priv           A       172.16.100.53
dbnode3-vip            A       192.168.78.63
dbnode4                A       192.168.78.54
dbnode4-priv           A       172.16.100.54
dbnode4-vip            A       192.168.78.64
dbnode5                A       192.168.78.55
dbnode5-priv           A       172.16.100.55
dbnode5-vip            A       192.168.78.65
dbnode6                A       192.168.78.56
dbnode6-priv           A       172.16.100.56
dbnode6-vip            A       192.168.78.66
dbnode7                A       192.168.78.57
dbnode7-priv           A       172.16.100.57
dbnode7-vip            A       192.168.78.67
dbnode8                A       192.168.78.58
dbnode8-priv           A       172.16.100.58
dbnode8-vip            A       192.168.78.68
dbnode9                A       192.168.78.59
dbnode9-priv           A       172.16.100.59
dbnode9-vip            A       192.168.78.69
dbleafnode1                A       192.168.78.71
dbleafnode1-priv           A       172.16.100.71
dbleafnode1-vip            A       192.168.78.81
dbleafnode2                A       192.168.78.72
dbleafnode2-priv           A       172.16.100.72
dbleafnode2-vip            A       192.168.78.82
dbleafnode3                A       192.168.78.73
dbleafnode3-priv           A       172.16.100.73
dbleafnode3-vip            A       192.168.78.83
dbleafnode4                A       192.168.78.74
dbleafnode4-priv           A       172.16.100.74
dbleafnode4-vip            A       192.168.78.84
dbleafnode5                A       192.168.78.75
dbleafnode5-priv           A       172.16.100.75
dbleafnode5-vip            A       192.168.78.85
dbleafnode6                A       192.168.78.76
dbleafnode6-priv           A       172.16.100.76
dbleafnode6-vip            A       192.168.78.86
dbleafnode7                A       192.168.78.77
dbleafnode7-priv           A       172.16.100.77
dbleafnode7-vip            A       192.168.78.87
dbleafnode8                A       192.168.78.78
dbleafnode8-priv           A       172.16.100.78
dbleafnode8-vip            A       192.168.78.88
dbleafnode9                A       192.168.78.79
dbleafnode9-priv           A       172.16.100.79
dbleafnode9-vip            A       192.168.78.89
appnode1                A       192.168.78.91
appnode2                A       192.168.78.92
appnode3                A       192.168.78.93
appnode4                A       192.168.78.94
appnode5                A       192.168.78.95
appnode6                A       192.168.78.96
appnode7                A       192.168.78.97
appnode8                A       192.168.78.98
appnode9                A       192.168.78.99
localhost               A       127.0.0.1
localhost.              A       127.0.0.1
dbnode-cluster-gns.internal.lab.     A       192.168.78.244
$ORIGIN dbnode.internal.lab.
@                       NS      dbnode-cluster-gns.internal.lab.
' \
> /var/named/internal.lab


echo '$ORIGIN .
$TTL 10800      ; 3 hours
in-addr.arpa            IN SOA  dbnode1.internal.lab. hostmaster.internal.lab. (
                                101        ; serial
                                86400      ; refresh (1 day)
                                3600       ; retry (1 hour)
                                604800     ; expire (1 week)
                                10800      ; minimum (3 hours)
                                )
                        NS      dbnode1.internal.lab.
                        NS      dbnode2.internal.lab.
$ORIGIN 100.16.172.in-addr.arpa.
51                      PTR     dbnode1-priv.internal.lab.
52                      PTR     dbnode2-priv.internal.lab.
53                      PTR     dbnode3-priv.internal.lab.
54                      PTR     dbnode4-priv.internal.lab.
55                      PTR     dbnode5-priv.internal.lab.
56                      PTR     dbnode6-priv.internal.lab.
57                      PTR     dbnode7-priv.internal.lab.
58                      PTR     dbnode8-priv.internal.lab.
59                      PTR     dbnode9-priv.internal.lab.
71                      PTR     dbleafnode1-priv.internal.lab.
72                      PTR     dbleafnode2-priv.internal.lab.
73                      PTR     dbleafnode3-priv.internal.lab.
74                      PTR     dbleafnode4-priv.internal.lab.
75                      PTR     dbleafnode5-priv.internal.lab.
76                      PTR     dbleafnode6-priv.internal.lab.
77                      PTR     dbleafnode7-priv.internal.lab.
78                      PTR     dbleafnode8-priv.internal.lab.
79                      PTR     dbleafnode9-priv.internal.lab.
$ORIGIN 78.168.192.in-addr.arpa.
251                     PTR     dbnode-cluster-scan.internal.lab.
252                     PTR     dbnode-cluster-scan.internal.lab.
253                     PTR     dbnode-cluster-scan.internal.lab.
244			PTR	dbnode-cluster-gns.internal.lab.
51                      PTR     dbnode1.internal.lab.
52                      PTR     dbnode2.internal.lab.
53                      PTR     dbnode3.internal.lab.
54                      PTR     dbnode4.internal.lab.
55                      PTR     dbnode5.internal.lab.
56                      PTR     dbnode6.internal.lab.
57                      PTR     dbnode7.internal.lab.
58                      PTR     dbnode8.internal.lab.
59                      PTR     dbnode9.internal.lab.
61                      PTR     dbnode1-vip.internal.lab.
62                      PTR     dbnode2-vip.internal.lab.
63                      PTR     dbnode3-vip.internal.lab.
64                      PTR     dbnode4-vip.internal.lab.
65                      PTR     dbnode5-vip.internal.lab.
66                      PTR     dbnode6-vip.internal.lab.
67                      PTR     dbnode7-vip.internal.lab.
68                      PTR     dbnode8-vip.internal.lab.
69                      PTR     dbnode9-vip.internal.lab.
71                      PTR     dbleafnode1.internal.lab.
81                      PTR     dbleafnode1-vip.internal.lab.
72                      PTR     dbleafnode2.internal.lab.
82                      PTR     dbleafnode2-vip.internal.lab.
73                      PTR     dbleafnode3.internal.lab.
83                      PTR     dbleafnode3-vip.internal.lab.
74                      PTR     dbleafnode4.internal.lab.
84                      PTR     dbleafnode4-vip.internal.lab.
75                      PTR     dbleafnode5.internal.lab.
85                      PTR     dbleafnode5-vip.internal.lab.
76                      PTR     dbleafnode6.internal.lab.
86                      PTR     dbleafnode6-vip.internal.lab.
77                      PTR     dbleafnode7.internal.lab.
87                      PTR     dbleafnode7-vip.internal.lab.
78                      PTR     dbleafnode8.internal.lab.
88                      PTR     dbleafnode8-vip.internal.lab.
79                      PTR     dbleafnode9.internal.lab.
89                      PTR     dbleafnode9-vip.internal.lab.
91                      PTR     appnode1.internal.lab.
92                      PTR     appnode2.internal.lab.
93                      PTR     appnode3.internal.lab.
94                      PTR     appnode4.internal.lab.
95                      PTR     appnode5.internal.lab.
96                      PTR     appnode6.internal.lab.
97                      PTR     appnode7.internal.lab.
98                      PTR     appnode8.internal.lab.
99                      PTR     appnode9.internal.lab.
' \
> /var/named/in-addr.arpa



if [ ! -f /etc/rndc.key ] ; then
  rndc-confgen -a -r /dev/urandom
  chgrp named /etc/rndc.key
  chmod g+r /etc/rndc.key
  service named restart || true
fi

# final command must return success or vagrant thinks the script failed
echo "successfully completed named steps"
