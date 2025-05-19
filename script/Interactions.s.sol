//SPDX License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract Fund is Script {
    function fund(address mostRecentDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployed)).fund{value: 0.1 ether}();
        vm.stopBroadcast();
    }

    function run() external {
        // get the most recent deployed contract address
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

        // fund the contract
        fund(mostRecentDeployed);
    }
}

contract Withdraw is Script {
    function withdraw(address mostRecentDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        // get the most recent deployed contract address
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

        withdraw(mostRecentDeployed);
    }
}
