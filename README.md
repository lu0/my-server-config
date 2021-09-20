Server configuration
---

Documentation and configuration files for the server I use to host my websites :)

*I'm currently migrating one of my servers and documenting it here to help my future self.*

- [1. SSH Login](#1-ssh-login)
  - [1.1. As root](#11-as-root)
  - [1.2. As rootless](#12-as-rootless)
- [2. Environment](#2-environment)
  - [2.1. Timezone](#21-timezone)
  - [2.2. Bash utilities](#22-bash-utilities)
  - [2.3. Docker](#23-docker)
    - [2.3.1. Install](#231-install)
    - [2.3.2. Rootless Docker](#232-rootless-docker)
  - [2.4. Networking](#24-networking)
- [3. DNS configuration](#3-dns-configuration)
  - [3.1. Reverse DNS](#31-reverse-dns)
  - [3.2. DNS records](#32-dns-records)
    - [3.2.1. A (IPv4) and AAAA (IPv6)](#321-a-ipv4-and-aaaa-ipv6)
    - [3.2.2. TXT and MX (mail)](#322-txt-and-mx-mail)
- [4. Mail server](#4-mail-server)
  - [4.1. Configuration files](#41-configuration-files)
  - [4.2. Create mail accounts](#42-create-mail-accounts)

# 1. SSH Login
## 1.1. As root
Add a SSH key by default on your first setup of the server (with your VPS provider) and make sure you have access to your server using the default key.
```
ssh -i /path/to/your/key root@<ip-address assigned>
```
Disable password logins by setting `UsePaM` and `PasswordAuthentication` to `no` in the `/etc/ssh/sshd_config` file. You should also change the default ssh `Port` to a random number below `1024` and uncomment the lines `MaxAuthTries` and `MaxSessions`.
```zsh
apt install vim
vim /etc/ssh/sshd_config
```
Restart the ssh daemon.
```zsh
systemctl reload sshd
```
Logout from your server and test the default connection. You must receive a "port 22: Connection refused" error if you changed the port.
```zsh
ssh -i /path/to/your/key root@<ip-address assigned>
```
Test the password authentication by providing the correct port. You must receive a "Permission denied (publickey)." error.
```zsh
ssh -p <port configured in sshd_config> root@<ip-address assigned>
```
Finally, login by using your ssh key and the new port.
```zsh
ssh -i /path/to/your/key -p <port> root@<ip-address>
```
## 1.2. As rootless
Create a new key pair in your host machine and store it in a safe path (you can use the same key you use for root logins, but don't).
```zsh
ssh-keygen
```
Login to your server as root.
```zsh
ssh -i /path/to/your/root-key -p <port> root@<ip-address>
```
Create a new user, password and add it to the sudoers group.
```zsh
apt install sudo
useradd -mp "userpassword" <username>
adduser <username> sudo
```
Use the new user:
```zsh
cd /home/<username>
sudo su <username>
```
Create the `authorized_keys` file and paste the contents of the `.pub` section of the key you generated before.
```zsh
mkdir -p ~/.ssh
vim ~/.ssh/authorized_keys
```
Logout from your server, then test the connection with the rootless user.
```zsh
ssh -i /path/to/your/rootless-key -p <port> <username>@<ip-address>
```

# 2. Environment
***I can't stand the default shell...***

## 2.1. Timezone
I like to use the timezone I live in.
```zsh
export TZ="America/Monterrey"
sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
echo $TZ | sudo tee /etc/timezone
```
Restart the shell
```zsh
bash
```
Test the timezone
```zsh
date
```

## 2.2. Bash utilities
I use bash instead of dash.
```zsh
sudo ln -srf /usr/bin/bash /usr/bin/sh
# run 'passwd <username>' logged as root if you forgot your password...
```
Input, aliases and functions I use. Run from this repo folder on your host machine to make a secure copy to your server.
```zsh
scp -P <port> -i /path/to/your/root-key ./bash-utils/inputrc.sh \
    root@<ip-address>:/etc/inputrc

scp -P <port> -i /path/to/your/rootless-key ./bash-utils/bashrc.sh \
    <username>@<ip-address>:/home/<username>/.bashrc

scp -P <port> -i /path/to/your/rootless-key ./bash-utils/bash_aliases.sh \
    <username>@<ip-address>:/home/<username>/.bash_aliases
```
Sometimes I ssh into my servers with VSCode, but it uses dash instead of bash by default on rootless users. Override the default shell the `settings.json` of your host machine with:
```json
"terminal.integrated.defaultProfile.linux": "bash"
```

## 2.3. Docker
I use docker to deploy most of the applications I use.
### 2.3.1. Install
```zsh
sudo apt install -y docker docker.io docker-compose
```
### 2.3.2. Rootless Docker
Follow these steps to use docker with a rootless user, recommended by [docker itself](https://docs.docker.com/engine/install/linux-postinstall/).

Create the `docker` group if it doesn't exist.
```zsh
[ ! $(getent group docker) ] && sudo groupadd docker
```

Add your user to the docker group and apply the changes (you may need to logout from and login to your server.)
```zsh
sudo usermod -aG docker ${USER} && newgrp docker
```

## 2.4. Networking
Some utilities for testing network configurations.
```zsh
sudo apt install -y netcat telnet iputils-ping curl
```

# 3. DNS configuration

The exact steps will vary depending on your registrar and VPS provider, but this is the most common configuration.

## 3.1. Reverse DNS
Create a revers DNS with your VPS provider using the IPv6 address you were assigned.

## 3.2. DNS records
Set your DNS records to link your server with your domain in your registrar's panel.

### 3.2.1. A (IPv4) and AAAA (IPv6)
Point the blank, wildcard (`*`) and `www` prefixes of your hostname to the `IPv4`  and `IPv6` addresses of your server.

### 3.2.2. TXT and MX (mail)
Use this MX record, or create a custom one
```txt
mail.<example-domain>.<com or the TLD you use>
```
Use this TXT record for the blank wildcard, or create your own:
```txt
v=spf1 mx a:mail.example.com -all
```
Use this TXT record for the `_dmarc` prefix, or create your own:
```txt
v=DMARC1; p=reject; rua=mailto:dmarc@example.com; fo=1
```
[Configure a mail server in your VPS](#mail-configuration) to generate a `DKIM` key.


# 4. Mail server
I use `docker-mailserver` as I want my mail server in an isolated environment, but `emailwiz` is a good alternative if you want to create it directly on your filesystem.

## 4.1. Configuration files
Copy the configuration files and source code of `docker-mailserver` to the server:
```zsh
scp -P <port> -i /path/to/your/rootless-key -pr ./mail-server \
    <username>@<ip-address>:/home/<username>/mail-server
```

Run the mail server on your VPS. I'm using the relesase `10.1.2`.
```zsh
docker-compose -f ${HOME}/mail-server/docker-compose.yml up -d --force-recreate
```
Test the script by running it with the `help` argument. I aliased it in the `bash_aliases.sh` file to `mail-setup`.
```zsh
chmod a+x ${GIT_DIR_MAIL}/setup.sh # var exported in ~/.bashrc
mail-setup help
```

## 4.2. Create mail accounts
Use the setup script to create new accounts.
```zsh
mail-setup email add <user@{HOSTNAME}> <password>
mail-setup alias add postmaster@${HOSTNAME} <user@{HOSTNAME}>
```

Create the `DKIM` key, I use a keysize of 2048 as some registrars accept a limited amount of characters.
```zsh
mail-setup config dkim keysize 2048
```
Restart your mail server to apply the changes.
```
docker restart mailserver
```

Run the following alias to print DKI, MX and TXT records you will set up in your registrar. If the DKIM key has multiple lines, concatenate them.
```zsh
# will ask for sudo password
mail-dns-show
```

Wait a few minutes to let the DNS records propagate, and then test them.
```zsh
dig example.com A       # IPv2
dig example.com AAAA    # IPv6
dig example.com MX
dig example.com TXT
dig _dmarc.example.com TXT
dig mail._domainkey.example.com TXT # DKIM
```
