// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Governor.sol";
import "../src/TitanToken.sol";

contract VoteAsSecondVoter is Script {
    address constant GOVERNANCE = 0x482BFe34fC0535a2E3355EF8b4e2405bCD879f19;
    address constant TITAN_TOKEN = 0xbA6720e72f929318E66AcED4389889640Aee0F6e;

    function run() external {
        uint256 voterPrivateKey = vm.envUint("SECOND_VOTER_PRIVATE_KEY");
        address voter = vm.addr(voterPrivateKey);

        Governor governor = Governor(payable(GOVERNANCE));
        TitanToken titan = TitanToken(TITAN_TOKEN);

        console.log("Voting as second voter...");
        console.log("Voter:", voter);
        console.log("TITAN balance:", titan.balanceOf(voter) / 1e18);

        vm.startBroadcast(voterPrivateKey);

        // First delegate to self to get voting power
        titan.delegate(voter);
        console.log("Delegated to self");
        console.log("Voting power:", titan.getVotes(voter) / 1e18);

        // Vote opposite of main voter on active proposals
        // Main voter voted: FOR on 5, AGAINST on 6, FOR on 7, didn't vote on 8

        // Proposal 5: Vote AGAINST (main voted FOR)
        governor.castVote(5, 0);
        console.log("Voted AGAINST on Proposal 5");

        // Proposal 6: Vote FOR (main voted AGAINST)
        governor.castVote(6, 1);
        console.log("Voted FOR on Proposal 6");

        // Proposal 7: Vote AGAINST (main voted FOR)
        governor.castVote(7, 0);
        console.log("Voted AGAINST on Proposal 7");

        // Proposal 8: Vote FOR (main didn't vote)
        governor.castVote(8, 1);
        console.log("Voted FOR on Proposal 8");

        vm.stopBroadcast();

        console.log("\n========== VOTING COMPLETE ==========");
    }
}
