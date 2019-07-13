pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/EventTickets.sol";
import "./Proxy.sol";

contract TestEventTickets {
  uint public initialBalance = 1 ether;
  string description = 'book';
  string url = 'website';
  uint totalTickets = 10;
  uint TICKET_PRICE = 100 wei;

  // address buyer = 0xCdABc2bcb262A2aaDdD01de1f7710C6E2F50AC12;

  EventTickets public eventTickets;
  Proxy public ticketsBuyer;

  event ConsoleLog(bytes);

  function() external payable {}

  function beforeEach() public
  {
    // Contract to test
    eventTickets = new EventTickets(description, url, totalTickets);
    ticketsBuyer = new Proxy(eventTickets);
    address(ticketsBuyer).transfer(500 wei);

    (bool success, bytes memory ticketsBought) = ticketsBuyer.buyTickets(500 wei, 5);
    emit ConsoleLog(ticketsBought);
    Assert.isTrue(success, "Buyer should have bought 5 tickets");
  }

  function testReadEvent() public  {
    (string memory eventDescription, string memory eventUrl, uint eventTotalTickets, uint eventSales, bool eventIsOpen) = eventTickets.readEvent();
    Assert.isTrue(keccak256(abi.encodePacked(eventDescription)) == keccak256(abi.encodePacked(description)), "event not initialized properly");
    Assert.isTrue(keccak256(abi.encodePacked(eventUrl)) == keccak256(abi.encodePacked(url)), "event not initialized properly");
    Assert.isTrue(eventTotalTickets == totalTickets, "event not initialized properly");
    Assert.isTrue(eventSales == 0, "event not initialized properly");
    Assert.isTrue(eventIsOpen == true, "event not initialized properly");
  }

  function testGetBuyerTicketCount() public {
    uint afterBuyTickets = eventTickets.getBuyerTicketCount(address(ticketsBuyer));
    Assert.isTrue(afterBuyTickets == 5, "Buyer should have bought 5 tickets");
  }


}