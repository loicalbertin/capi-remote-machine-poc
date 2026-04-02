Vagrant.configure("2") do |config|
  # Générer une clé SSH
  ssh_key_path = File.expand_path(".vagrant/id_rsa_vagrant")
  unless File.exist?(ssh_key_path)
    system("ssh-keygen -t rsa -b 4096 -f #{ssh_key_path} -N ''")
  end

  # Lire la clé privée
  ssh_private_key = File.read(ssh_key_path)

  config.vm.define "control-plane" do |node|
    # node.vm.box = "ubuntu/jammy64"
    node.vm.box = "cloud-image/ubuntu-24.04"
    # node.vm.network "private_network_lv", ip: "192.168.56.10"
    node.vm.network "private_network", ip: "192.168.57.10", 
                    netmask: "255.255.255.0",
                    libvirt__network_name: "capi_test",
                    libvirt__network_address: "192.168.57.0/24"
    # node.vm.provider "virtualbox" do |vb|
    #   vb.memory = "2048"
    #   vb.cpus = 4
    # end

    
    node.vm.provider "libvirt" do |libvirt|
        libvirt.driver = "kvm"
        libvirt.memory = 2048  # 1GB RAM
        libvirt.cpus = 4       # 2 CPU
        # libvirt.storage_pool_name = "default"
    end

    node.vm.provision "shell", inline: <<-SHELL
        sudo hostnamectl set-hostname cluster2-remote-cp-0
        sudo apt-get update
        # apt-transport-https may be a dummy package; if so, you can skip that package
        sudo apt-get install -y apt-transport-https ca-certificates curl gpg
       
        sudo install -m 0755 -d /etc/apt/keyrings

        curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
        # This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
        echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc
        sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
     
        sudo apt-get update
        sudo apt-get install -y kubelet kubeadm kubectl containerd.io
        sudo apt-mark hold kubelet kubeadm kubectl containerd.io

        sudo systemctl enable --now kubelet

        sudo sysctl -w net.ipv4.ip_forward=1

        sudo containerd config default | sudo tee  /etc/containerd/config.toml
        sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
        sudo systemctl restart containerd
    SHELL

    # Injecter la clé SSH dans la VM
    node.vm.provision "file", source: ssh_key_path, destination: "~/.ssh/id_rsa"
    node.vm.provision "file", source: "#{ssh_key_path}.pub", destination: "~/.ssh/id_rsa.pub"

    node.vm.provision "shell", inline: <<-SHELL
        cat ~vagrant/.ssh/id_rsa.pub >> ~vagrant/.ssh/authorized_keys
        chmod 600 ~vagrant/.ssh/authorized_keys
    SHELL


    node.vm.cloud_init do |cloud_init|
        cloud_init.content_type = "text/cloud-config"
        cloud_init.inline = <<-EOF
        hostname: cluster2-remote-cp-0
        create_hostname_file: true
        manage_etc_hosts: true
        EOF
    end
  end

  config.vm.define "worker" do |node|
    # node.vm.box = "ubuntu/jammy64"
    node.vm.box = "cloud-image/ubuntu-24.04"
    node.vm.network "private_network", ip: "192.168.57.11", 
            netmask: "255.255.255.0",
            libvirt__network_name: "capi_test",
            libvirt__network_address: "192.168.57.0/24"
    # node.vm.provider "virtualbox" do |vb|
    #   vb.memory = "2048"
    #   vb.cpus = 2
    # end
    

    node.vm.provider "libvirt" do |libvirt|
        libvirt.driver = "kvm"
        libvirt.memory = 2048  # 1GB RAM
        libvirt.cpus = 4       # 2 CPU
        # libvirt.storage_pool_name = "default"
    end
        node.vm.provision "shell", inline: <<-SHELL
        sudo hostnamectl set-hostname cluster2-remote-worker-0
        sudo apt-get update
        # apt-transport-https may be a dummy package; if so, you can skip that package
        sudo apt-get install -y apt-transport-https ca-certificates curl gpg
       
        sudo install -m 0755 -d /etc/apt/keyrings

        curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
        # This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
        echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc
        sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
     
        sudo apt-get update
        sudo apt-get install -y kubelet kubeadm kubectl containerd.io
        sudo apt-mark hold kubelet kubeadm kubectl containerd.io

        sudo systemctl enable --now kubelet

        sudo sysctl -w net.ipv4.ip_forward=1

        sudo containerd config default | sudo tee  /etc/containerd/config.toml
        sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
        sudo systemctl restart containerd
    SHELL

    # Injecter la clé SSH dans la VM
    node.vm.provision "file", source: ssh_key_path, destination: "~/.ssh/id_rsa"
    node.vm.provision "file", source: "#{ssh_key_path}.pub", destination: "~/.ssh/id_rsa.pub"

    node.vm.provision "shell", inline: <<-SHELL
        cat ~vagrant/.ssh/id_rsa.pub >> ~vagrant/.ssh/authorized_keys
        chmod 600 ~vagrant/.ssh/authorized_keys
    SHELL


    node.vm.cloud_init do |cloud_init|
        cloud_init.content_type = "text/cloud-config"
        cloud_init.inline = <<-EOF
        hostname: cluster2-remote-worker-0
        create_hostname_file: true
        manage_etc_hosts: true
        EOF
    end
  end
end