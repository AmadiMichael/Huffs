// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.16;

/**
 * from ethereum engineering group video on front running
 */

error TooEarly();
error Mismatch();
error ProofAlreadySubmitted();
error InvalidProof();
error TransferFailed();

contract CommitRevealSchemeMock {
    mapping(uint256 => bool) proofSubmitted;
    mapping(address => bytes32) commitments;
    mapping(address => uint256) proofWait;

    constructor() payable {}

    function register(bytes32 _commitment) external {
        commitments[msg.sender] = _commitment;
        proofWait[msg.sender] = block.timestamp + 120;
    }

    function submitProof(uint256 _proof, uint256 _randomSalt) external {
        if (!(block.timestamp > proofWait[msg.sender])) revert TooEarly();
        if (
            commitments[msg.sender] !=
            keccak256(abi.encodePacked(msg.sender, _proof, _randomSalt))
        ) revert Mismatch();
        if (proofSubmitted[_proof]) revert ProofAlreadySubmitted();
        if (_proof % 13 != 0) revert InvalidProof();

        proofSubmitted[_proof] = true;
        (bool success, ) = payable(msg.sender).call{value: 1 ether}("");
        if (!success) revert TransferFailed();
    }
}
