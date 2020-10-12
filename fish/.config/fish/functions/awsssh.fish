# Defined in /var/folders/k7/4cy5vy5s0zs309v6mzkn_7gm0000gn/T//fish.PLG552/awsssh.fish @ line 2
function awsssh
	ssh -o StrictHostKeyChecking=no -o ConnectTimeout=1 -o ConnectionAttempts=10 -i ~/.ssh/aws-shaun-mbp.pem ubuntu@$argv[1]
end
