// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Governor.sol";

contract VoteNewProposals is Script {
    address constant NEW_GOVERNOR = 0x7F032E7F62D06161C9ebC83898e23171bC3bedB9;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        Governor governor = Governor(payable(NEW_GOVERNOR));

        console.log("Voting on proposals...");

        vm.startBroadcast(deployerPrivateKey);

        // Vote FOR on all proposals
        governor.castVote(1, 1); // FOR
        console.log("Voted FOR on Proposal 1");

        governor.castVote(2, 1); // FOR
        console.log("Voted FOR on Proposal 2");

        governor.castVote(3, 0); // AGAINST
        console.log("Voted AGAINST on Proposal 3");

        vm.stopBroadcast();

        console.log("\n========== VOTING COMPLETE ==========");
    }
}
