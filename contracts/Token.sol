// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract Token is ERC20{
    constructor () ERC20("Token","TK") {    
        _mint(msg.sender, 1000000 * 10 ** 18);
    }
}