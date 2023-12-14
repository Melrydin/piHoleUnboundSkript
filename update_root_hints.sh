#!/bin/bash
wget -O root.hints https://www.internic.net/domain/named.root &&
(
mv -fv root.hints /var/lib/unbound/
service unbound restart
)