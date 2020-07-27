pragma solidity >=0.4.22 <0.7.0;

contract Transaction {
    
    enum C_facts {
        Inital,
        Requested,
        Promissed, 
        Declined,
        Declared, 
        Accepted,
        Rejected
    }
    
    C_facts public c_fact = C_facts.Inital;
    
    address payable public initiator;
    address payable public  executor;
    
    event p_fact(address _from, bytes32 _hash);
    
    modifier p_act(){
        bytes32 hash = keccak256(abi.encodePacked(now, block.difficulty, msg.sender)); 
        emit p_fact(msg.sender, hash);
        _;
    }
    
    //ensures that the function can only be called at a certain C_fact
    modifier atCFact(C_facts _c_fact) {
        require(
            c_fact == _c_fact,
            "Function cannot be called at this time."
        );
        _;
    }
    //address public owner = msg.sender;
    modifier onlyBy(address _account) {
        require(
            msg.sender == _account,
            "Sender not authorized."
        );
        _;
    }
}
