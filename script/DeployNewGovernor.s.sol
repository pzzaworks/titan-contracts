// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Governor.sol";

/**
 * @title DeployNewGovernor
 * @notice Deploys new Governor with proper voting period (7 days)
 */
contract DeployNewGovernor is Script {
    // Existing StakedTitan
    address constant STAKED_TITAN = 0xa7CA1376bc77535537BF43bf12315AA75c68DA29;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying new Governor with 7-day voting period...");
        console.log("Deployer:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy new Governor with proper timing
        // Voting Delay: 25 blocks (~5 minutes)
        // Voting Period: 50400 blocks (~7 days)
        Governor newGovernor = new Governor(
            STAKED_TITAN,            // sTITAN for voting
            1000 * 1e18,             // 1000 sTITAN to propose
            25,                      // 25 blocks voting delay (~5 min)
            50400,                   // 50400 blocks voting period (~7 days)
            1 days,                  // 1 day timelock
            400                      // 4% quorum
        );
        console.log("New Governor deployed:", address(newGovernor));

        vm.stopBroadcast();

        console.log("\n========== DEPLOYMENT COMPLETE ==========");
        console.log("Governor:", address(newGovernor));
        console.log("");
        console.log("Voting Delay: 25 blocks (~5 minutes)");
        console.log("Voting Period: 50400 blocks (~7 days)");
        console.log("");
        console.log("Update config.contracts.governance in frontend!");
        console.log("==========================================\n");
    }
}
