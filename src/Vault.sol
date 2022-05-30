// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract VaultWallet {

///=============================================================================================
/// Struct
///=============================================================================================

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        uint256 confirms;
        uint256 deadline; // timestamp in which tx can no longer be executed
        bool confirmed;
    }

///=============================================================================================
/// State
///=============================================================================================

    address immutable HotWallet;
    uint256 immutable expiry;

///=============================================================================================
/// Constructor
///=============================================================================================

    constructor(uint256 _expiry) {
        HotWallet = msg.sender;
        expiry = _expiry; 
    }


}