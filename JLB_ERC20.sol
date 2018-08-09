pragma solidity ^0.4.24;

library SafeMath {
    
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        if (_a == 0) {
          return 0;
        }
        c = _a * _b;
        assert(c / _a == _b);
        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return _a / _b;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        assert(_b <= _a);
        return _a - _b;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        c = _a + _b;
        assert(c >= _a);
        return c;
    }
}


contract Owned {
    address public owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
    
}


contract JKToken is Owned {
    
    using SafeMath for uint;
    
    string public name = "jiulian";
    string public symbol = "JLB";
    uint8 public decimals = 18;
    uint public totalSupply;
    
    mapping(address => uint) public balanceOf;
    mapping(address => uint) public frozenOf;
    mapping(address => mapping(address => uint)) public allowance;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed from, address indexed to, uint value);
    event Burn(address indexed from, uint value);
    event FrozenFunds(address indexed target,uint frozen);
    event unFreezeFunds(address indexed target, uint amount);
    
    constructor(uint initialSupply) public {
        totalSupply = initialSupply * 10 ** uint(decimals);
        balanceOf[msg.sender] = totalSupply;
    }
    
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != address(0));
        require(_value > 0);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        
        emit Transfer(_from,_to,_value);
    }
    
    function transfer(address _to, uint _value) public returns (bool success) {
        _transfer(msg.sender,_to,_value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from,_to,_value);
        return true;
    }
    
    function approval(address _spender,uint _amount) public returns(bool success) {
        allowance[msg.sender][_spender] = _amount;
        emit Approval(msg.sender,_spender,_amount);
        return true;
    }

    function burn(uint _value) public returns (bool success) {

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
        return true;
    }
    
    function burnFrom(address _from,uint _value) public returns(bool success) {
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        balanceOf[_from] = balanceOf[_from].sub(_value); 
        totalSupply = totalSupply.sub(_value);
        emit Burn(_from,_value);
        
        return true;
    }
    
    function mintToken(address target,uint mintedAmount) public onlyOwner returns (bool success) {
        balanceOf[target] = balanceOf[target].add(mintedAmount);
        totalSupply = totalSupply.add(mintedAmount);
        
        emit Transfer(0,this,mintedAmount);
        emit Transfer(this,target,mintedAmount);
        return true;
    }
    
    function freeze(address target, uint amount ) public onlyOwner returns (bool success) {
        require(amount <= 2**256 - 1);
        frozenOf[target] = amount;
        /*balanceOf[target] = balanceOf[target].sub(amount);
        frozenOf[target] = frozenOf[target].add(amount);*/
        emit FrozenFunds(target,amount);
        return true;
    }
    
    function unFreezeOf(address target, uint amount) public onlyOwner returns (bool success) {
        frozenOf[target] = frozenOf[target].sub(amount);
        balanceOf[target] = balanceOf[target].add(amount);
        
        emit unFreezeFunds(target,amount);
        return true;
    }
}