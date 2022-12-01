#
# // Copyright (C) 2022 CrazyDAO
#

sudo systemctl stop misestmd

cp $HOME/.misestm/data/priv_validator_state.json $HOME/.misestm/priv_validator_state.json.backup

SNAP_RPC="https://rpc.gw.mises.site:443"
SNAP_RPC2="https://e1.mises.site:443"
SNAP_RPC3="https://e2.mises.site:443"
SNAP_RPC4="https://w1.mises.site:443"
SNAP_RPC5="https://w2.mises.site:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC2,$SNAP_RPC3,$SNAP_RPC4,$SNAP_RPC5\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.misestm/config/config.toml

mv $HOME/.misestm/priv_validator_state.json.backup $HOME/.misestm/data/priv_validator_state.json
sudo systemctl restart misestmd
echo -e "\e[1m\e[32mINFO\e[0m \e[1m\e[31mLOADING FOR CONNECT STATE SYNC ...\e[0m"
sleep 10
sudo journalctl -u misestmd -f --no-hostname -o cat
