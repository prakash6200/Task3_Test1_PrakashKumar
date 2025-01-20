// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

contract PriceOracle is Ownable {
    uint256 private roiPriceUSD; // ROI price in USD (18 decimals)
    uint256 private bdolaPriceROI; // BDOLA price in ROI (18 decimals)

    event ROIPriceUpdated(uint256 newPrice);
    event BDOLAPriceUpdated(uint256 newPrice);

    constructor(address initialOwner) Ownable(initialOwner) {}

    /**
     * @dev Get the price of ROI in USD.
     */
    function getROIPriceUSD() external view returns (uint256) {
        return roiPriceUSD;
    }

    /**
     * @dev Get the price of BDOLA in ROI.
     */
    function getBDOLAPriceROI() external view returns (uint256) {
        return bdolaPriceROI;
    }

    /**
     * @dev Update the ROI price in USD (only owner).
     * @param _price New price of 1 ROI in USD (18 decimals).
     */
    function updateROIPriceUSD(uint256 _price) external onlyOwner {
        require(_price > 0, "Price must be greater than 0");
        roiPriceUSD = _price;
        emit ROIPriceUpdated(_price);
    }

    /**
     * @dev Update the BDOLA price in ROI (only owner).
     * @param _price New price of 1 BDOLA in ROI (18 decimals).
     */
    function updateBDOLAPriceROI(uint256 _price) external onlyOwner {
        require(_price > 0, "Price must be greater than 0");
        bdolaPriceROI = _price;
        emit BDOLAPriceUpdated(_price);
    }
}
