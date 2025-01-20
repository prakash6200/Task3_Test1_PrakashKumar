// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IPriceOracle {
    function getROIPriceUSD() external view returns (uint256);

    function getBDOLAPriceROI() external view returns (uint256);
}


contract DOLA is ERC20, Ownable {
    IERC20 public collateralToken; // BDOLA token
    IPriceOracle public priceOracle; // Oracle for ROI and BDOLA prices

    uint256 public collateralizationRatio = 150; // 150% collateralization
    mapping(address => uint256) public collateralBalances; // User collateral

    event Minted(address indexed user, uint256 dolaAmount, uint256 collateralUsed);
    event Burned(address indexed user, uint256 dolaAmount, uint256 collateralReturned);

    constructor(address _collateralToken, address _priceOracle)
        ERC20("DOLA Token", "DOLA")
        Ownable(msg.sender)
    {
        collateralToken = IERC20(_collateralToken);
        priceOracle = IPriceOracle(_priceOracle);
    }

    /**
     * @dev Mint DOLA by depositing BDOLA as collateral.
     * @param _dolaAmount Amount of DOLA to mint.
     */
    function mint(uint256 _dolaAmount) external {
        uint256 roiPriceUSD = priceOracle.getROIPriceUSD();
        uint256 bdolaPriceROI = priceOracle.getBDOLAPriceROI();

        uint256 requiredCollateral = (_dolaAmount * collateralizationRatio * roiPriceUSD) /
            (bdolaPriceROI * 100);

        require(
            collateralToken.transferFrom(msg.sender, address(this), requiredCollateral),
            "Collateral transfer failed"
        );

        collateralBalances[msg.sender] += requiredCollateral;
        _mint(msg.sender, _dolaAmount);

        emit Minted(msg.sender, _dolaAmount, requiredCollateral);
    }

    /**
     * @dev Burn DOLA to redeem BDOLA collateral.
     * @param _dolaAmount Amount of DOLA to burn.
     */
    function burn(uint256 _dolaAmount) external {
        uint256 roiPriceUSD = priceOracle.getROIPriceUSD();
        uint256 bdolaPriceROI = priceOracle.getBDOLAPriceROI();

        uint256 collateralToReturn = (_dolaAmount * collateralizationRatio * roiPriceUSD) /
            (bdolaPriceROI * 100);

        require(collateralBalances[msg.sender] >= collateralToReturn, "Insufficient collateral");

        _burn(msg.sender, _dolaAmount);
        collateralBalances[msg.sender] -= collateralToReturn;

        require(
            collateralToken.transfer(msg.sender, collateralToReturn),
            "Collateral transfer failed"
        );

        emit Burned(msg.sender, _dolaAmount, collateralToReturn);
    }

    /**
     * @dev Update the collateralization ratio (only owner).
     * @param _ratio New collateralization ratio (e.g., 150 for 150%).
     */
    function updateCollateralizationRatio(uint256 _ratio) external onlyOwner {
        require(_ratio >= 100, "Ratio must be at least 100%");
        collateralizationRatio = _ratio;
    }

    /**
     * @dev Withdraw excess collateral above the required amount.
     */
    function withdrawExcessCollateral() external {
        uint256 dolaBalance = balanceOf(msg.sender);
        uint256 roiPriceUSD = priceOracle.getROIPriceUSD();
        uint256 bdolaPriceROI = priceOracle.getBDOLAPriceROI();

        uint256 requiredCollateral = (dolaBalance * collateralizationRatio * roiPriceUSD) /
            (bdolaPriceROI * 100);

        uint256 excessCollateral = collateralBalances[msg.sender] > requiredCollateral
            ? collateralBalances[msg.sender] - requiredCollateral
            : 0;

        require(excessCollateral > 0, "No excess collateral");

        collateralBalances[msg.sender] -= excessCollateral;
        require(
            collateralToken.transfer(msg.sender, excessCollateral),
            "Collateral transfer failed"
        );
    }
}
