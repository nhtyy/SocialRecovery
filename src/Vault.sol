// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Vault {

    event NewTx(
        uint256 indexed nonce,
        address indexed to,
        bytes indexed data
    );

    event VetoReason(
        string reason
    );

///=============================================================================================
/// Struct
///=============================================================================================

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        uint256 veto;
        uint256 delay; // timestamp in which tx can no longer be executed
        bool confirmed; // tx has been executed
    }

///=============================================================================================
/// State
///=============================================================================================

    Transaction[] public transactions;

    // tx index -> guardian -> bool : did veto
    mapping(uint256 => mapping(address => bool)) veto;

    uint256 public currentTx;

    address immutable HotWallet;
    uint256 immutable expiry; // time in seconds tx are valid for
    uint256 immutable quorum;

///=============================================================================================
/// Constructor
///=============================================================================================

    constructor(uint256 _expiry, uint256 _quorum) {
        HotWallet = msg.sender;
        expiry = _expiry;
        quorum = _quorum;
    }

    function proposeTransaction(
        address to,
        uint256 value,
        bytes calldata data
    ) external {
        transactions.push(
            Transaction(
                to,
                value,
                data,
                0,
                block.timestamp + expiry,
                false
            )
        );

        emit NewTx(transactions.length - 1, to, data);
    }

    function executeTransaction(uint256 nonce) external {

    }

    function vetoTransction(uint256 nonce, string calldata reason) external {

    }
}