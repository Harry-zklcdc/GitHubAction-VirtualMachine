#linux-run.sh LINUX_USER_PASSWORD NGROK_AUTH_TOKEN LINUX_USERNAME LINUX_MACHINE_NAME XRAY_CONFIG FULLCHAIN_CRT PRIVATE_KEY
#!/bin/bash
# /home/runner/.ngrok2/ngrok.yml

sudo useradd -m $LINUX_USERNAME
sudo adduser $LINUX_USERNAME sudo
echo "$LINUX_USERNAME:$LINUX_USER_PASSWORD" | sudo chpasswd
sed -i 's/\/bin\/sh/\/bin\/bash/g' /etc/passwd
sudo hostname $LINUX_MACHINE_NAME

if [[ -z "$NPS_AUTH_TOKEN" ]]; then
  echo "Please set 'NPS_AUTH_TOKEN'"
  exit 2
fi

if [[ -z "$NPS_ADDRESS" ]]; then
  echo "Please set 'NPS_ADDRESS'"
  exit 3
fi

if [[ -z "$LINUX_USER_PASSWORD" ]]; then
  echo "Please set 'LINUX_USER_PASSWORD' for user: $USER"
  exit 4
fi

echo "### Install NPS ###"

wget -q https://github.com/ehang-io/nps/releases/download/v0.26.10/linux_amd64_client.tar.gz
tar -xzf linux_amd64_client.tar.gz
chmod +x ./npc

echo "### Update user: $USER password ###"
echo -e "$LINUX_USER_PASSWORD\n$LINUX_USER_PASSWORD" | sudo passwd "$USER"

echo "### Start NPS proxy for 22 port ###"
sudo ./npc nat -stun_addr=stun.stunprotocol.org:3478
sudo ./npc install -server="$NPS_ADDRESS" -vkey="$NPS_AUTH_TOKEN" -type=tcp
sudo npc start

sudo mkdir /usr/local/etc/xray/
sudo su
echo $XRAY_CONFIG > /usr/local/etc/xray/config.json
echo $FULLCHAIN_CRT > /home/fullchain.crt
echo $PRIVATE_KEY > /home/private.key
