
const hre = require("hardhat");

async function main() {
  const tokenContract = await hre.ethers.deployContract("Token");
  await tokenContract.waitForDeployment();
  console.log("Token Contract Deployed at : ", tokenContract.target);
  const exchangeContract = await hre.ethers.deployContract("Exchange",[tokenContract.target])
  await exchangeContract.waitForDeployment();
  console.log("Exchange Contract Deployed at : ",exchangeContract.target);

  // await sleep(30*1000);

  await hre.run("verify:verify",{
    address : tokenContract.target,
    constructorArguments : []
  })

  await hre.run("verify:verify",{
    address : exchangeContract.target,
    constructorArguments : [tokenContract.target]
  })
}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
