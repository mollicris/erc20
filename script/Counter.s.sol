// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";
import {MyToken} from "../src/MyToken.sol";

contract CounterScript is Script {
    Counter public counter;
    MyToken public myToken;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        counter = new Counter();
        myToken = new MyToken();


        vm.stopBroadcast();
    }
}
