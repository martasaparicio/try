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
             onlyBy(executor)
             transitionNext(true){
                 (uint256 startingDay, uint256 endingDay , , , , , , RentalCompleting.CarGroup memory carGroup) = rentalCompleting.rental();
                 uint256 baseCharge = (endingDay - startingDay)*carGroup.dailyRentalRate;
                 uint256 rentalCharge = baseCharge - carGroup.standardDepositAmount;
                 require(_invoiceAmount == rentalCharge);
             }
    
    function promiseInvoicePaying(uint256 _pm_invoiceAmount) public
             atCFact(C_facts.Requested)
             onlyBy(initiator)
             transitionNext(true){
                 pm_invoiceAmount = _pm_invoiceAmount;
             }
    
    function declineInvoicePaying() public
             atCFact(C_facts.Requested)
             onlyBy(initiator)
             transitionNext(false){
                 
             }
             
    function declareInvoicePaying() public payable
             atCFact(C_facts.Promissed)
             onlyBy(initiator)
             p_act()
             transitionNext(true){
                (uint256 startingDay, uint256 endingDay , , , , , , RentalCompleting.CarGroup memory carGroup) = rentalCompleting.rental();
                uint256 baseCharge = (endingDay - startingDay)*carGroup.dailyRentalRate;
                uint256 rentalCharge = baseCharge - carGroup.standardDepositAmount;
                require(msg.value >= rentalCharge);
                executor.transfer(rentalCharge);
                da_invoiceAmount = rentalCharge;
             }
             
    function acceptInvoicePaying() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             transitionNext(true)
             returns (address)
             {
                 require(da_invoiceAmount == pm_invoiceAmount);
                 return address(rentalCompleting);
             }
             
    function rejectInvoicePaying() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             transitionNext(false){
                 
             }
    
}
