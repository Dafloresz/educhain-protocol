# EduChain Protocol 🎓⛓

Plataforma descentralizada de estudos que emite **certificados NFT** ao concluir cursos, com sistema de **staking de recompensas** e **governança DAO on-chain**.

## Visão Geral do Protocolo

```
┌─────────────────────────────────────────────────────────────────┐
│                        EduChain Protocol                        │
├──────────────┬──────────────┬───────────────┬───────────────────┤
│  EduToken    │EduCertificate│   EduCourse   │   EduStaking      │
│  (ERC-20)    │  (ERC-721)   │  (ERC-1155)   │  + Chainlink      │
│              │  Soulbound   │               │  ETH/USD Oracle   │
├──────────────┴──────────────┴───────────────┴───────────────────┤
│                       EduPlatform                               │
│              (Orquestrador Central)                             │
├─────────────────────────────────────────────────────────────────┤
│                     EduGovernance (DAO)                         │
└─────────────────────────────────────────────────────────────────┘
```

## Fluxo do Aluno

```
1. Admin cria curso (EduCourse.createCourse)
        ↓
2. Aluno se inscreve (EduPlatform.enrollStudent)
   └→ Recebe token ERC-1155 de inscrição
        ↓
3. Aluno conclui curso (EduPlatform.completeCourse)
   ├→ Emite certificado NFT ERC-721 (soulbound, intransferível)
   ├→ Emite badge ERC-1155 de conclusão
   └→ Recebe recompensa em EDU (ERC-20), proporcional à nota
        ↓
4. Aluno faz stake de EDU (EduStaking.stake)
   └→ APR ajustado pelo preço ETH/USD (Chainlink)
        ↓
5. Aluno participa da DAO (EduGovernance.propose / castVote)
```

## Contratos

| Contrato | Padrão | Descrição |
|---|---|---|
| `EduToken` | ERC-20 | Token de recompensa (EDU) |
| `EduCertificate` | ERC-721 | Certificado NFT soulbound |
| `EduCourse` | ERC-1155 | Tokens de inscrição e badges |
| `EduStaking` | — | Staking com oracle Chainlink |
| `EduGovernance` | — | DAO simplificada |
| `EduPlatform` | — | Orquestrador central |

## Justificativa dos Padrões ERC

### ERC-20 (EduToken)
Token fungível para recompensas. Escolhido por ser o padrão universal de tokens de governança e utilidade, com suporte nativo em todas as DEXs e carteiras.

### ERC-721 (EduCertificate)
Certificados são únicos por natureza (um aluno, um curso, uma nota específica). ERC-721 garante unicidade e é o padrão mais reconhecido para credenciais digitais. Implementado como **soulbound** (intransferível), garantindo autenticidade.

### ERC-1155 (EduCourse)
Um único contrato gerencia TODOS os cursos da plataforma. Cada curso tem dois tokens: um fungível (inscrição, pode ter múltiplos alunos) e um não-fungível (badge único por aluno). Reduz gas de deploy e permite operações em lote — ideal para uma plataforma com múltiplos cursos.

## Instalação

```bash
# 1. Instalar dependências
npm install

# 2. Copiar e configurar variáveis de ambiente
cp .env.example .env
# Edite .env com suas chaves

# 3. Compilar contratos
npx hardhat compile

# 4. Rodar testes
npx hardhat test

# 5. Deploy local
npx hardhat node          # Terminal 1
npx hardhat run scripts/deploy.js --network localhost  # Terminal 2

# 6. Rodar script de interação
npx hardhat run scripts/interact.js --network localhost

# 7. Abrir frontend
# Abra frontend/index.html no navegador
```

## Deploy em Testnet (Sepolia)

```bash
# Configure .env com:
# PRIVATE_KEY=sua_chave_privada_sem_0x
# SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/SEU_ID
# ETHERSCAN_API_KEY=sua_chave

npx hardhat run scripts/deploy.js --network sepolia

# Verificar no Etherscan
npx hardhat verify --network sepolia ENDERECO_DO_CONTRATO "arg1" "arg2"
```

## Segurança

- ✅ `ReentrancyGuard` em todas as funções com transferência de tokens
- ✅ `AccessControl` com roles específicas por função
- ✅ `Pausable` para emergências em todos os contratos críticos
- ✅ `SafeERC20` para transferências seguras
- ✅ Solidity `^0.8.17` (overflow/underflow nativo)
- ✅ Certificados **soulbound** (não transferíveis)
- ✅ Oráculo Chainlink com verificação de staleness (máx 1h)

## Oráculo Chainlink

O contrato `EduStaking` integra o Chainlink ETH/USD Price Feed:
- APR base: **12% ao ano**
- Bônus quando ETH > $2.500: **+3% (total 15%)**
- Verificação de dados frescos (rejeita dados > 1h)

```solidity
// ETH > $2500 → APR = 15%
// ETH ≤ $2500 → APR = 12%
function effectiveApr() public view returns (uint256) {
    uint256 ethPrice = getEthUsdPrice();
    return ethPrice >= ETH_PRICE_THRESHOLD ? BASE_APR + BONUS_BPS : BASE_APR;
}
```

## Governança DAO

| Parâmetro | Valor |
|---|---|
| Threshold para propor | 1.000 EDU |
| Período de votação | 3 dias |
| Quórum mínimo | 4% do supply total |
| Timelock | 1 dia |
| Peso do voto | Saldo EDU do voter |

## Frontend Web3

O frontend (`frontend/index.html`) é uma dApp completa que:
- Conecta com MetaMask (ethers.js v5)
- Lista cursos disponíveis
- Exibe certificados NFT do aluno
- Permite staking/unstaking/claim de recompensas
- Mostra propostas de governança com barra de votos em tempo real
- Exibe preço ETH/USD do oráculo Chainlink

## Estrutura do Projeto

```
educhain/
├── contracts/
│   ├── EduToken.sol          # ERC-20
│   ├── EduCertificate.sol    # ERC-721 soulbound
│   ├── EduCourse.sol         # ERC-1155
│   ├── EduStaking.sol        # Staking + Chainlink
│   ├── EduGovernance.sol     # DAO
│   ├── EduPlatform.sol       # Orquestrador
│   └── mocks/
│       └── MockV3Aggregator.sol
├── scripts/
│   ├── deploy.js             # Deploy completo
│   └── interact.js           # Demonstração Web3
├── test/
│   └── EduChain.test.js      # Suite completa de testes
├── frontend/
│   └── index.html            # dApp Web3
├── deployments/              # Endereços pós-deploy
├── hardhat.config.js
└── package.json
```

## Variáveis de Ambiente

```env
PRIVATE_KEY=            # Chave privada da carteira (sem 0x)
SEPOLIA_RPC_URL=        # RPC Sepolia (Infura/Alchemy)
MUMBAI_RPC_URL=         # RPC Mumbai Polygon
ETHERSCAN_API_KEY=      # Para verificação de contratos
POLYGONSCAN_API_KEY=    # Para verificação na Polygon
COINMARKETCAP_API_KEY=  # Para relatório de gas (opcional)
REPORT_GAS=true         # Ativa relatório de gas
```

## Licença

MIT
