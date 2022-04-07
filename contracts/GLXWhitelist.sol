// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract GLXWhitelist is Ownable {
    struct WhitelistInfo {
        uint256 depositBalance;
        uint256 totalClaimable;
        uint256 claimed;
    }
    using SafeMath for uint256;
    
    address teamWallet; // dia chi vi cua team de nhan BUSD khi nguoi dung mua whitelist
    // address busdTokenAddress=0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // mainnet BUSD 
    address busdTokenAddress=0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // testnet BUSD 

    address glxTokenAddress;// GLX
    
    mapping(address=>bool) wlAddresses;
    mapping(address=>WhitelistInfo) whitelistInfo;
    mapping(uint256 => uint256) unlockFundRate; // unlocking rate each phase
       
    uint256 maxBuyPerUser = 150*10**18;  // 150 BUSD
    uint256 poolAmount = 50000000*10**18; // 50 millions GLX
    uint256 rate = 2; // Whitelist price 0.002 BUSD = 1 GLX
    // 10 minutes after listing, user can claim part of their tokens call unlockclaim()  
    uint256 tgeUnlockTime;
    // Unlock partly every 30 days
    // uint256 unlockTimeLock = 30 days;
    // Test
    uint256 unlockTimeLock = 5 minutes;
    bool public isWhitelistOpen = false;
    bool public isUnlockClaim = false; 
    
    constructor(address _glxTokenAddress, address _teamWallet){
        glxTokenAddress = _glxTokenAddress;
        teamWallet = _teamWallet;
        // unlock 20% at TGE, 20% every month after TGE(Token generation event)
        unlockFundRate[0] = 20; 
        unlockFundRate[1] = 40;
        unlockFundRate[2] = 60;
        unlockFundRate[3] = 80;
        unlockFundRate[4] = 100;
    }
    
    function setGLXToken(address _glxTokenAddress) public onlyOwner {
        glxTokenAddress =_glxTokenAddress;
    }
    
    function setTeamWallet(address _teamWallet) public onlyOwner {
        teamWallet = _teamWallet;
    }
    
    function addWhiteListAddr(address[] memory _addresses, bool _isWL) public onlyOwner {
        for(uint i=0;i<_addresses.length;i++){
            wlAddresses[_addresses[i]] = _isWL;
        }
    }
    
    function openWhitelistSale(bool _isOpen ) public onlyOwner{
        isWhitelistOpen = _isOpen;
    }
    
    // if cannot sell all public pool, withdraw the remaining GLX to teamWallet
    function withdrawPoolAmount() public onlyOwner{
        IERC20(glxTokenAddress).transfer(teamWallet, IERC20(glxTokenAddress).balanceOf(address(this)));
    }
    
    function depositWhitelist(uint256 amount) public {
        require(isWhitelistOpen, "Please wait for the whitelist open");
        require(isWhitelistAddress(_msgSender()),"Not in whitelist");
        require(whitelistInfo[_msgSender()].depositBalance == 0,"Deposited already! You can deposit only once!");
        require(amount > 0, "Deposit amount must be > 0");
        require(amount <= maxBuyPerUser,"Deposit > Max Buy");
        
        uint256 amountToken = amount.mul(1000).div(rate); // claimable GLX
        require(amountToken <= poolAmount, "Deposit > Available amount in the Pool");
        
        // Transfer BUSD from user to teamWallet
        IERC20(busdTokenAddress).transferFrom(_msgSender(), teamWallet, amount);
        
        // Save user info after deposit
        whitelistInfo[_msgSender()].depositBalance = amount;
        whitelistInfo[_msgSender()].totalClaimable = amountToken;
        
        poolAmount = poolAmount.sub(amountToken);
    }
    
    function claim() public {
        require(isUnlockClaim, "You can't claim GLX at this moment");
        require(isWhitelistAddress(_msgSender()),"Your address is not in whitelist");
        uint256 unlockedAmount = getUnlockedAmount(_msgSender());
        // get claimable GLXs
        uint256 availableForClaimAmount = availableClaim(_msgSender());
        require(availableForClaimAmount > 0, "Nothing for claim");
        
        // send to user
        IERC20(glxTokenAddress).transfer(_msgSender(), availableForClaimAmount);
        // reset their claimed GLX
        whitelistInfo[_msgSender()].claimed = unlockedAmount;
    }
    
    function getRemaninToken() public view returns(uint256){
        return poolAmount;
    }
    
    function getTotalDeposit(address _address) public view returns(uint256){
        return whitelistInfo[_address].depositBalance;
    }
    
    function getTotalClaimableBalance(address _address) public view returns(uint256){
        return whitelistInfo[_address].totalClaimable;
    }
    
    function unlockClaim() public onlyOwner{
        require(!isWhitelistOpen,"whitelist must be closed");
        tgeUnlockTime = block.timestamp;
        isUnlockClaim = true;
    }
    
    function getNextTimestampClaim() public view returns(uint256){
        uint256 unlockFundRateIndex = block.timestamp.sub(tgeUnlockTime).div(unlockTimeLock).add(1);
        return unlockFundRateIndex.mul(unlockTimeLock).add(tgeUnlockTime);
    }
    
    function isWhitelistAddress(address _address) public view returns(bool){
        return wlAddresses[_address];
    }
    function availableRemainClaimable(address _address) public view returns(uint256){
        return  whitelistInfo[_address].totalClaimable.sub(whitelistInfo[_address].claimed);
    }
    function availableClaim(address _address) public view returns(uint256){
        uint256 unlockedAmount = getUnlockedAmount(_address);
        return unlockedAmount - whitelistInfo[_address].claimed;
    }
    
    function getUnlockedAmount(address _address) internal view returns(uint256){
        // get index of unlockFundRate
        uint256 unlockFundRateIndex = block.timestamp.sub(tgeUnlockTime).div(unlockTimeLock);

        if(unlockFundRateIndex > 4) 
            unlockFundRateIndex = 4;
        
        // return rate * claimable tokens
        return whitelistInfo[_address].totalClaimable.mul(unlockFundRate[unlockFundRateIndex]).div(100);
    }
}

