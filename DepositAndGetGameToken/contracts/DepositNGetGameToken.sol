// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract DepositAndGetGameTokenContract is ReentrancyGuard {
    address public owner;
    uint256 public constant TOKEN_PRICE = 1e15; // 0.001 USD in wei (assuming token price is 0.001 USD)
    IERC20 public gameToken;
    IERC20 public USDT;
    IERC20 public USDC;

    mapping(address => uint256) public tokensPurchased;
    uint256 public totalCollectedUSDT;
    uint256 public totalCollectedUSDC;
    uint256 public totalGameTokens;

    bool public paused;

    event TokensDeposited(uint256 amount);
    event TokensWithdrawn(uint256 amount);
    event TokensPurchased(address buyer, uint256 amount);

    constructor(
        address _owner,
        address _gameToken,
        address _usdtAddress,
        address _usdcAddress
    ) {
        require(_gameToken != address(0), "Invalid presale token address");
        require(_usdtAddress != address(0), "Invalid USDT address");
        require(_usdcAddress != address(0), "Invalid USDC address");

        gameToken = IERC20(_gameToken);
        USDT = IERC20(_usdtAddress);
        USDC = IERC20(_usdcAddress);

        owner = _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    function depositTokens(uint256 amount) external onlyOwner {
        require(
            gameToken.transferFrom(msg.sender, address(this), amount),
            "Token transfer failed"
        );
        totalGameTokens += amount;
        emit TokensDeposited(amount);
    }

    function withdrawTokens(uint256 amount) external onlyOwner {
        require(totalGameTokens >= amount, "Not Enough Tokens to Withdraw");
        require(
            gameToken.transfer(msg.sender, amount),
            "Token transfer failed"
        );
        totalGameTokens -= amount;
        emit TokensWithdrawn(amount);
    }

    function buyTokensWithUSDT(uint256 usdtAmount) external nonReentrant whenNotPaused {
         require(usdtAmount >= 2 * 1e18, "Must send at least 2 USDT");
        // uint256 tokensToBuyupdateGVariable = usdtAmount / TOKEN_PRICE;
        uint256 tokensToBuy = (usdtAmount * 10**18) / TOKEN_PRICE;
        require(
            gameToken.balanceOf(address(this)) >= tokensToBuy,
            "Not enough tokens available"
        );
        require(
            USDT.allowance(msg.sender, address(this)) >= usdtAmount,
            "Insufficient USDT allowance"
        );
         
        require(
            USDT.transferFrom(msg.sender, address(this), usdtAmount),
            "USDT transfer failed"
        );

        totalCollectedUSDT += usdtAmount;
        tokensPurchased[msg.sender] += tokensToBuy;
        require(
            gameToken.transfer(msg.sender, tokensToBuy),
            "Token transfer failed"
        );
        totalGameTokens -= tokensToBuy;

        emit TokensPurchased(msg.sender, tokensToBuy);
    }

    function buyTokensWithUSDC(uint256 usdcAmount) external nonReentrant whenNotPaused {
        require(usdcAmount >= 2 * 1e18, "Must send at least 2 USDC");
       uint256 tokensToBuy = (usdcAmount * 10**18) / TOKEN_PRICE;
        require(
            gameToken.balanceOf(address(this)) >= tokensToBuy,
            "Not enough tokens available"
        );
        require(
            USDC.allowance(msg.sender, address(this)) >= usdcAmount,
            "Insufficient USDC allowance"
        );
        require(
            USDC.transferFrom(msg.sender, address(this), usdcAmount),
            "USDC transfer failed"
        );

        totalCollectedUSDC += usdcAmount;
        tokensPurchased[msg.sender] += tokensToBuy;
        require(
            gameToken.transfer(msg.sender, tokensToBuy),
            "Token transfer failed"
        );
        totalGameTokens -= tokensToBuy;

        emit TokensPurchased(msg.sender, tokensToBuy);
    }

 
  function WithdrawUSDT_with_GT(uint256 GTAmt) external nonReentrant {
    require(GTAmt >= 10000 * 10**18, "You need at least 10,000 Game Tokens");
    
    // Calculate the equivalent USDT amount (10,000 GT = 10 USDT, so 1 GT = 0.001 USDT)
    uint256 usdtAmount = GTAmt / 1000; // Conversion ratio: 1000 GT = 1 USDT

    // Ensure the contract has enough USDT to pay out
    require(
        USDT.balanceOf(address(this)) >= usdtAmount,
        "Not enough USDT in contract"
    );

    // Transfer the GT tokens from the user to the contract
    require(
        gameToken.transferFrom(msg.sender, address(this), GTAmt),
        "GT Token transfer failed"
    );

    // Transfer the corresponding USDT amount to the user
    require(
        USDT.transfer(msg.sender, usdtAmount),
        "USDT transfer failed"
    );

    // Update the contract's game token balance
    totalGameTokens += GTAmt;
    totalCollectedUSDT -= usdtAmount; // Reduce the total collected USDT

    emit TokensDeposited(GTAmt); // Emitting event for GT tokens deposited
}

   


   function withdrawCollectedUSDT(uint _amount) external onlyOwner {
    uint256 totalUsdtAmount = USDT.balanceOf(address(this));
    require(_amount <= totalUsdtAmount, "Not sufficient USDT to withdraw");

    require(USDT.transfer(owner, _amount), "USDT transfer to owner failed");
    
    totalCollectedUSDT -= _amount;  
}

function withdrawCollectedUSDC(uint _amount) external onlyOwner {
    uint256 totalUsdcAmount = USDC.balanceOf(address(this));
    require(_amount <= totalUsdcAmount, "Not sufficient USDC to withdraw");

    require(USDC.transfer(owner, _amount), "USDC transfer to owner failed");
    
    totalCollectedUSDC -= _amount;  
}

  function AddUSDT(uint256 amt) external onlyOwner {

     require( USDT.transferFrom(msg.sender, address(this), amt), "insufficent USDT");
        totalCollectedUSDT += amt;
  }


   function AddUSDC(uint256 amt) external onlyOwner {

     require( USDC.transferFrom(msg.sender, address(this), amt), "insufficent USDT");
        totalCollectedUSDC += amt;
  }


    function getRemainingTokens() external view returns (uint256) {
        return gameToken.balanceOf(address(this));
    }

    function getTokensPurchasedByUser(address user) external view returns (uint256) {
        return tokensPurchased[user];
    }

    function getTotalGameTokens() external view returns (uint256) {
        return totalGameTokens;
    }

    function pause() external onlyOwner {
        paused = true;
    }

    function unpause() external onlyOwner {
        paused = false;
    }

    receive() external payable {}
}
