#macos-run.sh MAC_USER_PASSWORD VNC_PASSWORD NPS_AUTH_TOKEN MAC_REALNAME NPS_ADDRESS

#disable spotlight indexing
sudo mdutil -i off -a

#Create new account
sudo dscl . -create /Users/koolisw
sudo dscl . -create /Users/koolisw UserShell /bin/bash
sudo dscl . -create /Users/koolisw RealName $4
sudo dscl . -create /Users/koolisw UniqueID 1001
sudo dscl . -create /Users/koolisw PrimaryGroupID 80
sudo dscl . -create /Users/koolisw NFSHomeDirectory /Users/koolisw
sudo dscl . -passwd /Users/koolisw $1
sudo dscl . -passwd /Users/koolisw $1
sudo createhomedir -c -u koolisw > /dev/null
sudo dscl . -append /Groups/admin GroupMembership username

#Enable VNC
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -allowAccessFor -allUsers -privs -all
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -clientopts -setvnclegacy -vnclegacy yes 

echo $2 | perl -we 'BEGIN { @k = unpack "C*", pack "H*", "1734516E8BA8C5E2FF1C39567390ADCA"}; $_ = <>; chomp; s/^(.{8}).*/$1/; @p = unpack "C*", $_; foreach (@k) { printf "%02X", $_ ^ (shift @p || 0) }; print "\n"' | sudo tee /Library/Preferences/com.apple.VNCSettings.txt

#Start VNC/reset changes
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -restart -agent -console
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate

#install NPS
sudo cd /Users/koolisw/Desktop/
sudo wget -q https://github.com/ehang-io/nps/releases/download/v0.26.10/darwin_amd64_client.tar.gz
sudo tar -xzf darwin_amd64_client.tar.gz
sudo chmod +x ./npc

#configure ngrok and start it
sudo ./npc install -server=$5 -vkey=$3 -type=tcp
sudo rm -rf /Users/koolisw/Desktop/conf /Users/koolisw/Desktop/darwin_amd64_client.tar.gz
sudo npc start

