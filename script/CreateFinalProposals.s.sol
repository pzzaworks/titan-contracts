// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Governor.sol";
import "../src/TitanToken.sol";

contract CreateFinalProposals is Script {
    address constant GOVERNANCE = 0x482BFe34fC0535a2E3355EF8b4e2405bCD879f19;
    address constant TITAN_TOKEN = 0xbA6720e72f929318E66AcED4389889640Aee0F6e;
    address constant SECOND_VOTER = 0xD1E1D89bdd552a0CD5560aB194eAD2Cf8246731E;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        Governor governor = Governor(payable(GOVERNANCE));
        TitanToken titan = TitanToken(TITAN_TOKEN);

        console.log("Creating final proposals...");
        console.log("Main voter power:", titan.getVotes(deployer) / 1e18);
        console.log("Second voter power:", titan.getVotes(SECOND_VOTER) / 1e18);

        vm.startBroadcast(deployerPrivateKey);

        // Empty arrays for proposals
        address[] memory targets = new address[](1);
        targets[0] = address(governor);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = "";

        // Proposal 12: Increase Staking APY
        string memory desc12 = "TIP-12: Increase Base Staking APY to 15%\n\nIncrease the base staking APY from 12% to 15% to incentivize more users to stake their TITAN tokens. Higher rewards will reduce circulating supply and strengthen the protocol.";
        governor.propose(targets, values, calldatas, desc12);
        console.log("Created Proposal 12");

        // Proposal 13: Partnership with Major DEX
        string memory desc13 = "TIP-13: Strategic Partnership with Uniswap\n\nAllocate 2M TITAN tokens for a strategic partnership with Uniswap to increase liquidity and visibility. This includes incentivized liquidity pools and co-marketing efforts.";
        governor.propose(targets, values, calldatas, desc13);
        console.log("Created Proposal 13");

        // Proposal 14: Mobile App Development
        string memory desc14 = "TIP-14: Fund Mobile App Development\n\nAllocate 500,000 TITAN from treasury to fund development of native iOS and Android apps. Mobile access will significantly expand the user base and improve accessibility.";
        governor.propose(targets, values, calldatas, desc14);
        console.log("Created Proposal 14");

        vm.stopBroadcast();

        console.log("\n========== PROPOSALS CREATED ==========");
        console.log("Total proposals:", governor.proposalCount());
    }
}
