// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Governor.sol";
import "../src/TitanToken.sol";

contract VoteVaried is Script {
    // Deployed addresses
    address constant GOVERNANCE = 0x482BFe34fC0535a2E3355EF8b4e2405bCD879f19;
    address constant TITAN_TOKEN = 0xbA6720e72f929318E66AcED4389889640Aee0F6e;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Voting on proposals...");
        console.log("Deployer:", deployer);

        Governor governor = Governor(payable(GOVERNANCE));
        TitanToken titan = TitanToken(TITAN_TOKEN);

        uint256 votes = titan.getVotes(deployer);
        console.log("Current voting power:", votes / 1e18, "TITAN");

        vm.startBroadcast(deployerPrivateKey);

        // Vote on proposals with varied support
        // 0 = Against, 1 = For, 2 = Abstain

        // Proposal 5: Vote FOR (veTITAN model is popular)
        governor.castVote(5, 1);
        console.log("Voted FOR on Proposal 5 (veTITAN)");

        // Proposal 6: Vote AGAINST (treasury diversification controversial)
        governor.castVote(6, 0);
        console.log("Voted AGAINST on Proposal 6 (Treasury Diversification)");

        // Proposal 7: Vote FOR (reduce cooldown)
        governor.castVote(7, 1);
        console.log("Voted FOR on Proposal 7 (Reduce Cooldown)");

        // Proposal 8: Don't vote - keep it active with 0 votes

        vm.stopBroadcast();

        console.log("\n========== VOTING COMPLETE ==========");
    }
}
