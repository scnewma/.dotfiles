function flush_dns
	dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
end
