// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    uint256 public constant DEFAULT_ANVIL_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaNetworkConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilNetworkConfig();
        }
    }

    // the deployerKey is mostly all I need, maybe the merkle root but it'll be too much work to set up a .env path for it atm
    struct NetworkConfig {
        uint256 deployerKey;
    }

    NetworkConfig public activeNetworkConfig;

    function getSepoliaNetworkConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({deployerKey: vm.envUint("PRIVATE_KEY")});
    }

    function getOrCreateAnvilNetworkConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({deployerKey: DEFAULT_ANVIL_KEY});
    }
}
