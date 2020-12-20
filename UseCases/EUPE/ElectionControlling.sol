pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <0.7.0;

import "./Transaction.sol";
import "./ElectionCompleting.sol";
import "./PoliticalPartyRegistering.sol";
import "./CandidateRegistering.sol";
import "./ElectionVoteCompleting.sol";
import "./ElectionVoting.sol";
import "./ElectionVoteCounting.sol";
import "./SeatAssigning.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.1.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.1.0/contracts/token/ERC721/ERC721.sol";


contract VotingToken is Ownable, ERC721{ 
	constructor(string memory name, string memory symbol) ERC721(name, symbol) Ownable() public payable{
	}

	function mint(address receiver) onlyOwner public {
		_safeMint(receiver, uint256(receiver));
	}

	function transfer(address from, address to) onlyOwner public {
		_transfer(from, to, uint256(from));
	}

 }
 
 contract ElectionControlling is Transaction{
    
    constructor() public{
        initiator = 0x588086ae79BD939160A73B939aB2CcDD366bE76B; 
        executor = msg.sender;
        
        votingToken = new VotingToken("VotingToken","VOTE");

    }
    
    function requestElectionControlling() public
             atCFact(C_facts.Inital)
             onlyBy(executor)
             transitionNext(true){
                
            }
             
    function promiseElectionControlling() public
             atCFact(C_facts.Requested)
             onlyBy(initiator)
             transitionNext(true)
             returns (address){
             
             ElectionCompleting electionCompleting = new ElectionCompleting(address(this));

             return address(electionCompleting);
                
             }
    
    function declineElectionControlling() public
             atCFact(C_facts.Requested)
             onlyBy(initiator)
             transitionNext(false){
                 
             }

    function declareElectionControlling(address _invoicePaying) public
             atCFact(C_facts.Promissed)
             onlyBy(initiator)
             p_act()
             transitionNext(true){
                                 
             }
             
    function acceptElectionControlling() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             transitionNext(true){
                  
             }
             
    function rejectElectionControlling() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             transitionNext(false){
                 
             }
}
