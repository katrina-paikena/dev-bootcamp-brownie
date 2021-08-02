#!/usr/bin/python3
from brownie import PriceContract, config, network
from scripts.helpful_scripts import (
    get_account,
    get_verify_status,
    get_contract,
    LOCAL_BLOCKCHAIN_ENVIRONMENTS,
)
 
def deploy_price_contract():
    jobId = config["networks"][network.show_active()]["jobId"]
    fee = config["networks"][network.show_active()]["fee"]
    account = get_account()
    price_contract = PriceContract.deploy(
        get_contract("oracle").address,
        jobId,
        fee,
        get_contract("link_token").address,
        get_contract("btc_usd_price_feed").address,
        {"from": account},
        publish_source=get_verify_status(),
    )
    print(f"Price Contract deployed to {price_contract.address}")
    return price_contract
 
 
def main():
    deploy_price_contract()