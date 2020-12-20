pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <0.7.0;

import "./Transaction.sol";
import "./ElectionCompleting.sol";
import "./CandidateRegistering.sol";

contract PoliticalPartyRegistering is Transaction {
    
    ElectionCompleting electionCompleting;
    
    constructor(address _electionCompleting) public{
        electionCompleting = ElectionCompleting(_electionCompleting);
        initiator = electionCompleting.executor(); 
        executor = electionCompleting.initiator(); 
    }
    
    function requestPoliticalPartyRegistering() public
             atCFact(C_facts.Inital)
             onlyBy(executor)
             transitionNext(true){
                            
             }
    
    function promisePoliticalPartyRegistering() public
             atCFact(C_facts.Requested)
             onlyBy(initiator)
             transitionNext(true){
             
             }
    
    function declinePoliticalPartyRegistering() public
             atCFact(C_facts.Requested)
             onlyBy(initiator)
             transitionNext(false){
                 
             }
             
    function declarePoliticalPartyRegistering(string memory name, string memory code, string memory website, uint256 countryId) public
             atCFact(C_facts.Promissed)
             onlyBy(initiator)
             p_act()
             transitionNext(true){
                require(now > partyRegistrationEnd);
                require(politicalParties[msg.sender].id == address(0));
                PoliticalParty memory party = PoliticalParty({
                    id: msg.sender,
                    name: name,
                    code: code,
                    website: website,
                    voteCount: 0,
                    allocatedSeats: 0,
                    countryId: countryId
                });
                politicalParties[msg.sender] = party;
                politicalPartiesKeys.push(msg.sender);
             }
             
    function acceptPoliticalPartyRegistering() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             transitionNext(true)
             returns (address)
             {
                
                CandidateRegistering candidateRegistering = new CandidateRegistering(address(electionCompleting), address(this));
                 
                 return address(candidateRegistering);
                
             }
             
    function rejectPoliticalPartyRegistering() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             transitionNext(false){
                 
             }
}
