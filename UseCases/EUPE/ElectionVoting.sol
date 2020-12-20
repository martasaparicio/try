pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <0.7.0;

import "./Transaction.sol";
import "./ElectionVoteCompleting.sol";
import "./ElectionVoteCount.sol";

contract ElectionVoting is Transaction {
    
    ElectionVoteCompleting electionVoteCompleting;

    constructor(address _electionVoteCompleting) public{
        
        electionVoteCompleting = ElectionVoteCompleting(_electionVoteCompleting);
        initiator = electionVoteCompleting.executor();                             
        executor = electionVoteCompleting.initiator(); 
    }
    
    function requestElectionVoting() public
             atCFact(C_facts.Inital)
             onlyBy(executor)
             transitionNext(true){

             }
    
    function promiseElectionVoting() public
             atCFact(C_facts.Requested)
             onlyBy(initiator)
             transitionNext(true){

                 
             }
    
    function declineElectionVoting() public
             atCFact(C_facts.Requested)
             onlyBy(initiator)
             transitionNext(false){
                 
             }
             
    function declareElectionVoting(uint256 countryId, address[] memory votingchoices) public payable
             atCFact(C_facts.Promissed)
             onlyBy(initiator)
             p_act()
             transitionNext(true){
              	require(votingchoices.length > 0, "At least one cadidate must be chosen");
    	          CountryElections storage country = countries[countryId];
    	          require(now > country.electionBeginDate, "Voting is currently not allowed");
    	          if (country.votingSystem == VotingSystem.ClosedList) {
                  require(votingChoices.length == 1, "Only a party vote is allowed");
                  PoliticalParty storage party = politicalParties[votingChoices[0]];
                  require(party.id != address(0), "Party address is invalid");
                  require(party.countryId == countryId); }
                else if (country.votingSystem == VotingSystem.OpenList) {
                  address firstCandidateParty;
                  bool first = true;
                  for (uint i = 0; i<votingChoices.length; i++){
                    require(candidates[votingChoices[i]].approved==true, "Candidate address is invalid");
                    address currCandidateParty = candidates[votingChoices[i]].partyId;
                    if(first) {
                      firstCandidateParty = currCandidateParty;
                      require(politicalParties[firstCandidateParty].countryId == countryId);
                      first = false; 
                    }
                    else {
                      require(currCandidateParty == firstCandidateParty, "Candidates must be from the same party"); 
                    } 
                   } 
                }
                else if (country.votingSystem == VotingSystem.SingleTransferable) {
                  for (uint i = 0; i<votingChoices.length; i++){
                    Candidate storage candidate = candidates[votingChoices[i]];
                      require(candidate.approved == true, "Candidate address is invalid");
                      require(politicalParties[candidate.partyId].countryId == countryId); 
                   }
                }
                votingToken.transfer(msg.sender, address(this));
                if (country.votingSystem == VotingSystem.ClosedList){
                  PoliticalParty storage party = politicalParties[votingchoices[0]];
                  party.voteCount += 1; 
                }
                else{
                  for(uint i = 0; i<votingchoices.length; i++){
                    Candidate storage candidate = candidates[votingchoices[i]];
                    candidate.voteCount += 1; 
                   } 
                }
                
             }
             
    function acceptElectionVoting() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             transitionNext(true)
             returns (address){
                               
                 ElectionVoteCounting electionVoteCounting = new ElectionVoteCounting(address(electionVoteCompleting), address(this));
                 
                 return address(electionVoteCounting);
             }
             
    function rejectElectionVoting() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             transitionNext(false){
                 
             }
}
