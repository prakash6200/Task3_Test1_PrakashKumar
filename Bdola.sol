// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BDOLA is ERC20, Ownable {
    constructor(uint256 initialSupply) ERC20("BDOLA Token", "BDOLA") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply * (10 ** decimals()));
    }

    /**
     * @dev Mint new BDOLA tokens (only owner).
     * @param account Address to mint tokens to.
     * @param amount Number of tokens to mint.
     */
    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    /**
     * @dev Burn BDOLA tokens (only owner).
     * @param account Address to burn tokens from.
     * @param amount Number of tokens to burn.
     */
    function burn(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }
}
