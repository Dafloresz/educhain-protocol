// scripts/interact.js
// Script de integração Web3 – demonstra todas as funcionalidades do protocolo
// Uso: npx hardhat run scripts/interact.js --network localhost

const { ethers } = require("hardhat");
const fs   = require("fs");
const path = require("path");

async function loadDeployment(chainId) {
  const file = path.join(__dirname, "../deployments", `${chainId}.json`);
  if (!fs.existsSync(file)) {
    throw new Error(`Deployment não encontrado para chainId ${chainId}. Execute deploy.js primeiro.`);
  }
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

async function main() {
  const [admin, student1, student2] = await ethers.getSigners();
  const network  = await ethers.provider.getNetwork();
  const chainId  = network.chainId;
  const deploy   = await loadDeployment(chainId);

  console.log("\n═══════════════════════════════════════════════");
  console.log("  EduChain Protocol – Demonstração Interativa");
  console.log("═══════════════════════════════════════════════\n");

  // ─── Conecta aos contratos ────────────────────────────────────────────────
  const EduToken       = await ethers.getContractFactory("EduToken");
  const EduCertificate = await ethers.getContractFactory("EduCertificate");
  const EduCourse      = await ethers.getContractFactory("EduCourse");
  const EduStaking     = await ethers.getContractFactory("EduStaking");
  const EduGovernance  = await ethers.getContractFactory("EduGovernance");
  const EduPlatform    = await ethers.getContractFactory("EduPlatform");

  const eduToken    = EduToken.attach(deploy.contracts.EduToken);
  const certificate = EduCertificate.attach(deploy.contracts.EduCertificate);
  const course      = EduCourse.attach(deploy.contracts.EduCourse);
  const staking     = EduStaking.attach(deploy.contracts.EduStaking);
  const governance  = EduGovernance.attach(deploy.contracts.EduGovernance);
  const platform    = EduPlatform.attach(deploy.contracts.EduPlatform);

  // ─── ETAPA 1: Matrícula ───────────────────────────────────────────────────
  console.log("── ETAPA 1: Matrícula de Alunos ──────────────────────");
  
  let tx = await platform.connect(admin).enrollStudent(student1.address, 0);
  await tx.wait();
  console.log(`  ✅ ${student1.address} matriculado no curso #0`);

  tx = await platform.connect(admin).enrollStudent(student2.address, 0);
  await tx.wait();
  console.log(`  ✅ ${student2.address} matriculado no curso #0`);

  // Verifica token ERC-1155 de inscrição
  const enrollTokenId = 0; // courseId * 2
  const bal1 = await course.balanceOf(student1.address, enrollTokenId);
  console.log(`  Token ERC-1155 de inscrição (aluno1): ${bal1.toString()}`);

  // ─── ETAPA 2: Conclusão de Curso ──────────────────────────────────────────
  console.log("\n── ETAPA 2: Conclusão de Curso e Emissão de Certificado ──");

  const metadataURI = "ipfs://QmExampleHashEduChainCertificate";
  
  tx = await platform.connect(admin).completeCourse(
    student1.address,
    0,                    // courseId
    "Blockchain Fundamentals",
    95,                   // grade (nota 95 → 100% de recompensa)
    metadataURI
  );
  const receipt = await tx.wait();

  // Extrai tokenId do evento
  const event = receipt.events?.find(e => e.event === "CourseCompleted");
  const certTokenId = event?.args?.certTokenId;
  const rewardAmt   = event?.args?.rewardAmount;

  console.log(`  ✅ Certificado NFT emitido (tokenId: ${certTokenId})`);
  console.log(`  ✅ Recompensa EDU: ${ethers.utils.formatEther(rewardAmt)} EDU`);

  const certData = await certificate.certificates(certTokenId);
  console.log(`  Certificado: Curso="${certData.courseName}", Nota=${certData.grade}`);

  const eduBalance = await eduToken.balanceOf(student1.address);
  console.log(`  Saldo EDU do aluno1: ${ethers.utils.formatEther(eduBalance)} EDU`);

  // ─── ETAPA 3: Oráculo – Preço ETH/USD ─────────────────────────────────────
  console.log("\n── ETAPA 3: Consulta ao Oráculo (Chainlink ETH/USD) ──");

  const ethPrice = await staking.getEthUsdPrice();
  const ethPriceFormatted = ethers.utils.formatUnits(ethPrice, 8);
  console.log(`  ETH/USD (Chainlink): $${ethPriceFormatted}`);

  const apr = await staking.effectiveApr();
  console.log(`  APR efetivo de staking: ${apr.toNumber() / 100}%`);

  // ─── ETAPA 4: Staking ─────────────────────────────────────────────────────
  console.log("\n── ETAPA 4: Staking de EDU Tokens ───────────────────");

  const stakeAmount = ethers.utils.parseEther("50");
  await eduToken.connect(student1).approve(staking.address, stakeAmount);
  tx = await staking.connect(student1).stake(stakeAmount);
  await tx.wait();
  console.log(`  ✅ ${ethers.utils.formatEther(stakeAmount)} EDU em stake (aluno1)`);

  const stakeInfo = await staking.stakes(student1.address);
  console.log(`  Stake ativo: ${ethers.utils.formatEther(stakeInfo.amount)} EDU`);

  // ─── ETAPA 5: Governança – Criar Proposta ─────────────────────────────────
  console.log("\n── ETAPA 5: Governança (DAO) ─────────────────────────");

  // Mint EDU para student1 ter tokens suficientes para propor
  await eduToken.mint(student1.address, ethers.utils.parseEther("2000"));

   // Mint EDU para admin ter tokens suficientes para propor, pois castVote exige saldo EDU > 0
  await eduToken.mint(admin.address, ethers.utils.parseEther("1000"));

  tx = await governance.connect(student1).propose(
    "Aumentar recompensa de conclusão de 100 EDU para 150 EDU",
    ethers.constants.AddressZero, // sinalização off-chain
    "0x"
  );
  const propReceipt = await tx.wait();
  const propEvent   = propReceipt.events?.find(e => e.event === "ProposalCreated");
  const proposalId  = propEvent?.args?.id;
  console.log(`  ✅ Proposta #${proposalId} criada`);

  // Vota na proposta
  tx = await governance.connect(student1).castVote(proposalId, true); // SIM
  await tx.wait();
  console.log(`  ✅ Voto SIM registrado (aluno1)`);

  tx = await governance.connect(admin).castVote(proposalId, true); // SIM
  await tx.wait();
  console.log(`  ✅ Voto SIM registrado (admin)`);

  const summary = await governance.getVoteSummary(proposalId);
  console.log(`  Votos SIM: ${ethers.utils.formatEther(summary.forVotes)} EDU`);
  console.log(`  Votos NÃO: ${ethers.utils.formatEther(summary.againstVotes)} EDU`);
  console.log(`  Quórum necessário: ${ethers.utils.formatEther(summary.quorumRequired)} EDU`);

  // ─── ETAPA 6: Resumo ─────────────────────────────────────────────────────
  console.log("\n─────────────────────────────────────────────────────");
  console.log("  RESUMO DO PROTOCOLO");
  console.log("─────────────────────────────────────────────────────");
  console.log(`  Total EDU em circulação : ${ethers.utils.formatEther(await eduToken.totalSupply())} EDU`);
  console.log(`  Total EDU em stake      : ${ethers.utils.formatEther(await staking.totalStaked())} EDU`);
  console.log(`  Certificados emitidos   : ${await certificate.totalSupply()}`);
  console.log(`  Cursos criados          : ${await course.courseCount()}`);
  console.log(`  Propostas de gov.       : ${await governance.proposalCount()}`);
  console.log("═══════════════════════════════════════════════\n");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
