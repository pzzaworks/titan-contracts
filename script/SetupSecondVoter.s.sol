// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Governor.sol";
import "../src/TitanToken.sol";

contract SetupSecondVoter is Script {
    address constant GOVERNANCE = 0x482BFe34fC0535a2E3355EF8b4e2405bCD879f19;
    address constant TITAN_TOKEN = 0xbA6720e72f929318E66AcED4389889640Aee0F6e;
    address constant SECOND_VOTER = 0xD1E1D89bdd552a0CD5560aB194eAD2Cf8246731E;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        TitanToken titan = TitanToken(TITAN_TOKEN);

        console.log("Setting up second voter...");
        console.log("Deployer:", deployer);
        console.log("Second voter:", SECOND_VOTER);
        console.log("Deployer TITAN balance:", titan.balanceOf(deployer) / 1e18);

        vm.startBroadcast(deployerPrivateKey);

        // Transfer 15M TITAN to second voter
        uint256 amount = 15_000_000 * 1e18;
        titan.transfer(SECOND_VOTER, amount);
        console.log("Transferred 15M TITAN to second voter");

        // Send some ETH for gas
        payable(SECOND_VOTER).transfer(0.001 ether);
        console.log("Sent 0.001 ETH for gas");

        vm.stopBroadcast();

        console.log("Second voter TITAN balance:", titan.balanceOf(SECOND_VOTER) / 1e18);
    }
}
