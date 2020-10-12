# Defined in /var/folders/k7/4cy5vy5s0zs309v6mzkn_7gm0000gn/T//fish.3Jkznp/update_kubectl_abbrs.fish @ line 2
function update_kubectl_abbrs
	curl -s -o /tmp/fish-k8s-abbrs https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases
    cat /tmp/fish-k8s-abbrs | sed 's/alias /abrr -a /' | sed "s/='/ '/" > /tmp/kubectl_abbrs.fish
    source /tmp/kubectl_abbrs.fish
    rm /tmp/fish-k8s-abbrs /tmp/kubectl_abbrs.fish
end
