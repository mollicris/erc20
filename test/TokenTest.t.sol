// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {MyToken} from "../src/MyToken.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20Errors} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";



contract TokenTest is Test {
    Counter public counter;
    MyToken public myToken;
    address public owner = address(1);
    address public pauser = address(2);
    address public minter = address(3);
    address public other = address(4);
    address public user1 = address(5);
    address public user2 = address(6);
    //error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);


    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
        myToken = new MyToken();       
    }

    function testVerifyToken() public view{
        assertEq(myToken.name(), "MyToken");
        assertEq(myToken.symbol(), "CM");
        assertEq(myToken.decimals(), 18);
    }

    function testMint() public {
        myToken.grantRole(myToken.MINTER_ROLE(), minter);
        myToken.mint(minter, 100);
        assertEq(myToken.balanceOf(minter), 100);
    }

    function testMintWithinCap() public {
        uint256 mintAmount = 500_000 * 10**18; // 500K tokens (mitad del CAP)
        
        myToken.grantRole(myToken.MINTER_ROLE(), minter);

        myToken.mint(minter, mintAmount);

        // Verificaciones:
        assertEq(myToken.totalSupply(), mintAmount, "totalSupply incorrecto");
        assertEq(myToken.balanceOf(minter), mintAmount, "balanceOf incorrecto");
    }
    function testMintExceedingCap() public {
        uint256 mintAmount = 1_100_000 * 10**18; // 1.1M tokens (excede el CAP)
        
        myToken.grantRole(myToken.MINTER_ROLE(), minter);
        // Intentar hacer minting que excede el cap
        vm.expectRevert("Minting exceeds cap");
        myToken.mint(minter, mintAmount);
    }

 /*   function testOnlyMinterCanMint() public {
    
    
    vm.prank(other); // Simula llamada desde cuenta no autorizada
    
    vm.expectRevert(
        abi.encodeWithSelector(
            IAccessControl.AccessControlUnauthorizedAccount.selector,
            other,                    // Cuenta que falló
            myToken.MINTER_ROLE()      // Rol requerido
        )
    );

    myToken.mint(other, 100); // Debe 
}
*/





    function testPauseAndUnpause() public {
        myToken.grantRole(myToken.PAUSER_ROLE(), pauser);
        
        // Pausar el contrato
        vm.prank(pauser);
        myToken.pause();
        assertTrue(myToken.paused(), "pausado");

        // Intentar minting mientras está pausado
        myToken.grantRole(myToken.MINTER_ROLE(), minter);
        vm.prank(minter);
        //vm.expectRevert("Pausable: paused");
        vm.expectRevert(abi.encodeWithSignature("EnforcedPause()"));
        myToken.mint(minter, 100);

        // Despausar el contrato
        vm.prank(pauser);
        myToken.unpause();
        assertFalse(myToken.paused(), "El contrato no esta despausado");

        // Ahora el minting debe funcionar
        vm.prank(minter);
        myToken.mint(minter, 100);
        assertEq(myToken.balanceOf(minter), 100, "Minting fallo despues de despausar");
    }

      function testTransferUpdatesBalances() public {
        myToken.grantRole(myToken.MINTER_ROLE(), minter);
        vm.prank(minter);
        myToken.mint(user1, 1000);

        vm.prank(user1);
        myToken.transfer(user2, 500);

        assertEq(myToken.balanceOf(user1), 500);
        assertEq(myToken.balanceOf(user2), 500);
    }

    function testTransferFromWithInsufficientAllowance() public {
        myToken.grantRole(myToken.MINTER_ROLE(), minter);
        vm.prank(minter);
        myToken.mint(user1, 1000);

        vm.prank(user1);
        myToken.approve(user2, 300);

        vm.prank(user2);
        //vm.expectRevert("insufficient allowance");
        vm.expectRevert(
    abi.encodeWithSelector(
        IERC20Errors.ERC20InsufficientAllowance.selector,
        user2,
        300,
        500
    )
);
        myToken.transferFrom(user1, user2, 500);
    }

     function testIncreaseAllowance() public {
        vm.prank(user1);
        myToken.approve(user2, 100);

        vm.prank(user1);
        myToken.increaseAllowance(user2, 50);

        assertEq(myToken.allowance(user1, user2), 150);
    }
    function testDecreaseAllowance() public {
        vm.prank(user1);
        myToken.approve(user2, 100);

        vm.prank(user1);
        myToken.decreaseAllowance(user2, 30);

        assertEq(myToken.allowance(user1, user2), 70);
    }



}
