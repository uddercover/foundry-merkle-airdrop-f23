// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {DeployMerkleAirdrop} from "./DeployMerkleAirdrop.s.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract ClaimAirdrop is Script {
    HelperConfig config = new HelperConfig();

    bytes32 proofOne = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] private merkleProof = [proofOne, proofTwo];

    function run() external returns (string memory) {
        address merkleAirdrop = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(merkleAirdrop);
        return "Claim Successful";
    }

    function claimAirdrop(address airdrop) public {
        address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        uint256 CLAIMING_ADDRESS_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        uint256 AMOUNT_TO_CLAIM = 25e18;

        (uint256 deployerKey) = config.activeNetworkConfig();

        bytes32 digest = MerkleAirdrop(airdrop).getMessage(CLAIMING_ADDRESS, AMOUNT_TO_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(CLAIMING_ADDRESS_KEY, digest);

        vm.startBroadcast(deployerKey);
        MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, AMOUNT_TO_CLAIM, merkleProof, v, r, s);
        vm.stopBroadcast();
    }
}
