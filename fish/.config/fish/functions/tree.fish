# Defined in /var/folders/k2/p4mkwx394s19tbkd966wpx5m8_rkkb/T//fish.EliwzL/tree.fish @ line 1
function tree
	set realtree /usr/local/bin/tree
    echo "ignoring vendor/; run $realtree if you want to show vendor as well" >&2
    $realtree -I vendor $argv
end
