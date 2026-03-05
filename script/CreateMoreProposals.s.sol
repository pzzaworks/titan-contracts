// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Governor.sol";
import "../src/TitanToken.sol";

contract CreateMoreProposals is Script {
    // Deployed addresses
    address constant GOVERNANCE = 0x482BFe34fC0535a2E3355EF8b4e2405bCD879f19;
    address constant TITAN_TOKEN = 0xbA6720e72f929318E66AcED4389889640Aee0F6e;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Creating more proposals on Governance...");
        console.log("Deployer:", deployer);

        Governor governor = Governor(payable(GOVERNANCE));
        TitanToken titan = TitanToken(TITAN_TOKEN);

        // Check voting power
        uint256 votes = titan.getVotes(deployer);
        console.log("Current voting power:", votes / 1e18, "TITAN");

        vm.startBroadcast(deployerPrivateKey);

        // Empty arrays for proposals (no on-chain actions, just governance signals)
        address[] memory targets = new address[](1);
        targets[0] = address(governor);

        uint256[] memory values = new uint256[](1);
        values[0] = 0;

        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = "";

        // Proposal 5: Implement veToken Model
        string memory desc5 = "TIP-5: Implement Vote-Escrowed TITAN (veTITAN)\n\nIntroduce a vote-escrowed token model where users can lock TITAN for up to 4 years to receive veTITAN. veTITAN holders will receive boosted staking rewards and increased governance power proportional to their lock duration.";
        uint256 prop5 = governor.propose(targets, values, calldatas, desc5);
        console.log("Created Proposal 5:", prop5);

        // Proposal 6: Treasury Diversification
        string memory desc6 = "TIP-6: Treasury Diversification Strategy\n\nAllocate 20% of the protocol treasury to stable assets (USDC, DAI) to ensure operational runway during market downturns. The remaining 80% will continue to be held in TITAN and ETH.";
        uint256 prop6 = governor.propose(targets, values, calldatas, desc6);
        console.log("Created Proposal 6:", prop6);

        // Proposal 7: Reduce Staking Cooldown
        string memory desc7 = "TIP-7: Reduce Unstaking Cooldown Period\n\nReduce the unstaking cooldown period from 7 days to 3 days. This change aims to improve capital efficiency for stakers while maintaining sufficient security for the protocol.";
        uint256 prop7 = governor.propose(targets, values, calldatas, desc7);
        console.log("Created Proposal 7:", prop7);

        // Proposal 8: Launch Referral Program
        string memory desc8 = "TIP-8: Launch Community Referral Program\n\nIntroduce a referral program where users earn 5% of their referees' staking rewards for the first 6 months. This will incentivize organic growth and community building.";
        uint256 prop8 = governor.propose(targets, values, calldatas, desc8);
        console.log("Created Proposal 8:", prop8);

        vm.stopBroadcast();

        console.log("\n========== PROPOSALS CREATED ==========");
        console.log("Total proposals:", governor.proposalCount());
        console.log("=========================================\n");
    }
}
