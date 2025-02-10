cat << EOF > ~/.ssh/config

# Read more about SSH config files: https://linux.die.net/man/5/ssh_config
Host ${hostname}
    HostName ${hostname}
    User ${user}
    IdentityFile ${identifyfile}

EOF