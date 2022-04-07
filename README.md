 <!-- Hardhat Project -->
<!-- install lib  -->
npm install --save-dev hardhat @nomiclabs/hardhat-waffle ethereum-waffle chai @nomiclabs/hardhat-ethers ethers @nomiclabs/hardhat-etherscan
<!-- set up env , key , args config -->
<!-- npx hardhat compile -->
npx hardhat run --network testnet scripts/deploy.js
npx hardhat run scripts/verify.js --network testnet
<!-- Test -->
Deploy Token contract
Deploy ICO contract 
Deposit Token -> ICO contract 
user trúng ICO được add vào whitelist
kết thúc add user ICO openWhitelistSale
user->approve(BUSD)-> ICO contract -> deposit BUSD
unlock claim -> user wait each phase to claim token 
Hết đợt nếu còn dư token withdraw từ contract về ví
