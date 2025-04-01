// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Reputeth} from "../src/Reputeth.sol";

interface ICreateX {
    function deployCreate2(bytes32 salt, bytes calldata initCode) external payable returns (address);
}

ICreateX constant CREATEX = ICreateX(0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed);
//contractAddress: "0x000000000000b361194cfe6312EE3210d53C15AA",

contract ReputethScript is Script {
    function setUp() public {}
    function run() public {
        vm.startBroadcast();
        address reputeth =
            CREATEX.deployCreate2(bytes32(0), abi.encodePacked(type(Reputeth).creationCode, abi.encode(msg.sender)));
        vm.stopBroadcast();
        console.log("Reputeth deployed at", reputeth);
        Reputeth rpt = Reputeth(reputeth);
        console.log("Owner", rpt.owner());
    }
}

