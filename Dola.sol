// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IROI {
    function price() external view returns (uint256);
}

interface IBDOLA {
    function burn(address from, uint256 amount) external;
    function mint(address to, uint256 amount) external;
}

contract DOLA is ERC20, Ownable {
    IROI public roiToken;
    IBDOLA public bdolaToken;

    constructor(address _roiToken, address _bdolaToken) ERC20("DOLA Stablecoin", "DOLA") Ownable(msg.sender) {
        require(_roiToken != address(0), "Invalid ROI token address");
        require(_bdolaToken != address(0), "Invalid BDOLA token address");
        
        roiToken = IROI(_roiToken);
        bdolaToken = IBDOLA(_bdolaToken);
    }


    /**
     * @notice Mint DOLA by depositing BDOLA as collateral.
     * @param amount The amount of DOLA to mint.
     */
    function mint(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        // Transfer BDOLA from the sender and burn it
        bdolaToken.burn(msg.sender, amount);

        // Mint DOLA to the sender
        _mint(msg.sender, amount);
    }

    /**
     * @notice Redeem DOLA for BDOLA collateral.
     * @param amount The amount of DOLA to redeem.
     */
    function redeem(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(balanceOf(msg.sender) >= amount, "Insufficient DOLA balance");

        // Burn DOLA from the sender
        _burn(msg.sender, amount);

        // Mint BDOLA to the sender
        bdolaToken.mint(msg.sender, amount);
    }

}
