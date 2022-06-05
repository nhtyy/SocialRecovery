// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./Hot.sol";

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
        bool executed;
    }

///=============================================================================================
/// State
///=============================================================================================

    Transaction[] public transactions;

    uint256 public currentTx;

    // tx index -> guardian -> bool : did veto
    mapping(uint256 => mapping(address => bool)) veto;

    HotWallet immutable hot;
    uint256 immutable expiry; // time in seconds tx are valid for
    uint256 immutable quorum;

///=============================================================================================
/// Constructor
///=============================================================================================

    constructor(uint256 _expiry, uint256 _quorum) {
        hot = HotWallet(msg.sender);
        expiry = _expiry;
        quorum = _quorum;
    }

///=============================================================================================
/// Modifiers
///=============================================================================================    

    modifier onlyGuardian() {
        require(hot.isGuardian(msg.sender), "Not A Guardian");
        _;
    }

    modifier onlySigner() {
        require(hot.signingKey(), "Not The Signer");
        _;
    }

///=============================================================================================
/// External Methods
///=============================================================================================    

    function proposeTransaction(
        address to,
        uint256 value,
        bytes calldata data
    ) external onlySigner {
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

        currentTx = transactions.length - 1;

        emit NewTx(value, to, data);
    }

    function executeTransaction() external onlySigner {
        Transaction memory _transaction = transactions[currentTx];
        require(block.timestamp > _transaction.delay, "Delay has not yet passed");
        require(_transaction.delay != 0, "This Tx is empty");
        require(!_transaction.executed, "Tx already executed");

        transactions[currentTx].executed = true;

        (bool success, ) = _transaction.to.call{value: _transaction.value}(_transaction.data);
        require(success, "Transaction Failed");
    }

    function vetoTransaction(string calldata reason) external onlyGuardian {
        require(!veto[currentTx][msg.sender], "Already Vetoed");

        transactions[currentTx].veto += 1;

        if (transactions[currentTx].veto > quorum) {
            currentTx += 1;
        }
    }
}