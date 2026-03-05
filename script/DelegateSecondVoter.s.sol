// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/TitanToken.sol";

contract DelegateSecondVoter is Script {
    address constant TITAN_TOKEN = 0xbA6720e72f929318E66AcED4389889640Aee0F6e;

    function run() external {
        uint256 voterPrivateKey = vm.envUint("SECOND_VOTER_PRIVATE_KEY");
        address voter = vm.addr(voterPrivateKey);

        TitanToken titan = TitanToken(TITAN_TOKEN);

        console.log("Delegating second voter...");
        console.log("Voter:", voter);
        console.log("Balance:", titan.balanceOf(voter) / 1e18);
        console.log("Current votes:", titan.getVotes(voter) / 1e18);

        vm.startBroadcast(voterPrivateKey);
        titan.delegate(voter);
        vm.stopBroadcast();

        console.log("Votes after delegation:", titan.getVotes(voter) / 1e18);
    }
}
