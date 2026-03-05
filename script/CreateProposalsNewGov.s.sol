// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Governor.sol";

contract CreateProposalsNewGov is Script {
    address constant NEW_GOVERNANCE = 0x374A62ddeCa9739Bd4E586f586B12a355B8aA1D1;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        console.log("Creating proposals on new Governor...");

        vm.startBroadcast(deployerPrivateKey);

        Governor governor = Governor(payable(NEW_GOVERNANCE));

        // Empty arrays for signaling proposals
        address[] memory targets = new address[](1);
        targets[0] = NEW_GOVERNANCE;
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = "";

        // Proposal 1: Increase Staking Rewards to 15% APY
        governor.propose(
            targets,
            values,
            calldatas,
            "Increase Staking Rewards to 15% APY\n\nProposal to increase the base staking APY from 10% to 15% to attract more stakers and strengthen protocol security through increased TVL."
        );
        console.log("Proposal 1 created: Increase Staking Rewards to 15% APY");

        // Proposal 2: Launch Cross-Chain Bridge to Arbitrum
        governor.propose(
            targets,
            values,
            calldatas,
            "Launch Cross-Chain Bridge to Arbitrum\n\nDeploy TITAN bridge to Arbitrum One for lower gas fees and faster transactions. This will expand the ecosystem and improve accessibility."
        );
        console.log("Proposal 2 created: Launch Cross-Chain Bridge to Arbitrum");

        // Proposal 3: Establish Community Grants Program
        governor.propose(
            targets,
            values,
            calldatas,
            "Establish Community Grants Program\n\nAllocate 1M TITAN tokens for community grants to fund development of tools, integrations, and educational content for the Titan ecosystem."
        );
        console.log("Proposal 3 created: Establish Community Grants Program");

        // Proposal 4: Treasury Diversification
        governor.propose(
            targets,
            values,
            calldatas,
            "Diversify Treasury with ETH Allocation\n\nProposal to allocate 10% of the DAO treasury into ETH to reduce single-asset risk and ensure long-term sustainability of protocol operations."
        );
        console.log("Proposal 4 created: Diversify Treasury with ETH Allocation");

        vm.stopBroadcast();

        console.log("\n4 proposals created successfully!");
    }
}
