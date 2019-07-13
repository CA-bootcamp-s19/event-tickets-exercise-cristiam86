pragma solidity >= 0.5.0 < 0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/EventTickets.sol";


/// @title Simulate Roles for testing scenarios
/// @notice Use this Contract to simulate various roles in tests
/// @dev A Proxy can fulfill a Buyer, Seller or random agent
contract Proxy {

    /// the proxied EventTickets contract
    EventTickets public eventTickets;

    /// @notice Create a proxy
    /// @param _target the EventTickets to interact with
    constructor(EventTickets _target) public { eventTickets = _target; }

    /// Allow contract to receive ether
    function() external payable {}

    /// @notice Retrieve eventTickets contract
    /// @return the eventTickets contract
    function getTarget()
        public view
        returns (EventTickets)
    {
        return eventTickets;
    }

    function buyTickets(uint value, uint ticketsNumber) public payable returns (bool, bytes memory){
        (bool success, bytes memory ticketsBought) = address(eventTickets).call.value(value)(abi.encodeWithSignature("buyTickets(uint256 ticketsNumber)", ticketsNumber));
        return (success, ticketsBought);
    }

   
/*
    /// @notice Purchase an item
    /// @param sku item Sku
    /// @param offer the price you pay
    function purchaseItem(uint256 sku, uint256 offer)
        public
        returns (bool)
    {
        /// Use call.value to invoke `eventTickets.buyItem(sku)` with msg.sender
        /// set to the address of this proxy and value is set to `offer`
        (bool success, bytes memory returnedData) = address(eventTickets).call.value(offer)(abi.encodeWithSignature("buyItem(uint256)", sku));
        return returnedData;
    }

    /// @notice Ship an item
    /// @param sku item Sku
    function shipItem(uint256 sku)
        public
        returns (bool)
    {
        /// invoke `eventTickets.shipItem(sku)` with msg.sender set to the address of this proxy
        (bool success, ) = address(eventTickets).call(abi.encodeWithSignature("shipItem(uint256)", sku));
        return success;
    }

    /// @notice Receive an item
    /// @param sku item Sku
    function receiveItem(uint256 sku)
        public
        returns (bool)
    {
        /// invoke `receiveChain.shipItem(sku)` with msg.sender set to the address of this proxy
        (bool success, ) = address(eventTickets).call(abi.encodeWithSignature("receiveItem(uint256)", sku));
        return success;
    }
    */
}