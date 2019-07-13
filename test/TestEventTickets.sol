pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/EventTickets.sol";
import "./Proxy.sol";

contract TestEventTickets {
  uint public initialBalance = 1 ether;
  string description = 'my event';
  string url = 'website';
  uint totalTickets = 10;
  uint TICKET_PRICE = 100 wei;

  EventTickets public eventTickets;
  Proxy public ticketsBuyer;

  function() external payable {}

  function beforeEach() public
  {
    // Contract to test
    eventTickets = new EventTickets(description, url, totalTickets);
    ticketsBuyer = new Proxy(eventTickets);
    address(ticketsBuyer).transfer(100 wei);
    ticketsBuyer.buyTickets(100 wei, 1);
  }

  function testBuyTickets() public {
    address(ticketsBuyer).transfer(500 wei);
    (bool success, uint ticketsBought) = ticketsBuyer.buyTickets(500 wei, 5);
    Assert.isTrue(success, "Buyer should have completed the purchase");
    Assert.isTrue(ticketsBought == 5, "Buyer should have bought 5 tickets");
  }

  function testReadEvent() public  {
    ( string memory eventDescription,
      string memory eventUrl,
      uint eventTotalTickets,
      uint eventSales,
      bool eventIsOpen
      ) = eventTickets.readEvent();
    Assert.isTrue(
      keccak256(abi.encodePacked(eventDescription)) == keccak256(abi.encodePacked(description)),
      "event description not initialized properly"
    );
    Assert.isTrue(keccak256(abi.encodePacked(eventUrl)) == keccak256(abi.encodePacked(url)), "event url not initialized properly");
    Assert.isTrue(eventTotalTickets == totalTickets, "event totalTickets not initialized properly");
    Assert.isTrue(eventIsOpen == true, "event isOpen not initialized properly");
    Assert.isTrue(eventSales == 1, "event sales not initialized properly");
  }

  function testGetBuyerTicketCount() public {
    uint beforeBuyTickets = eventTickets.getBuyerTicketCount(address(ticketsBuyer));
    Assert.isTrue(beforeBuyTickets == 1, "Buyer should have bought 1 ticket");

    address(ticketsBuyer).transfer(500 wei);
    ticketsBuyer.buyTickets(500 wei, 5);
    uint afterBuyTickets = eventTickets.getBuyerTicketCount(address(ticketsBuyer));
    Assert.isTrue(afterBuyTickets == 6, "Buyer should have bought 6 tickets");
  }

  function testGetRefund() public {
    uint ticketsBeforeRefund = eventTickets.getBuyerTicketCount(address(ticketsBuyer));
    ( , , , uint salesBeforeRefund, ) = eventTickets.readEvent();

    bool success = ticketsBuyer.getRefund();
    Assert.isTrue(success, "Tickets should have been refunded");

    ( , , , uint salesAfterRefund, ) = eventTickets.readEvent();
    Assert.isTrue(salesAfterRefund == salesBeforeRefund - ticketsBeforeRefund, 'Tickets have not been refunded');
  }

  function testEndSale() public {
    eventTickets.endSale();
    ( , , , , bool eventIsOpen) = eventTickets.readEvent();
    Assert.isFalse(eventIsOpen, 'Event should be closed');

    address(ticketsBuyer).transfer(500 wei);
    (bool success, ) = ticketsBuyer.buyTickets(500 wei, 5);
    Assert.isFalse(success, "Tickets should't been bought when event is closed");
  }
}