// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import {HuffConfig} from "foundry-huff/HuffConfig.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import "forge-std/console.sol";
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

    // @notice Test that a non-matching selector reverts
    function testNonMatchingSelector(bytes32 callData) public {
        bytes4[] memory func_selectors = new bytes4[](2);
        func_selectors[0] = bytes4(hex"e1fa8e84");
        func_selectors[1] = bytes4(hex"1ec03679");

        bool success = nonMatchingSelectorHelper(
            func_selectors,
            callData,
            address(commitRevealScheme)
        );
        assert(!success);
    }

    function testRegister() external {
        // vm.prank(0xABCD);
        bytes32 commit = keccak256(
            abi.encodePacked(address(this), uint256(13), uint256(1))
        );
        commitRevealScheme.register(commit);

        vm.warp(block.timestamp + 121);
        vm.deal(address(commitRevealScheme), 1 ether);

        uint256 contractOldBal = address(commitRevealScheme).balance;
        uint256 senderOldBal = address(this).balance;

        commitRevealScheme.submitProof(uint256(13), uint256(1));
        vm.stopPrank();

        assert(address(commitRevealScheme).balance == contractOldBal - 1 ether);
        assert(address(this).balance == senderOldBal + 1 ether);
    }

    receive() external payable {}
}
