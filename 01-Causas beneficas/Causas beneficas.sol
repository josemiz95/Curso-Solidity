// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;

contract causasBeneficas{

    struct CausaBenefica{
        uint Id;
        string name;
        uint objetivo;
        uint recaudado;
    }

    uint contador_causas = 0;
    mapping (string => CausaBenefica) causas;

    function nuevaCausa(string memory _nombre, uint _objetivo) public payable {
        contador_causas = contador_causas ++;
        causas[_nombre] = CausaBenefica(contador_causas, _nombre, _objetivo, 0);
    }

    function objetivoCumplido(string memory _nombre, uint _donar) private view returns(bool){
        CausaBenefica memory causa = causas[_nombre];
        return (causa.recaudado+_donar)<=causa.objetivo;
    }

    function donar(string memory _nombre, uint _cantidad) public returns(bool){
        bool aceptar_donacion = true;

        if(objetivoCumplido(_nombre, _cantidad)){
            causas[_nombre].recaudado =  causas[_nombre].recaudado+_cantidad;
        } else {
            aceptar_donacion = false;
        }

        return aceptar_donacion;
    }

    function comporbarCausa(string memory _nombre) public view returns(bool,uint){
        CausaBenefica memory causa = causas[_nombre];

        return (causa.objetivo>=causa.recaudado, causa.recaudado);
    }
}