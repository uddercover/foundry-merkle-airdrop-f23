// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {DeployMerkleAirdrop} from "./DeployMerkleAirdrop.s.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract ClaimAirdrop is Script {
    HelperConfig config = new HelperConfig();
    bytes32 proofOne;
    bytes32 proofTwo;
    bytes32[] private merkleProof;

    function run() external returns (string memory) {
        address merkleAirdrop = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(merkleAirdrop);
        return "Claim Successful";
    }

    function claimAirdrop(address airdrop) public {
        address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        uint256 CLAIMING_ADDRESS_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        uint256 AMOUNT_TO_CLAIM = 25e18;
        setMerkleProof();

        (uint256 deployerKey) = config.activeNetworkConfig();

        bytes32 digest = MerkleAirdrop(airdrop).getMessage(CLAIMING_ADDRESS, AMOUNT_TO_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(CLAIMING_ADDRESS_KEY, digest);

        vm.startBroadcast(deployerKey);
        MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, AMOUNT_TO_CLAIM, merkleProof, v, r, s);
        vm.stopBroadcast();
    }

    function setMerkleProof() internal {
        if (block.chainid == 11155111) {
            proofOne = 0x0c7ef881bb675a5858617babe0eb12b538067e289d35d5b044ee76b79d335191;
            proofTwo = 0x81f0e530b56872b6fc3e10f8873804230663f8407e21cef901b8aeb06a25e5e2;
        } else {
            proofOne = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
            proofTwo = 0xa2af7c161f5b7159dd5044cf2c386cba4f9156339636380af02017f8d5ac7ad3;
        }
        merkleProof = [proofOne, proofTwo];
    }
}
