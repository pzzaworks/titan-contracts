// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/StakedTitan.sol";
import "../src/Governor.sol";

/**
 * @title UpgradeGovernance
 * @notice Deploys new StakedTitan with ERC20Votes and new Governor using sTITAN
 */
contract UpgradeGovernance is Script {
    // Existing contracts
    address constant TITAN_TOKEN = 0xbA6720e72f929318E66AcED4389889640Aee0F6e;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Upgrading Governance to use sTITAN...");
        console.log("Deployer:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy new StakedTitan with ERC20Votes
        // ~10% APY: 10 / 100 / 365 / 24 / 3600 * 1e18 ≈ 3.17e9
        uint256 rewardRate = 3170979198; // ~10% APY
        StakedTitan newSTitan = new StakedTitan(TITAN_TOKEN, rewardRate, deployer);
        console.log("New StakedTitan (sTITAN) deployed:", address(newSTitan));

        // 2. Deploy new Governor using sTITAN for voting power
        Governor newGovernor = new Governor(
            address(newSTitan),     // sTITAN for voting
            1000 * 1e18,            // 1000 sTITAN to propose
            1,                       // 1 block voting delay (instant for testing)
            50400,                   // ~7 days voting period (12s blocks)
            1 days,                  // 1 day timelock
            400                      // 4% quorum
        );
        console.log("New Governor deployed:", address(newGovernor));

        vm.stopBroadcast();

        console.log("\n========== UPGRADE COMPLETE ==========");
        console.log("New sTITAN:", address(newSTitan));
        console.log("New Governor:", address(newGovernor));
        console.log("");
        console.log("Update frontend config with these addresses!");
        console.log("==========================================\n");
    }
}
