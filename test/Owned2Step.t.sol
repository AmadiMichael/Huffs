// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import {HuffConfig} from "foundry-huff/HuffConfig.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import "forge-std/console.sol";

interface Ownable2Step {
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

contract OwnedTest is Test {
    Ownable2Step owner;
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
        owner = Ownable2Step(config.deploy("Owned2Step"));
    }

    // @notice Test that a non-matching selector reverts
    function testNonMatchingSelector(bytes32 callData) public {
        bytes4[] memory func_selectors = new bytes4[](4);
        func_selectors[0] = bytes4(hex"f2fde38b");
        func_selectors[1] = bytes4(hex"79ba5097");
        func_selectors[2] = bytes4(hex"8da5cb5b");
        func_selectors[3] = bytes4(hex"e30c3978");

        bytes4 func_selector = bytes4(callData >> 0xe0);
        for (uint256 i = 0; i < 4; i++) {
            if (func_selector == func_selectors[i]) {
                return;
            }
        }

        address target = address(owner);
        bool success = false;
        assembly {
            mstore(0x80, callData)
            success := staticcall(gas(), target, 0x80, 0x20, 0, 0)

            if iszero(success) {
                success := call(gas(), target, 0, 0x80, 0x20, 0, 0)
            }
        }
        assert(!success);
    }

    function testGetOwner() public {
        assertEq(OWNER, owner.owner());
    }

    function testGetPendingOwner() public {
        assertEq(address(0), owner.pendingOwner());
    }

    function testTransferOwnership(address new_owner) public {
        if (new_owner == OWNER) return;
        vm.startPrank(new_owner);
        vm.expectRevert();
        owner.transferOwnership(new_owner);
        vm.stopPrank();
        assertEq(OWNER, owner.owner());
        assertEq(address(0), owner.pendingOwner());
    }

    function testOwnerCanTransferOwnership() public {
        address new_owner = address(0x50ca1);
        vm.startPrank(OWNER);
        vm.expectEmit(true, true, true, true);
        emit OwnershipTransferStarted(OWNER, new_owner);
        owner.transferOwnership(new_owner);
        vm.stopPrank();
        assertEq(OWNER, owner.owner());
        assertEq(new_owner, owner.pendingOwner());
    }

    function testAcceptOwnership(address pending_owner) public {
        testOwnerCanTransferOwnership();
        if (pending_owner == address(0x50ca1)) return;
        vm.startPrank(pending_owner);
        vm.expectRevert();
        owner.acceptOwnership();
        vm.stopPrank();
        assertEq(OWNER, owner.owner());
        assertEq(address(0x50ca1), owner.pendingOwner());
    }

    function testPendingOwnerCanAcceptOwnership() public {
        testOwnerCanTransferOwnership();
        address new_owner = address(0x50ca1);
        vm.startPrank(new_owner);
        vm.expectEmit(true, true, true, true);
        emit OwnerUpdated(OWNER, new_owner);
        owner.acceptOwnership();
        vm.stopPrank();
        assertEq(new_owner, owner.owner());
        assertEq(address(0), owner.pendingOwner());
    }
}
