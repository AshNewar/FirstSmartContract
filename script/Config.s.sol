//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/mock.sol";

contract HomeConfig is Script {
    NetworkConfig public ActiveConfig;

    struct NetworkConfig {
        address feed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            ActiveConfig = SepoliaConfig();
        } else if (block.chainid == 1) {
            ActiveConfig = EthConfig();
        } else {
            ActiveConfig = AnvilConfig();
        }
    }

    function SepoliaConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({feed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
    }

    function EthConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({feed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
    }

    //local Setup  Using Anvil
    function AnvilConfig() public returns (NetworkConfig memory) {
        if (ActiveConfig.feed != address(0)) return ActiveConfig;
        // address(0) means address of the contract

        vm.startBroadcast();
        MockV3Aggregator aggregator = new MockV3Aggregator(8, 10e8);
        vm.stopBroadcast();

        return NetworkConfig({feed: address(aggregator)});
    }
}
