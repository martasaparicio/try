pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <0.7.0;

import "./Transaction.sol";
import "./CarTaking.sol";
import "./CarReturning.sol";
import "./DepositPaying.sol";
import "./InvoicePaying.sol";

contract RentalCompleting is Transaction{
    
    struct Rental {
        uint256 stratingDate;
        uint256 endingDate;
        string pickUpLocation;
        string returnLocation;
        uint256 drivingLicenseExpirationDay;       //not sure
        uint256 depositAmount;
        CarGroup carGroup;
    }
    
    struct CarGroup {
        uint256 maxRentalDuration;
        uint256 dailyRentalRate;
        uint256 standardDepositAmount;
        uint256 locationFineRate;
        uint256 lateReturnFineRate;
        uint256[] cars;
    }
    
    Rental public rental;
    CarGroup public carGroup; 
    
    constructor() public{
        initiator = 0xf57596949E8ee597e4D1464706a49CD71FB25AdF; //rentACar
        executor = msg.sender; //client
        
        carGroup.maxRentalDuration = 10000000; //10000000 = 10 dias como solidity não implementa Date do JS datas tem de ser feitas num contrato à parte
        carGroup.dailyRentalRate = 35;
        carGroup.standardDepositAmount = 35;
        carGroup.locationFineRate = 40;
        carGroup.lateReturnFineRate = 40;
        carGroup.cars = [1,2,3,4];
    }
    
   
    DepositPaying public depositPaying;
    InvoicePaying public invoicePaying;
    
    function returnsCarGroup(address _address) public  view returns (CarGroup memory){
        return CarGroup(carGroup.maxRentalDuration, carGroup.dailyRentalRate, carGroup.standardDepositAmount, carGroup.locationFineRate, carGroup.lateReturnFineRate, carGroup.cars);
    }
    function returnsRental(address _address) public view returns (Rental memory){
        return Rental(rental.stratingDate, rental.endingDate, rental.pickUpLocation, rental.returnLocation, rental.depositAmount, rental.drivingLicenseExpirationDay, rental.carGroup);
    }
    
    function requestRentalCompleting(uint256 _startingDate, uint256 _endingDate, string memory _fromBranch, string memory _toBranch, uint256 _depositAmount, uint256 _drivingLicenseExpirationDay) public
             atCFact(C_facts.Inital)
             onlyBy(executor){
                
                 require(_endingDate >= _startingDate);
                 require((_endingDate - _startingDate) <= carGroup.maxRentalDuration);
                 require(_drivingLicenseExpirationDay >= _endingDate);
                 rental.stratingDate = _startingDate;
                 rental.endingDate = _endingDate;
                 rental.pickUpLocation = _fromBranch;
                 rental.returnLocation = _toBranch;
                 rental.depositAmount = _depositAmount;
                 rental.drivingLicenseExpirationDay = _drivingLicenseExpirationDay;
                 rental.carGroup = carGroup;
                 
                 
                 
                 c_fact = C_facts.Requested;
                 
            }
             
    function promiseRentalCompleting() public
             atCFact(C_facts.Requested)
             onlyBy(initiator)
             returns (address){
                 //while não tem de ser representado acho o seu trabalho e feito pelo stateMachine common pattern!!!!!!
                 //require(depositPaying.c_fact() == C_facts.Accepted); 
                 //implementei os While com requires pq fica mais à la solidity mas não sei se é correto...
                 //require(carTarking.c_fact() == C_facts.Accepted);
                 //require(carReturning.c_fact() == C_facts.Accepted);
                 //require(invoicePaying.c_fact() == C_facts.Accepted);
                 
                 depositPaying = new DepositPaying(address(this));
                 
                 c_fact = C_facts.Promissed;
                 
                 return address(depositPaying);
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
                 
                 
                 
                c_fact = C_facts.Declared; 
             }
             
    function acceptRentalCompleting() public
             atCFact(C_facts.Declared)
             onlyBy(executor){
                 
                 c_fact = C_facts.Accepted; 
             }
             
    function rejectRentalCompleting() public
             atCFact(C_facts.Declared)
             onlyBy(executor){
                 
                 c_fact = C_facts.Rejected;
             }
}
