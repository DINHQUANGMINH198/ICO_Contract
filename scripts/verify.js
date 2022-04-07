const hre = require('hardhat')

// Define the FT
const name = 'GLXToken'
const symbol = 'GLX'

async function main() {
  await hre.run('verify:verify', {
    address: '0xD0703300B78c6b47A0Ea533548AB40357E008C5F',
    constructorArguments: [
      name,
      symbol,

    ],
  })
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })