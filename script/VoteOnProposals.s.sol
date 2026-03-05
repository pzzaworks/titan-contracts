// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Governor.sol";

contract VoteOnProposals is Script {
    address constant GOVERNANCE = 0x482BFe34fC0535a2E3355EF8b4e2405bCD879f19;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Voting on proposals...");
        console.log("Voter:", deployer);

        Governor governor = Governor(payable(GOVERNANCE));

        vm.startBroadcast(deployerPrivateKey);

        // Vote FOR on all proposals (support = 1)
        // Proposal 1
        governor.castVoteWithReason(1, 1, "Strong support for increased safety margins");
        console.log("Voted FOR on Proposal 1");

        // Proposal 2
        governor.castVoteWithReason(2, 1, "USDC collateral will boost TVL significantly");
        console.log("Voted FOR on Proposal 2");

        // Proposal 3 - Vote AGAINST (support = 0)
        governor.castVoteWithReason(3, 0, "Current liquidation bonus is fair for liquidators");
        console.log("Voted AGAINST on Proposal 3");

        // Proposal 4
        governor.castVoteWithReason(4, 1, "Cross-chain expansion is essential for growth");
        console.log("Voted FOR on Proposal 4");

        vm.stopBroadcast();

        console.log("\n========== VOTES CAST ==========");
        (uint256 for1, uint256 against1, ) = governor.getVotes(1);
        (uint256 for2, uint256 against2, ) = governor.getVotes(2);
        (uint256 for3, uint256 against3, ) = governor.getVotes(3);
        (uint256 for4, uint256 against4, ) = governor.getVotes(4);

        console.log("Proposal 1 - For:", for1 / 1e18, "Against:", against1 / 1e18);
        console.log("Proposal 2 - For:", for2 / 1e18, "Against:", against2 / 1e18);
        console.log("Proposal 3 - For:", for3 / 1e18, "Against:", against3 / 1e18);
        console.log("Proposal 4 - For:", for4 / 1e18, "Against:", against4 / 1e18);
        console.log("=================================\n");
    }
}
