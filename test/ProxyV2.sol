pragma solidity >= 0.5.0 < 0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/EventTicketsV2.sol";


/// @title Simulate Roles for testing scenarios
/// @notice Use this Contract to simulate various roles in tests
/// @dev A Proxy can fulfill a Buyer, Seller or random agent
contract ProxyV2 {

    /// the proxied EventTickets contract
    EventTicketsV2 public eventTickets;

    /// @notice Create a proxy
    /// @param _target the EventTickets to interact with
    constructor(EventTicketsV2 _target) public { eventTickets = _target; }

    /// Allow contract to receive ether
    function() external payable {}

    /// @notice Retrieve eventTickets contract
    /// @return the eventTickets contract
    function getTarget()
        public view
        returns (EventTicketsV2)
    {
        return eventTickets;
    }

    function buyTickets(uint eventId, uint value, uint ticketsNumber) public payable returns (bool){
        (bool success, ) = 
            address(eventTickets).call.value(value)(abi.encodeWithSignature("buyTickets(uint256,uint256)", eventId, ticketsNumber));
        return success;
    }

    function getRefund(uint eventId) public returns (bool) {
        (bool success, ) = address(eventTickets).call(abi.encodeWithSignature("getRefund(uint256)", eventId));
        return success;
    }

    function getBuyerNumberTickets(uint eventId) public returns (bool, uint){
        (bool success, bytes memory returnedData) = address(eventTickets).call(abi.encodeWithSignature("getBuyerNumberTickets(uint256)", eventId));

        (uint ticketsBought) = abi.decode(returnedData, (uint));
        return (success, ticketsBought);
    }
}