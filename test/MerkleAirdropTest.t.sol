// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {TamagoToken} from "../src/TamagoToken.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    MerkleAirdrop merkleAirdrop;
    bytes32 merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    TamagoToken tamago;

    address user;
    uint256 userPrivKey;
    address gasPayer;

    uint256 constant AMOUNT_TO_CLAIM = 25e18;
    uint256 constant AMOUNT_TO_MINT = AMOUNT_TO_CLAIM * 10;

    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] private merkleProof = [proofOne, proofTwo];

    function setUp() public {
        if (isZkSyncChain()) {
            tamago = new TamagoToken();
            merkleAirdrop = new MerkleAirdrop(merkleRoot, tamago);
            tamago.mint(address(merkleAirdrop), AMOUNT_TO_MINT);
        } else {
            //deploy with script
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (merkleAirdrop, tamago) = deployer.run();
        }
        (user, userPrivKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = tamago.balanceOf(user);
        bytes32 digest = merkleAirdrop.getMessage(user, AMOUNT_TO_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);

        vm.prank(gasPayer);
        merkleAirdrop.claim(user, AMOUNT_TO_CLAIM, merkleProof, v, r, s);

        uint256 endingBalance = tamago.balanceOf(user);

        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
}
