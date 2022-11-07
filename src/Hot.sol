// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./Vault.sol";

contract HotWallet {
    ///=============================================================================================
    /// Data Types
    ///=============================================================================================

    struct Proposal {
        address proposedAddress;
        address _replaced;
        uint256 confirms;
        uint256 deadline;
        bool operation;
        bool executed;
    }

    ///=============================================================================================
    /// Immutable State
    ///=============================================================================================

    uint256 immutable expiry;

    uint256 immutable quorum;

    Vault immutable vault;

    ///=============================================================================================
    /// State
    ///=============================================================================================

    address public signingKey;

    Proposal[] public propsals;

    mapping(address => bool) public isGuardian;

    address[] public guardians;
    mapping(address => uint256) guardianIndex;

    // proposals index => guardian => bool
    mapping(uint256 => mapping(address => bool)) voted;

    ///=============================================================================================
    /// Constructor
    ///=============================================================================================

    constructor(
        address[] memory _guardians,
        uint256 _expiry,
        address _signingKey,
        uint256 _quorum
    ) {
        vault = new Vault(_expiry, _quorum);
        expiry = _expiry;
        quorum = _quorum;
        signingKey = _signingKey;

        uint256 length = _guardians.length;
        for (uint256 i; i < length; ) {
            isGuardian[_guardians[i]] = true;

            guardians.push(_guardians[i]);
            guardianIndex[_guardians[i]] = i;
            unchecked {
                ++i;
            }
        }
    }

    ///=============================================================================================
    /// Modifiers
    ///=============================================================================================

    modifier onlySigner() {
        require(msg.sender == signingKey, "Not The Signer");
        _;
    }

    modifier onlyGuardian() {
        require(isGuardian[msg.sender], "Not A Guardian");
        _;
    }

    ///=============================================================================================
    /// External Functions
    ///=============================================================================================

    function sendTx(
        address to,
        uint256 _value,
        bytes calldata data
    ) external onlySigner {
        (bool success, ) = to.call{value: _value}(data);
        require(success, "TX Failed");
    }

    function initiateSignerChange(address _proposedSigner)
        external
        onlyGuardian
    {
        require(_proposedSigner != address(0), "Zero Address");
        propsals.push(
            Proposal(
                _proposedSigner,
                signingKey,
                0,
                block.timestamp + expiry,
                true,
                false
            )
        );
    }

    // new guardians MUST replace old guardians. The total amount of guardians should never change
    function initiateGuardianChange(address _proposedSigner, address _replacing)
        external
        onlyGuardian
    {
        require(_proposedSigner != address(0), "Zero Address");
        require(isGuardian[_replacing], "_replacing is not a guardian");
        propsals.push(
            Proposal(
                _proposedSigner,
                _replacing,
                0,
                block.timestamp + expiry,
                false,
                false
            )
        );
    }

    function confirmProposal(uint256 index) external onlyGuardian {
        require(!voted[index][msg.sender], "Already Voted");
        voted[index][msg.sender] = true;
        propsals[index].confirms += 1;
    }

    function executeProposal(uint256 index) external onlyGuardian {
        Proposal memory _proposal = propsals[index];
        require(
            _proposal.confirms >= quorum &&
                _proposal.deadline <= block.timestamp &&
                !_proposal.executed
        );

        if (propsals[index].operation) {
            signingKey = _proposal.proposedAddress;
        } else {
            guardians[guardianIndex[_proposal._replaced]] = _proposal
                .proposedAddress;
            isGuardian[_proposal._replaced] = false;
            isGuardian[_proposal.proposedAddress] = true;
        }

        propsals[index].executed = true;
    }
}
