pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <0.7.0;

import "./Transaction.sol";
import "./CarReturning.sol";
import "./RentalCompleting.sol";

contract InvoicePaying is Transaction {
    
    RentalCompleting rentalCompleting;
    CarReturning carReturning;
    
    constructor(address _rentalCompleting, address _carReturning) public{
        rentalCompleting = RentalCompleting(_rentalCompleting);
        carReturning = CarReturning(_carReturning);
        initiator = rentalCompleting.executor(); //client
        executor = rentalCompleting.initiator(); //rentACar
    }
    
    uint256 pm_invoiceAmount;
    uint256 da_invoiceAmount;
    function requestInvoicePaying(uint256 _invoiceAmount) public
             atCFact(C_facts.Inital)
             onlyBy(executor){
                 (uint256 startingDay, uint256 endingDay , , , , , , RentalCompleting.CarGroup memory carGroup) = rentalCompleting.rental();
                 uint256 baseCharge = (endingDay - startingDay)*carGroup.dailyRentalRate;
                 uint256 rentalCharge = baseCharge - carGroup.standardDepositAmount;
                 require(_invoiceAmount == rentalCharge);
                 c_fact = C_facts.Requested;
             }
    
    function promiseInvoicePaying(uint256 _pm_invoiceAmount) public
             atCFact(C_facts.Requested)
             onlyBy(initiator){
                 pm_invoiceAmount = _pm_invoiceAmount;
                 c_fact = C_facts.Promissed;
             }
    
    function declineInvoicePaying() public
             atCFact(C_facts.Requested)
             onlyBy(initiator){
                 
                 c_fact = C_facts.Inital;
             }
             
    function declareInvoicePaying() public payable
             atCFact(C_facts.Promissed)
             onlyBy(initiator)
             p_act(){
                (uint256 startingDay, uint256 endingDay , , , , , , RentalCompleting.CarGroup memory carGroup) = rentalCompleting.rental();
                uint256 baseCharge = (endingDay - startingDay)*carGroup.dailyRentalRate;
                uint256 rentalCharge = baseCharge - carGroup.standardDepositAmount;
                require(msg.value >= rentalCharge);
                executor.transfer(rentalCharge);
                da_invoiceAmount = rentalCharge;
                c_fact = C_facts.Declared; 
             }
             
    function acceptInvoicePaying() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             returns (address)
             {
                 require(da_invoiceAmount == pm_invoiceAmount);
                 //rentalCompleting = address(rentalCompleting);
        
                 c_fact = C_facts.Accepted; 
                 
                 return address(rentalCompleting);
             }
             
    function rejectInvoicePaying() public
             atCFact(C_facts.Declared)
             onlyBy(executor){
                 
                 c_fact = C_facts.Rejected;
             }
    
}
