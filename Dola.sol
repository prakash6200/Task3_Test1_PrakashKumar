// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DOLA is ERC20, Ownable {
    // Collateral token (BDOLA)
    IERC20 public collateralToken;

    // Price Oracle (ROI price in USD and BDOLA price in ROI)
    IPriceOracle public priceOracle;

    // Collateralization ratio (e.g., 150%)
    uint256 public collateralizationRatio = 150;

    // Mapping of user collateral
    mapping(address => uint256) public collateralBalances;

    // Events
    event Minted(address indexed user, uint256 amount, uint256 collateral);
    event Burned(address indexed user, uint256 amount, uint256 collateral);
    event CollateralWithdrawn(address indexed user, uint256 amount);

    constructor(address _collateralToken, address _priceOracle) ERC20("DOLA Token", "DOLA") {
        collateralToken = IERC20(_collateralToken);
        priceOracle = IPriceOracle(_priceOracle);
    }

    /**
     * @dev Mint DOLA by depositing BDOLA collateral.
     * @param _amount Amount of DOLA to mint.
     */
    function mint(uint256 _amount) external {
        uint256 roiPriceUSD = priceOracle.getROIPriceUSD(); // ROI price in USD
        uint256 bdolaPriceROI = priceOracle.getBDOLAPriceROI(); // BDOLA price in ROI

        uint256 requiredCollateral = (_amount * collateralizationRatio * roiPriceUSD) / (bdolaPriceROI * 100);

        // Transfer BDOLA as collateral
        require(collateralToken.transferFrom(msg.sender, address(this), requiredCollateral), "Collateral transfer failed");

        // Update collateral balance and mint DOLA
        collateralBalances[msg.sender] += requiredCollateral;
        _mint(msg.sender, _amount);

        emit Minted(msg.sender, _amount, requiredCollateral);
    }

    /**
     * @dev Burn DOLA to withdraw BDOLA collateral.
     * @param _amount Amount of DOLA to burn.
     */
    function burn(uint256 _amount) external {
        uint256 roiPriceUSD = priceOracle.getROIPriceUSD(); // ROI price in USD
        uint256 bdolaPriceROI = priceOracle.getBDOLAPriceROI(); // BDOLA price in ROI

        uint256 collateralToReturn = (_amount * collateralizationRatio * roiPriceUSD) / (bdolaPriceROI * 100);

        require(collateralBalances[msg.sender] >= collateralToReturn, "Insufficient collateral");

        // Burn DOLA and return collateral
        _burn(msg.sender, _amount);
        collateralBalances[msg.sender] -= collateralToReturn;
        require(collateralToken.transfer(msg.sender, collateralToReturn), "Collateral transfer failed");

        emit Burned(msg.sender, _amount, collateralToReturn);
    }

    /**
     * @dev Withdraw excess collateral without burning DOLA.
     */
    function withdrawExcessCollateral() external {
        uint256 roiPriceUSD = priceOracle.getROIPriceUSD();
        uint256 bdolaPriceROI = priceOracle.getBDOLAPriceROI();

        uint256 dolaBalance = balanceOf(msg.sender);
        uint256 requiredCollateral = (dolaBalance * collateralizationRatio * roiPriceUSD) / (bdolaPriceROI * 100);
        uint256 excessCollateral = collateralBalances[msg.sender] > requiredCollateral
            ? collateralBalances[msg.sender] - requiredCollateral
            : 0;

        require(excessCollateral > 0, "No excess collateral");

        collateralBalances[msg.sender] -= excessCollateral;
        require(collateralToken.transfer(msg.sender, excessCollateral), "Collateral transfer failed");

        emit CollateralWithdrawn(msg.sender, excessCollateral);
    }

    /**
     * @dev Set a new collateralization ratio (only owner).
     */
    function setCollateralizationRatio(uint256 _ratio) external onlyOwner {
        require(_ratio >= 100, "Ratio must be >= 100%");
        collateralizationRatio = _ratio;
    }
}

interface IPriceOracle {
    function getROIPriceUSD() external view returns (uint256);
    function getBDOLAPriceROI() external view returns (uint256);
}
