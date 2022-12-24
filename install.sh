#!/bin/bash

echo -e "\033[0;35m"
echo "                                                                       "
echo " ███╗   ███╗██████╗    ██████╗ ███████╗███╗   ██╗██████╗  ██████╗ ██╗  "  
echo " ████╗ ████║██╔══██╗   ██╔══██╗██╔════╝████╗  ██║██╔══██╗██╔═══██╗██║  "  
echo " ██╔████╔██║██████╔╝   ██████╔╝█████╗  ██╔██╗ ██║██║  ██║██║   ██║██║  " 
echo " ██║╚██╔╝██║██╔══██╗   ██╔═══╝ ██╔══╝  ██║╚██╗██║██║  ██║██║   ██║██║  "  
echo " ██║ ╚═╝ ██║██║  ██║██╗██║     ███████╗██║ ╚████║██████╔╝╚██████╔╝███████╗ "
echo " ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝     ╚══════╝╚═╝  ╚═══╝╚═════╝  ╚═════╝ ╚══════╝ "
echo "                    Auto Installer Mises Mainnet                         ";
echo -e "\e[0m"
sleep 2

# Variable
MIS_WALLET=wallet
MIS=misestmd
MIS_ID=mainnet
MIS_FOLDER=.misestm
MIS_VER=1.0.4
MIS_REPO=https://github.com/mises-id/mises-tm
MIS_GENESIS=https://e1.mises.site:443/genesis
#MIS_ADDRBOOK=
MIS_DENOM=umis

echo "export MIS_WALLET=${MIS_WALLET}" >> $HOME/.bash_profile
echo "export MIS=${MIS}" >> $HOME/.bash_profile
echo "export MIS_ID=${MIS_ID}" >> $HOME/.bash_profile
echo "export MIS_FOLDER=${MIS_FOLDER}" >> $HOME/.bash_profile
echo "export MIS_VER=${MIS_VER}" >> $HOME/.bash_profile
echo "export MIS_REPO=${MIS_REPO}" >> $HOME/.bash_profile
echo "export MIS_GENESIS=${MIS_GENESIS}" >> $HOME/.bash_profile
#echo "export MIS_ADDRBOOK=${MIS_ADDRBOOK}" >> $HOME/.bash_profile
echo "export MIS_DENOM=${MIS_DENOM}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $MIS_NODENAME ]; then
	read -p "ahnesianews1@gmail.com:~# [ENTER YOUR NODE] > " MIS_NODENAME
	echo 'export MIS_NODENAME='$MIS_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$MIS_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$MIS_ID\e[0m"
echo ""

# Update
sudo apt-get update && sudo apt-get upgrade -y

# Package
sudo apt install jq lz4 build-essential -y

# Get mainnet version of mises
cd $HOME
wget $MIS_REPO$MIS_VER/misestmd.linux-amd64.tar.gz
tar -xvf misestmd.linux-amd64.tar.gz
sudo mv build/$MIS /usr/bin/
chmod +x /usr/bin/$MIS
rm -f misestmd.linux-amd64.tar.gz
rm -rf build

# Create Service
sudo tee /etc/systemd/system/$MIS.service > /dev/null <<EOF
[Unit]
Description=$MIS
After=network-online.target
[Service]
User=$USER
ExecStart=$(which $MIS) start --home $HOME/$MIS_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# Register service
sudo systemctl daemon-reload
sudo systemctl enable $MIS

# Init generation
$MIS config chain-id $MIS_ID
$MIS init $MIS_NODENAME --chain-id $MIS_ID

# Set Seeds And Peers
PEERS=40a8318fa18fa9d900f4b0d967df7b1020689fa0@e1.mises.site:26656
sed -i -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/$MIS_FOLDER/config/config.toml

# Create file genesis.json
touch $HOME/$MIS_FOLDER/config/genesis.json

# Set Config Gas
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.000025$MIS_DENOM\"/" $HOME/$MIS_FOLDER/config/app.toml

# Set Config prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/$MIS_FOLDER/config/config.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$MIS_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$MIS_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$MIS_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$MIS_FOLDER/config/app.toml

# Set config snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"1000\"/" $HOME/$MIS_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"2\"/" $HOME/$MIS_FOLDER/config/app.toml

# Enable state sync
$MIS unsafe-reset-all

SNAP_RPC="https://e1.mises.site:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo ""
echo -e "\e[1m\e[31m[!]\e[0m HEIGHT : \e[1m\e[31m$LATEST_HEIGHT\e[0m BLOCK : \e[1m\e[31m$BLOCK_HEIGHT\e[0m HASH : \e[1m\e[31m$TRUST_HASH\e[0m"
echo ""

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/$MIS_FOLDER/config/config.toml

# Start Service
sudo systemctl start $MIS

echo -e "\e[1m\e[31m[!]\e[0m SETUP FINISHED"
echo -e "\e[1m\e[31m[!]\e[0m STATE SYNC ESTIMATION CAN TAKE 15-30 MINS PLEASE WAITTING"
echo ""
echo -e "\e[1m\e[31m[!]\e[0m CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $MIS -o cat\e[0m"
echo ""

# End
