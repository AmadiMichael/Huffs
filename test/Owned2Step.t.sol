// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import {HuffConfig} from "foundry-huff/HuffConfig.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {NonMatchingSelectorsHelper} from "test/utils/NonMatchingSelectorHelper.sol";

interface Owned2Step {
    event OwnershipTransferStarted(
        address indexed previousOwner,
        address indexed newOwner
    );

    event OwnerUpdated(address indexed user, address indexed newOwner);

    error CallerIsNotOwner();
    error CallerIsNotNewOwner();

    function transferOwnership(address newOwner) external;

    function acceptOwnership() external;

    function owner() external view returns (address);

    function pendingOwner() external view returns (address);
}

contract Owned2Step_tests is Test, NonMatchingSelectorsHelper {
    Owned2Step owned2Step;
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
        owned2Step = Owned2Step(config.deploy("Owned2Step"));
    }

    // @notice Test that a non-matching selector reverts
    function testNonMatchingSelector(bytes32 callData) public {
        bytes4[] memory func_selectors = new bytes4[](4);
        func_selectors[0] = bytes4(hex"f2fde38b");
        func_selectors[1] = bytes4(hex"79ba5097");
        func_selectors[2] = bytes4(hex"8da5cb5b");
        func_selectors[3] = bytes4(hex"e30c3978");

        bool success = nonMatchingSelectorHelper(
            func_selectors,
            callData,
            address(owned2Step)
        );
        assert(!success);
    }

    /// @notice test that owner is equal to OWNER after deoloyment
    function testGetOwner() public {
        assertEq(OWNER, owned2Step.owner());
    }

    /// @notice test that pending owner is equal to address 0 after deployment
    function testGetPendingOwner() public {
        assertEq(address(0), owned2Step.pendingOwner());
    }

    /// @notice test that non-owner CANNOT transfer ownership
    function testFailTransferOwnership(address new_owner) public {
        if (new_owner == OWNER) revert();
        vm.startPrank(new_owner);
        owned2Step.transferOwnership(new_owner);
        vm.stopPrank();
        assertEq(OWNER, owned2Step.owner());
        assertEq(address(0), owned2Step.pendingOwner());
    }

    /// @notice test that owner CAN transfer ownership
    function testOwnerCanTransferOwnership() public {
        address new_owner = address(0x50ca1);
        vm.startPrank(OWNER);
        vm.expectEmit(true, true, true, true);
        emit OwnershipTransferStarted(OWNER, new_owner);
        owned2Step.transferOwnership(new_owner);
        vm.stopPrank();
        assertEq(OWNER, owned2Step.owner());
        assertEq(new_owner, owned2Step.pendingOwner());
    }

    /// @notice test that non-pendingOwner CANNOT transfer ownership
    function testFailAcceptOwnership(address pending_owner) public {
        testOwnerCanTransferOwnership();
        if (pending_owner == address(0x50ca1)) revert();
        vm.startPrank(pending_owner);
        owned2Step.acceptOwnership();
        vm.stopPrank();
        assertEq(OWNER, owned2Step.owner());
        assertEq(address(0x50ca1), owned2Step.pendingOwner());
    }

    /// @notice test that pendingOwner CAN transfer ownership
    function testPendingOwnerCanAcceptOwnership() public {
        testOwnerCanTransferOwnership();
        address new_owner = address(0x50ca1);
        vm.startPrank(new_owner);
        vm.expectEmit(true, true, true, true);
        emit OwnerUpdated(OWNER, new_owner);
        owned2Step.acceptOwnership();
        vm.stopPrank();
        assertEq(new_owner, owned2Step.owner());
        assertEq(address(0), owned2Step.pendingOwner());
    }
}
