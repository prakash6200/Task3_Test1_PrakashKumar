// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// BDOLA Token Contract
contract BDOLA is ERC20 {
    address public admin;

    constructor(uint256 initialSupply) ERC20("BDOLA Token", "BDOLA") {
        admin = msg.sender;
        _mint(msg.sender, initialSupply * 10 ** 18);
    }

    function burn(address from, uint256 amount) external {
        require(msg.sender == admin, "Only admin can burn tokens");
        _burn(from, amount);
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == admin, "Only admin can mint tokens");
        _mint(to, amount);
    }
}
