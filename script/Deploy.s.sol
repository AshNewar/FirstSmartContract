//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HomeConfig} from "./Config.s.sol";

contract Deploy is Script {
    function run() external returns (FundMe) {
        HomeConfig homeConfig = new HomeConfig();
        address feed = homeConfig.ActiveConfig();
        vm.startBroadcast();
        FundMe fundme = new FundMe(feed);
        vm.stopBroadcast();
        return fundme;
    }
}
