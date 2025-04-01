pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Reputeth.sol";

contract ReputethTest is Test {
    Reputeth public reputeth;
    address public alice = address(0x1);
    address public bob = address(0x2);
    address public charlie = address(0x3);
    address public dave = address(0x4);
    uint256 public initBal = 1e9 * 1e18;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    address constant OWNER = 0x9906B794407BBe3C1Ca9741fdB30Dc2fACc838DE;
    function setUp() public {
        reputeth = new Reputeth(OWNER);
    }

    function testInitialBalance() public view {
        assertEq(reputeth.balanceOf(alice), initBal);
        assertEq(reputeth.balanceOf(bob), initBal);
        assertEq(reputeth.balanceOf(charlie), initBal);
    }

    function testTransferSuccess() public {
        uint256 transferAmount = 1000 * 1e18;
        vm.deal(bob, 1 ether);

        vm.prank(alice, alice);
        reputeth.transfer(bob, transferAmount);

        assertEq(reputeth.balanceOf(alice), initBal + (transferAmount / 3));

        assertEq(reputeth.balanceOf(bob), initBal - transferAmount);
    }

    function testTransferUpdatesReputation() public {
        uint256 transferAmount = 1000 * 1e18;
        vm.deal(bob, 1 ether);

        uint256 aliceInitPlus = reputeth.plus(alice);
        uint256 bobInitMinus = reputeth.minus(bob);

        vm.prank(alice, alice);
        reputeth.transfer(bob, transferAmount);

        assertEq(reputeth.plus(alice), aliceInitPlus + (transferAmount / 3));
        assertEq(reputeth.minus(bob), bobInitMinus + transferAmount);
    }

    function testTransferRevertsWhenOverLimit() public {
        uint256 overLimit = uint256(2e5) * 1e18;
        vm.deal(bob, 1 ether);

        vm.prank(alice, alice);
        vm.expectRevert(Reputeth.OverLimit.selector);
        reputeth.transfer(bob, overLimit);
    }

    function testTransferRevertsWhenRecipientInactive() public {
        address inactiveAddress = address(0x5);
        uint256 transferAmount = 1000 * 1e18;

        vm.prank(alice, alice);
        vm.expectRevert(Reputeth.InactiveAddress.selector);
        reputeth.transfer(inactiveAddress, transferAmount);
    }

    function testMultipleTransfersUpdateBalances() public {
        vm.deal(bob, 1 ether);
        vm.prank(alice, alice);
        reputeth.transfer(bob, 1000 * 1e18);

        vm.deal(charlie, 1 ether);
        vm.prank(bob, bob);
        reputeth.transfer(charlie, 500 * 1e18);

        uint256 aliceExpected = initBal + ((uint256(1000) * 1e18) / 3);
        uint256 bobExpected = initBal - (uint256(1000) * 1e18) + ((uint256(500) * 1e18) / 3);
        uint256 charlieExpected = initBal - (uint256(500) * 1e18);

        assertEq(reputeth.balanceOf(alice), aliceExpected);
        assertEq(reputeth.balanceOf(bob), bobExpected);
        assertEq(reputeth.balanceOf(charlie), charlieExpected);
    }

    function testAirdropDistributesInitialBalance() public {
        address[] memory accounts = new address[](3);
        accounts[0] = bob;
        accounts[1] = charlie;
        accounts[2] = dave;

        vm.deal(bob, 1 ether);
        vm.deal(charlie, 1 ether);
        vm.deal(dave, 1 ether);

        vm.expectEmit(true, true, false, false);
        emit Transfer(address(reputeth), bob, initBal);

        vm.expectEmit(true, true, false, false);
        emit Transfer(address(reputeth), charlie, initBal);

        vm.expectEmit(true, true, false, false);
        emit Transfer(address(reputeth), dave, initBal);

        vm.prank(reputeth.owner());
        reputeth.airdrop(accounts);

        assertEq(reputeth.balanceOf(bob), initBal);
        assertEq(reputeth.balanceOf(charlie), initBal);
        assertEq(reputeth.balanceOf(dave), initBal);
    }

    function testReputationCalculation() public {
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
}
