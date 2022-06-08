// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../src/Hot.sol";
import "../src/Vault.sol";

contract ContractTest is Test {

    HotWallet hot;
    Vm cheats = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address[] guards = 
        [
        0xdd2591a1f98f965b5C5407298758e6CE28B8c4Fa, 
        0x896882b30bfE7948566e651a24Dd3f10728ffC1f,
        0xaC1F06076D3cDBf08A6AEfE239df8A6434369e4C,
        0x10DA7924386e015AC945AA53E49fAB95fA700D27
        ];

    address signer;

    function setUp() public {
        signer = msg.sender;
        hot = new HotWallet(guards, 3 days, signer, 3);
    }

    function testModifiersHot() public {

        cheats.expectRevert("Not The Signer");
        hot.sendTx(address(this), 1e18, abi.encode(0));

        cheats.prank(signer);
        hot.sendTx(address(this), 1e18, abi.encode(0));
    }
}
