pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <0.7.0;

import "./Transaction.sol";
import "./CarReturning.sol";
import "./RentalCompleting.sol";

contract InvoicePaying is Transaction {
    
    CarReturning carReturning;
    RentalCompleting rentalCompleting;
    
    constructor(address _carReturning) public{
        initiator = tx.origin; //client
        executor = 0x87483BD38209d8fc0E244f9BF63E4141b300676F; //rentACar
        
        carReturning = CarReturning(_carReturning);
    }
    function requestInvoicePaying() public
             atCFact(C_facts.Inital)
             onlyBy(executor){
                 c_fact = C_facts.Requested;
             }
    
    function promiseInvoicePaying() public
             atCFact(C_facts.Requested)
             onlyBy(initiator){
                 c_fact = C_facts.Promissed;
             }
    
    function declineInvoicePaying() public
             atCFact(C_facts.Requested)
             onlyBy(initiator){
                 
                 c_fact = C_facts.Inital;
             }
             
    function declareInvoicePaying() public
             atCFact(C_facts.Promissed)
             onlyBy(initiator)
             p_act(){
               
                
                
                c_fact = C_facts.Declared; 
             }
             
    function acceptInvoicePaying() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             returns (address)
             {
                 
                 rentalCompleting = carReturning.carTaking().depositPaying().rentalCompleting();
        
                 c_fact = C_facts.Accepted; 
                 
                 return address(rentalCompleting);
             }
             
    function rejectInvoicePaying() public
             atCFact(C_facts.Declared)
             onlyBy(executor){
                 
                 c_fact = C_facts.Rejected;
             }
    
}
