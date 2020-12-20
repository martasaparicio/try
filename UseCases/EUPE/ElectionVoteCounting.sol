pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <0.7.0;

import "./Transaction.sol";
import "./ElectionVoteCompleting.sol";
import "./ElectionVoting.sol";

contract ElectionVoteCounting is Transaction {
    
    ElectionVoteCompleting electionVoteCompleting;
    ElectionVoting electionVoting;
    
    constructor(address _electionVoteCompleting, address _electionVoting) public{
        electionVoteCompleting = ElectionVoteCompleting(_rentalCompleting);
        electionVoting = ElectionVoting(_electionVoting);
        initiator = electionVoteCompleting.executor(); //client
        executor = electionVoteCompleting.initiator(); //rentACar
    }

     uint256 da_voteCount;
    function requestElectionVoteCounting() public
             atCFact(C_facts.Inital)
             onlyBy(executor)
             transitionNext(true){
             
             }
    
    function promiseElectionVoteCounting() public
             atCFact(C_facts.Requested)
             onlyBy(initiator)
             transitionNext(true){
             }
    
    function declineElectionVoteCounting() public
             atCFact(C_facts.Requested)
             onlyBy(initiator)
             transitionNext(false){
                 
             }
             
    function declareElectionVoteCounting(address partyAddress, address[] memory candidateAddresses) public payable
             atCFact(C_facts.Promissed)
             onlyBy(initiator)
             p_act()
             transitionNext(true){
             if (country.votingSystem == VotingSystem.ClosedList){
                PoliticalParty storage party = politicalParties[partyAddress];
                da_voteCount = party.voteCount; 
             }
            else{
              for(uint i = 0; i<candidateAddresses.length; i++){
                Candidate storage candidate = candidates[candidateAddresses[i]];
                da_voteCount =candidate.voteCount;
               } 
             }
           }
             
    function acceptElectionVoteCounting() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             transitionNext(true)
             returns (address)
             {
                return address(electionVoteCompleting);
             }
             
    function rejectElectionVoteCounting() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             transitionNext(false){
                 
             }
    
}
