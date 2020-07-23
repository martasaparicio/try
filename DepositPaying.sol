pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <0.7.0;

import "./Transaction.sol";
import "./RentalCompleting.sol";

contract DepositPaying is Transaction {
    
    RentalCompleting rentalCompleting;

    constructor(address _rentalCompleting) public{
        initiator =  msg.sender; //client
        executor = 0x23ED60DEc9490AEBA10f9C36ED25Ae62FF0Ea216; //rentACar
        
        rentalCompleting = RentalCompleting(_rentalCompleting);
    }
    function getCarGroup() view public returns (RentalCompleting.CarGroup memory){
        return rentalCompleting.returnsCarGroup(address(this));
    }
     function getRental() view public returns (RentalCompleting.Rental memory){
        return rentalCompleting.returnsRental(address(this));
    }
    //RentalCompleting.CarGroup  cg = rentalCompleting.returnsCarGroup(address(this));
    //RentalCompleting.Rental r = rentalCompleting.returnsRental(address(this));
    
    function requestDepositPaying() public
             atCFact(C_facts.Inital)
             onlyBy(executor){
             //require(cg.standardDepositAmount == 100);
                 c_fact = C_facts.Requested;
             }
    
    function promiseRentalCompleting() public
             atCFact(C_facts.Requested)
             onlyBy(initiator){
                 c_fact = C_facts.Promissed;
             }
    
    function declineRentalCompleting() public
             atCFact(C_facts.Requested)
             onlyBy(initiator){
                 
                 c_fact = C_facts.Inital;
             }
             
    function declareRentalCompleting() payable public
             atCFact(C_facts.Promissed)
             onlyBy(initiator)
             p_act(){
                //require(RentalCompleting.rental.depositAmount == msg.value); 
                
                c_fact = C_facts.Declared; 
             }
             
    function acceptRentalCompleting() public
             atCFact(C_facts.Declared)
             onlyBy(executor){
                 
                 c_fact = C_facts.Accepted; 
             }
             
    function rejectRentalCompleting() public
             atCFact(C_facts.Declared)
             onlyBy(executor){
                 
                 c_fact = C_facts.Rejected;
             }
}
