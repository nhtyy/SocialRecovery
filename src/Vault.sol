// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Vault {

    event NewTx(
        uint256 indexed value,
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
    }

///=============================================================================================
/// State
///=============================================================================================

    Transaction public transaction;

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
        transaction = 
            Transaction(
                to,
                value,
                data,
                0,
                block.timestamp + expiry
        );

        emit NewTx(value, to, data);
    }

    function executeTransaction() external {
        require(block.timestamp > transaction.delay, "Delay has not yet passed");
        Transaction memory _transaction = transaction;

        (bool success, ) = _transaction.to.call{value: _transaction.value}(_transaction.data);
        require(success, "Transaction Failed");
        clearTransaction();
    }

    function vetoTransaction(uint256 nonce, string calldata reason) external {
        require(veto )

    }

    function clearTransaction() internal {
        transaction = 
            Transaction(
                address(0),
                0,
                abi.encode(0),
                0,
                0
            );
    }
}