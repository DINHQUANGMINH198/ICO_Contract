const hre = require('hardhat')

let args  = require("./args.json");


async function main() {
  await hre.run('verify:verify', {
    address: '0xF36F102665c6F7BDBFC0bc7C18e6bBd9061F8C38', //contract address
    constructorArguments: [
      args.glxTokenAddress,
      args.teamWallet

    ],
  })
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })