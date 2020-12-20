pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <0.7.0;

import "./Transaction.sol";
import "./ElectionCompleting.sol";
import "./PoliticalPartyRegistering.sol";
import "./ElectionVoteCompleting.sol";

contract CandidateRegistering is Transaction {
    
    ElectionCompleting electionCompleting;
    DepositPaying depositPaying;
    
    constructor(address _electionCompleting, address _politicalPartyRegistering) public{
        electionCompleting = ElectionCompleting(_electionCompleting);
        depositPaying = DepositPaying(_politicalPartyRegistering);
        initiator =  electionCompleting.executor(); 
        executor = electionCompleting.initiator(); 
    }
    
    string pm_car;
    string da_car;
    string public ac_car;
    
    function requestCandidateRegistering() public
             atCFact(C_facts.Inital)
             onlyBy(executor)
             transitionNext(true){
                 
             }
    
    function promiseCandidateRegistering() public
             atCFact(C_facts.Requested)
             onlyBy(initiator)
             transitionNext(true){
             }
    
    function declineCandidateRegistering() public
             atCFact(C_facts.Requested)
             onlyBy(initiator)
             transitionNext(false){
                 
             }
             
    function declareCandidateRegistering(address partyId, string memory name, string memory website) public
             atCFact(C_facts.Promissed)
             onlyBy(initiator)
             p_act()
             transitionNext(true){
                require(now > candidateRegistrationEnd);
                PoliticalParty storage party = politicalParties[partyId];
                //check whether a party exists
                require(bytes(party.name).length > 0);
                //check whether a candidate is not already registered to this address
                require(candidates[msg.sender].id == address(0));
        
                Candidate memory candidate = Candidate({
                  id: msg.sender,
                  name: name,
                  website: website, 
                  voteCount: 0, 
                  hasSeat: false,
                  approved: false,
                  partyId: party.id
                });
        
                candidatesKeys.push(msg.sender);
                candidates[msg.sender] = candidate;
             }
             
    function acceptCandidateRegistering() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             transitionNext(true)
             returns (address)
             {
                 ElectionVoteCompleting electionVoteCompleting = new ElectionVoteCompleting(address(electionCompleting),address(this));
                 
                 return address(electionVoteCompleting);
             }
             
    function rejectCandidateRegistering() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             transitionNext(false){
                 
             }
}
