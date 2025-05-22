type -q terraform || return

abbr -ag tf terraform
abbr -ag tfi terraform init
abbr -ag tfa terraform apply
abbr -ag tfaa terraform apply --auto-approve
abbr -ag tfp terraform plan
