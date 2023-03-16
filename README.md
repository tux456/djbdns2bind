# djbdns2bind
Basic DNS zone converter from tinydns to bind

Can convert basic NS, CNAME, A, PTR entries.  Work in progress, don't use without reviewing/editing manualy the result.

Usage:

````
export ORIGIN=example.org ZONETYPE=DIRECT MASTER=ns.example.org;bash djb2bind.sh djbexample.data > bindexample.data

export ORIGIN=3.2.3.in-addr.arpa ZONETYPE=PTR master=ns.example.org;bash djb2bind.sh djb123.data  > bind123.data
````