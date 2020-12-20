pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <0.7.0;

import "./Transaction.sol";
import "./Elec.sol";
import "./CarTaking.sol";

contract PoliticalPartyRegistering is Transaction {
    
    RentalCompleting rentalCompleting;
    CarTaking carTaking;
    
    constructor(address _rentalCompleting, address _carTaking) public{
        rentalCompleting = RentalCompleting(_rentalCompleting);
        carTaking = CarTaking(_carTaking);
        initiator = rentalCompleting.executor(); //client
        executor = rentalCompleting.initiator(); //rentACar
    }
    string pm_car;
    string da_car;
    
    function requestCarReturning(string memory _rq_car) public
             atCFact(C_facts.Inital)
             onlyBy(executor)
             transitionNext(true){
                 require(keccak256(abi.encodePacked(_rq_car))==keccak256(abi.encodePacked(carTaking.ac_car())));
                 
             }
    
    function promiseCarReturning(string memory _car) public
             atCFact(C_facts.Requested)
             onlyBy(initiator)
             transitionNext(true){
                 pm_car = _car;
             }
    
    function declineCarReturning() public
             atCFact(C_facts.Requested)
             onlyBy(initiator)
             transitionNext(false){
                 
             }
             
    function declareCarReturning(string memory _car) public
             atCFact(C_facts.Promissed)
             onlyBy(initiator)
             p_act()
             transitionNext(true){
                da_car = _car;
             }
             
    function acceptCarReturning() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             transitionNext(true)
             returns (address)
             {
                 require(keccak256(abi.encodePacked(da_car))==keccak256(abi.encodePacked(pm_car)));
                 
                 InvoicePaying invoicePaying = new InvoicePaying(address(rentalCompleting), address(this));
                 
                 return address(invoicePaying);
             }
             
    function rejectCarReturning() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             transitionNext(false){
                 
             }
}
