pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <0.7.0;

import "./Transaction.sol";
import "./RentalCompleting.sol";
import "./DepositPaying.sol";
import "./CarReturning.sol";

contract CarTaking is Transaction {
    
    RentalCompleting rentalCompleting;
    DepositPaying depositPaying;
    
    constructor(address _rentalCompleting, address _depositPaying) public{
        rentalCompleting = RentalCompleting(_rentalCompleting);
        depositPaying = DepositPaying(_depositPaying);
        initiator =  rentalCompleting.executor(); //client
        executor = rentalCompleting.initiator(); //rentACar
    }
    
    string pm_car;
    string da_car;
    string public ac_car;
    
    function requestCarTaking(string memory _car) public
             atCFact(C_facts.Inital)
             onlyBy(executor)
             transitionNext(true){
                 ( , , , , , string memory car, , ) = rentalCompleting.rental();
                 require(keccak256(abi.encodePacked(_car))==keccak256(abi.encodePacked(car)));
                 
             }
    
    function promiseCarTaking(string memory _pm_car) public
             atCFact(C_facts.Requested)
             onlyBy(initiator)
             transitionNext(true){
                 pm_car = _pm_car;
             }
    
    function declineCarTaking() public
             atCFact(C_facts.Requested)
             onlyBy(initiator)
             transitionNext(false){
                 
             }
             
    function declareCarTaking(string memory _da_car) public
             atCFact(C_facts.Promissed)
             onlyBy(initiator)
             p_act()
             transitionNext(true){
                da_car = _da_car;
             }
             
    function acceptCarTaking() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             transitionNext(true)
             returns (address)
             {
                 require(keccak256(abi.encodePacked(da_car))==keccak256(abi.encodePacked(pm_car)));
                 ac_car = da_car;
                 CarReturning carReturning = new CarReturning(address(rentalCompleting),address(this));
                 
                 return address(carReturning);
             }
             
    function rejectCarTaking() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             transitionNext(false){
                 
             }
}
