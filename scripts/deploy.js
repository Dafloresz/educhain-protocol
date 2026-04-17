// scripts/deploy.js
// Deploy completo do protocolo EduChain
// Uso: npx hardhat run scripts/deploy.js --network <rede>
 
const hre = require("hardhat");
const { ethers } = require("hardhat");
const fs   = require("fs");
const path = require("path");
 
// Endereços Chainlink ETH/USD por rede
const CHAINLINK_FEEDS = {
  31337:    null,            // local – usará mock
  11155111: "0x694AA1769357215DE4FAC081bf1f309aDC325306", // Sepolia
  80001:    "0x0715A7794a1dc8e42615F059dD6e406A6594651A", // Mumbai
};
 
async function main() {
  const [deployer] = await ethers.getSigners();
  const network    = await ethers.provider.getNetwork();
  const chainId    = network.chainId;
 
  console.log("\n═══════════════════════════════════════════════");
  console.log("  EduChain Protocol – Deploy");
  console.log("═══════════════════════════════════════════════");
  console.log(`  Network  : ${network.name} (chainId: ${chainId})`);
  console.log(`  Deployer : ${deployer.address}`);
  console.log(`  Balance  : ${ethers.utils.formatEther(await deployer.getBalance())} ETH\n`);
 
  // ─── 1. Price Feed ─────────────────────────────────────────────────────────
  let priceFeedAddress = CHAINLINK_FEEDS[chainId];
 
  if (!priceFeedAddress) {
    console.log("⚙  Deploying MockV3Aggregator (local/testnet sem feed)...");
    const Mock = await ethers.getContractFactory("MockV3Aggregator");
    const mock = await Mock.deploy(8, ethers.BigNumber.from("300000000000"));
    await mock.deployed();
    priceFeedAddress = mock.address;
    console.log(`   MockV3Aggregator : ${priceFeedAddress}`);
  } else {
    console.log(`✅ Chainlink ETH/USD feed : ${priceFeedAddress}`);
  }
 
  // ─── 2. EduToken (ERC-20) ──────────────────────────────────────────────────
  console.log("\n⚙  Deploying EduToken (ERC-20)...");
  const EduToken = await ethers.getContractFactory("EduToken");
  const eduToken = await EduToken.deploy(deployer.address);
  await eduToken.deployed();
  console.log(`   EduToken : ${eduToken.address}`);
 
  // ─── 3. EduCertificate (ERC-721) ──────────────────────────────────────────
  console.log("\n⚙  Deploying EduCertificate (ERC-721)...");
  const EduCertificate = await ethers.getContractFactory("EduCertificate");
  const certificate = await EduCertificate.deploy(deployer.address, true);
  await certificate.deployed();
  console.log(`   EduCertificate : ${certificate.address}`);
 
  // ─── 4. EduCourse (ERC-1155) ──────────────────────────────────────────────
  console.log("\n⚙  Deploying EduCourse (ERC-1155)...");
  const EduCourse = await ethers.getContractFactory("EduCourse");
  const eduCourse = await EduCourse.deploy(
    deployer.address,
    "https://api.educhain.io/metadata/{id}.json"
  );
  await eduCourse.deployed();
  console.log(`   EduCourse : ${eduCourse.address}`);
 
  // ─── 5. EduStaking ─────────────────────────────────────────────────────────
  console.log("\n⚙  Deploying EduStaking...");
  const EduStaking = await ethers.getContractFactory("EduStaking");
  const staking = await EduStaking.deploy(
    eduToken.address,
    priceFeedAddress,
    deployer.address
  );
  await staking.deployed();
  console.log(`   EduStaking : ${staking.address}`);
 
  // ─── 6. EduGovernance ──────────────────────────────────────────────────────
  console.log("\n⚙  Deploying EduGovernance...");
  const EduGovernance = await ethers.getContractFactory("EduGovernance");
  const governance = await EduGovernance.deploy(
    eduToken.address,
    deployer.address
  );
  await governance.deployed();
  console.log(`   EduGovernance : ${governance.address}`);
 
  // ─── 7. EduPlatform (Orquestrador) ────────────────────────────────────────
  console.log("\n⚙  Deploying EduPlatform (Orquestrador)...");
  const EduPlatform = await ethers.getContractFactory("EduPlatform");
  const platform = await EduPlatform.deploy(
    eduToken.address,
    certificate.address,
    eduCourse.address,
    deployer.address
  );
  await platform.deployed();
  console.log(`   EduPlatform : ${platform.address}`);
 
  // ─── 8. Configuração de Roles ──────────────────────────────────────────────
  console.log("\n⚙  Configurando permissões (roles)...");
 
  const MINTER_ROLE = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("MINTER_ROLE"));
 
  let tx;
 
  tx = await eduToken.grantRole(MINTER_ROLE, platform.address);
  await tx.wait();
  console.log("   ✅ EduPlatform → MINTER_ROLE no EduToken");
 
  tx = await certificate.grantRole(MINTER_ROLE, platform.address);
  await tx.wait();
  console.log("   ✅ EduPlatform → MINTER_ROLE no EduCertificate");
 
  tx = await eduCourse.grantRole(MINTER_ROLE, platform.address);
  await tx.wait();
  console.log("   ✅ EduPlatform → MINTER_ROLE no EduCourse");
 
  // ─── 9. Criação de curso de demonstração ──────────────────────────────────
  console.log("\n⚙  Criando curso de demonstração...");
  tx = await eduCourse.createCourse(
    "Blockchain Fundamentals",
    "Introdução a Blockchain, DeFi e Web3",
    0,
    deployer.address
  );
  await tx.wait();
  console.log("   ✅ Curso #0 criado: 'Blockchain Fundamentals'");
 
  // ─── 10. Fundo o pool de recompensas do staking ───────────────────────────
  console.log("\n⚙  Fundando pool de recompensas do staking (10.000 EDU)...");
  const rewardAmount = ethers.utils.parseEther("10000");
 
  // ✅ FIX: aguarda cada transação ser confirmada antes de prosseguir
  tx = await eduToken.mint(deployer.address, rewardAmount);
  await tx.wait();
  console.log("   ✅ 10.000 EDU mintados");
 
  tx = await eduToken.approve(staking.address, rewardAmount);
  await tx.wait();
  console.log("   ✅ Approve confirmado");
 
  tx = await staking.fundRewardPool(rewardAmount);
  await tx.wait();
  console.log("   ✅ 10.000 EDU depositados no pool de staking");
 
  // ─── 11. Salva endereços em arquivo ───────────────────────────────────────
  const addresses = {
    network:       network.name,
    chainId:       chainId,
    deployer:      deployer.address,
    deployedAt:    new Date().toISOString(),
    contracts: {
      EduToken:       eduToken.address,
      EduCertificate: certificate.address,
      EduCourse:      eduCourse.address,
      EduStaking:     staking.address,
      EduGovernance:  governance.address,
      EduPlatform:    platform.address,
      PriceFeed:      priceFeedAddress,
    },
  };
 
  const outputPath = path.join(__dirname, "../deployments", `${chainId}.json`);
  fs.mkdirSync(path.dirname(outputPath), { recursive: true });
  fs.writeFileSync(outputPath, JSON.stringify(addresses, null, 2));
 
  // ─── Resumo final ─────────────────────────────────────────────────────────
  console.log("\n═══════════════════════════════════════════════");
  console.log("  Deploy Concluído com Sucesso!");
  console.log("═══════════════════════════════════════════════");
  console.log("  Contratos Deployados:");
  Object.entries(addresses.contracts).forEach(([name, addr]) => {
    console.log(`    ${name.padEnd(18)}: ${addr}`);
  });
  console.log(`\n  Endereços salvos em: deployments/${chainId}.json`);
  console.log("═══════════════════════════════════════════════\n");
 
  return addresses;
}
 
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
