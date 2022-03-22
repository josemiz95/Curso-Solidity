// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.4 < 0.7.0;
pragma experimental ABIEncoderV2;

import "./token.sol";

contract SistemaDePagos {
    Token private token; // Instancia del contrato del token
    address payable public owner;

    constructor() public {
        token = new Token(10000000);
        owner = msg.sender;
    }

    struct cliente {
        uint tokens_comprados;
        string [] atracciones;
    }

    mapping(address => cliente) public Clientes;

    modifier onlyOwner(){
        require(msg.sender == owner, "No puedes hacer esto");
        _;
    }

    // Funcion que devuelve el precio del token
    function PrecioToken(uint _amount) internal pure returns(uint){
        return _amount*(0.002 ether);
    }

    // Funcion para comprar tokens
    function CompraTokens(uint _amount) public payable {
        uint coste = PrecioToken(_amount);

        require(msg.value >= coste, "No tiene suficientes ethers");
        uint returnValue = msg.value - coste; // Tokens que sobran
        msg.sender.transfer(returnValue); // Devolver tokens restantes

        // Obtencion del numero de tokens disponibles
        uint Balance = balanceOf();
        require(_amount <= Balance, "No hay suficientes tokens");

        // transferir tokens
        token.transfer(msg.sender, _amount);
        Clientes[msg.sender].tokens_comprados += _amount;
    }

    function balanceOf() public view returns (uint){
        return token.balanceOf(address(this)); // Balance del contrato actual
    }

    // numero de tokens restantes
    function misTokens() public view returns (uint) {
        return token.balanceOf(msg.sender);
    }

    // Funcion para generar mas tokens
    function generarTokens (uint _amount) public onlyOwner(){
        token.increaseTotalSupply(_amount);
    }

    event disfrutaAtraccion(string);
    event nuevaAtraccion(string);
    event bajaAtraccion(string);

    struct Atraccion {
        string nombre;
        uint precio;
        bool estado;
    }

    mapping(string => Atraccion) public atracciones;

    string [] nombreAtracciones;

    function NuevaAtraccion(string memory _nombreAtraccion, uint _precio) public onlyOwner{
        atracciones[_nombreAtraccion]= Atraccion(_nombreAtraccion, _precio, true);
        nombreAtracciones.push(_nombreAtraccion);
        emit nuevaAtraccion(_nombreAtraccion);
    }

    function BajaAtraccion(string memory _nombreAtraccion) public onlyOwner{
        atracciones[_nombreAtraccion].estado = false;
        emit bajaAtraccion(_nombreAtraccion);
    }

    function VerAtracciones() public view returns(string [] memory){
        return nombreAtracciones;
    }

    function SubirAtraccion (string memory _name) public {
        uint precio = atracciones[_name].precio;
        require(atracciones[_name].estado, "La atraccion no esta disponible");
        require(precio <= token.balanceOf(msg.sender), "No tiene suficientes tokens");
        token.transferTo(msg.sender, address(this), precio);

        Clientes[msg.sender].atracciones.push(_name);

        emit disfrutaAtraccion(_name);
    }

    function HistorialAtracciones () public view returns (string[] memory){
        return Clientes[msg.sender].atracciones;
    }

    function DevolverTokens (uint _amount) public payable {
        require(_amount>0, "Cantidad no valida");
        require(_amount <= misTokens(), "No tienes esa cantidad de tokens");
        token.transferTo(msg.sender, address(this), _amount);
        // Devolver ethers
        msg.sender.transfer(PrecioToken(_amount));
    }
}