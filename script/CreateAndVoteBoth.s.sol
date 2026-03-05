// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Governor.sol";
import "../src/TitanToken.sol";

contract CreateAndVoteBoth is Script {
    address constant GOVERNANCE = 0x482BFe34fC0535a2E3355EF8b4e2405bCD879f19;
    address constant TITAN_TOKEN = 0xbA6720e72f929318E66AcED4389889640Aee0F6e;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        Governor governor = Governor(payable(GOVERNANCE));
        TitanToken titan = TitanToken(TITAN_TOKEN);

        console.log("Creating new proposals and voting...");
        console.log("Deployer:", deployer);
        console.log("Deployer voting power:", titan.getVotes(deployer) / 1e18);

        vm.startBroadcast(deployerPrivateKey);

        // Empty arrays for proposals
        address[] memory targets = new address[](1);
        targets[0] = address(governor);

        uint256[] memory values = new uint256[](1);
        values[0] = 0;

        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = "";

        // Create Proposal 9: Fee reduction
        string memory desc9 = "TIP-9: Reduce Swap Fees to 0.25%\n\nProposal to reduce the swap fee from 0.3% to 0.25% to make TITAN DEX more competitive with other decentralized exchanges. Lower fees will attract more trading volume.";
        uint256 prop9 = governor.propose(targets, values, calldatas, desc9);
        console.log("Created Proposal 9:", prop9);

        // Create Proposal 10: Liquidity Mining
        string memory desc10 = "TIP-10: Launch Liquidity Mining Program\n\nAllocate 5M TITAN tokens over 12 months for liquidity mining rewards. LPs in TITAN/ETH and TITAN/tUSD pools will earn additional TITAN rewards proportional to their liquidity share.";
        uint256 prop10 = governor.propose(targets, values, calldatas, desc10);
        console.log("Created Proposal 10:", prop10);

        // Create Proposal 11: Bug Bounty Program
        string memory desc11 = "TIP-11: Establish Bug Bounty Program\n\nCreate a security bug bounty program with rewards up to 100,000 TITAN for critical vulnerabilities. This will improve protocol security through crowdsourced auditing.";
        uint256 prop11 = governor.propose(targets, values, calldatas, desc11);
        console.log("Created Proposal 11:", prop11);

        vm.stopBroadcast();

        console.log("\n========== PROPOSALS CREATED ==========");
        console.log("Total proposals:", governor.proposalCount());
        console.log("Now wait for voting period to start, then run VoteBothWallets script");
    }
}
