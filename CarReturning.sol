pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <0.7.0;

import "./Transaction.sol";
import "./CarTaking.sol";

contract CarReturning is Transaction {
    
    CarTaking public carTaking;
    InvoicePaying public invoicePaying;
    
    constructor(address _carTaking) public{
        initiator =  msg.sender; //client
        executor = 0x87483BD38209d8fc0E244f9BF63E4141b300676F; //rentACar
        
        carTaking = CarTaking(_carTaking);
    }
    
    //RentalCompleting.CarGroup oi = carTaking.depositPaying().getCarGroup();
    function requestCarReturning() public
             atCFact(C_facts.Inital)
             onlyBy(executor){
                 c_fact = C_facts.Requested;
             }
    
    function promiseCarReturning() public
             atCFact(C_facts.Requested)
             onlyBy(initiator){
                 c_fact = C_facts.Promissed;
             }
    
    function declineCarReturning() public
             atCFact(C_facts.Requested)
             onlyBy(initiator){
                 
                 c_fact = C_facts.Inital;
             }
             
    function declareCarReturning() public
             atCFact(C_facts.Promissed)
             onlyBy(initiator)
             p_act(){
               
                
                
                c_fact = C_facts.Declared; 
             }
             
    function acceptCarReturning() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             returns (address)
             {
                 
                 invoicePaying = new InvoicePaying(address(this));
                 
                 c_fact = C_facts.Accepted; 
                 
                 return address(invoicePaying);
             }
             
    function rejectCarReturning() public
             atCFact(C_facts.Declared)
             onlyBy(executor){
                 
                 c_fact = C_facts.Rejected;
             }
}
