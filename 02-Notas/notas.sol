// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

contract notas {
    
    address public profesor; // Direccion del profesor

    constructor() public {
        profesor = msg.sender;
    }

    mapping (bytes32 => uint) Notas; // Relaciona un hash de la indentidad de una persona con una nota
    string [] revisiones; // array de alumnos que piden revisiones

    event alumno_evaluado(bytes32, uint);
    event evento_revision(string);
    event evento_error(string);

    modifier OnlyProfe(){
        require(msg.sender == profesor, "You don't have permission for this action");
        _;
    }

    function Evaluar(string memory _idAlumno, uint _nota) public OnlyProfe(){
        bytes32  hashAlumno = keccak256(abi.encodePacked(_idAlumno));
        Notas[hashAlumno] = _nota;
        emit alumno_evaluado(hashAlumno, _nota);
    } 

    function VerNotas(string memory _idAlumno) public view returns(uint){
        bytes32  hashAlumno = keccak256(abi.encodePacked(_idAlumno));
        uint notaAlumno = Notas[hashAlumno];

        return notaAlumno;
    }

    function Revision(string memory _idAlumno) public {
        revisiones.push(_idAlumno);
        emit evento_revision(_idAlumno);
    }

    function VerRevisiones() public view OnlyProfe() returns (string [] memory){
        return revisiones;
    }
}