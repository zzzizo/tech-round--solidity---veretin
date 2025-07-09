// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

interface IAaveLendingPool {
    function deposit(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
}

contract YieldAggregator {
    address public owner;
    IERC20 public immutable usdc;
    IAaveLendingPool public aave;

    mapping(address => uint256) public deposits;

    constructor(address _usdc, address _aave) {
        owner = msg.sender;
        usdc = IERC20(_usdc);
        aave = IAaveLendingPool(_aave);
    }

    
    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");

        usdc.transferFrom(msg.sender, address(this), amount);
        usdc.approve(address(aave), amount);

        aave.deposit(address(usdc), amount, msg.sender, 0); // deposited on behalf of user

        deposits[msg.sender] += amount;
    }

    
    function setAave(address _aave) external {
        require(msg.sender == owner, "Not owner");
        aave = IAaveLendingPool(_aave);
    }

    
    function emergencyWithdraw(address token, uint256 amount) external {
        require(msg.sender == owner, "Not owner");

        IERC20(token).transfer(owner, amount);
    }
}
