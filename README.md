---
Description: >-
  Mises is a social network protocol based on blockchain technology, it helps
  developer build decentralized social media applications on blockchain.
---

# Mises Validator Mainnet

[DOC](https://github.com/mises-id/mises-tm)

[Register Validator](https://docs.google.com/forms/u/0/d/e/1FAIpQLSdTqmA_ZfzIB5rWPI_GVA5X7joPG7ZKI5pU-VreI3_BhY0dtQ/viewform?usp=form_confirm)

[Detail](https://www.mises.site/validator)

# Tutorial Running Validator Mises On Mainnet

<p align="center">
  <img height="auto" width="auto" src="https://user-images.githubusercontent.com/112532410/205029097-6f4b724c-7b50-4300-83c4-3c7513aa125a.jpeg">
</p>


## HARDWARE 

| Component | Minimum Requirements  |
| ------------ | ------------ |
| CPU  | Intel Core i7-8700 Hexa-Core  |
| RAM |  4 GB  |
| Storage  | 80GB NVMe SSD |

## SOFTWARE 

| Component | Minimum Requirements |
| ------------ | ------------ |
| OS |  Ubuntu 18.04 | 

>NOTE: Before Running a Node, Make Sure You Have Mises ON Mainnet

# Installing Mises mainnet
To installing Installing Mises mainnet you can run command below
```
wget https://raw.githubusercontent.com/0xevoid/mises_validator_guide/main/install.sh && chmod +x install.sh && ./install.sh
```
>Wait for the install process to finish


### Useful Commands

   * Check sync node
```
misestmd status 2>&1 | jq .SyncInfo
```
>NOTE: This Command is used To begin with you create a Validator, Please remember the status in ("catching_up": false) should be like that!!!
   * Check log node
```
journalctl -fu misestmd -o cat
```
   * Check node info
```
misestmd status 2>&1 | jq .NodeInfo
```
   * Check validator info
```
misestmd status 2>&1 | jq .ValidatorInfo
```
  * Check node id
```
misestmd tendermint show-node-id
```
  * Check Valoper Address
```
misestmd keys show $WALLET --bech val -a
```
* Check balance
```
misestmd query bank balances $MISES_WALLET_ADDRESS
```
### Prepare Wallet
* Create a new wallet
```
misestmd keys add $WALLET
```

* Recover wallets
```
misestmd keys add $WALLET --recover
```

* See a list of wallets
```
misestmd keys list
```

* Deleting wallets
```
misestmd keys delete $WALLET
```
### Save wallet information
```
MISES_WALLET_ADDRESS=$(misestmd keys show $WALLET -a)
MISES_VALOPER_ADDRESS=$(misestmd keys show $WALLET --bech val -a)
echo 'export MISES_WALLET_ADDRESS='${MISES_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export MISES_VALOPER_ADDRESS='${MISES_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```
### Create validators
```
misestmd tx staking create-validator \
   --amount 1000000umis \
   --from $WALLET \
   --commission-max-change-rate "0.01" \
   --commission-max-rate "0.2" \
   --commission-rate "0.07" \
   --min-self-delegation "1" \
   --pubkey $(misestmd tendermint show-validator) \
   --moniker $NODENAME \
   --fees 250umis \
   --chain-id $MISES_CHAIN_ID
```
* Edit validators
```
misestmd tx staking edit-validator \
   --moniker="node-name" \
   --identity="<your_keybase_id>" \
   --website="<your_website>" \
   --details="<your_validator_description>" \
   --chain-id=$MISES_CHAIN_ID \
   --fees 250umis \
   --from=$WALLET
```
  *Unjail validator
```
misestmd tx slashing unjail \
   --broadcast-mode=block \
   --from=$WALLET \
   --chain-id=$MISES_CHAIN_ID \
   --fees=250umis
```
### Vote
```
misestmd tx gov vote 1 yes --from $WALLET --chain-id=$MISES_CHAIN_ID
```
### Delegation and Rewards
   * Delegate
```
misestmd tx staking delegate $MISES_VALOPER_ADDRESS 1000000umis --from=$WALLET --chain-id=MISES_CHAIN_ID --fees=250umis
```
   *Withdraw rewards
```
misestmd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$MISES_CHAIN_ID --fees=250umis
```
   * Withdrawal rewards and commissions
```
misestmd tx distribution withdraw-rewards $MISES_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$MISES_CHAIN_ID
```
### Stop Nodes

```
sudo systemctl stop misestmd
```

### Restart Node

```
sudo systemctl restart misestmd
```

### Delete node If it is no longer used
```
sudo systemctl stop misestmd && \
sudo systemctl disable misestmd && \
rm /etc/systemd/system/misestmd. service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf mises-tm && \
rm -rf mises.sh && \
rm -rf .misestm && \
rm -rf $(which misestmd)
```
   
