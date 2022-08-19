const fs = require("fs");
const { ethers } = require("hardhat");
const { artifacts } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Stake = await ethers.getContractFactory("Stake");
  //Passing Starknet core contract address and Stake L2 address
  const stake = await Stake.deploy(
    "0xde29d060D45901Fb19ED6C6e959EB22d8626708e",
    "0x03be0a73017ce6eed4fc2202d9ee283d0c3ee3fa8eb675b16614a13f413b1df5"
  );
  console.log("Stake smart contract address:", stake.address);

  const data_stake = {
    address: stake.address,
    abi: JSON.parse(stake.interface.format("json")),
  };

  if (!fs.existsSync("artifacts/ABI")) fs.mkdirSync("artifacts/ABI");
  fs.writeFileSync("artifacts/ABI/Stake.json", JSON.stringify(data_stake), {
    flag: "w",
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
