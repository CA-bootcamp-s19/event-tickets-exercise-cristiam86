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

    function buyTickets(uint value, uint ticketsNumber) public payable returns (bool, uint){
        (bool success, bytes memory returnedData) =
            address(eventTickets).call.value(value)(abi.encodeWithSignature("buyTickets(uint256)", ticketsNumber));

        // Convert `returnedData` using `abi.decode`
        //
        // See https://solidity.readthedocs.io/en/v0.5.3/units-and-global-variables.html#abi-encoding-and-decoding-functions
        //
        (uint ticketsBought) = abi.decode(returnedData, (uint));
        return (success, ticketsBought);
    }

    function getRefund() public returns (bool) {
        (bool success, ) = address(eventTickets).call(abi.encodeWithSignature("getRefund()"));
        return success;
    }
}