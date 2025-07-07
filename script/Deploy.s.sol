// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/MyToken.sol";
//import "../test/TokenTest.t.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey); 

        MyToken myToken = new MyToken();
        //TokenTest tokenTest = new TokenTest();
        vm.stopBroadcast();
        console.log("Contract deployed at:", address(myToken));
    }
}