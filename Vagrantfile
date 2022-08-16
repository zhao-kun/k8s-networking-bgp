# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 2.0.0"

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
$vm_memory ||= 2048
$vm_cpus ||= 2
$subnet ||= "172.18.8"
Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2004"
  #config.vm.network "public_network"
  (1..2).each do |i|
    config.vm.define vm_name = "bgp-%01d" % [i] do |node|
      node.vm.hostname = vm_name
      ip = "#{$subnet}.#{i+100}"
      node.vm.network :private_network, ip: ip
      node.vm.provider :virtualbox do |vb|
        vb.memory = $vm_memory
        vb.cpus = $vm_cpus
        vb.linked_clone = true
        vb.customize ["modifyvm", :id, "--vram", "8"] # ubuntu defaults to 256 MB which is a waste of precious RAM
        vb.customize ["modifyvm", :id, "--audio", "none"]
      end
      node.vm.provision "file", source: "gobgpd-#{i}.yml", destination: "gobgpd.yml"
      node.vm.provision "shell", inline: "sudo cp gobgpd.yml /etc/gobgpd.yml"
      node.vm.provision "file", source: "create_pod_impl.sh", destination: "CREATE_POD.sh"
      node.vm.provision "file", source: "gobgpd.service", destination: "gobgpd.service"
      node.vm.provision "shell", inline: "sudo cp gobgpd.service /lib/systemd/system/gobgpd.service"
      node.vm.provision "shell", inline: <<-SHELL
sudo systemctl daemon-reload
sudo systemctl restart gobgpd.service
SHELL
    end
  end
  config.vm.provision "shell", inline: <<-SHELL
sudo apt update -y
sudo apt install -y quagga-core
sudo touch /etc/quagga/zebra.conf
sudo systemctl restart zebra
curl -sL -ogobgp_3.5.0_linux-amd64.tar.gz  https://github.com/osrg/gobgp/releases/download/v3.5.0/gobgp_3.5.0_linux_amd64.tar.gz
sudo tar -C /usr/local/bin -xvf gobgp_3.5.0_linux-amd64.tar.gz
SHELL
end
