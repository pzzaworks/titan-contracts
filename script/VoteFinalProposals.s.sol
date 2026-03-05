// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Governor.sol";
import "../src/TitanToken.sol";

contract VoteFinalProposals is Script {
    address constant GOVERNANCE = 0x482BFe34fC0535a2E3355EF8b4e2405bCD879f19;
    address constant TITAN_TOKEN = 0xbA6720e72f929318E66AcED4389889640Aee0F6e;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        uint256 secondVoterKey = vm.envUint("SECOND_VOTER_PRIVATE_KEY");

        address deployer = vm.addr(deployerPrivateKey);
        address secondVoter = vm.addr(secondVoterKey);

        Governor governor = Governor(payable(GOVERNANCE));
        TitanToken titan = TitanToken(TITAN_TOKEN);

        console.log("Voting on proposals 12-14...");
        console.log("Main voter:", deployer, "power:", titan.getVotes(deployer) / 1e18);
        console.log("Second voter:", secondVoter, "power:", titan.getVotes(secondVoter) / 1e18);

        // Vote from main wallet (34M TITAN)
        vm.startBroadcast(deployerPrivateKey);

        // Proposal 12: Main votes FOR (increase staking APY)
        governor.castVote(12, 1);
        console.log("Main voted FOR on Proposal 12");

        // Proposal 13: Main votes FOR (Uniswap partnership)
        governor.castVote(13, 1);
        console.log("Main voted FOR on Proposal 13");

        // Proposal 14: Main votes AGAINST (mobile app)
        governor.castVote(14, 0);
        console.log("Main voted AGAINST on Proposal 14");

        vm.stopBroadcast();

        // Vote from second wallet (15M TITAN)
        vm.startBroadcast(secondVoterKey);

        // Proposal 12: Second votes AGAINST
        governor.castVote(12, 0);
        console.log("Second voted AGAINST on Proposal 12");

        // Proposal 13: Second votes AGAINST
        governor.castVote(13, 0);
        console.log("Second voted AGAINST on Proposal 13");

        // Proposal 14: Second votes FOR
        governor.castVote(14, 1);
        console.log("Second voted FOR on Proposal 14");

        vm.stopBroadcast();

        console.log("\n========== VOTING COMPLETE ==========");
        console.log("Proposal 12: ~34M FOR, ~15M AGAINST");
        console.log("Proposal 13: ~34M FOR, ~15M AGAINST");
        console.log("Proposal 14: ~15M FOR, ~34M AGAINST");
    }
}
