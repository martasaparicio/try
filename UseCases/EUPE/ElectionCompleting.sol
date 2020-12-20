pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <0.7.0;

import "./Transaction.sol";
import "./ElectionControlling.sol";
import "./PoliticalPartyRegistering.sol";

contract ElectionCompleting is Transaction {

uint256 approveCandidatesCounter; 
    
    VotingToken votingToken;
    
    uint candidateApprovalEnd;

	  uint candidateRegistrationEnd;

	  uint partyRegistrationEnd;

	  uint startDate;

	  mapping (address => Candidate) candidates;
	  address[] candidatesKeys;

	  mapping (address => PoliticalParty) politicalParties;
	  address[] politicalPartiesKeys;

	  CountryElections[] countries;

	  enum VotingSystem{
		  ClosedList,
		  OpenList,
		  SingleTransferable
	  }

	  struct CountryElections{
		  uint256 id;
		  string countryName;
		  uint electionBeginDate;
		  uint electionEndDate;
		  address[] voters;
		  VotingSystem votingSystem;
		  int availableSeats;
		  uint8 electoralTreshold;
		  uint8 minimumAge;
	  }

	  struct PoliticalParty{
		  address id;
		  string name;
		  string code;
		  string website;
		  int voteCount;
		  int allocatedSeats;
		  uint256 countryId;
	  }

	  struct Candidate{
		  address id;
		  string name;
		  string website;
		  int voteCount;
		  bool hasSeat;
		  bool approved;
		  address partyId;
	  }

    ElectionControlling electionControlling;
    
    constructor(address _electionControlling) public{
        
        electionControlling = ElectionControlling(_electionControlling);
        initiator = electionControlling.executor();                            
        executor = electionControlling.initiator(); 
	
	candidateApprovalEnd = 9598986017;
	candidateRegistrationEnd = 9598986017;
	partyRegistrationEnd = 9598986017;
	    
	CountryElections memory czechElections = CountryElections(0,"Czech Republic", 9598986017, 959994017, new address[](0), VotingSystem.OpenList, 10, 20, 18);
        countries.push(czechElections);
        CountryElections memory germanElections = CountryElections(1,"Germany", 9598986017, 959994017, new address[](0), VotingSystem.ClosedList, 20, 40, 18);
        countries.push(germanElections);
    }
    
    function requestElectionCompleting() public
             atCFact(C_facts.Inital)
             onlyBy(executor)
             transitionNext(true){
             
             }
    
    function promiseElectionCompleting() public
             atCFact(C_facts.Requested)
             onlyBy(initiator)
             transitionNext(true){
             PoliticalPartyRegistering politicalPartyRegistering = new PoliticalPartyRegistering(address(this));
             return address(politicalPartyRegistering)                 
             }
    
    function declineElectionCompleting() public
             atCFact(C_facts.Requested)
             onlyBy(initiator)
             transitionNext(false){
                 
             }
             
    function declareElectionCompleting(address _seatAssigning) public payable
             atCFact(C_facts.Promissed)
             onlyBy(initiator)
             p_act()
             transitionNext(true){
                SeatAssigning seatAssigning = SeatAssigning(_seatAssigning);
                require(seatAssigning.c_fact() == C_facts.Accepted);
             }
             
    function acceptElectionCompleting() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             transitionNext(true)
             returns (address){

             }
             
    function rejectElectionCompleting() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             transitionNext(false){
                 
             }
}
