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

    function setUp() public {
        // Create Owner
        string memory wrapper_code = vm.readFile(
            "test/mocks/Owned2StepWrappers.huff"
        );
        HuffConfig config = HuffDeployer
            .config()
            .with_code(wrapper_code)
            .with_args(abi.encode(OWNER));
        vm.expectEmit(true, true, true, true);
        emit OwnerUpdated(address(0), OWNER);
        weth9 = WETH9(config.deploy("WETH9"));
    }

    // @notice Test that a non-matching selector reverts
    function testNonMatchingSelector(bytes32 callData) public {
        // bytes4[] memory func_selectors = new bytes4[](4);
        // func_selectors[0] = bytes4(hex"f2fde38b");
        // func_selectors[1] = bytes4(hex"79ba5097");
        // func_selectors[2] = bytes4(hex"8da5cb5b");
        // func_selectors[3] = bytes4(hex"e30c3978");
        // bytes4 func_selector = bytes4(callData >> 0xe0);
        // for (uint256 i = 0; i < 4; i++) {
        //     if (func_selector == func_selectors[i]) {
        //         return;
        //     }
        // }
        // address target = address(weth9);
        // bool success = false;
        // assembly {
        //     mstore(0x80, callData)
        //     success := staticcall(gas(), target, 0x80, 0x20, 0, 0)
        //     if iszero(success) {
        //         success := call(gas(), target, 0, 0x80, 0x20, 0, 0)
        //     }
        // }
        // assert(!success);
    }
}
