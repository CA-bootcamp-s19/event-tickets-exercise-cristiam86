pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/EventTicketsV2.sol";
import "./ProxyV2.sol";

contract TestEventTicketsV2 {
  uint public initialBalance = 1 ether;
  string description = 'my event';
  string url = 'website';
  uint totalTickets = 10;
  uint TICKET_PRICE = 100 wei;

  EventTicketsV2 public eventTickets;
  ProxyV2 public ticketsBuyer;

  function() external payable {}

  function beforeEach() public
  {
    // Contract to test
    eventTickets = new EventTicketsV2();
    ticketsBuyer = new ProxyV2(eventTickets);
    eventTickets.addEvent(description, url, totalTickets);
  }

  function testBuyTickets() public {
    address(ticketsBuyer).transfer(500 wei);
    bool success = ticketsBuyer.buyTickets(0, 500 wei, 5);
    Assert.isTrue(success, "Buyer should have completed the purchase");
  }

  function testReadEvent() public  {
    ( string memory eventDescription,
      string memory eventUrl,
      uint eventTotalTickets,
      uint eventSales,
      bool eventIsOpen
      ) = eventTickets.readEvent(0);
    Assert.isTrue(
      keccak256(abi.encodePacked(eventDescription)) == keccak256(abi.encodePacked(description)),
      "event description not initialized properly"
    );
    Assert.isTrue(keccak256(abi.encodePacked(eventUrl)) == keccak256(abi.encodePacked(url)), "event url not initialized properly");
    Assert.isTrue(eventTotalTickets == totalTickets, "event totalTickets not initialized properly");
    Assert.isTrue(eventIsOpen == true, "event isOpen not initialized properly");
    Assert.isTrue(eventSales == 0, "event sales not initialized properly");
  }

  function testGetBuyerTicketCount() public {
    (, uint beforeBuyTickets) = ticketsBuyer.getBuyerNumberTickets(0);
    Assert.isTrue(beforeBuyTickets == 0, "Buyer should have bought 0 tickets");

    address(ticketsBuyer).transfer(500 wei);
    ticketsBuyer.buyTickets(0, 500 wei, 5);
    (, uint afterBuyTickets) = ticketsBuyer.getBuyerNumberTickets(0);
    Assert.isTrue(afterBuyTickets == 5, "Buyer should have bought 5 tickets");
  }

  function testGetRefund() public {
    address(ticketsBuyer).transfer(500 wei);
    ticketsBuyer.buyTickets(0, 500 wei, 5);

    (, uint ticketsBeforeRefund) = ticketsBuyer.getBuyerNumberTickets(0);
    ( , , , uint salesBeforeRefund, ) = eventTickets.readEvent(0);

    bool success = ticketsBuyer.getRefund(0);
    Assert.isTrue(success, "Tickets should have been refunded");

    ( , , , uint salesAfterRefund, ) = eventTickets.readEvent(0);
    Assert.isTrue(salesAfterRefund == salesBeforeRefund - ticketsBeforeRefund, 'Tickets have not been refunded');
  }

  function testEndSale() public {
    eventTickets.endSale(0);
    ( , , , , bool eventIsOpen) = eventTickets.readEvent(0);
    Assert.isFalse(eventIsOpen, 'Event should be closed');

    address(ticketsBuyer).transfer(500 wei);
    bool success = ticketsBuyer.buyTickets(0, 500 wei, 5);
    Assert.isFalse(success, "Tickets should't been bought when event is closed");
  }
}