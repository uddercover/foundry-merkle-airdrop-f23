// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {TamagoToken} from "../src/TamagoToken.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    MerkleAirdrop merkleAirdrop;
    bytes32 merkleRoot = 0x7f27b2c0c34d5e7ca06adbbb1a62fc74ed490e5d42cd41dd8dc533d4001f57a7;
    TamagoToken tamago;

    address user;
    uint256 userPrivKey;
    address gasPayer;

    uint256 constant AMOUNT_TO_CLAIM = 25e18;
    uint256 constant AMOUNT_TO_MINT = AMOUNT_TO_CLAIM * 10;

    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0xa2af7c161f5b7159dd5044cf2c386cba4f9156339636380af02017f8d5ac7ad3;
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
