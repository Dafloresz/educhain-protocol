// test/EduChain.test.js
const { expect }       = require("chai");
const { ethers }       = require("hardhat");
const { time }         = require("@nomicfoundation/hardhat-network-helpers");

describe("EduChain Protocol", function () {
  let admin, student1, student2, attacker;
  let eduToken, certificate, course, staking, governance, platform, mockFeed;

  const ETH_PRICE  = ethers.BigNumber.from("300000000000"); // $3000, 8 dec
  const BASE_APR   = 1200;
  const BONUS_APR  = 1500; // 12 + 3
  const LOCK       = 7 * 24 * 3600;

  beforeEach(async () => {
    [admin, student1, student2, attacker] = await ethers.getSigners();

    // Mock Price Feed
    const Mock = await ethers.getContractFactory("MockV3Aggregator");
    mockFeed   = await Mock.deploy(8, ETH_PRICE);

    // EduToken
    const EduToken = await ethers.getContractFactory("EduToken");
    eduToken = await EduToken.deploy(admin.address);

    // EduCertificate
    const EduCertificate = await ethers.getContractFactory("EduCertificate");
    certificate = await EduCertificate.deploy(admin.address, true);

    // EduCourse
    const EduCourse = await ethers.getContractFactory("EduCourse");
    course = await EduCourse.deploy(
      admin.address,
      "https://api.educhain.io/metadata/{id}.json"
    );

    // EduStaking
    const EduStaking = await ethers.getContractFactory("EduStaking");
    staking = await EduStaking.deploy(
      eduToken.address,
      mockFeed.address,
      admin.address
    );

    // EduGovernance
    const EduGovernance = await ethers.getContractFactory("EduGovernance");
    governance = await EduGovernance.deploy(eduToken.address, admin.address);

    // EduPlatform
    const EduPlatform = await ethers.getContractFactory("EduPlatform");
    platform = await EduPlatform.deploy(
      eduToken.address,
      certificate.address,
      course.address,
      admin.address
    );

    // Configura roles
    const MINTER_ROLE = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("MINTER_ROLE"));
    await eduToken.grantRole(MINTER_ROLE, platform.address);
    await certificate.grantRole(MINTER_ROLE, platform.address);
    await course.grantRole(MINTER_ROLE, platform.address);

    // Cria curso #0
    await course.connect(admin).createCourse(
      "Blockchain 101", "Curso de introdução", 0, admin.address
    );

    // Fundo o pool de staking
    const poolAmt = ethers.utils.parseEther("10000");
    await eduToken.mint(admin.address, poolAmt);
    await eduToken.approve(staking.address, poolAmt);
    await staking.fundRewardPool(poolAmt);
  });

  // ─── EduToken ──────────────────────────────────────────────────────────────
  describe("EduToken (ERC-20)", () => {
    it("deve ter nome e símbolo corretos", async () => {
      expect(await eduToken.name()).to.equal("EduToken");
      expect(await eduToken.symbol()).to.equal("EDU");
    });

    it("deve mintar tokens com MINTER_ROLE", async () => {
      await eduToken.mint(student1.address, ethers.utils.parseEther("100"));
      expect(await eduToken.balanceOf(student1.address))
        .to.equal(ethers.utils.parseEther("100"));
    });

    it("deve rejeitar mint sem MINTER_ROLE", async () => {
      await expect(
        eduToken.connect(attacker).mint(attacker.address, 1000)
      ).to.be.reverted;
    });

    it("não deve ultrapassar MAX_SUPPLY", async () => {
      const max = await eduToken.MAX_SUPPLY();
      await expect(
        eduToken.mint(student1.address, max.add(1))
      ).to.be.revertedWith("EduToken: max supply exceeded");
    });

    it("deve pausar e bloquear transferências", async () => {
      await eduToken.mint(student1.address, ethers.utils.parseEther("100"));
      await eduToken.pause();
      await expect(
        eduToken.connect(student1).transfer(student2.address, 1)
      ).to.be.revertedWith("Pausable: paused");
      await eduToken.unpause();
    });
  });

  // ─── EduCertificate ────────────────────────────────────────────────────────
  describe("EduCertificate (ERC-721 Soulbound)", () => {
    it("deve emitir certificado corretamente", async () => {
      const tx = await certificate.connect(admin).issueCertificate(
        student1.address, 0, "Blockchain 101", 90, "ipfs://test"
      );
      const receipt = await tx.wait();
      const event   = receipt.events?.find(e => e.event === "CertificateIssued");
      expect(event).to.not.be.undefined;
      expect(event.args.student).to.equal(student1.address);
      expect(event.args.grade).to.equal(90);
    });

    it("não deve emitir certificado duplicado", async () => {
      await certificate.connect(admin).issueCertificate(
        student1.address, 0, "Blockchain 101", 90, "ipfs://test"
      );
      await expect(
        certificate.connect(admin).issueCertificate(
          student1.address, 0, "Blockchain 101", 85, "ipfs://test2"
        )
      ).to.be.revertedWith("CERT: certificate already issued");
    });

    it("soulbound: deve bloquear transferência", async () => {
      await certificate.connect(admin).issueCertificate(
        student1.address, 0, "Blockchain 101", 90, "ipfs://test"
      );
      await expect(
        certificate.connect(student1).transferFrom(
          student1.address, student2.address, 1
        )
      ).to.be.revertedWith("CERT: soulbound token non-transferable");
    });

    it("deve retornar certificados por aluno", async () => {
      await certificate.connect(admin).issueCertificate(
        student1.address, 0, "Blockchain 101", 90, "ipfs://test"
      );
      const certs = await certificate.getCertificatesByStudent(student1.address);
      expect(certs.length).to.equal(1);
    });
  });

  // ─── EduCourse ─────────────────────────────────────────────────────────────
  describe("EduCourse (ERC-1155)", () => {
    it("deve criar curso e emitir token de inscrição", async () => {
      await course.createCourse("DeFi Advanced", "Curso avançado", 0, admin.address);
      const c = await course.courses(1);
      expect(c.name).to.equal("DeFi Advanced");
    });

    it("deve matricular aluno e emitir token ERC-1155", async () => {
      await course.connect(admin).enroll(0, student1.address);
      const balance = await course.balanceOf(student1.address, 0);
      expect(balance).to.equal(1);
    });

    it("não deve permitir dupla matrícula", async () => {
      await course.connect(admin).enroll(0, student1.address);
      await expect(
        course.connect(admin).enroll(0, student1.address)
      ).to.be.revertedWith("EduCourse: already enrolled");
    });

    it("deve emitir badge ao concluir", async () => {
      await course.connect(admin).enroll(0, student1.address);
      await course.connect(admin).completeCourse(0, student1.address);
      const badgeBalance = await course.balanceOf(student1.address, 1);
      expect(badgeBalance).to.equal(1);
    });
  });

  // ─── EduPlatform ───────────────────────────────────────────────────────────
  describe("EduPlatform (Orquestrador)", () => {
    it("fluxo completo: matrícula → conclusão → certificado + EDU", async () => {
      await platform.connect(admin).enrollStudent(student1.address, 0);
      expect(await course.enrolled(0, student1.address)).to.be.true;

      const tx = await platform.connect(admin).completeCourse(
        student1.address, 0, "Blockchain 101", 95, "ipfs://cert"
      );
      const receipt = await tx.wait();
      const event   = receipt.events?.find(e => e.event === "CourseCompleted");

      expect(await certificate.hasCertificate(student1.address, 0)).to.be.true;

      const reward = event.args.rewardAmount;
      expect(reward).to.equal(ethers.utils.parseEther("100"));
      expect(await eduToken.balanceOf(student1.address)).to.equal(reward);
    });

    it("deve rejeitar conclusão com nota < 60", async () => {
      await platform.connect(admin).enrollStudent(student1.address, 0);
      await expect(
        platform.connect(admin).completeCourse(
          student1.address, 0, "Blockchain 101", 50, "ipfs://cert"
        )
      ).to.be.revertedWith("Platform: minimum grade not met (60)");
    });

    it("recompensa proporcional: nota 70–89 = 80 EDU", async () => {
      await platform.connect(admin).enrollStudent(student1.address, 0);
      const tx = await platform.connect(admin).completeCourse(
        student1.address, 0, "Blockchain 101", 75, "ipfs://cert"
      );
      const receipt = await tx.wait();
      const event   = receipt.events?.find(e => e.event === "CourseCompleted");
      expect(event.args.rewardAmount).to.equal(ethers.utils.parseEther("80"));
    });
  });

  // ─── EduStaking ────────────────────────────────────────────────────────────
  describe("EduStaking", () => {
    beforeEach(async () => {
      await eduToken.mint(student1.address, ethers.utils.parseEther("1000"));
      await eduToken.connect(student1).approve(
        staking.address, ethers.utils.parseEther("1000")
      );
    });

    it("deve aceitar stake e registrar corretamente", async () => {
      const amount = ethers.utils.parseEther("100");
      await staking.connect(student1).stake(amount);
      const info = await staking.stakes(student1.address);
      expect(info.amount).to.equal(amount);
      expect(await staking.totalStaked()).to.equal(amount);
    });

    it("deve calcular APR com bônus quando ETH > $2500", async () => {
      const apr = await staking.effectiveApr();
      expect(apr).to.equal(BASE_APR + 300);
    });

    it("deve calcular APR base quando ETH < $2500", async () => {
      await mockFeed.updateAnswer(ethers.BigNumber.from("200000000000")); // $2000
      const apr = await staking.effectiveApr();
      expect(apr).to.equal(BASE_APR);
    });

    it("deve acumular recompensas com o tempo", async () => {
      await staking.connect(student1).stake(ethers.utils.parseEther("1000"));

      const oneYear = 365 * 24 * 3600;
      await time.increase(oneYear);

      // ✅ FIX: atualiza o mock oracle para refletir o novo timestamp
      await mockFeed.updateAnswer(ETH_PRICE);

      const pending = await staking.pendingRewards(student1.address);
      expect(pending).to.be.gt(ethers.utils.parseEther("140"));
    });

    it("deve bloquear saque antes do lock period", async () => {
      await staking.connect(student1).stake(ethers.utils.parseEther("100"));
      await expect(
        staking.connect(student1).withdraw(ethers.utils.parseEther("100"))
      ).to.be.revertedWith("Staking: tokens still locked");
    });

    it("deve permitir saque após o lock period", async () => {
      const amount = ethers.utils.parseEther("100");
      await staking.connect(student1).stake(amount);

      await time.increase(LOCK + 1);

      // ✅ FIX: atualiza o mock oracle para refletir o novo timestamp
      await mockFeed.updateAnswer(ETH_PRICE);

      await staking.connect(student1).withdraw(amount);
      const info = await staking.stakes(student1.address);
      expect(info.amount).to.equal(0);
    });
  });

  // ─── EduGovernance ─────────────────────────────────────────────────────────
  describe("EduGovernance (DAO)", () => {
    beforeEach(async () => {
      await eduToken.mint(student1.address, ethers.utils.parseEther("2000"));
      await eduToken.mint(student2.address, ethers.utils.parseEther("500"));
      // ✅ FIX: admin também precisa de EDU para ter poder de voto
      await eduToken.mint(admin.address, ethers.utils.parseEther("1000"));
    });

    it("deve criar proposta com tokens suficientes", async () => {
      const tx = await governance.connect(student1).propose(
        "Aumentar recompensa", ethers.constants.AddressZero, "0x"
      );
      const receipt = await tx.wait();
      expect(receipt.events?.find(e => e.event === "ProposalCreated")).to.not.be.undefined;
    });

    it("deve rejeitar proposta sem tokens suficientes", async () => {
      await expect(
        governance.connect(attacker).propose(
          "Proposta inválida", ethers.constants.AddressZero, "0x"
        )
      ).to.be.revertedWith("Gov: insufficient tokens to propose");
    });

    it("fluxo completo: proposta → votação → fila → execução", async () => {
      let tx = await governance.connect(student1).propose(
        "Teste governança", ethers.constants.AddressZero, "0x"
      );
      let receipt = await tx.wait();
      const propId = receipt.events?.find(e => e.event === "ProposalCreated")?.args?.id;

      await governance.connect(student1).castVote(propId, true);
      await governance.connect(admin).castVote(propId, true); // ✅ agora admin tem EDU

      await time.increase(3 * 24 * 3600 + 1);

      await governance.queue(propId);
      const p = await governance.proposals(propId);
      expect(p.eta).to.be.gt(0);

      await time.increase(24 * 3600 + 1);

      await governance.execute(propId);
      expect(await governance.state(propId)).to.equal(5); // Executed
    });

    it("não deve votar duas vezes", async () => {
      const tx = await governance.connect(student1).propose(
        "Proposta duplo voto", ethers.constants.AddressZero, "0x"
      );
      const receipt = await tx.wait();
      const propId  = receipt.events[0].args.id;

      await governance.connect(student1).castVote(propId, true);
      await expect(
        governance.connect(student1).castVote(propId, false)
      ).to.be.revertedWith("Gov: already voted");
    });
  });

  // ─── Segurança ─────────────────────────────────────────────────────────────
  describe("Segurança", () => {
    it("deve proteger contra acesso não autorizado a roles", async () => {
      await expect(
        platform.connect(attacker).enrollStudent(student1.address, 0)
      ).to.be.reverted;
    });

    it("deve rejeitar endereço zero em operações críticas", async () => {
      await expect(
        certificate.connect(admin).issueCertificate(
          ethers.constants.AddressZero, 0, "Test", 90, "ipfs://test"
        )
      ).to.be.revertedWith("CERT: invalid student address");
    });

    it("EduStaking: deve rejeitar stake de 0", async () => {
      await expect(
        staking.connect(student1).stake(0)
      ).to.be.revertedWith("Staking: amount must be > 0");
    });

    it("deve pausar toda a plataforma em emergências", async () => {
      await platform.pause();
      await expect(
        platform.connect(admin).enrollStudent(student1.address, 0)
      ).to.be.revertedWith("Pausable: paused");
      await platform.unpause();
    });
  });
});