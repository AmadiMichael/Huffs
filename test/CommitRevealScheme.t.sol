// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import {HuffConfig} from "foundry-huff/HuffConfig.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {CommitRevealSchemeMock} from "./mocks/CommitRevealSchemeMock.sol";
import {NonMatchingSelectorsHelper} from "test/utils/NonMatchingSelectorHelper.sol";

interface CommitRevealScheme {
    function register(bytes32) external;

    function submitProof(uint256, uint256) external;
}

contract CommitRevealSchemeTest is Test, NonMatchingSelectorsHelper {
    CommitRevealSchemeMock commitRevealSchemeMock;
    CommitRevealScheme commitRevealScheme;
    address constant OWNER = address(0x420);

    function setUp() public {
        HuffConfig config = HuffDeployer.config();

        commitRevealScheme = CommitRevealScheme(
            config.deploy("CommitRevealScheme")
        );
        commitRevealSchemeMock = new CommitRevealSchemeMock();
    }

    function testCommitReveal() external {
        vm.deal(address(commitRevealScheme), 1 ether);

        vm.startPrank(address(0xABCD));
        bytes32 commit = keccak256(
            abi.encodePacked(address(0xABCD), uint256(13), uint256(1))
        );
        commitRevealScheme.register(commit);

        vm.warp(block.timestamp + 121);

        uint256 contractOldBal = address(commitRevealScheme).balance;
        uint256 senderOldBal = address(0xABCD).balance;

        commitRevealScheme.submitProof(uint256(13), uint256(1));
        vm.stopPrank();

        assert(address(commitRevealScheme).balance == contractOldBal - 1 ether);
        assert(address(0xABCD).balance == senderOldBal + 1 ether);
    }

    receive() external payable {}
}
