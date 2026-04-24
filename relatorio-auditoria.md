python : 'npx hardhat clean' running (wd: C:\Projetos\Projeto smart contract Avanþado\EduCation Claude (completo)\educhain_protocol\educhain)
No linha:1 caractere:1
+ python -m slither . --checklist 2>&1 | Out-File -FilePath relatorio-a ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: ('npx hardhat cl...tocol\educhain):String) [], RemoteException
    + FullyQualifiedErrorId : NativeCommandError
 
'npx hardhat clean --global' running (wd: C:\Projetos\Projeto smart contract Avanþado\EduCation Claude (completo)\educhain_protocol\educhain)
'npx hardhat compile --force' running (wd: C:\Projetos\Projeto smart contract Avanþado\EduCation Claude (completo)\educhain_protocol\educhain)
INFO:Detectors:
Detector: incorrect-exp
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#55-134) has bitwise-xor operator ^ instead of the exponentiation operator **: 
	 - inverse = (3 * denominator) ^ 2 (node_modules/@openzeppelin/contracts/utils/math/Math.sol#116)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-exponentiation
INFO:Detectors:
Detector: divide-before-multiply
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
	- denominator = denominator / twos (node_modules/@openzeppelin/contracts/utils/math/Math.sol#101)
	- inverse = (3 * denominator) ^ 2 (node_modules/@openzeppelin/contracts/utils/math/Math.sol#116)
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
	- denominator = denominator / twos (node_modules/@openzeppelin/contracts/utils/math/Math.sol#101)
	- inverse *= 2 - denominator * inverse (node_modules/@openzeppelin/contracts/utils/math/Math.sol#120)
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
	- denominator = denominator / twos (node_modules/@openzeppelin/contracts/utils/math/Math.sol#101)
	- inverse *= 2 - denominator * inverse (node_modules/@openzeppelin/contracts/utils/math/Math.sol#121)
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
	- denominator = denominator / twos (node_modules/@openzeppelin/contracts/utils/math/Math.sol#101)
	- inverse *= 2 - denominator * inverse (node_modules/@openzeppelin/contracts/utils/math/Math.sol#122)
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
	- denominator = denominator / twos (node_modules/@openzeppelin/contracts/utils/math/Math.sol#101)
	- inverse *= 2 - denominator * inverse (node_modules/@openzeppelin/contracts/utils/math/Math.sol#123)
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
	- denominator = denominator / twos (node_modules/@openzeppelin/contracts/utils/math/Math.sol#101)
	- inverse *= 2 - denominator * inverse (node_modules/@openzeppelin/contracts/utils/math/Math.sol#124)
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
	- denominator = denominator / twos (node_modules/@openzeppelin/contracts/utils/math/Math.sol#101)
	- inverse *= 2 - denominator * inverse (node_modules/@openzeppelin/contracts/utils/math/Math.sol#125)
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
	- prod0 = prod0 / twos (node_modules/@openzeppelin/contracts/utils/math/Math.sol#104)
	- result = prod0 * inverse (node_modules/@openzeppelin/contracts/utils/math/Math.sol#131)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#divide-before-multiply
INFO:Detectors:
Detector: incorrect-equality
EduStaking.withdraw(uint256) (contracts/EduStaking.sol#136-158) uses a dangerous strict equality:
	- info.amount == 0 (contracts/EduStaking.sol#151)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#dangerous-strict-equalities
INFO:Detectors:
Detector: reentrancy-no-eth
Reentrancy in EduCertificate.issueCertificate(address,uint256,string,uint8,string) (contracts/EduCertificate.sol#70-99):
	External calls:
	- _safeMint(student,tokenId) (contracts/EduCertificate.sol#84)
		- retval = IERC721Receiver(to).onERC721Received(_msgSender(),from,tokenId,data) (node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol#406-417)
	State variables written after the call(s):
	- hasCertificate[student][courseId] = true (contracts/EduCertificate.sol#95)
	EduCertificate.hasCertificate (contracts/EduCertificate.sol#45) can be used in cross function reentrancies:
	- EduCertificate.hasCertificate (contracts/EduCertificate.sol#45)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-2
INFO:Detectors:
Detector: unused-return
EduStaking.getEthUsdPrice() (contracts/EduStaking.sol#86-91) ignores return value by (None,answer,None,updatedAt,None) = priceFeed.latestRoundData() (contracts/EduStaking.sol#87)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#unused-return
INFO:Detectors:
Detector: reentrancy-benign
Reentrancy in EduStaking.fundRewardPool(uint256) (contracts/EduStaking.sol#210-214):
	External calls:
	- eduToken.safeTransferFrom(msg.sender,address(this),amount) (contracts/EduStaking.sol#211)
	State variables written after the call(s):
	- rewardPool += amount (contracts/EduStaking.sol#212)
Reentrancy in EduCertificate.issueCertificate(address,uint256,string,uint8,string) (contracts/EduCertificate.sol#70-99):
	External calls:
	- _safeMint(student,tokenId) (contracts/EduCertificate.sol#84)
		- retval = IERC721Receiver(to).onERC721Received(_msgSender(),from,tokenId,data) (node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol#406-417)
	State variables written after the call(s):
	- _setTokenURI(tokenId,tokenURI_) (contracts/EduCertificate.sol#85)
		- _tokenURIs[tokenId] = _tokenURI (node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol#57)
	- certificates[tokenId] = CertificateData({student:student,courseId:courseId,issuedAt:block.timestamp,courseName:courseName,grade:grade}) (contracts/EduCertificate.sol#87-93)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-3
INFO:Detectors:
Detector: reentrancy-events
Reentrancy in EduStaking.fundRewardPool(uint256) (contracts/EduStaking.sol#210-214):
	External calls:
	- eduToken.safeTransferFrom(msg.sender,address(this),amount) (contracts/EduStaking.sol#211)
	Event emitted after the call(s):
	- RewardPoolFunded(amount) (contracts/EduStaking.sol#213)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-4
INFO:Detectors:
Detector: timestamp
EduGovernance.castVote(uint256,bool) (contracts/EduGovernance.sol#145-165) uses timestamp for comparisons
	Dangerous comparisons:
	- require(bool,string)(block.timestamp >= p.startTime,Gov: voting not started) (contracts/EduGovernance.sol#147)
	- require(bool,string)(block.timestamp <= p.endTime,Gov: voting ended) (contracts/EduGovernance.sol#148)
	- require(bool,string)(! p.cancelled,Gov: proposal cancelled) (contracts/EduGovernance.sol#149)
EduGovernance.execute(uint256) (contracts/EduGovernance.sol#182-195) uses timestamp for comparisons
	Dangerous comparisons:
	- require(bool,string)(block.timestamp >= p.eta,Gov: timelock not expired) (contracts/EduGovernance.sol#185)
EduGovernance.cancel(uint256) (contracts/EduGovernance.sol#200-209) uses timestamp for comparisons
	Dangerous comparisons:
	- require(bool,string)(msg.sender == p.proposer || hasRole(ADMIN_ROLE,msg.sender),Gov: not authorized) (contracts/EduGovernance.sol#202-205)
	- require(bool,string)(! p.executed,Gov: already executed) (contracts/EduGovernance.sol#206)
EduGovernance.state(uint256) (contracts/EduGovernance.sol#213-233) uses timestamp for comparisons
	Dangerous comparisons:
	- block.timestamp < p.startTime (contracts/EduGovernance.sol#219)
	- block.timestamp <= p.endTime (contracts/EduGovernance.sol#220)
EduStaking.getEthUsdPrice() (contracts/EduStaking.sol#86-91) uses timestamp for comparisons
	Dangerous comparisons:
	- require(bool,string)(block.timestamp - updatedAt <= 3600,Staking: stale oracle) (contracts/EduStaking.sol#89)
EduStaking.withdraw(uint256) (contracts/EduStaking.sol#136-158) uses timestamp for comparisons
	Dangerous comparisons:
	- require(bool,string)(info.amount >= amount,Staking: insufficient staked amount) (contracts/EduStaking.sol#138)
	- require(bool,string)(block.timestamp >= info.stakedAt + LOCK_PERIOD,Staking: tokens still locked) (contracts/EduStaking.sol#139-142)
	- info.amount == 0 (contracts/EduStaking.sol#151)
EduStaking.claimRewards() (contracts/EduStaking.sol#163-179) uses timestamp for comparisons
	Dangerous comparisons:
	- require(bool,string)(info.amount > 0,Staking: no active stake) (contracts/EduStaking.sol#165)
	- require(bool,string)(total > 0,Staking: no rewards to claim) (contracts/EduStaking.sol#169)
	- require(bool,string)(rewardPool >= total,Staking: reward pool insufficient) (contracts/EduStaking.sol#170)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#block-timestamp
INFO:Detectors:
Detector: assembly
ERC721._checkOnERC721Received(address,address,uint256,bytes) (node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol#399-421) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol#413-415)
Address._revert(bytes,string) (node_modules/@openzeppelin/contracts/utils/Address.sol#231-243) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/Address.sol#236-239)
Strings.toString(uint256) (node_modules/@openzeppelin/contracts/utils/Strings.sol#19-39) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/Strings.sol#25-27)
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/Strings.sol#31-33)
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#55-134) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/math/Math.sol#62-66)
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/math/Math.sol#85-92)
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/math/Math.sol#99-108)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#assembly-usage
INFO:Detectors:
Detector: pragma
3 different versions of Solidity are used:
	- Version constraint ^0.8.0 is used by:
		-^0.8.0 (node_modules/@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol#2)
		-^0.8.0 (node_modules/@openzeppelin/contracts/access/AccessControl.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/access/IAccessControl.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/interfaces/IERC165.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/interfaces/IERC4906.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/interfaces/IERC721.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/security/Pausable.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC1155/IERC1155.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/utils/Context.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/utils/Counters.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/utils/Strings.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/utils/introspection/ERC165.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/utils/introspection/IERC165.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/utils/math/Math.sol#4)
		-^0.8.0 (node_modules/@openzeppelin/contracts/utils/math/SignedMath.sol#4)
	- Version constraint ^0.8.1 is used by:
		-^0.8.1 (node_modules/@openzeppelin/contracts/utils/Address.sol#4)
	- Version constraint ^0.8.17 is used by:
		-^0.8.17 (contracts/EduCertificate.sol#2)
		-^0.8.17 (contracts/EduCourse.sol#2)
		-^0.8.17 (contracts/EduGovernance.sol#2)
		-^0.8.17 (contracts/EduPlatform.sol#2)
		-^0.8.17 (contracts/EduStaking.sol#2)
		-^0.8.17 (contracts/EduToken.sol#2)
		-^0.8.17 (contracts/mocks/MockV3Aggregator.sol#2)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#different-pragma-directives-are-used
INFO:Detectors:
Detector: dead-code
EduCertificate._burn(uint256) (contracts/EduCertificate.sol#137-142) is never used and should be removed
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#dead-code
INFO:Detectors:
Detector: solc-version
Version constraint ^0.8.0 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess
	- AbiReencodingHeadOverflowWithStaticArrayCleanup
	- DirtyBytesArrayToStorage
	- DataLocationChangeInInternalOverride
	- NestedCalldataArrayAbiReencodingSizeValidation
	- SignedImmutables
	- ABIDecodeTwoDimensionalArrayMemory
	- KeccakCaching.
It is used by:
	- ^0.8.0 (node_modules/@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol#2)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/access/AccessControl.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/access/IAccessControl.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/interfaces/IERC165.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/interfaces/IERC4906.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/interfaces/IERC721.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/security/Pausable.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC1155/IERC1155.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/utils/Context.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/utils/Counters.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/utils/Strings.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/utils/introspection/ERC165.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/utils/introspection/IERC165.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/utils/math/Math.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts/utils/math/SignedMath.sol#4)
Version constraint ^0.8.1 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess
	- AbiReencodingHeadOverflowWithStaticArrayCleanup
	- DirtyBytesArrayToStorage
	- DataLocationChangeInInternalOverride
	- NestedCalldataArrayAbiReencodingSizeValidation
	- SignedImmutables
	- ABIDecodeTwoDimensionalArrayMemory
	- KeccakCaching.
It is used by:
	- ^0.8.1 (node_modules/@openzeppelin/contracts/utils/Address.sol#4)
Version constraint ^0.8.17 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- VerbatimInvalidDeduplication
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess.
It is used by:
	- ^0.8.17 (contracts/EduCertificate.sol#2)
	- ^0.8.17 (contracts/EduCourse.sol#2)
	- ^0.8.17 (contracts/EduGovernance.sol#2)
	- ^0.8.17 (contracts/EduPlatform.sol#2)
	- ^0.8.17 (contracts/EduStaking.sol#2)
	- ^0.8.17 (contracts/EduToken.sol#2)
	- ^0.8.17 (contracts/mocks/MockV3Aggregator.sol#2)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity
INFO:Detectors:
Detector: low-level-calls
Low level call in SafeERC20._callOptionalReturnBool(IERC20,bytes) (node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#134-142):
	- (success,returndata) = address(token).call(data) (node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#139)
Low level call in Address.sendValue(address,uint256) (node_modules/@openzeppelin/contracts/utils/Address.sol#64-69):
	- (success,None) = recipient.call{value: amount}() (node_modules/@openzeppelin/contracts/utils/Address.sol#67)
Low level call in Address.functionCallWithValue(address,bytes,uint256,string) (node_modules/@openzeppelin/contracts/utils/Address.sol#128-137):
	- (success,returndata) = target.call{value: value}(data) (node_modules/@openzeppelin/contracts/utils/Address.sol#135)
Low level call in Address.functionStaticCall(address,bytes,string) (node_modules/@openzeppelin/contracts/utils/Address.sol#155-162):
	- (success,returndata) = target.staticcall(data) (node_modules/@openzeppelin/contracts/utils/Address.sol#160)
Low level call in Address.functionDelegateCall(address,bytes,string) (node_modules/@openzeppelin/contracts/utils/Address.sol#180-187):
	- (success,returndata) = target.delegatecall(data) (node_modules/@openzeppelin/contracts/utils/Address.sol#185)
Low level call in EduGovernance.execute(uint256) (contracts/EduGovernance.sol#182-195):
	- (success,None) = p.target.call(p.callData) (contracts/EduGovernance.sol#190)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#low-level-calls
INFO:Detectors:
Detector: naming-convention
Function IERC20Permit.DOMAIN_SEPARATOR() (node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol#89) is not in mixedCase
Function ERC721.__unsafe_increaseBalance(address,uint256) (node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol#463-465) is not in mixedCase
Parameter EduCertificate.setSoulbound(bool)._soulbound (contracts/EduCertificate.sol#119) is not in mixedCase
Parameter MockV3Aggregator.updateAnswer(int256)._answer (contracts/mocks/MockV3Aggregator.sol#22) is not in mixedCase
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
INFO:Detectors:
Detector: unindexed-event-address
Event Pausable.Paused(address) (node_modules/@openzeppelin/contracts/security/Pausable.sol#21) has address parameters but no indexed parameters
Event Pausable.Unpaused(address) (node_modules/@openzeppelin/contracts/security/Pausable.sol#26) has address parameters but no indexed parameters
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#unindexed-event-address-parameters
INFO:Detectors:
Detector: immutable-states
MockV3Aggregator.decimals (contracts/mocks/MockV3Aggregator.sol#10) should be immutable 
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#state-variables-that-could-be-declared-immutable
**THIS CHECKLIST IS NOT COMPLETE**. Use `--show-ignored-findings` to show all the results.
Summary
 - [incorrect-exp](#incorrect-exp) (1 results) (High)
 - [divide-before-multiply](#divide-before-multiply) (8 results) (Medium)
 - [incorrect-equality](#incorrect-equality) (1 results) (Medium)
 - [reentrancy-no-eth](#reentrancy-no-eth) (1 results) (Medium)
 - [unused-return](#unused-return) (1 results) (Medium)
 - [reentrancy-benign](#reentrancy-benign) (2 results) (Low)
 - [reentrancy-events](#reentrancy-events) (1 results) (Low)
 - [timestamp](#timestamp) (7 results) (Low)
 - [assembly](#assembly) (4 results) (Informational)
 - [pragma](#pragma) (1 results) (Informational)
 - [dead-code](#dead-code) (1 results) (Informational)
 - [solc-version](#solc-version) (3 results) (Informational)
 - [low-level-calls](#low-level-calls) (6 results) (Informational)
 - [naming-convention](#naming-convention) (4 results) (Informational)
 - [unindexed-event-address](#unindexed-event-address) (2 results) (Informational)
 - [immutable-states](#immutable-states) (1 results) (Optimization)
## incorrect-exp
Impact: High
Confidence: Medium
 - [ ] ID-0
[Math.mulDiv(uint256,uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L55-L134) has bitwise-xor operator ^ instead of the exponentiation operator **: 
	 - [inverse = (3 * denominator) ^ 2](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L116)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L55-L134


## divide-before-multiply
Impact: Medium
Confidence: Medium
 - [ ] ID-1
[Math.mulDiv(uint256,uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L55-L134) performs a multiplication on the result of a division:
	- [denominator = denominator / twos](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L101)
	- [inverse *= 2 - denominator * inverse](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L120)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L55-L134


 - [ ] ID-2
[Math.mulDiv(uint256,uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L55-L134) performs a multiplication on the result of a division:
	- [prod0 = prod0 / twos](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L104)
	- [result = prod0 * inverse](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L131)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L55-L134


 - [ ] ID-3
[Math.mulDiv(uint256,uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L55-L134) performs a multiplication on the result of a division:
	- [denominator = denominator / twos](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L101)
	- [inverse *= 2 - denominator * inverse](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L122)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L55-L134


 - [ ] ID-4
[Math.mulDiv(uint256,uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L55-L134) performs a multiplication on the result of a division:
	- [denominator = denominator / twos](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L101)
	- [inverse *= 2 - denominator * inverse](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L125)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L55-L134


 - [ ] ID-5
[Math.mulDiv(uint256,uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L55-L134) performs a multiplication on the result of a division:
	- [denominator = denominator / twos](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L101)
	- [inverse *= 2 - denominator * inverse](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L124)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L55-L134


 - [ ] ID-6
[Math.mulDiv(uint256,uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L55-L134) performs a multiplication on the result of a division:
	- [denominator = denominator / twos](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L101)
	- [inverse *= 2 - denominator * inverse](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L123)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L55-L134


 - [ ] ID-7
[Math.mulDiv(uint256,uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L55-L134) performs a multiplication on the result of a division:
	- [denominator = denominator / twos](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L101)
	- [inverse *= 2 - denominator * inverse](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L121)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L55-L134


 - [ ] ID-8
[Math.mulDiv(uint256,uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L55-L134) performs a multiplication on the result of a division:
	- [denominator = denominator / twos](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L101)
	- [inverse = (3 * denominator) ^ 2](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L116)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L55-L134


## incorrect-equality
Impact: Medium
Confidence: High
 - [ ] ID-9
[EduStaking.withdraw(uint256)](contracts/EduStaking.sol#L136-L158) uses a dangerous strict equality:
	- [info.amount == 0](contracts/EduStaking.sol#L151)

contracts/EduStaking.sol#L136-L158


## reentrancy-no-eth
Impact: Medium
Confidence: Medium
 - [ ] ID-10
Reentrancy in [EduCertificate.issueCertificate(address,uint256,string,uint8,string)](contracts/EduCertificate.sol#L70-L99):
	External calls:
	- [_safeMint(student,tokenId)](contracts/EduCertificate.sol#L84)
		- [retval = IERC721Receiver(to).onERC721Received(_msgSender(),from,tokenId,data)](node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol#L406-L417)
	State variables written after the call(s):
	- [hasCertificate[student][courseId] = true](contracts/EduCertificate.sol#L95)
	[EduCertificate.hasCertificate](contracts/EduCertificate.sol#L45) can be used in cross function reentrancies:
	- [EduCertificate.hasCertificate](contracts/EduCertificate.sol#L45)

contracts/EduCertificate.sol#L70-L99


## unused-return
Impact: Medium
Confidence: Medium
 - [ ] ID-11
[EduStaking.getEthUsdPrice()](contracts/EduStaking.sol#L86-L91) ignores return value by [(None,answer,None,updatedAt,None) = priceFeed.latestRoundData()](contracts/EduStaking.sol#L87)

contracts/EduStaking.sol#L86-L91


## reentrancy-benign
Impact: Low
Confidence: Medium
 - [ ] ID-12
Reentrancy in [EduStaking.fundRewardPool(uint256)](contracts/EduStaking.sol#L210-L214):
	External calls:
	- [eduToken.safeTransferFrom(msg.sender,address(this),amount)](contracts/EduStaking.sol#L211)
	State variables written after the call(s):
	- [rewardPool += amount](contracts/EduStaking.sol#L212)

contracts/EduStaking.sol#L210-L214


 - [ ] ID-13
Reentrancy in [EduCertificate.issueCertificate(address,uint256,string,uint8,string)](contracts/EduCertificate.sol#L70-L99):
	External calls:
	- [_safeMint(student,tokenId)](contracts/EduCertificate.sol#L84)
		- [retval = IERC721Receiver(to).onERC721Received(_msgSender(),from,tokenId,data)](node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol#L406-L417)
	State variables written after the call(s):
	- [_setTokenURI(tokenId,tokenURI_)](contracts/EduCertificate.sol#L85)
		- [_tokenURIs[tokenId] = _tokenURI](node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol#L57)
	- [certificates[tokenId] = CertificateData({student:student,courseId:courseId,issuedAt:block.timestamp,courseName:courseName,grade:grade})](contracts/EduCertificate.sol#L87-L93)

contracts/EduCertificate.sol#L70-L99


## reentrancy-events
Impact: Low
Confidence: Medium
 - [ ] ID-14
Reentrancy in [EduStaking.fundRewardPool(uint256)](contracts/EduStaking.sol#L210-L214):
	External calls:
	- [eduToken.safeTransferFrom(msg.sender,address(this),amount)](contracts/EduStaking.sol#L211)
	Event emitted after the call(s):
	- [RewardPoolFunded(amount)](contracts/EduStaking.sol#L213)

contracts/EduStaking.sol#L210-L214


## timestamp
Impact: Low
Confidence: Medium
 - [ ] ID-15
[EduGovernance.state(uint256)](contracts/EduGovernance.sol#L213-L233) uses timestamp for comparisons
	Dangerous comparisons:
	- [block.timestamp < p.startTime](contracts/EduGovernance.sol#L219)
	- [block.timestamp <= p.endTime](contracts/EduGovernance.sol#L220)

contracts/EduGovernance.sol#L213-L233


 - [ ] ID-16
[EduStaking.claimRewards()](contracts/EduStaking.sol#L163-L179) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(info.amount > 0,Staking: no active stake)](contracts/EduStaking.sol#L165)
	- [require(bool,string)(total > 0,Staking: no rewards to claim)](contracts/EduStaking.sol#L169)
	- [require(bool,string)(rewardPool >= total,Staking: reward pool insufficient)](contracts/EduStaking.sol#L170)

contracts/EduStaking.sol#L163-L179


 - [ ] ID-17
[EduStaking.getEthUsdPrice()](contracts/EduStaking.sol#L86-L91) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(block.timestamp - updatedAt <= 3600,Staking: stale oracle)](contracts/EduStaking.sol#L89)

contracts/EduStaking.sol#L86-L91


 - [ ] ID-18
[EduGovernance.cancel(uint256)](contracts/EduGovernance.sol#L200-L209) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(msg.sender == p.proposer || hasRole(ADMIN_ROLE,msg.sender),Gov: not authorized)](contracts/EduGovernance.sol#L202-L205)
	- [require(bool,string)(! p.executed,Gov: already executed)](contracts/EduGovernance.sol#L206)

contracts/EduGovernance.sol#L200-L209


 - [ ] ID-19
[EduStaking.withdraw(uint256)](contracts/EduStaking.sol#L136-L158) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(info.amount >= amount,Staking: insufficient staked amount)](contracts/EduStaking.sol#L138)
	- [require(bool,string)(block.timestamp >= info.stakedAt + LOCK_PERIOD,Staking: tokens still locked)](contracts/EduStaking.sol#L139-L142)
	- [info.amount == 0](contracts/EduStaking.sol#L151)

contracts/EduStaking.sol#L136-L158


 - [ ] ID-20
[EduGovernance.castVote(uint256,bool)](contracts/EduGovernance.sol#L145-L165) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(block.timestamp >= p.startTime,Gov: voting not started)](contracts/EduGovernance.sol#L147)
	- [require(bool,string)(block.timestamp <= p.endTime,Gov: voting ended)](contracts/EduGovernance.sol#L148)
	- [require(bool,string)(! p.cancelled,Gov: proposal cancelled)](contracts/EduGovernance.sol#L149)

contracts/EduGovernance.sol#L145-L165


 - [ ] ID-21
[EduGovernance.execute(uint256)](contracts/EduGovernance.sol#L182-L195) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(block.timestamp >= p.eta,Gov: timelock not expired)](contracts/EduGovernance.sol#L185)

contracts/EduGovernance.sol#L182-L195


## assembly
Impact: Informational
Confidence: High
 - [ ] ID-22
[ERC721._checkOnERC721Received(address,address,uint256,bytes)](node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol#L399-L421) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol#L413-L415)

node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol#L399-L421


 - [ ] ID-23
[Math.mulDiv(uint256,uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L55-L134) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L62-L66)
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L85-L92)
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L99-L108)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L55-L134


 - [ ] ID-24
[Strings.toString(uint256)](node_modules/@openzeppelin/contracts/utils/Strings.sol#L19-L39) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/Strings.sol#L25-L27)
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/Strings.sol#L31-L33)

node_modules/@openzeppelin/contracts/utils/Strings.sol#L19-L39


 - [ ] ID-25
[Address._revert(bytes,string)](node_modules/@openzeppelin/contracts/utils/Address.sol#L231-L243) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/Address.sol#L236-L239)

node_modules/@openzeppelin/contracts/utils/Address.sol#L231-L243


## pragma
Impact: Informational
Confidence: High
 - [ ] ID-26
3 different versions of Solidity are used:
	- Version constraint ^0.8.0 is used by:
		-[^0.8.0](node_modules/@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol#L2)
		-[^0.8.0](node_modules/@openzeppelin/contracts/access/AccessControl.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/access/IAccessControl.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/interfaces/IERC165.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/interfaces/IERC4906.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/interfaces/IERC721.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/security/Pausable.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/token/ERC1155/IERC1155.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/utils/Context.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/utils/Counters.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/utils/Strings.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/utils/introspection/ERC165.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/utils/introspection/IERC165.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L4)
		-[^0.8.0](node_modules/@openzeppelin/contracts/utils/math/SignedMath.sol#L4)
	- Version constraint ^0.8.1 is used by:
		-[^0.8.1](node_modules/@openzeppelin/contracts/utils/Address.sol#L4)
	- Version constraint ^0.8.17 is used by:
		-[^0.8.17](contracts/EduCertificate.sol#L2)
		-[^0.8.17](contracts/EduCourse.sol#L2)
		-[^0.8.17](contracts/EduGovernance.sol#L2)
		-[^0.8.17](contracts/EduPlatform.sol#L2)
		-[^0.8.17](contracts/EduStaking.sol#L2)
		-[^0.8.17](contracts/EduToken.sol#L2)
		-[^0.8.17](contracts/mocks/MockV3Aggregator.sol#L2)

node_modules/@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol#L2


## dead-code
Impact: Informational
Confidence: Medium
 - [ ] ID-27
[EduCertificate._burn(uint256)](contracts/EduCertificate.sol#L137-L142) is never used and should be removed

contracts/EduCertificate.sol#L137-L142


## solc-version
Impact: Informational
Confidence: High
 - [ ] ID-28
Version constraint ^0.8.17 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- VerbatimInvalidDeduplication
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess.
It is used by:
	- [^0.8.17](contracts/EduCertificate.sol#L2)
	- [^0.8.17](contracts/EduCourse.sol#L2)
	- [^0.8.17](contracts/EduGovernance.sol#L2)
	- [^0.8.17](contracts/EduPlatform.sol#L2)
	- [^0.8.17](contracts/EduStaking.sol#L2)
	- [^0.8.17](contracts/EduToken.sol#L2)
	- [^0.8.17](contracts/mocks/MockV3Aggregator.sol#L2)

contracts/EduCertificate.sol#L2


 - [ ] ID-29
Version constraint ^0.8.0 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess
	- AbiReencodingHeadOverflowWithStaticArrayCleanup
	- DirtyBytesArrayToStorage
	- DataLocationChangeInInternalOverride
	- NestedCalldataArrayAbiReencodingSizeValidation
	- SignedImmutables
	- ABIDecodeTwoDimensionalArrayMemory
	- KeccakCaching.
It is used by:
	- [^0.8.0](node_modules/@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol#L2)
	- [^0.8.0](node_modules/@openzeppelin/contracts/access/AccessControl.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/access/IAccessControl.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/interfaces/IERC165.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/interfaces/IERC4906.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/interfaces/IERC721.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/security/Pausable.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/token/ERC1155/IERC1155.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/utils/Context.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/utils/Counters.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/utils/Strings.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/utils/introspection/ERC165.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/utils/introspection/IERC165.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L4)
	- [^0.8.0](node_modules/@openzeppelin/contracts/utils/math/SignedMath.sol#L4)

node_modules/@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol#L2


 - [ ] ID-30
Version constraint ^0.8.1 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess
	- AbiReencodingHeadOverflowWithStaticArrayCleanup
	- DirtyBytesArrayToStorage
	- DataLocationChangeInInternalOverride
	- NestedCalldataArrayAbiReencodingSizeValidation
	- SignedImmutables
	- ABIDecodeTwoDimensionalArrayMemory
	- KeccakCaching.
It is used by:
	- [^0.8.1](node_modules/@openzeppelin/contracts/utils/Address.sol#L4)
INFO:Slither:. analyzed (39 contracts with 101 detectors), 44 result(s) found

node_modules/@openzeppelin/contracts/utils/Address.sol#L4


## low-level-calls
Impact: Informational
Confidence: High
 - [ ] ID-31
Low level call in [Address.functionCallWithValue(address,bytes,uint256,string)](node_modules/@openzeppelin/contracts/utils/Address.sol#L128-L137):
	- [(success,returndata) = target.call{value: value}(data)](node_modules/@openzeppelin/contracts/utils/Address.sol#L135)

node_modules/@openzeppelin/contracts/utils/Address.sol#L128-L137


 - [ ] ID-32
Low level call in [SafeERC20._callOptionalReturnBool(IERC20,bytes)](node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#L134-L142):
	- [(success,returndata) = address(token).call(data)](node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#L139)

node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#L134-L142


 - [ ] ID-33
Low level call in [EduGovernance.execute(uint256)](contracts/EduGovernance.sol#L182-L195):
	- [(success,None) = p.target.call(p.callData)](contracts/EduGovernance.sol#L190)

contracts/EduGovernance.sol#L182-L195


 - [ ] ID-34
Low level call in [Address.sendValue(address,uint256)](node_modules/@openzeppelin/contracts/utils/Address.sol#L64-L69):
	- [(success,None) = recipient.call{value: amount}()](node_modules/@openzeppelin/contracts/utils/Address.sol#L67)

node_modules/@openzeppelin/contracts/utils/Address.sol#L64-L69


 - [ ] ID-35
Low level call in [Address.functionStaticCall(address,bytes,string)](node_modules/@openzeppelin/contracts/utils/Address.sol#L155-L162):
	- [(success,returndata) = target.staticcall(data)](node_modules/@openzeppelin/contracts/utils/Address.sol#L160)

node_modules/@openzeppelin/contracts/utils/Address.sol#L155-L162


 - [ ] ID-36
Low level call in [Address.functionDelegateCall(address,bytes,string)](node_modules/@openzeppelin/contracts/utils/Address.sol#L180-L187):
	- [(success,returndata) = target.delegatecall(data)](node_modules/@openzeppelin/contracts/utils/Address.sol#L185)

node_modules/@openzeppelin/contracts/utils/Address.sol#L180-L187


## naming-convention
Impact: Informational
Confidence: High
 - [ ] ID-37
Parameter [MockV3Aggregator.updateAnswer(int256)._answer](contracts/mocks/MockV3Aggregator.sol#L22) is not in mixedCase

contracts/mocks/MockV3Aggregator.sol#L22


 - [ ] ID-38
Function [IERC20Permit.DOMAIN_SEPARATOR()](node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol#L89) is not in mixedCase

node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol#L89


 - [ ] ID-39
Function [ERC721.__unsafe_increaseBalance(address,uint256)](node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol#L463-L465) is not in mixedCase

node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol#L463-L465


 - [ ] ID-40
Parameter [EduCertificate.setSoulbound(bool)._soulbound](contracts/EduCertificate.sol#L119) is not in mixedCase

contracts/EduCertificate.sol#L119


## unindexed-event-address
Impact: Informational
Confidence: High
 - [ ] ID-41
Event [Pausable.Unpaused(address)](node_modules/@openzeppelin/contracts/security/Pausable.sol#L26) has address parameters but no indexed parameters

node_modules/@openzeppelin/contracts/security/Pausable.sol#L26


 - [ ] ID-42
Event [Pausable.Paused(address)](node_modules/@openzeppelin/contracts/security/Pausable.sol#L21) has address parameters but no indexed parameters

node_modules/@openzeppelin/contracts/security/Pausable.sol#L21


## immutable-states
Impact: Optimization
Confidence: High
 - [ ] ID-43
[MockV3Aggregator.decimals](contracts/mocks/MockV3Aggregator.sol#L10) should be immutable 

contracts/mocks/MockV3Aggregator.sol#L10


