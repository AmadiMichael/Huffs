// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import {HuffConfig} from "foundry-huff/HuffConfig.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import "forge-std/console.sol";
import {BitMathMock} from "src/Mocks/BitMathMock.sol";

interface BitMath {
    function mostSignificantBit(uint256) external pure returns (uint8);

    function leastSignificantBit(uint256) external pure returns (uint8);
}

contract BitMathTest_tests is Test {
    BitMath bitMath;
    BitMathMock bitMathMock;

    function setUp() public {
        // Deploy BitMath
        string memory wrapper_code = vm.readFile(
            "test/mocks/BitMathWrappers.huff"
        );
        HuffConfig config = HuffDeployer.config().with_code(wrapper_code);

        bitMath = BitMath(config.deploy("BitMath"));

        // deploy bit map mock
        bitMathMock = new BitMathMock();
    }

    function testMostSignificantBit(uint256 x) external {
        if (x == 0) {
            x = 1;
        }
        assertEq(
            bitMath.mostSignificantBit(x),
            bitMathMock.mostSignificantBit(x)
        );
    }

    function testLeastSignificantBit(uint256 x) external {
        if (x == 0) {
            x = 1;
        }
        assertEq(
            bitMath.leastSignificantBit(x),
            bitMathMock.leastSignificantBit(x)
        );
    }
}
