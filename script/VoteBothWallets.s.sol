// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Governor.sol";
import "../src/TitanToken.sol";

contract VoteBothWallets is Script {
    address constant GOVERNANCE = 0x482BFe34fC0535a2E3355EF8b4e2405bCD879f19;
    address constant TITAN_TOKEN = 0xbA6720e72f929318E66AcED4389889640Aee0F6e;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        uint256 secondVoterKey = vm.envUint("SECOND_VOTER_PRIVATE_KEY");

        address deployer = vm.addr(deployerPrivateKey);
        address secondVoter = vm.addr(secondVoterKey);

        Governor governor = Governor(payable(GOVERNANCE));
        TitanToken titan = TitanToken(TITAN_TOKEN);

        console.log("Voting from both wallets...");
        console.log("Main voter:", deployer, "power:", titan.getVotes(deployer) / 1e18);
        console.log("Second voter:", secondVoter, "power:", titan.getVotes(secondVoter) / 1e18);

        // Vote from main wallet first
        vm.startBroadcast(deployerPrivateKey);

        // Proposal 9: Main votes FOR
        governor.castVote(9, 1);
        console.log("Main voted FOR on Proposal 9");

        // Proposal 10: Main votes FOR
        governor.castVote(10, 1);
        console.log("Main voted FOR on Proposal 10");

        // Proposal 11: Main votes AGAINST
        governor.castVote(11, 0);
        console.log("Main voted AGAINST on Proposal 11");

        vm.stopBroadcast();

        // Vote from second wallet
        vm.startBroadcast(secondVoterKey);

        // Proposal 9: Second votes AGAINST
        governor.castVote(9, 0);
        console.log("Second voted AGAINST on Proposal 9");

        // Proposal 10: Second votes AGAINST
        governor.castVote(10, 0);
        console.log("Second voted AGAINST on Proposal 10");

        // Proposal 11: Second votes FOR
        governor.castVote(11, 1);
        console.log("Second voted FOR on Proposal 11");

        vm.stopBroadcast();

        console.log("\n========== VOTING COMPLETE ==========");
    }
}
