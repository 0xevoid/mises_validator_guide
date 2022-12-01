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
sudo apt-get install curl pkg-config libssl-dev liblz4-tool chrony bsdmainutils clang tar build-essential ncdu git wget jq make gcc rustc cargo tmux unzip -y

# Install GO
ver="1.18.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# Get testnet version of mis
cd $HOME
git clone -b $MIS_VER $MIS_REPO
cd mises-tm
git checkout $MIS_VER
make install
mv $HOME/go/bin/$MIS /usr/bin/




# GenTx generation

$MIS config chain-id $MIS_ID





# Init generation

$MIS init $MIS_NODENAME --chain-id $MIS_ID




# Download genesis and addrbook

cd $HOME

curl -s $MIS_GENESIS | jq .result.genesis > ~/$MIS_FOLDER/config/genesis.json




# Set Seeds And Peers

#SEEDS=""

PEERS="40889503320199c676570b417b132755d0414332@rpc.gw.mises.site:26656"

#sed -i.default "s/^seeds *=.*/seeds = \"$SEEDS\"/;" $HOME/$MIS_FOLDER/config/config.toml

sed -i.default "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/;" $HOME/$MIS_FOLDER/config/config.toml



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

# Create Service
sudo tee /etc/systemd/system/$MIS.service > /dev/null <<EOF
[Unit]
Description=$MIS
After=network.target

[Service]
Type=simple
User=$USER
ExecStart=$(which $MIS) start
Restart=on-abort

[Install]
WantedBy=multi-user.target

[Service]
LimitNOFILE=65535
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $MIS
sudo systemctl start $MIS

echo -e "\e[1m\e[31mSETUP COMPLETED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $MIS -o cat\e[0m"
echo ""

# End
