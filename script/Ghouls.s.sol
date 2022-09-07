// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import { GhoulsRoyalties } from "../src/GhoulsRoyalties.sol";
import { Ghouls } from "../src/Ghouls.sol";

contract GhoulsScript is Script {
	function setUp() public {}

	string public constant baseUri = "ipfs://temporary";
	address payable public constant DBS_TREASURY_ADDRESS =
		payable(address(0xF39c20D7866be8956CF8D99650294f150B971740));
	address[] public ROYALTY_RECEIVERS = [
		payable(address(0x66489267CA0848Fa961045060b0E597c52A69996)),
		payable(address(0xB41204CbA1eE7A4E3A20a887c8D22d0858f9d7E7))
	];
	uint256[] public ROYALTY_SHARES = [50, 50];

	function run() external {
		vm.startBroadcast();

		GhoulsRoyalties royalties = new GhoulsRoyalties(
			ROYALTY_RECEIVERS,
			ROYALTY_SHARES
		);

		Ghouls ghouls = new Ghouls(
			"Ghouls",
			"GHLS",
			baseUri,
			DBS_TREASURY_ADDRESS,
			payable(address(royalties)),
			800,
			Ghouls.SalesConfiguration({
				publicSalePrice: 0.1 ether,
				publicSaleStart: 1662739200,
				allowlistStart: 1662652800,
				allowlistMerkleRoot: bytes32(
					0x3e9ed7360d5d875d7b0563382c6797e2a42c4439ebe902edb865f05451e10b04
				)
			})
		);

		vm.stopBroadcast();
	}
}
