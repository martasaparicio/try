pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <0.7.0;

import "./Transaction.sol";
import "./DepositPaying.sol";
import "./CarTaking.sol";
import "./CarReturning.sol";
import "./InvoicePaying.sol";

contract RentalCompleting is Transaction{
    
    struct Rental {
        uint256 stratingDate;
        uint256 endingDate;
        uint256 maxRentalDuration;
        uint256 drivingLicenseExpirationDay;
        
        uint256 depositAmount;
        string car;
        uint256 invoiceAmount;
        
        CarGroup carGroup;
    }
    
    struct CarGroup {
        string[] freeCars;
        uint256 standardDepositAmount;
        uint256 dailyRentalRate;
    }
     
    Rental public rental;
    
    constructor() public{
        initiator = 0x588086ae79BD939160A73B939aB2CcDD366bE76B; //rentACar
        executor = msg.sender; //client
        
        rental.maxRentalDuration = 10000000; //10dias
        rental.depositAmount=0;
        rental.invoiceAmount=0;
        rental.car = '';
        rental.carGroup.dailyRentalRate = 10 wei;
        rental.carGroup.standardDepositAmount = 10 wei;
        rental.carGroup.freeCars = ['PG0870','7293FQ','2533XQ'];
    }
    
    function requestRentalCompleting(uint256 _startingDate, uint256 _endingDate, uint256 _drivingLicenseExpirationDay) public
             atCFact(C_facts.Inital)
             onlyBy(executor)
             transitionNext(true){
                
                 require(_endingDate >= _startingDate);
                 require((_endingDate - _startingDate) <= rental.maxRentalDuration);
                 require(_drivingLicenseExpirationDay >= _endingDate);
                 rental.stratingDate = _startingDate;
                 rental.endingDate = _endingDate;
                 rental.drivingLicenseExpirationDay = _drivingLicenseExpirationDay;
                 
            }
             
    function promiseRentalCompleting() public
             atCFact(C_facts.Requested)
             onlyBy(initiator)
             transitionNext(true)
             returns (address){
                 //while não tem de ser representado acho o seu trabalho e feito pelo stateMachine common pattern
                 //implementei os While com requires pq fica mais à la solidity mas não sei se é correto...
                 rental.car=rental.carGroup.freeCars[0];
                 DepositPaying depositPaying = new DepositPaying(address(this));

                 return address(depositPaying);
             }
    
    function declineRentalCompleting() public
             atCFact(C_facts.Requested)
             onlyBy(initiator)
             transitionNext(false){
                 
             }

    function declareRentalCompleting(address _invoicePaying) public
             atCFact(C_facts.Promissed)
             onlyBy(initiator)
             p_act()
             transitionNext(true){
                 
                 InvoicePaying invoicePaying = InvoicePaying(_invoicePaying);
                 require(invoicePaying.c_fact() == C_facts.Accepted);
                 
             }
             
    function acceptRentalCompleting() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             transitionNext(true){
                  
             }
             
    function rejectRentalCompleting() public
             atCFact(C_facts.Declared)
             onlyBy(executor)
             transitionNext(false){
                 
             }
}
