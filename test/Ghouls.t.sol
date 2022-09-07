// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import { GhoulsRoyalties } from "../src/GhoulsRoyalties.sol";
import { Ghouls } from "../src/Ghouls.sol";

contract GhoulsTest is Test {
	GhoulsRoyalties royalties;
	Ghouls ghoulsNFTBase;
	address public constant DEFAULT_OWNER_ADDRESS = address(0x666);
	address payable public constant DEFULT_FUNDS_RECIPIENT_ADDRESS =
		payable(address(0x616));
	address payable public constant DBS_TREASURY_ADDRESS =
		payable(address(0xdeadbb));
	address[] public ROYALTY_RECEIVERS = [
		payable(address(0x1234)),
		payable(address(0x2345))
	];
	uint256[] public ROYALTY_SHARES = [50, 50];

	modifier setupGhoulsNFTBase() {
		royalties = new GhoulsRoyalties(ROYALTY_RECEIVERS, ROYALTY_SHARES);
		ghoulsNFTBase = new Ghouls(
			"TestGhouls",
			"tGHLS",
			"ipfs://jfisadjfkjsadiofwejj/",
			DBS_TREASURY_ADDRESS,
			DEFULT_FUNDS_RECIPIENT_ADDRESS,
			1000,
			Ghouls.SalesConfiguration({
				publicSalePrice: 0.1 ether,
				publicSaleStart: 0,
				allowlistStart: 0,
				allowlistMerkleRoot: bytes32(0)
			})
		);
		ghoulsNFTBase.transferOwnership(DEFAULT_OWNER_ADDRESS);
		_;
	}

	function getAirdrops() public returns (Ghouls.Airdrop[] memory) {
		Ghouls.Airdrop[] memory airdrops = new Ghouls.Airdrop[](10);
		for (uint160 i = 0; i < 7; i++) {
			airdrops[i] = Ghouls.Airdrop({ to: address(i + 1), num: 4 });
		}
		for (uint160 i = 7; i < 9; i++) {
			airdrops[i] = Ghouls.Airdrop({ to: address(i + 1), num: 3 });
		}
		airdrops[9] = Ghouls.Airdrop({ to: DBS_TREASURY_ADDRESS, num: 75 });

		return airdrops;
	}

	function setUp() public {}

	function testConstructor() public setupGhoulsNFTBase {
		require(
			ghoulsNFTBase.owner() == DEFAULT_OWNER_ADDRESS,
			"Default owner wrong"
		);
		(
			uint104 publicSalePrice,
			uint64 publicSaleStart,
			uint64 allowlistStart,
			bytes32 allowlistMerkleRoot
		) = ghoulsNFTBase.salesConfig();

		require(publicSalePrice == 0.1 ether, "Public sale price wrong");
		require(publicSaleStart == 0, "Public sale start wrong");
		require(allowlistStart == 0, "Allowlist start wrong");
		require(
			allowlistMerkleRoot == bytes32(0),
			"Allowlist merkle root wrong"
		);

		string memory name = ghoulsNFTBase.name();
		string memory symbol = ghoulsNFTBase.symbol();
		require(
			keccak256(bytes(name)) == keccak256(bytes("TestGhouls")),
			"Name wrong"
		);
		require(
			keccak256(bytes(symbol)) == keccak256(bytes("tGHLS")),
			"Symbol wrong"
		);
	}

	function test_Airdrop() public setupGhoulsNFTBase {
		Ghouls.Airdrop[] memory airdrops = getAirdrops();
		vm.prank(DEFAULT_OWNER_ADDRESS);
		ghoulsNFTBase.airdrop(airdrops, 109);
		assertEq(
			ghoulsNFTBase.ownerOf(90),
			DBS_TREASURY_ADDRESS,
			"Airdrop to DBS Treasury failed"
		);
		assertEq(
			ghoulsNFTBase.ownerOf(1),
			address(1),
			"Airdrop to admin user failed"
		);
		assertEq(
			ghoulsNFTBase.ownerOf(29),
			address(8),
			"Airdrop to creator failed"
		);
		assertEq(
			ghoulsNFTBase.balanceOf(address(1)),
			4,
			"Airdrop to admin user failed"
		);
		assertEq(
			ghoulsNFTBase.balanceOf(address(8)),
			3,
			"Airdrop failed: creator balance"
		);
		assertEq(
			ghoulsNFTBase.balanceOf(DBS_TREASURY_ADDRESS),
			75,
			"DBS Treasury does not have expected amount of tokens"
		);
	}

	function test_canAirdropAfterPublic() public setupGhoulsNFTBase {
		vm.deal(address(9), 10 ether);
		vm.prank(address(9));
		ghoulsNFTBase.purchase(
			ghoulsNFTBase.NUM_MAX_GHOULS() - ghoulsNFTBase.NUM_AIRDROP_FREE()
		);
		Ghouls.Airdrop[] memory airdrops = getAirdrops();
		ghoulsNFTBase.airdrop(airdrops, 109);
	}

	function test_royalties() public setupGhoulsNFTBase {
		// Airdrop and check royalties
		//Purchase and check royalties
	}
}
