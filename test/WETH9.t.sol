// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import {HuffConfig} from "foundry-huff/HuffConfig.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import "forge-std/console.sol";

// TO-DO:= WETH TESTS
interface WETH9 {
    event OwnershipTransferStarted(
        address indexed previousOwner,
        address indexed newOwner
    );

    event OwnerUpdated(address indexed user, address indexed newOwner);

    error CallerIsNotOwner();
    error CallerIsNotNewOwner();

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    function deposit() external payable;

    function withdraw(uint256) external;

    function totalSupply() external view returns (uint256);

    function approve(address) external returns (bool);

    function transfer(address, uint256) external returns (bool);

    function transferFrom(address, address, uint256) external returns (bool);
}

contract Owned2StepTest is Test {
    WETH9 weth9;
    address constant OWNER = address(0x420);

    event OwnershipTransferStarted(
        address indexed previousOwner,
        address indexed newOwner
    );

    event OwnerUpdated(address indexed user, address indexed newOwner);

    function setUp() public {}

    // @notice Test that a non-matching selector reverts
    function testNonMatchingSelector(bytes32 callData) public {}
}
