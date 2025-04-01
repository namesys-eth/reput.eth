pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Reputeth.sol";

contract ReputethTest is Test {
    Reputeth public reputeth;
    address public alice = address(0x1);
    address public bob = address(0x2);
    address public charlie = address(0x3);
    uint256 public initBal = 1e9 * 1e18;
    uint256 public limit = 1e5 * 1e18;

    event Transfer(address indexed from, address indexed to, uint256 amount);

    address constant OWNER = 0x9906B794407BBe3C1Ca9741fdB30Dc2fACc838DE;

    function setUp() public {
        reputeth = new Reputeth(OWNER);
    }

    function testInitialState() public view {
        assertEq(reputeth.name(), "REPUT.ETH");
        assertEq(reputeth.symbol(), "RPT");
        assertEq(reputeth.decimals(), 18);
        assertEq(reputeth.totalSupply(), type(uint256).max);
        assertEq(reputeth.owner(), OWNER);
    }

    function testBalanceOf() public view {
        assertEq(reputeth.balanceOf(alice), initBal);
        assertEq(reputeth.balanceOf(bob), initBal);
    }

    function testTransfer() public {
        uint256 transferAmount = 1000 * 1e18;
        vm.deal(bob, 1 ether);

        vm.prank(alice);
        reputeth.transfer(bob, transferAmount);

        assertEq(reputeth.balanceOf(alice), initBal + (transferAmount / 3));
        assertEq(reputeth.balanceOf(bob), initBal - transferAmount);
        assertEq(reputeth.plus(alice), transferAmount / 3);
        assertEq(reputeth.minus(bob), transferAmount);
    }

    function testTransferReverts() public {
        // Test OverLimit
        vm.prank(alice);
        vm.expectRevert(Reputeth.OverLimit.selector);
        reputeth.transfer(bob, limit + 1);

        // Test InactiveAddress
        address inactiveAddress = address(0x5);
        vm.prank(alice);
        vm.expectRevert(Reputeth.InactiveAddress.selector);
        reputeth.transfer(inactiveAddress, 1000 * 1e18);

        // Test SelfTransfer
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        vm.expectRevert(Reputeth.SelfTransfer.selector);
        reputeth.transfer(alice, 1000 * 1e18);
    }

    function testReputation() public {
        vm.deal(bob, 1 ether);
        vm.deal(charlie, 1 ether);

        vm.prank(alice);
        reputeth.transfer(bob, 1500 * 1e18);

        vm.prank(bob);
        reputeth.transfer(charlie, 900 * 1e18);

        assertEq(reputeth.reputation(alice), int256(500 * 1e18));
        assertEq(reputeth.reputation(bob), int256(-1200 * 1e18));
        assertEq(reputeth.reputation(charlie), int256(-900 * 1e18));
    }

    function testAirdrop() public {
        address[] memory accounts = new address[](2);
        accounts[0] = bob;
        accounts[1] = charlie;

        vm.deal(bob, 1 ether);
        vm.deal(charlie, 1 ether);

        vm.expectEmit(true, true, false, false);
        emit Transfer(address(reputeth), bob, initBal);

        vm.expectEmit(true, true, false, false);
        emit Transfer(address(reputeth), charlie, initBal);

        vm.prank(OWNER);
        reputeth.airdrop(accounts);

        assertEq(reputeth.balanceOf(bob), initBal);
        assertEq(reputeth.balanceOf(charlie), initBal);
    }

    function testAirdropRevert() public {
        address[] memory accounts = new address[](1);
        accounts[0] = bob;

        vm.prank(alice);
        vm.expectRevert(ERC173.OnlyOwner.selector);
        reputeth.airdrop(accounts);
    }
}
