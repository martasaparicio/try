pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <0.7.0;

import "./Transaction.sol";
import "./RentalCompleting.sol";
import "./CarTaking.sol";

contract DepositPaying is Transaction {
    
    RentalCompleting rentalCompleting;
    //CarTaking public carTarking;

    constructor(address _rentalCompleting) public{
        
        rentalCompleting = RentalCompleting(_rentalCompleting);
        initiator = rentalCompleting.executor(); //client   msg.sender                            
        executor = rentalCompleting.initiator(); //rentACar
    }
    
    //function getRental() view public returns (RentalCompleting.Rental memory){
    //    return rentalCompleting.returnsRental(address(this));
    //}
    
    uint256 pm_depositAmount;
    uint256 da_depositAmount;
    
    function requestDepositPaying(uint256 _rq_depositAmount) public
             atCFact(C_facts.Inital)
             onlyBy(executor){
                 ( , , , , , , , RentalCompleting.CarGroup memory carGroup) = rentalCompleting.rental();
                 require(_rq_depositAmount == carGroup.standardDepositAmount);
                 c_fact = C_facts.Requested;
             }
    
    function promiseDepositPaying(uint256 _pm_depositAmount) public
             atCFact(C_facts.Requested)
             onlyBy(initiator){
                 pm_depositAmount = _pm_depositAmount;
                 c_fact = C_facts.Promissed;
             }
    
    function declineDepositPaying() public
             atCFact(C_facts.Requested)
             onlyBy(initiator){
                 c_fact = C_facts.Inital;
             }
             
    function declareDepositPaying() public payable
             atCFact(C_facts.Promissed)
             onlyBy(initiator)
             p_act(){
                 ( , , , , , , , RentalCompleting.CarGroup memory carGroup) = rentalCompleting.rental();
                require(msg.value >= carGroup.standardDepositAmount);
                executor.transfer(carGroup.standardDepositAmount);
                da_depositAmount = carGroup.standardDepositAmount;
                c_fact = C_facts.Declared; 
             }
             
    function acceptDepositPaying() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             returns (address){
                 require(da_depositAmount == pm_depositAmount);
                 
                 //getRental().depositAmount = da_depositAmount;
                 CarTaking carTarking = new CarTaking(address(rentalCompleting), address(this));
                 
                 c_fact = C_facts.Accepted; 
                 
                 return address(carTarking);
             }
             
    function rejectDepositPaying() public
             atCFact(C_facts.Declared)
             onlyBy(executor){
                 
                 c_fact = C_facts.Rejected;
             }
}
