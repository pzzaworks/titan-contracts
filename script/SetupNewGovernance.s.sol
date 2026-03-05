// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/StakedTitan.sol";
import "../src/Governor.sol";
import "../src/TitanToken.sol";

/**
 * @title SetupNewGovernance
 * @notice Stakes TITAN to get sTITAN and creates test proposals
 */
contract SetupNewGovernance is Script {
    address constant TITAN_TOKEN = 0xbA6720e72f929318E66AcED4389889640Aee0F6e;
    address constant NEW_STITAN = 0xa7CA1376bc77535537BF43bf12315AA75c68DA29;
    address constant NEW_GOVERNOR = 0x7F032E7F62D06161C9ebC83898e23171bC3bedB9;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        TitanToken titan = TitanToken(TITAN_TOKEN);
        StakedTitan sTitan = StakedTitan(NEW_STITAN);
        Governor governor = Governor(payable(NEW_GOVERNOR));

        console.log("Setting up new governance...");
        console.log("Deployer:", deployer);
        console.log("TITAN balance:", titan.balanceOf(deployer) / 1e18);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Approve TITAN for staking
        uint256 stakeAmount = 10_000_000 * 1e18; // 10M TITAN
        titan.approve(address(sTitan), stakeAmount);
        console.log("Approved TITAN for staking");

        // 2. Stake TITAN to get sTITAN (auto-delegates voting power)
        uint256 sTitanReceived = sTitan.deposit(stakeAmount);
        console.log("Staked TITAN, received sTITAN:", sTitanReceived / 1e18);

        // Check voting power
        uint256 votes = sTitan.getVotes(deployer);
        console.log("Voting power:", votes / 1e18);

        // 3. Create test proposals
        address[] memory targets = new address[](1);
        targets[0] = address(governor);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = "";

        // Proposal 1
        string memory desc1 = "TIP-1: Increase Staking Rewards to 15% APY\n\nProposal to increase the base staking APY from 10% to 15% to attract more stakers and strengthen protocol security through increased TVL.";
        governor.propose(targets, values, calldatas, desc1);
        console.log("Created Proposal 1");

        // Proposal 2
        string memory desc2 = "TIP-2: Launch Cross-Chain Bridge to Arbitrum\n\nDeploy TITAN bridge to Arbitrum One for lower gas fees and faster transactions. This will expand the ecosystem and improve accessibility.";
        governor.propose(targets, values, calldatas, desc2);
        console.log("Created Proposal 2");

        // Proposal 3
        string memory desc3 = "TIP-3: Establish Community Grants Program\n\nAllocate 1M TITAN tokens for community grants to fund development of tools, integrations, and educational content for the Titan ecosystem.";
        governor.propose(targets, values, calldatas, desc3);
        console.log("Created Proposal 3");

        vm.stopBroadcast();

        console.log("\n========== SETUP COMPLETE ==========");
        console.log("sTITAN balance:", sTitan.balanceOf(deployer) / 1e18);
        console.log("Voting power:", sTitan.getVotes(deployer) / 1e18);
        console.log("Total proposals:", governor.proposalCount());
        console.log("=====================================\n");
    }
}
