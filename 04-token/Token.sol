// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.4 < 0.7.0;
pragma experimental ABIEncoderV2;

import "./SafeMath.sol";

interface IERC20{
    // Cantidad total de tokens existentes
    function totalSupply() external view returns (uint256);
    
    // Balance de una direccion
    function balanceOf(address owner) external view returns(uint256);

    // Cantidad de tokens que el spender podra gastar del owner
    function allowance(address owner, address delegate) external view returns(uint256);

    // Se puede realizar la transferencia?
    function transfer(address receiver, uint256 amount) external returns(bool);

    // Resultado de la operacion de gasto
    function approve(address delegate, uint256 amount) external returns(bool);

    // Resultado de transferencia de una catidad usando el metodo allowance()
    function transferFrom(address sender, address receiver, uint256 amount) external returns(bool);

    // Evento que se emitira cuando se realice una transferencia
    event Transfer(address indexed from, address indexed to, uint256 amount);

    // Evento que se emitira cuando se establece una asignacion con el metodo allowance()
    event Approval(address indexed owner, address indexed receiver, uint256 value);
}

contract Token is IERC20 {
    string public constant name = "ERC20 Token Z";
    string public constant symbol = "ZTKN";
    uint8 public constant decimals = 2; // Importante al desplegar el contrato hay que añadir este numero de 0

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed receiver, uint256 amount);

    using SafeMath for uint256;

    mapping (address => uint) balances;
    mapping (address => mapping(address => uint)) allowed;
    uint256 totalSupply_;

    constructor (uint256 inialSupply) public {
        totalSupply_ = inialSupply;
        balances[msg.sender] = totalSupply_;
    }

    function totalSupply() public override view returns (uint256){
        return totalSupply_;
    }

    function increaseTotalSupply(uint newTokensAmount) public {
        totalSupply_ += newTokensAmount;
        balances[msg.sender] += newTokensAmount;
    }

    function balanceOf(address owner) public override view returns(uint256){
        return balances[owner];
    }

    function allowance(address owner, address delegate) public override view returns(uint256){
        return allowed[owner][delegate];
    }

    function transfer(address receiver, uint256 amount) public override returns(bool){
        require(amount <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(amount);
        balances[receiver] = balances[receiver].add(amount);

        emit Transfer(msg.sender, receiver, amount);

        return true;
    }

    function approve(address delegate, uint256 amount) public override returns(bool){
        allowed[msg.sender][delegate] = amount;

        emit Approval(msg.sender, delegate, amount);

        return true;
    }

    function transferFrom(address owner, address receiver, uint256 amount) public override returns(bool){
        require(amount <= balances[owner]);
        require(amount <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(amount);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(amount);
        balances[receiver] = balances[receiver].add(amount);

        emit Transfer(owner, receiver, amount);

        return true;
    }
}