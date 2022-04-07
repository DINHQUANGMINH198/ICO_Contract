// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GLXToken is ERC20,Ownable {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000000*10**18);
    }
function withdraw(address TokenAddress , address teamWallet) public onlyOwner{
        IERC20(TokenAddress).transfer(teamWallet, IERC20(TokenAddress).balanceOf(address(this)));
    }

}