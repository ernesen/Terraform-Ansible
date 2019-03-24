#!/usr/bin/expect -f

set host_user [lindex $argv 0]
set host_pass [lindex $argv 1]
set host_name [lindex $argv 2]

# no need for timeout 1
set timeout 60

spawn /usr/bin/ssh-copy-id -i ~/.ssh/id_rsa.pub $host_user@$host_name
expect {
   "*yes/no*" { send "yes\r" ; exp_continue }
   "*assword:" { send "$host_pass\r" ; exp_continue }
   timeout { exit }
}
