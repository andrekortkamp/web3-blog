const hre = require("hardhat");
const fs = require('fs');

async function main() {
  /* essas duas linhas implantam o contrato na rede */
  const Blog = await hre.ethers.getContractFactory("Blog");
  const blog = await Blog.deploy("My blog");

  await blog.deployed();
  console.log("Blog deployed to:", blog.address);

  /* este código grava os endereços do contrato em um local */
/* arquivo chamado config.js que podemos usar no aplicativo */
  fs.writeFileSync('./config.js', ` export const contractAddress = "${blog.address}" export const ownerAddress = "${blog.signer.address}" `)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });