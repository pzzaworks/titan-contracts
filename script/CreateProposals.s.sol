// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Governor.sol";
import "../src/TitanToken.sol";

contract CreateProposals is Script {
    // Deployed addresses
    address constant GOVERNANCE = 0x482BFe34fC0535a2E3355EF8b4e2405bCD879f19;
    address constant TITAN_TOKEN = 0xbA6720e72f929318E66AcED4389889640Aee0F6e;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Creating proposals on Governance...");
        console.log("Deployer:", deployer);

        Governor governor = Governor(payable(GOVERNANCE));
        TitanToken titan = TitanToken(TITAN_TOKEN);

        // Check voting power
        uint256 votes = titan.getVotes(deployer);
        console.log("Current voting power:", votes / 1e18, "TITAN");

        vm.startBroadcast(deployerPrivateKey);

        // If no voting power, delegate to self first
        if (votes < 1000e18) {
            console.log("Delegating to self...");
            titan.delegate(deployer);
            votes = titan.getVotes(deployer);
            console.log("Voting power after delegation:", votes / 1e18, "TITAN");
        }

        // Empty arrays for proposals (no on-chain actions, just governance signals)
        address[] memory targets = new address[](1);
        targets[0] = address(governor); // Target the governor itself (no-op)

        uint256[] memory values = new uint256[](1);
        values[0] = 0;

        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = ""; // Empty calldata

        // Proposal 1: Increase Vault MCR (Active)
        string memory desc1 = "TIP-1: Increase Vault MCR from 150% to 160%\n\nThis proposal aims to increase the Minimum Collateral Ratio for the Vault from 150% to 160% to provide additional safety margin during high volatility periods.";
        uint256 prop1 = governor.propose(targets, values, calldatas, desc1);
        console.log("Created Proposal 1:", prop1);

        // Proposal 2: Add USDC Collateral (Active)
        string memory desc2 = "TIP-2: Add USDC as Alternative Collateral\n\nEnable USDC as an accepted collateral type in the Vault system alongside TITAN. This will allow users to mint tUSD using USDC at a lower collateral ratio of 110%.";
        uint256 prop2 = governor.propose(targets, values, calldatas, desc2);
        console.log("Created Proposal 2:", prop2);

        // Proposal 3: Reduce Liquidation Bonus (Active)
        string memory desc3 = "TIP-3: Reduce Liquidation Bonus to 8%\n\nLower the liquidation bonus from 10% to 8% to reduce the penalty for liquidated users while still maintaining sufficient incentive for liquidators.";
        uint256 prop3 = governor.propose(targets, values, calldatas, desc3);
        console.log("Created Proposal 3:", prop3);

        // Proposal 4: Launch Cross-Chain Bridge (Active)
        string memory desc4 = "TIP-4: Launch TITAN Cross-Chain Bridge\n\nDeploy a cross-chain bridge to enable TITAN transfers between Ethereum mainnet, Arbitrum, and Base. This will increase accessibility and liquidity across L2 ecosystems.";
        uint256 prop4 = governor.propose(targets, values, calldatas, desc4);
        console.log("Created Proposal 4:", prop4);

        vm.stopBroadcast();

        console.log("\n========== PROPOSALS CREATED ==========");
        console.log("Total proposals:", governor.proposalCount());
        console.log("=========================================\n");
    }
}
