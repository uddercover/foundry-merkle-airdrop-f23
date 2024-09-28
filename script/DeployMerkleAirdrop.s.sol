// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {TamagoToken} from "../src/TamagoToken.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 constant MERKLE_ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
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
