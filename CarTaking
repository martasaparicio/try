pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <0.7.0;

import "./Transaction.sol";
import "./DepositPaying.sol";

contract CarTaking is Transaction {
    
    DepositPaying public depositPaying;
    CarReturning public carReturning;
    
    constructor(address _depositPaying) public{
        initiator =  msg.sender; //client
        executor = 0x87483BD38209d8fc0E244f9BF63E4141b300676F; //rentACar
        
        depositPaying = DepositPaying(_depositPaying);
    }
    
    //RentalCompleting.CarGroup oi = depositPaying.getCarGroup();
    
    function requestCarTaking() public
             atCFact(C_facts.Inital)
             onlyBy(executor){
             require(depositPaying.getCarGroup().cars.length >= 1);
                 c_fact = C_facts.Requested;
             }
    
    function promiseCarTaking() public
             atCFact(C_facts.Requested)
             onlyBy(initiator){
                 c_fact = C_facts.Promissed;
             }
    
    function declineCarTaking() public
             atCFact(C_facts.Requested)
             onlyBy(initiator){
                 
                 c_fact = C_facts.Inital;
             }
             
    function declareCarTaking() public
             atCFact(C_facts.Promissed)
             onlyBy(initiator)
             p_act(){
               
                
                
                c_fact = C_facts.Declared; 
             }
             
    function acceptCarTaking() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             returns (address)
             {
                 
                 carReturning = new CarReturning(address(this));
                 
                 c_fact = C_facts.Accepted; 
                 
                 return address(carReturning);
             }
             
    function rejectCarTaking() public
             atCFact(C_facts.Declared)
             onlyBy(executor){
                 
                 c_fact = C_facts.Rejected;
             }
}
