pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <0.7.0;

import "./Transaction.sol";
import "./RentalCompleting.sol";
//import "./CarTaking.sol";

contract DepositPaying is Transaction {
    
    RentalCompleting public rentalCompleting;
    CarTaking public carTarking;

    constructor(address _rentalCompleting) public{
        initiator = msg.sender; //client   msg.sender                            
        executor = 0xf57596949E8ee597e4D1464706a49CD71FB25AdF; //rentACar
        
        rentalCompleting = RentalCompleting(_rentalCompleting);
    }
    function getCarGroup() view public returns (RentalCompleting.CarGroup memory){
        return rentalCompleting.returnsCarGroup(address(this));
    }
    function getRental() view public returns (RentalCompleting.Rental memory){
        return rentalCompleting.returnsRental(address(this));
    }
    
    function requestDepositPaying() public
             atCFact(C_facts.Inital)
             onlyBy(executor){
             //require(getCarGroup().standardDepositAmount == getRental().depositAmount);COMO SE ACEDE
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
             
    function declareRentalCompleting() public
             atCFact(C_facts.Promissed)
             onlyBy(initiator)
             p_act(){
                require(getCarGroup().standardDepositAmount == getRental().depositAmount); //NOT SURE...
                
                c_fact = C_facts.Declared; 
             }
             
    function acceptRentalCompleting() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             returns (address){
                 
                 carTarking = new CarTaking(address(this));
                 
                 c_fact = C_facts.Accepted; 
                 
                 return address(carTarking);
             }
             
    function rejectRentalCompleting() public
             atCFact(C_facts.Declared)
             onlyBy(executor){
                 
                 c_fact = C_facts.Rejected;
             }
}
