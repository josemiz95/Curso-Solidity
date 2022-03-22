// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;

// CANDIDATO    /   EDAD    /   ID
// --------------------------------------
// Josemi       /   20      /   1234567A
// Alba         /   24      /   1234567B
// Juan         /   23      /   1234567C

contract votacion {

    address public owner;

    constructor() public{
        owner = msg.sender;
    }

    mapping(string=>bytes32) idCandidato; // Candidato -> hash de sus datos

    mapping(string=>uint) votosCandidato; // Votos de cada candidato

    string [] candidatos;

    bytes32 [] votantes;

    // Cualquier personna se presente a las elecciones
    function Representar(string memory _nombre, uint _edad, string memory _id) public {
        // Hash del candidato
        bytes32 hashCandidato = keccak256(abi.encodePacked(_nombre, _edad, _id));

        idCandidato[_id] = hashCandidato;

        candidatos.push(_nombre);
    }

    function VerCandidatos() public view returns(string[] memory){
        return candidatos;
    }

    function Votar(string memory _candidato) public{
        bytes32 hashVotante = keccak256(abi.encodePacked(msg.sender));

        for(uint i=0; i<votantes.length; i++){
            require(votantes[i]!=hashVotante, "Ya ha votado previamente");
        }

        votantes.push(hashVotante);

        votosCandidato[_candidato]++;
    }

    function VerVotos(string memory _candidato) public view returns(uint){
        return votosCandidato[_candidato];
    }

    function VerResultados() public view returns(string memory){
        string memory resultado;

        for(uint i=0; i<candidatos.length; i++){
            string memory _candidato = candidatos[i];
            string memory _votos = uint2str(votosCandidato[_candidato]);
            resultado = string(abi.encodePacked(resultado, "(", _candidato, ",", _votos, ")"));
        }

        return resultado;
    }

    function VerGanador() public view returns(string memory){
        require(candidatos.length>0, "No se han presnetado candidatos");
        string memory ganador = candidatos[0];

        for(uint i=1; i<candidatos.length; i++){

            string memory _candidato = candidatos[i];
            if(votosCandidato[ganador]<votosCandidato[_candidato]){
                ganador = _candidato;
            }
            
        }

        return ganador;

    }

    function uint2str(uint _i) internal pure returns (string memory) {
        if (_i==0){ return "0"; }
        uint j = _i;
        uint len;
        while (j!=0){
            len++;
            j/=10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while(_i != 0){
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}