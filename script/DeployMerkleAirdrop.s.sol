// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {TamagoToken} from "../src/TamagoToken.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 constant MERKLE_ROOT = 0x7f27b2c0c34d5e7ca06adbbb1a62fc74ed490e5d42cd41dd8dc533d4001f57a7;
    uint256 constant AMOUNT_TO_MINT = 25e18 * 4;

    function run() public returns (MerkleAirdrop, TamagoToken) {
        HelperConfig config = new HelperConfig();
        (uint256 deployerKey) = config.activeNetworkConfig();

        vm.startBroadcast(deployerKey);
        TamagoToken tamago = new TamagoToken();
        MerkleAirdrop merkleAirdrop = new MerkleAirdrop(MERKLE_ROOT, tamago);

        tamago.mint(address(merkleAirdrop), AMOUNT_TO_MINT);
        vm.stopBroadcast();
        return (merkleAirdrop, tamago);
    }
}
