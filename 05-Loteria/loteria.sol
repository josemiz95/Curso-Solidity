// SPDX-License-Identifier: MIT
pragma solidity >0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./token.sol";

contract loteria {
    Token private token;

    address public owner;
    address public contrato;

    uint public tokens_creados = 10000;

    constructor() public{
        token = new Token(tokens_creados);
        owner = msg.sender;
        contrato = address(this);
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "No tienes permisos");
        _;
    }

    function PrecioToken(uint _numTokens) internal pure returns(uint){
        return _numTokens * (0.002 ether);
    }

    function GeneraTokens(uint _amount) public onlyOwner{
        token.increaseTotalSupply(_amount);
    }

    function ComprarTokens(uint _amount) public payable {
        uint coste = PrecioToken(_amount);
        require(msg.value >= coste, "Compra menos tokens");
        uint returnValue = msg.value - coste;
        msg.sender.transfer(returnValue);
        uint Balance = tokensDisponibles();
        require (_amount <= Balance, "Compra un numero de tokens adecuado");
        token.transfer(msg.sender, _amount);
    }

    function tokensDisponibles() public view returns(uint) {
        return token.balanceOf(contrato); 
    }

    function BalanceBote() public view returns(uint) {
        return token.balanceOf(owner);
    }

    function MisTokens() public view returns(uint){
        return token.balanceOf(msg.sender);
    }

    /// LOTERIA

    uint public PrecioBoleto = 5;

    mapping(address => uint[]) idPersonaBoletos;
    mapping(uint => address) adnBoleto;
    // Numeros aleatorios
    uint randNonce = 0;
    // Boletos generados
    uint [] boletos_comprados;

    function CompraBoleto(uint _amount) public{
        uint precioTotal = _amount*PrecioBoleto;
        require(precioTotal <= MisTokens(), "Debes comprar mas tokens");
        token.transferTo(msg.sender, owner, precioTotal);

        // GENERAR NUMERO ALEATORIO
        for(uint i=0; i<_amount; i++){
            /*
                Se genera utilizando:
                    - Timestamp con now
                    - Direccion de msg.sender
                    - un Nonce (Numero que solo se puede usar una vez)
                Se saca un uint del has que hemos generado a partir de estos datos, y dividimos entre 10000 para coger los 4 ultimos digitos (modulo)
            */
             uint random = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % 10000;
             randNonce ++;
             idPersonaBoletos[msg.sender].push(random);
             boletos_comprados.push(random);
             adnBoleto[random] = msg.sender;
        }
    }

    function MisBoletos() public view returns (uint [] memory){
        return idPersonaBoletos[msg.sender];
    }

    function GenerarGanador() public onlyOwner{
        uint camountBoletos = boletos_comprados.length;
        require(camountBoletos > 0, "No se han vendido boletos");
        // numero aleatorio entre 0 y logitud
        uint posicionArray = uint(uint(keccak256(abi.encodePacked(now))) % camountBoletos);
        uint eleccion = boletos_comprados[posicionArray];
        address ganador = adnBoleto[eleccion];

        token.transferTo(msg.sender, ganador, BalanceBote());
    }

    function DevolverTokens (uint _amount) public payable{
        require(_amount > 0, "Necesitas devolver tokens");
        require(_amount <= MisTokens(), "No tienes suficientes tokens ");

        token.transferTo(msg.sender, contrato, _amount);

        msg.sender.transfer(PrecioToken(_amount));
    }
}