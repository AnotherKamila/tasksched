# -*- mode: ruby -*-
# vi: set ft=ruby :

#
# This is totally not an overkill
#
Vagrant.configure("2") do |config|
  config.vm.box = "devuan"
  config.vm.box_url = "https://files.devuan.org/devuan_jessie/virtual/devuan_jessie_1.0.0_amd64_vagrant.box"
  config.ssh.username = 'root'
  config.ssh.password = 'toor'
  config.ssh.forward_agent = false
  config.vm.guest = :debian
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "512"
  end
  
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.define "tasksched" do |ansible|
    ansible.vm.network "forwarded_port", guest: 5000, host: 5000
    ansible.vm.hostname = "tasksched-vm"
    ansible.vm.provision "shell", inline: <<-SHELL
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical
# Update keyring
apt-get update -q
apt-get install -qy devuan-keyring
# Switch to Round Robin mirrors
sed -i 's/auto.mirror/deb/g' /etc/apt/sources.list
# Upgrade VM to ascii
sed -i 's/jessie/ascii/g' /etc/apt/sources.list
apt-get update -q
apt-get dist-upgrade -qy
apt-get upgrade -qy
# Install dependencies
apt-get install make git task -qy
# Add NodeJS repositories
echo "deb http://deb.nodesource.com/node_9.x/ stretch main" >> /etc/apt/sources.list.d/nodejs.list
wget -qO- https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
apt-get update -qy
# Do install NodeJS
apt-get install nodejs -qy
# Create user
adduser --disabled-password --gecos "" tasks
# Get actual code
git clone https://github.com/AnotherKamila/tasksched /srv/tasksched
chown -R tasks:tasks /srv/tasksched

# Create one-line exec script
cat >/srv/tasksched.sh << SH
#!/bin/sh
cd /srv/tasksched
make run
SH
# Fix permissions
chmod 755 /srv/tasksched.sh
# Install and setup monit
apt-get install monit -qy
sed -i 's/  set daemon 120/  set daemon 30/g' /etc/monit/monitrc
cat >/etc/monit/conf.d/tasksched << MONIT
check process tasksched
    matching "node"
    start program = "/srv/tasksched.sh"
        as uid "tasks" and gid "tasks"
    stop program = "/usr/bin/killall node"
    if failed host 127.0.0.1 port 5000 then restart
MONIT
# Reboot, we want those kernel patches
reboot
    SHELL
  end
end
