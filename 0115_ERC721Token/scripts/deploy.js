// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const ERC721TokenContract = await hre.ethers.getContractFactory("ERC721Token");
  const ERC721Token = await ERC721TokenContract.deploy();
  await ERC721Token.waitForDeployment();
  const ERC721TokenAddr = ERC721Token.target;
  console.log("ERC721Token contract has been deployed to: " + ERC721TokenAddr);

  // ERC777TokenGTT has already deployed to: 0x6307230425563aA7D0000213f579516159CDf84a
  const ERC777TokenGTTAddr = "0x6307230425563aA7D0000213f579516159CDf84a";
  const NFTMarketContract = await hre.ethers.getContractFactory("NFTMarket");
  const NFTMarket = await NFTMarketContract.deploy(ERC777TokenGTTAddr);
  await NFTMarket.waitForDeployment();
  const NFTMarketAddr = NFTMarket.target;
  console.log("NFTMarket contract has been deployed to: " + NFTMarketAddr);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
