Vagrant.configure("2") do |config|
  # bento boxes support ARM64 (Apple Silicon) and x86_64
  config.vm.box = "bento/debian-12"
  config.vm.hostname = "cuddlephish"

  # Forward Fastify port for local testing (no Caddy TLS in dev)
  config.vm.network "forwarded_port", guest: 58082, host: 58082

  # ── Apple Silicon (ARM) ──────────────────────────────────────────────────────
  # Install Parallels Desktop (https://www.parallels.com) and the plugin:
  #   vagrant plugin install vagrant-parallels
  config.vm.provider "parallels" do |prl|
    prl.name = "cuddlephish"
    prl.memory = 4096
    prl.cpus = 2
  end

  # ── Apple Silicon alternative: VMware Fusion (free for personal use) ─────────
  # Install VMware Fusion and the plugin:
  #   vagrant plugin install vagrant-vmware-desktop
  config.vm.provider "vmware_desktop" do |vmw|
    vmw.vmx["displayname"] = "cuddlephish"
    vmw.memory = 4096
    vmw.cpus = 2
  end

  # ── Intel Mac / Linux ────────────────────────────────────────────────────────
  config.vm.provider "virtualbox" do |vb|
    vb.name = "cuddlephish"
    vb.memory = 4096
    vb.cpus = 2
    vb.customize ["modifyvm", :id, "--vram", "128"]
  end

  # Sync the project directory into the VM
  config.vm.synced_folder ".", "/home/vagrant/cuddlephish"

  config.vm.provision "shell", inline: <<-SHELL
    set -e

    echo "==> Installing Docker..."
    apt-get update -qq
    apt-get install -y -qq ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
      | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -qq
    apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    echo "==> Adding vagrant user to docker group..."
    usermod -aG docker vagrant

    echo "==> Installing Node 20 via nvm..."
    apt-get install -y -qq curl
    su - vagrant -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash"
    su - vagrant -c "source ~/.nvm/nvm.sh && nvm install 20 && nvm alias default 20"

    echo "==> Installing system deps for Chrome/Xvfb..."
    apt-get install -y -qq \
      xvfb \
      libnss3 \
      libasound2 \
      libgbm-dev \
      libgtk-3-0 \
      libx11-xcb1 \
      libxcomposite1 \
      libatk1.0-0 \
      libatk-bridge2.0-0 \
      libcairo2 \
      libcups2 \
      libdbus-1-3 \
      libexpat1 \
      libfontconfig1 \
      libgbm1 \
      libgcc1 \
      libglib2.0-0 \
      libnspr4 \
      libpango-1.0-0 \
      libpangocairo-1.0-0 \
      libstdc++6 \
      libx11-6 \
      libxcb1 \
      libxcursor1 \
      libxdamage1 \
      libxext6 \
      libxfixes3 \
      libxi6 \
      libxrandr2 \
      libxrender1 \
      libxss1 \
      libxtst6

    echo "==> Done. SSH in with: vagrant ssh"
    echo "    Project is at: /home/vagrant/cuddlephish"
    echo ""
    echo "    To run bare-metal:"
    echo "      cd /home/vagrant/cuddlephish"
    echo "      npm install"
    echo "      node index.js <target>"
    echo ""
    echo "    To run via Docker Compose:"
    echo "      cd /home/vagrant/cuddlephish"
    echo "      CUDDLEPHISH_TARGET=example docker compose up --build"
  SHELL
end
