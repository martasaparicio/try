pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <0.7.0;

import "./Transaction.sol";
import "./ElectionCompleting.sol";
import "./CandidateRegistering.sol";

contract ElectionVoteCompleting is Transaction {
    
    ElectionCompleting electionCompleting;
    CandidateRegistering candidateRegistering;
    
    constructor(address _electionCompleting, address _candidateRegistering) public{
        electionCompleting = ElectionCompleting(_electionCompleting);
        candidateRegistering = DepositPaying(_candidateRegistering);
        initiator =  electionCompleting.executor(); 
        executor = electionCompleting.initiator(); 
        
        CountryElections storage cz = countries[0];
        cz.voters.push(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
        CountryElections storage ge = countries[1];
        ge.voters.push(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2); 
    }
    
    function requestElectionVoteCompleting() public
             atCFact(C_facts.Inital)
             onlyBy(executor)
             transitionNext(true){

                 
             }
    
    function promiseElectionVoteCompleting(untryId) public
             atCFact(C_facts.Requested)
             onlyBy(initiator)
             transitionNext(true)
             returns (address){
                CountryElections storage country = countries[countryId];
                for (uint256 i = 0; i < country.voters.length; i++) {
                    votingToken.mint(country.voters[i]);
                }
                ElectionVoteCounting electionVoteCounting = new ElectionVoteCounting(address(this));
             return address(electionVoteCounting);
             }
    
    function declineElectionVoteCompleting() public
             atCFact(C_facts.Requested)
             onlyBy(initiator)
             transitionNext(false){
                 
             }
             
    function declareElectionVoteCompleting(address _electionVoteCounting) public
             atCFact(C_facts.Promissed)
             onlyBy(initiator)
             p_act()
             transitionNext(true){
             
             ElectionVoteCounting electionVoteCounting = ElectionVoteCounting(_electionVoteCounting);
             require(electionVoteCounting.c_fact() == C_facts.Accepted);

             }
             
    function acceptElectionVoteCompleting() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             transitionNext(true)
             returns (address)
             {
                SeatAssigning seatAssigning = new SeatAssigning(address(electionCompleting), address(this));
                return address(seatAssigning);
             }
             
    function rejectElectionVoteCompleting() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             transitionNext(false){
                 
             }
}
